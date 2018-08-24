util = require 'util'
exec = require('child_process').exec
AskTile = require './ask-tile'
{CompositeDisposable} = require 'atom'

module.exports = AskIntegration =
  subscriptions: null
  askTile: null
  statusBarTile: null

  activate: (state) ->
    @askTile = new AskTile(state.askTileState)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that speaks (for now)
    @subscriptions.add atom.commands.add 'atom-workspace', 'ask-integration:speak': => @speak()

  consumeStatusBar: (statusBar) ->
    @statusBarTile = statusBar.addRightTile(item: @askTile.getElement(), visible: true, priority: 100)

  deactivate: ->
    @subscriptions.dispose()
    @statusBarTile?.destroy()
    @statusBarTile = null

  serialize: ->
    askTileState: @askTile.serialize()

  speak: ->
    exec('say hello')
