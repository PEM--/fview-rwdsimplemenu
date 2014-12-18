FView.ready ->
  # Sortcuts
  MainMenu = RwdSimpleMenu._class.MainMenu
  # Private class defining the side menu
  class RwdSimpleMenu._class.SideMenu extends famous.core.View
    @DEFAULT_OPTIONS:
      sideMenuZindex: 150
      sideMenuWidth: 200
      sideMenuLabelHeight: 50
      sideMenuBgColor: CSSC.darkgray
      sideMenuColor: CSSC.silver
      sideMenuSelBgColor: CSSC.gray
      sideMenuSelColor: CSSC.white
    # Constructor accepts non mandatory options
    constructor: (@options) ->
      # Call parent class View's constructor with bypassed options
      super @options
      # Get and check if main menu placeholder is available
      @_placeHolder = MainMenu._getPlaceholder 'RwdSimpleMenuSideMenu'
      # Create a stylesheet for the componenent
      @_css = new CSSC
      # Create the main modifier that contains the slide menu
      @_mainNode = @_createMainModAndBg()
      # By default the side menu is hidden
      @_isMenuHidden = true
      # Accept event event from parent
      @_eventInput.subscribe @
      # On 'sidemenutoggled' from parent toggles the side menu in or out
      @_eventInput.on 'sidemenutoggled', => @_toggle()
      @_eventInput.on 'routing', (evt) => @_setRoute evt.route
      # Create the menu items
      @_createMenuItems()
    # Create the main modifier that contains the slide menu
    # and its bakground surface
    _createMainModAndBg: ->
      # The side menu is created in the left portion of the viewport
      @_mainMod = new famous.modifiers.StateModifier
        align: [0,0]
        origin: [1,0]
        opacity: 0
        size: [@options.sideMenuWidth, rwindow.innerHeight()]
      @_mainMod.setOpacity 1, @options.transition
      # Resize event relies on reactivity instead of basic events.
      # Reactivity is debounce in the package reactive-window.
      Tracker.autorun =>
        @_mainMod.setSize [@options.sideMenuWidth, rwindow.innerHeight()]
      # Create a background surface
      surf = new famous.core.Surface
        properties: backgroundColor: @options.sideMenuBgColor
      node = @_placeHolder.node.add @_mainMod
      node.add surf
      # Return the render node
      node
    # Create menu items
    _createMenuItems: ->
      # Create a sequence layout that displays all menu labels.
      @_seqMenuItems = new famous.views.SequentialLayout
        direction: famous.utilities.Utility.Direction.Y
        itemSpacing: 0
      @_mainNode.add @_seqMenuItems
      # Menu items is a sequence of labelled entries
      @_seqLabel = new famous.core.ViewSequence
      @_seqMenuItems.sequenceFrom @_seqLabel
      # Get menu items template
      @_menuItemTpl = RwdSimpleMenu._class.MainMenu._getTemplate \
        'RwdSimpleMenuSideMenuLabel'
      # Style the labels and ensure a proper hand cursor
      # FIXME This should be done with Famo.us
      hackyColorTrans = "background-color #{@options.transition.duration}ms, \
        color #{@options.transition.duration}ms"
      @_css.add '.rwd-simple-menu-side-menu-label',
        backgroundColor: @options.sideMenuBgColor
        color: @options.sideMenuColor
        textAlign: 'center'
        lineHeight: CSSC.px @options.sideMenuLabelHeight
        # FIXME This should be done with Famo.us
        webkitTransition: hackyColorTrans
        mozTransition: hackyColorTrans
        oTransition: hackyColorTrans
        transition: hackyColorTrans
        cursor: 'pointer'
      @_css.add '.rwd-simple-menu-side-menu-label.active',
        fontWeight: 'boldest'
        backgroundColor: @options.sideMenuSelBgColor
        color: @options.sideMenuSelColor
        webkitTransition: hackyColorTrans
        mozTransition: hackyColorTrans
        oTransition: hackyColorTrans
        transition: hackyColorTrans
    # Add a route into the menu items
    addRoute: (route, data) ->
      # Menu items are created within a render node to handle
      # animation through a StateModifier
      node = new famous.core.RenderNode
      # Add a route member to the render node for easy retrivieng it
      node.route = route
      mod = new famous.modifiers.StateModifier
        align: [.5,0]
        origin: [.5,0]
        size: [@options.sideMenuWidth, @options.sideMenuLabelHeight]
        opacity: 0
      surf = new famous.core.Surface
        classes: ['rwd-simple-menu-side-menu-label']
        content: Blaze.toHTMLWithData @_menuItemTpl, data
      (node.add mod).add surf
      @_seqLabel.push node
      # Adding is performed with a little opacity animation
      mod.setOpacity 1, @options.transition
      # Ensure events bubbling.
      surf.pipe @
      # Emit a routing event on click.
      surf.on 'click', => @_eventOutput.emit 'routing', route: route
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
    # Toggle display of the side menu
    _toggle: ->
      @_isMenuHidden = not @_isMenuHidden
      # Halt pending animations for immediate response to toggling.
      @_mainMod.halt()
      # Translate the side menu in or out of the main viewport
      translate = if @_isMenuHidden then 0 else @options.sideMenuWidth
      @_mainMod.setTransform (famous.core.Transform.translate \
        translate, 0, @options.sideMenuZindex), @options.transition
    # Set selected menu item
    _setRoute: (route) ->
      # Find the requested route
      seq = @_seqLabel
      found = null
      until seq is null
        node = seq.get()
        surf = node._child._child._object
        surf.removeClass 'active'
        found = surf if node.route is route
        seq = seq.getNext()
      found.addClass 'active' unless found is null
    # Size of the side menu
    getSize: -> [@options.sideMenuWidth, rwindow.innerHeight()]
    # Select the top menu item. In case a former one has been already
    #  selected, unselect it.
    selectMenuItem: (route) ->
      console.log 'Setting side menu route', route
      @_setRoute route
