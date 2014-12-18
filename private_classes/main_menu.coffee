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
        console.log 'Routing', evt
        # Toggle back the side menu when routing has been activated and
        #  when the screen display the side menu (in xsmall width).
        if rwindow.screen 'lte', @options.minWidth
          @_eventOutput.trigger 'sidemenutoggled' unless evt.route is '/'
        # Set the appropriate selected route on the top menu
        @_sideMenu.selectMenuItem evt.route
        @_topMenu.selectMenuItem evt.route
        # Activate the routing
        #Router.go evt.route



      #@isSideMenuActive = false
      #@isSideMenuActiveDeps = new Tracker.Dependency
      ###
      Template.RwdSimpleMenuMainMenu.rendered = =>
        #@fview = FView.byId 'sideMenu'
        RwdSimpleMenuMainHomeButton = FView.byId 'RwdSimpleMenuMainHomeButton'
        RwdSimpleMenuMainHomeButton.surface.on 'click', =>
          @setMenuItem()
          Router.go '/'
        hackyColorTrans = "background-color #{@options.transition.duration}ms, \
          color #{@options.transition.duration}ms"
        css.add ['.rwd-simple-menu-main-home-button', '.menulabel'],
          lineHeight: CSSC.px @options.menuHeight
          cursor: 'pointer'
          textAlign: 'center'
        .add '.sideMenu', backgroundColor: @options.sideMenuBgColor
        .add '.menuUnderline',
          backgroundColor: @options.underlineBgColor
          borderRadius: CSSC.px @options.underlineBorderRadius
        .add '.menuitem',
          textAlign: 'center'
          lineHeight: CSSC.px @options.menuHeight
          cursor: 'pointer'
          backgroundColor: @options.sideMenuBgColor
          color: @options.sideMenuColor
          webkitTransition: hackyColorTrans
          mozTransition: hackyColorTrans
          oTransition: hackyColorTrans
          transition: hackyColorTrans
        .add '.menuitem.active',
          backgroundColor: @options.sideMenuSelBgColor
          color: @options.sideMenuSelColor
      Template.RwdSimpleMenuMainMenu.helpers
        buttonSize: => "[#{@options.menuHeight},#{@options.menuHeight}]"
      ###
      ###
      Template.menuHamburger.rendered = =>
        menuHamburger = FView.byId 'menuHamburger'
        menuHamburger.surface.on 'click', => @toggle()
      Template.menuHamburger.helpers
        buttonSize: => "[#{@options.menuHeight},#{@options.menuHeight}]"
      Template.menuTop.rendered = =>
        @menuUnderline = (FView.byId 'menuUnderline').modifier
      Template.menuTopItem.rendered = ->
        surf = (FView.byId @data.rt).surface
        surf.on 'click', => Router.go "/#{@data.rt}"
      ###
      ###
      Template.menuTop.helpers
        items: => @_items
        spacing: => @options.labelSpacing
        underLineSize: =>
          "[#{@options.labelWidth}, #{@options.underlineBorderRadius}]"
        itemSize: =>
          "[#{@options.labelWidth}, #{@options.menuHeight}]"
      Template.sideMenu.helpers
        side: => "[#{@options.sideMenuWidth}, #{rwindow.innerHeight()}]"
        translate: =>
          "[-#{@options.sideMenuWidth}, 0, #{@options.sideMenuZindex}]"
      Template.innerSideMenu.helpers
        items: => _.extend {act:'menuitem inactive'}, item for item in @_items
        side: => "[#{@options.sideMenuWidth}, #{rwindow.innerHeight()}]"
        itemSize: => "[#{@options.sideMenuWidth}, #{@options.menuHeight}]"
      Template.menuTopItem.rendered = ->
        surf = (FView.byId @data.rt).surface
        surf.on 'click', =>
          mainMenu.setMenuItem @data.rt
          Router.go "/#{@data.rt}"
      Template.sideMenuItem.rendered = ->
        surf = (FView.byId @data.rt).surface
        surf.on 'click', =>
          mainMenu.setMenuItem @data.rt
          Router.go "/#{@data.rt}"
          mainMenu.deactivate()
      @depend()
      ###
    addRoute: (route, data) ->
      @_sideMenu.addRoute route, data
      @_topMenu.addRoute route, data
    removeRoute: (route) ->
      @_sideMenu.removeRoute route
      @_topMenu.removeRoute route
    ###
    depend: =>
      Tracker.autorun =>
        @isSideMenuActiveDeps.depend()
        posx = if @isSideMenuActive then 0 else -@options.sideMenuWidth
        @fview?.modifier.setTransform (famous.core.Transform.translate posx, \
          0, @options.sideMenuZindex), @options.transition
    activate: ->
      if @isSideMenuActive is false
        @isSideMenuActive = true
        @isSideMenuActiveDeps.changed()
    deactivate: ->
      if @isSideMenuActive is true
        @isSideMenuActive = false
        @isSideMenuActiveDeps.changed()
    toggle: ->
      @isSideMenuActive = not @isSideMenuActive
      @isSideMenuActiveDeps.changed()
    ###
    ###
    setMenuItem: (route) ->
      found = _.indexOf @_items, (_.find @_items, (item) -> item.rt is route)
      if rwindow.screen 'lte', 'xsmall'
        for item, idx in @_items
          surf = (FView.byId "#{item.rt}").surface
          if found is idx
            surf.addClass 'active'
          else
            surf.removeClass 'active'
      else
        if found is -1
          @menuUnderline.setOpacity 0, @options.transition
        else
          @menuUnderline.setOpacity 1, @options.transition
          posX = (@_items.length-found-1)*@options.labelWidth + \
            (@_items.length-found-1)*@options.labelSpacing
          @menuUnderline.setTransform (famous.core.Transform.translate -posX,\
            0, 0), @options.transition
    ###
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
