util = require 'util'
{ exec } = require('child_process')
AskTile = require './ask-tile'
{CompositeDisposable, Directory} = require 'atom'

module.exports = AskIntegration =
  subscriptions: null
  askTile: null
  statusBarTile: null

  activate: (state) ->
    # create the AskTile
    @askTile = new AskTile () => @deploy()
    @askTile.hide() unless @checkAskFolder()

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that deploys (for now)
    @subscriptions.add atom.commands.add 'atom-workspace', 'ask-integration:deploy': => @deploy()
    @subscriptions.add atom.workspace.onDidChangeActiveTextEditor () => @checkAskFolder()

  consumeStatusBar: (statusBar) ->
    @statusBarTile = statusBar.addRightTile(item: @askTile.getElement(), visible: true, priority: 100)

  deactivate: ->
    @subscriptions.dispose()
    @statusBarTile?.destroy()
    @statusBarTile = null

  serialize: ->
    # askTileState: @askTile.serialize()

  deploy: ->
    console.log 'deployment started'
    exec "cd #{@rootPath()}; ask deploy -t lambda | tail", (err, stdout, stderr) =>
      console.log "err: #{err}"
      console.log "stdout: #{stdout}"
      console.log "stderr: #{stderr} #{!!stderr}"
      if stderr
        atom.notifications.addError stderr
      else
        atom.notifications.addSuccess 'Deployment successfull', description: 'Model and Lambda were sucessfully deployed'

  checkAskFolder: ->
    if new Directory(@rootPath('/.ask/')).existsSync()
      @askTile.show()
      true
    else
      @askTile.hide()
      false

  rootPath: (path) ->
    output = atom.project.relativizePath(atom.workspace.getActiveTextEditor()?.getPath())[0]
    if path then output + path else output
