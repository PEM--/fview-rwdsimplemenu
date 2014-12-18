FView.ready ->
  # Shortcuts
  TopMenu = RwdSimpleMenu._class.TopMenu
  SideMenu = RwdSimpleMenu._class.SideMenu
  # Private class defining the menu
  class RwdSimpleMenu._class.MainMenu extends famous.core.View
    @DEFAULT_OPTIONS:
      menuHeight: 50
      transition: curve: 'easeInOut', duration: 300
    constructor: (options) ->
      # Instantiate parent class without options
      super
      # Merge default options from aggregate classes and transmitted options
      @_optionsManager.patch RwdSimpleMenu._class.TopMenu.DEFAULT_OPTIONS
      @_optionsManager.patch RwdSimpleMenu._class.SideMenu.DEFAULT_OPTIONS
      @_optionsManager.patch RwdSimpleMenu._class.Hamburger.DEFAULT_OPTIONS
      @_optionsManager.patch options
      # A data array that contains all labels declared by the user.
      @_items = []
      @_itemsDeps = new Tracker.Dependency
      # Instantiate aggregated classes with the merged options
      @_topMenu = new RwdSimpleMenu._class.TopMenu @options
      @_sideMenu = new RwdSimpleMenu._class.SideMenu @options
      # Subscribe and pipe events
      @_eventInput.subscribe @_topMenu
      @_eventInput.subscribe @_sideMenu
      @_eventOutput.pipe @_topMenu
      @_eventOutput.pipe @_sideMenu
      # When receiving an 'sidemenutoggled' event from the top menu
      #  sends it to the sidemenu.
      @_eventInput.on 'sidemenutoggled', =>
        @_eventOutput.trigger 'sidemenutoggled'
      # Handle routing event from inner menus
      @_eventInput.on 'routing', (evt) =>
        # Toggle back the side menu when routing has been activated and
        #  when the screen display the side menu (in xsmall width).
        if rwindow.screen 'lte', @options.minWidth
          @_eventOutput.trigger 'sidemenutoggled' unless evt.route is '/'
        # Set the appropriate selected route on the top menu
        @_sideMenu.selectMenuItem evt.route
        @_topMenu.selectMenuItem evt.route
        # Activate the routing
        Router.go evt.route
    addRoute: (route, data) ->
      @_sideMenu.addRoute route, data
      @_topMenu.addRoute route, data
    removeRoute: (route) ->
      @_sideMenu.removeRoute route
      @_topMenu.removeRoute route
    # Static functions used by aggreagated classes
    # --------------------------------------------
    # Get an FView from the user's templates and throw an
    # explicit error if the template cannot be found.
    @_getPlaceholder: (placeHolderName) ->
      fview = FView.byId placeHolderName
      if fview is undefined
        FView.log.error "Please create a placeholder #{placeHolderName}"
        throw new Error "No placeholder for #{placeHolderName}"
      placeHolder = fview.modifier
      if placeHolder is undefined
        FView.log.error "Placeholder #{placeHolderName} isn't a StateModifier"
        throw new Error "#{placeHolderName} isn't a StateModifier"
      fview
    # Get a template and throw an explicit error if it cannot be found.
    @_getTemplate: (tplName) ->
      tpl = Template[tplName]
      if tpl is undefined
        FView.log.error "Please set template #{tplName}"
        throw new Error "No #{tplName} defined"
      tpl
    # Parse as static HTML a template defined by the user and throw an
    # explicit error if the template cannot be found.
    @_getHtmlFromTemplate: (tplName) ->
      tpl = RwdSimpleMenu._class.MainMenu._getTemplate tplName
      Blaze.toHTML tpl
