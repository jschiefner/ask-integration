module.exports =
class AskTile
  constructor: (serializedState) ->
    # Create root element
    @element = document.createElement('span')
    @element.classList.add('ask-tile')

    # Create image element
    image = document.createElement('img')
    image.src = 'atom://ask-integration/lib/alexa-logo.svg'
    image.height = '12'
    image.className = 'icon'
    @element.appendChild(image)

    # Create message element
    message = document.createElement('span')
    message.textContent = "Ask"
    message.classList.add('message')
    @element.appendChild(message)

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element
