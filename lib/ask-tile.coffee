module.exports =
class AskTile
  constructor: (askClick) ->
    # Create root element
    @element = document.createElement 'span'
    @element.classList.add 'ask-tile'
    @element.classList.add 'inline-block'

    # Create image element
    @image = document.createElement 'img'
    @image.src = 'atom://ask-integration/lib/alexa-logo.svg'
    @image.className = 'ask-icon'
    @element.appendChild @image

    # Create message element
    message = document.createElement 'span'
    message.textContent = "Ask"
    message.classList.add 'message'
    @element.appendChild message
    @element.addEventListener 'click', askClick

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  hide: ->
    @element.style = 'display: none;'

  show: ->
    @element.style = ''

  rotate: (rotation) ->
    if rotation
      @image.classList.add 'rotating'
    else
      @image.addEventListener 'animationiteration', (() => @image.classList.remove 'rotating'), once: true

  getElement: ->
    @element
