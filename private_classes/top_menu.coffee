FView.ready ->
  # Shortcuts
  MainMenu = RwdSimpleMenu._class.MainMenu
  Hamburger = RwdSimpleMenu._class.Hamburger
  # Register a physical transition for a spring effect.
  SpringTransition = famous.transitions.SpringTransition
  Transitionable = famous.transitions.Transitionable
  Transitionable.registerMethod 'spring', SpringTransition

  # The top menu as a private class
  class RwdSimpleMenu._class.TopMenu extends famous.core.View
    @DEFAULT_OPTIONS:
      minWidth: 'xsmall'
      maxWidth: 960
      logoWidth: 50
      logoHeight: 50
      labelWidth: 100
      labelSpacing: 20
      underlineBorderRadius: 4
      underlineBgColor: CSSC.darkgray
    # Constructor accepts non mandatory options
    constructor: (@options, @_items, @_itemsDeps) ->
      # Call parent class View's constructor with bypassed options
      super @options
      # Get and check if top menu placeholder is available
      @_placeHolder = MainMenu._getPlaceholder 'RwdSimpleMenuMainMenu'
      # Add current component to the placeholder
      @_placeHolder.node.add @
      # Create a stylesheet for the componenent
      @_css = new CSSC
      # Create an autoresize modifier that encapsulates all included components
      @_menuNode = @_createMainMod()
      # Create and insert the Home button
      @_createHomeButton()
      # Create a placeholder for menu items.
      @_createMenuItems()
      # Create the menu slider
      @_createMenuSlider()
    # Create an autoresize modifier that encapsulates all included components
    _createMainMod: ->
      # The menu is set in the top - middle of the screen.
      # Its size is maximized according the the 960px standard (see default
      # values for modifying this size).
      @_mainMod = new famous.modifiers.StateModifier
        align: [.5,0]
        origin: [.5,0]
        size: [
          (Math.min rwindow.innerWidth()
          @options.maxWidth), @options.menuHeight
        ]
      # Resize event relies on reactivity instead of basic events.
      # Reactivity is debounce in the package reactive-window.
      Tracker.autorun =>
        curWidth = Math.min rwindow.innerWidth(), @options.maxWidth
        @_mainMod.setSize [curWidth, @options.menuHeight]
      # Add the main modifier to the component and return its render node.
      @add @_mainMod
    # Create and insert the Home button
    _createHomeButton: ->
      # Home button is set at the upper left corner of the menu.
      # At start, the opacity is set to 0 to avoid sudain and annoying
      # appearance on screen.
      homeButtonMod = new famous.modifiers.StateModifier
        align: [0,0]
        origin: [0,0]
        size: [@options.logoWidth, @options.logoHeight]
        opacity: 0
      # This will trigger the opaticty transition when the current
      #  caller will give the hand back to the main thread.
      homeButtonMod.setOpacity 1, @options.transition
      # A second modifier is used to animate button's touch/click
      #  with a physical effect.
      animMod = new famous.modifiers.StateModifier
        align: [.5,.5]
        origin: [.5,.5]
        size: [@options.logoWidth, @options.logoHeight]
      # The surface of the button uses a class that can be overload
      #  by the user so that he can modify colors of the content.
      # The content is extracted from a template provided in the user's code.
      homeButtonSurf = new famous.core.Surface
        classes: ['rwd-simple-menu-logo']
        content: MainMenu._getHtmlFromTemplate 'RwdSimpleMenuLogo'
      # A basic style is applied for desktop: when hovering the button,
      #  the mouse cursor becomes a hand.
      @_css.add '.rwd-simple-menu-logo', cursor: 'pointer'
      # Add all created modifiers and surface to the menu.
      ((@_menuNode.add homeButtonMod).add animMod).add homeButtonSurf
      # On click event, the router is called to go back on the home page.
      # The button is animated to demonstrate that the user has clicked on it.
      homeButtonSurf.on 'click', =>
        homeButtonMod.halt()
        homeButtonMod.setTransform (famous.core.Transform.translate 0,0,0),
          method:'spring', period: 300, dampingRatio: .5, velocity: 0.05
        @_eventOutput.emit 'routing', route: '/'
    # Create a placeholder for menu items.
    # Depending on the viewport size this placeholder displays
    #  either a hamburger menu (a 2 state menu) or a sequence of labels.
    _createMenuItems: ->
      # The sequence modifier is aligned to the upper right corner
      # of the screen with a maximized sized for the screen.
      @_seqMod = new famous.modifiers.StateModifier
        align: [1,0]
        origin: [1,0]
      # Create an empty sequence at first.
      @_seqView = new famous.views.SequentialLayout
        itemSpacing: @options.labelSpacing
        direction: famous.utilities.Utility.Direction.X
      # Add the empty sequence to the component
      @_seqNode = @_menuNode.add @_seqMod
      @_seqNode.add @_seqView
      # Create a view sequence for the hamburger
      @_hamburgerSeq = new famous.core.ViewSequence
      # Create an hamburger button, subscribe to its events and push
      #  it in its dedicated sequence
      hamburger = new Hamburger @options
      @_eventInput.subscribe hamburger
      @_hamburgerSeq.push hamburger
      @_eventInput.on 'toggled', => @_eventOutput.emit 'sidemenutoggled'
      @_eventInput.on 'sidemenutoggled', -> hamburger._toggle()
      # Create a view sequence for the menu items
      @_seqLabel = new famous.core.ViewSequence
      # Set the length of the view sequence for easy retrieving it
      @_seqLabelLength = 0
      # Get menu items template
      @_menuItemTpl = RwdSimpleMenu._class.MainMenu._getTemplate \
        'RwdSimpleMenuTopMenuLabel'
      # Handle resize of viewport's width with reactivity as it is debounced
      Tracker.autorun =>
        # If screen is too small, use the hamburger menu
        isSmall = rwindow.screen 'lte', @options.minWidth
        currSeq = if isSmall then @_hamburgerSeq else @_seqLabel
        @_seqView.sequenceFrom currSeq
    # Create the menu slider
    _createMenuSlider: ->
      @_sliderMod = new famous.modifiers.StateModifier
        align: [1,1]
        origin: [1,1]
        size: [@options.labelWidth, @options.underlineBorderRadius]
        #TODO opacity: 0
      slider = new famous.core.Surface
        properties:
          borderRadius: CSSC.px @options.underlineBorderRadius
          backgroundColor: @options.underlineBgColor
      (@_seqNode.add @_sliderMod).add slider
    # Add a route into the menu items
    addRoute: (route, data) ->
      # Menu items are created within a render node to handle
      # animation through a StateModifier
      node = new famous.core.RenderNode
      # Add a route member to the render node for easy retrivieng it
      node.route = route
      mod = new famous.modifiers.StateModifier
        size: [@options.labelWidth, @options.sideMenuLabelHeight]
        opacity: 0
      surf = new famous.core.Surface
        classes: ['rwd-simple-menu-top-menu-label']
        content: Blaze.toHTMLWithData @_menuItemTpl, data
      (node.add mod).add surf
      @_seqLabel.push node
      # Style the menu labels
      @_css.add '.rwd-simple-menu-top-menu-label',
        cursor: 'pointer'
        lineHeight: CSSC.px @options.menuHeight
        textAlign: 'center'
      # Adding is performed with a little opacity animation
      mod.setOpacity 1, @options.transition
      # Ensure events bubbling.
      surf.pipe @
      # Emit a routing event on click.
      surf.on 'click', => @_eventOutput.emit 'routing', route: route
      # Increase the sequence length
      @_seqLabelLength++
    # Remove a route from the menu items
    removeRoute: (route) ->
      # Find the requested route
      seq = @_seqLabel
      seq = seq.getNext() while seq.get().route isnt route
      # Get the modifier of animating the removal
      mod = seq.get()._child._object
      # Start by setting to 0
      mod.setOpacity 0, @options.transition
      # And at the same moment, resize the content to 0
      mod.setSize [0, 0], @options.transition, =>
        # When the size is set to 0, remove the menu item
        @_seqLabel.splice seq.index, 0
      # Decrease the sequence length
      @_seqLabelLength--
    # Size of the top menu.
    getSize: -> @_mainMod.getSize()
    # Select the top menu item. In case a former one has been already
    #  selected, unselect it.
    selectMenuItem: (route) ->
      # Find the requested route
      seq = @_seqLabel
      seq = seq.getNext() until (seq is null) or (seq.get().route is route)
      # Stop any previous transitions.
      @_sliderMod.halt()
      # Set opacity only if menu is shown.
      # Note that if route is not found the opacity is set to 0.
      if rwindow.screen 'gt', @options.minWidth
        @_sliderMod.setOpacity (Number seq isnt null), @options.transitions
      # Set the appropriate position if the route has been found.
      unless seq is null
        pos = (seq.index + 1 - @_seqLabelLength) * @options.labelWidth + \
          (seq.index + 1 - @_seqLabelLength) * @options.labelSpacing
        @_sliderMod.setTransform (famous.core.Transform.translate \
          pos, 0, 200), @options.transition
