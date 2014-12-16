FView.ready ->
  # Sortcuts
  MainMenu = RwdSimpleMenu._class.MainMenu
  # Private class defining the side menu
  class RwdSimpleMenu._class.SideMenu extends famous.core.View
    @DEFAULT_OPTIONS:
      sideMenuZindex: 150
      sideMenuWidth: 200
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
      # Create the menu items
      @_createMenuItems()

    # Create the main modifier that contains the slide menu
    # and its bakground surface
    _createMainModAndBg: ->
      # The side menu is created in the left portion of the viewport
      @_mainMod = new famous.modifiers.StateModifier
        align: [0,0]
        origin: [1,0]
        size: [@options.sideMenuWidth, rwindow.innerHeight()]
      #@_mainMod.setTransform famous.core.Transform.translate \
      #    @options.sideMenuWidth, 0, @options.sideMenuZindex
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
      seqMenuItems = new famous.views.SequentialLayout
        direction: famous.utilities.Utility.Y
        itemSpacing: 0
      @_mainNode.add seqMenuItems

      # Menu items is a sequence of labelled entries
      seqLabel = new famous.core.ViewSequence

    # Toggle display of the side menu
    _toggle: ->
      @_isMenuHidden = not @_isMenuHidden
      # Halt pending animations for immediate response to toggling.
      @_mainMod.halt()
      # Translate the side menu in or out of the main viewport
      translate = if @_isMenuHidden then 0 else @options.sideMenuWidth
      @_mainMod.setTransform (famous.core.Transform.translate \
        translate, 0, @options.sideMenuZindex), @options.transition








    # Size of the side menu
    getSize: -> [@options.sideMenuWidth, rwindow.innerHeight()]
