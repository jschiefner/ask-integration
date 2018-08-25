util = require 'util'
exec = require('child_process').exec
AskTile = require './ask-tile'
{CompositeDisposable, Directory} = require 'atom'

module.exports = AskIntegration =
  subscriptions: null
  askTile: null
  statusBarTile: null

  activate: (state) ->
    # create the AskTile
    @askTile = new AskTile () => @speak()
    @askTile.hide() unless @checkAskFolder()

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that speaks (for now)
    @subscriptions.add atom.commands.add 'atom-workspace', 'ask-integration:speak': => @speak()
    @subscriptions.add atom.workspace.onDidChangeActiveTextEditor () => @checkAskFolder()

  consumeStatusBar: (statusBar) ->
    @statusBarTile = statusBar.addRightTile(item: @askTile.getElement(), visible: true, priority: 100)

  deactivate: ->
    @subscriptions.dispose()
    @statusBarTile?.destroy()
    @statusBarTile = null

  serialize: ->
    # askTileState: @askTile.serialize()

  speak: ->
    exec('say ask integration')

  checkAskFolder: ->
    askDirPath = atom.project.relativizePath(atom.workspace.getActiveTextEditor()?.getPath())[0] + '/.ask/'
    dir = new Directory askDirPath
    if dir.existsSync()
      @askTile.show()
      true
    else
      @askTile.hide()
      false
