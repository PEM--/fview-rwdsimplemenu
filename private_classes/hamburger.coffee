console.log RwdSimpleMenu.constructor


FView.ready ->
  class RwdSimpleMenu._class.Hamburger extends famous.core.View
    @DEFAULT_OPTIONS: {}
    constructor: (@options) ->
      super @options
