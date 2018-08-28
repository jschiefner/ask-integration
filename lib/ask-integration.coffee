util = require 'util'
{ exec } = require('child_process')
AskTile = require './ask-tile'
{CompositeDisposable, Directory} = require 'atom'

module.exports = AskIntegration =
  subscriptions: null
  askTile: null
  statusBarTile: null
  tooltip: null

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

  activate: (state) ->
    # create the AskTile
    @askTile = new AskTile (event) => @askClick(event)
    @askTile.hide() unless @checkAskFolder()

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register commands
    @subscriptions.add atom.commands.add 'atom-workspace', 'ask-integration:deploy': => @deploy()
    @subscriptions.add atom.commands.add 'atom-workspace', 'ask-integration:deploy-lambda': => @deployLambda()
    @subscriptions.add atom.commands.add 'atom-workspace', 'ask-integration:deploy-model': => @deployModel()
    @subscriptions.add atom.commands.add 'atom-workspace', 'ask-integration:force-deploy-lambda': => @forceDeployLambda()
    @subscriptions.add atom.commands.add 'atom-workspace', 'ask-integration:force-deploy-model': => @forceDeployModel()

    # register tooltip
    @registerTooltip()

    # register checking for .ask Folder on every editor change
    @subscriptions.add atom.workspace.onDidChangeActiveTextEditor () => @checkAskFolder()

  consumeStatusBar: (statusBar) ->
    @statusBarTile = statusBar.addRightTile item: @askTile.getElement(), visible: true, priority: 100

  deactivate: ->
    @subscriptions.dispose()
    @tooltip?.dispose()
    @tooltip = null
    @statusBarTile?.destroy()
    @statusBarTile = null

  serialize: ->
    # askTileState: @askTile.serialize()

  deploy: (options = {}) ->
    # start rotating Alexa Logo
    @askTile.rotate true

     # always navigate to project directory before executing ask deploy
    cmd = "cd #{@rootPath()} &&"

    # add custom command if the user defined one
    customCommand = atom.config.get 'ask-integration.customCommand'
    cmd += " #{customCommand};" unless customCommand == 'none'

    # build command and the notification description with force and target options
    cmd += ' ask deploy'
    description = 'Model and lambda were'
    tooltipTitle = 'Deploying...'
    if options.force
      cmd += ' --force'
    if options.target
      cmd += " -t #{options.target}"
      description = "#{options.target} was"
      tooltipTitle = "Deploying #{options.target}..."
    description += if options.force then ' force deployed' else ' sucessfully deployed'

    # set the tooltip title to deploying [lambda/model]...
    @registerTooltip tooltipTitle

    # when all preparations are done, execute the ask command
    exec cmd, (err, stdout, stderr) =>
      unless err || stderr
        atom.notifications.addSuccess 'Deployment successfull', description: description
      else
        if stderr.includes('Lambda update failed') || stderr.includes('eTag does not match')
          atom.notifications.addError stderr, dismissable: true,
          description: 'You might want to force deploy. Please proceed with caution.',
          buttons: [{
            onDidClick: =>
              @forceDeployLambda()
            text: 'Force Deploy Lambda'
          },
          {
            onDidClick: =>
              @forceDeployModel()
            text: 'Force Deploy Model'
          }]
        else
          atom.notifications.addError stderr, description: "The current directory #{@rootPath()} doesn't seem to be a valid ask folder.", dismissable: true

      # when everything is done stop the rotation and reset the tooltip
      @askTile.rotate false
      @registerTooltip()

  registerTooltip: (title) ->
    @tooltip?.dispose()
    @tooltip = atom.tooltips.add @askTile.getElement(), title: (if title then title else 'Click to deploy. Right click for more options')

  askClick: (event) ->
    action = atom.config.get 'ask-integration.clickAction'
    action = 'deployLambda' if event.altKey
    action = 'deployModel' if event.shiftKey

    switch action
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
