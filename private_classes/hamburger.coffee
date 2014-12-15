FView.ready ->
  class RwdSimpleMenu._class.Hamburger extends famous.core.View
    @DEFAULT_OPTIONS:
      hamburgerSize: 50
    constructor: (@options) ->
      super @options
      mod = new famous.modifiers.StateModifier
        align: [.5,.5]
        origin: [.5,.5]
        size: [@options.hamburgerSize, @options.hamburgerSize]
      node = @add mod
      @modOn = @_createModSurf node, 'On'
      @modOff = @_createModSurf node, 'Off'
      @status = false
      @modOn.setOpacity Number @status
      @modOff.setOpacity Number not @status
      window.hamburger = @
    _createModSurf: (node, name) ->
      mod = new famous.modifiers.StateModifier
        align: [.5,.5]
        origin: [.5,.5]
        size: [@options.hamburgerSize, @options.hamburgerSize]
      surf = new famous.core.Surface
        classes: [
          'rwd-simple-menu-hamburger'
          name.toLowerCase()
        ]
        size: [@options.hamburgerSize, @options.hamburgerSize]
        content: RwdSimpleMenu._class.MainMenu._getHtmlFromTemplate \
          "RwdSimpleMenuHamburger#{name}"
      (node.add mod).add surf
      mod
    toggle: ->
      @status = not @status
      @modOn.setOpacity (Number @status), @options.transition
      @modOff.setOpacity (Number not @status), @options.transition
