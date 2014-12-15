FView.ready ->
  # Display a little animated 2 state button.
  class RwdSimpleMenu._class.Hamburger extends famous.core.View
    @DEFAULT_OPTIONS:
      hamburgerSize: 50
    # Constructor accepts non mandatory options
    constructor: (@options) ->
      # Call parent class View's constructor with bypassed options
      super @options
      # Create a stylesheet for this component.
      @_css = new CSSC
      # Create 1 modifier and 1 surface for each state of the 2 states.
      @_modOn = @_createModSurf 'On'
      @_modOff = @_createModSurf 'Off'
      # By default the toggle button is not toggled.
      @status = false
      # Set opacity depending on current state.
      @_modOn.setOpacity Number @status
      @_modOff.setOpacity Number not @status
      # When the component is clicked, it toggles its state and emit
      #  a event 'toggled' that can be intercepted by its parent containers.
      @_eventInput.on 'click', =>
        @_toggle()
        @_eventOutput.emit 'toggled'
    # Create a modifier and a surface from a Spacebar template.
    _createModSurf: (name) ->
      # Create a modifier which will set the size of its child surface.
      mod = new famous.modifiers.StateModifier
        size: [@options.hamburgerSize, @options.hamburgerSize]
      # Create a surface with a specific CSS class allowing theming by users
      #  and fill it with the template defined by the user.
      surf = new famous.core.Surface
        classes: [
          'rwd-simple-menu-hamburger'
          name.toLowerCase()
        ]
        content: RwdSimpleMenu._class.MainMenu._getHtmlFromTemplate \
          "RwdSimpleMenuHamburger#{name}"
      # Each surface accepts click/touch events, ensure that a little hand
      #  instead of the raw cursor is displayed telling the user that this
      #  aera is clickable.
      @_css.add '.rwd-simple-menu-hamburger', cursor: 'pointer'
      # Ensure events bubbling.
      surf.pipe @
      # Add this modifier and its surface to the component content.
      (@add mod).add surf
      # Return the current modifier for further use in this component.
      mod
    # Toggle state of the component and animate it.
    _toggle: ->
      @status = not @status
      # Before performing the animation, it's better to halt a possibly
      #  animation in progress.
      @_modOn.halt()
      @_modOff.halt()
      @_modOn.setOpacity (Number @status), @options.transition
      @_modOff.setOpacity (Number not @status), @options.transition
    # Size of the hamburger is fixed at instantiation
    getSize: -> [@options.hamburgerSize, @options.hamburgerSize]
