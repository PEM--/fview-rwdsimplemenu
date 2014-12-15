FView.ready ->
  class RwdSimpleMenu._class.Hamburger extends famous.core.View
    @DEFAULT_OPTIONS:
      hamburgerSize: 50
    constructor: (@options) ->
      super @options
      @modOn = @_createModSurf 'On'
      @modOff = @_createModSurf 'Off'
      @status = false
      @modOn.setOpacity Number @status
      @modOff.setOpacity Number not @status
      @css = new CSSC
      @_eventInput.on 'click', =>
        @toggle()
        @_eventOutput.emit 'toggled'
    _createModSurf: (name) ->
      mod = new famous.modifiers.StateModifier
        size: [@options.hamburgerSize, @options.hamburgerSize]
      surf = new famous.core.Surface
        classes: [
          'rwd-simple-menu-hamburger'
          name.toLowerCase()
        ]
        content: RwdSimpleMenu._class.MainMenu._getHtmlFromTemplate \
          "RwdSimpleMenuHamburger#{name}"
      css.add '.rwd-simple-menu-hamburger', cursor: 'pointer'
      surf.pipe @
      (@add mod).add surf
      mod
    getSize: -> @modOn.getSize()
    toggle: ->
      @status = not @status
      @modOn.setOpacity (Number @status), @options.transition
      @modOff.setOpacity (Number not @status), @options.transition
