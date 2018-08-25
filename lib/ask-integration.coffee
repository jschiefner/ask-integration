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
    @askTile = new AskTile () => @askClick()
    @askTile.hide() unless @checkAskFolder()

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register commands
    @subscriptions.add atom.commands.add 'atom-workspace', 'ask-integration:deploy': => @deploy()
    @subscriptions.add atom.commands.add 'atom-workspace', 'ask-integration:deployLambda': => @deployLambda()
    @subscriptions.add atom.commands.add 'atom-workspace', 'ask-integration:deployModel': => @deployModel()
    @subscriptions.add atom.commands.add 'atom-workspace', 'ask-integration:forceDeployLambda': => @forceDeployLambda()
    @subscriptions.add atom.commands.add 'atom-workspace', 'ask-integration:forceDeployModel': => @forceDeployModel()

    # register checking for .ask Folder on every editor change
    @subscriptions.add atom.workspace.onDidChangeActiveTextEditor () => @checkAskFolder()

  consumeStatusBar: (statusBar) ->
    @statusBarTile = statusBar.addRightTile item: @askTile.getElement(), visible: true, priority: 100

  deactivate: ->
    @subscriptions.dispose()
    @statusBarTile?.destroy()
    @statusBarTile = null

  serialize: ->
    # askTileState: @askTile.serialize()

  deploy: (options = {}) ->
     # always navigate to project directory before executing ask deploy
    cmd = "cd #{@rootPath()} &&"

    # add custom command if the user defined one
    customCommand = atom.config.get 'ask-integration.customCommand'
    cmd += " #{customCommand} &&" unless customCommand == 'none'

    # built command and the notification description with force and target options
    cmd += ' ask deploy'
    description = 'Model and lambda were'
    if options.force
      cmd += ' --force'
    if options.target
      cmd += " -t #{options.target}"
      description = "#{options.target} was"
    description += if options.force then ' force deployed' else ' sucessfully deployed'

    atom.notifications.addInfo cmd
    atom.notifications.addSuccess description
    exec cmd, (err, stdout, stderr) =>
      console.log "err: #{err}"
      console.log "stdout: #{stdout}"
      console.log "stderr: #{stderr} #{!!stderr}"
      unless stderr
        atom.notifications.addSuccess 'Deployment successfull', description: description
      else
        atom.notifications.addError stderr

  askClick: ->
    switch atom.config.get 'ask-integration.clickAction'
      when 'deploy'
        @deploy()
      when 'deployLambda'
        @deployLambda()
      when 'deployModel'
        @deployModel()

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

  deployLambda: ->
    @deploy target: 'lambda'

  deployModel: ->
    @deploy target: 'model'

  forceDeployLambda: ->
    @deploy target: 'lambda', force: true

  forceDeployModel: ->
    @deploy target: 'model', force: true

  config:
    customCommand:
      type: 'string'
      title: 'Custom Command'
      description: 'You can set an optional Command, that will be executed from the Project Directory before deployment'
      default: 'none'
    clickAction:
      title: 'Default Action'
      description: 'You can choose which deployment should be performed by default when clicking the Ask Button in the status bar'
      type: 'string'
      default: 'none'
      enum: [
        {value: 'deploy', description: 'Deploy'}
        {value: 'deployLambda', description: 'Deploy Lambda'}
        {value: 'deployModel', description: 'Deploy Model'}
      ]
      default: 'deploy'
