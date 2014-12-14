# Private class defining the menu
class _Menu
  @DEFAULT_OPTIONS:
    labelWidth: 100
    labelSpacing: 20
    menuHeight: 50
    underlineBorderRadius: 4
    underlineBgColor: '#086599'
    sideMenuZindex: 150
    sideMenuWidth: 200
    sideMenuBgColor: CSSC.darkgray
    sideMenuColor: CSSC.silver
    sideMenuSelBgColor: CSSC.gray
    sideMenuSelColor: CSSC.white
    transition: curve: 'easeInOut', duration: 300
  constructor: (options) ->
    @options = famous.utilities.Utility.clone @constructor.DEFAULT_OPTIONS or \
      MainMenu.DEFAULT_OPTIONS
    @_optionsManager = new famous.core.OptionsManager @options
    @setOptions options
    @isSideMenuActive = false
    @isSideMenuActiveDeps = new Tracker.Dependency
    Template.menu.rendered = =>
      @fview = FView.byId 'sideMenu'
      menuHome = FView.byId 'menuHome'
      menuHome.surface.on 'click', =>
        @setMenuItem()
        Router.go '/'
      hackyColorTrans = "background-color #{@options.transition.duration}ms, \
        color #{@options.transition.duration}ms"
      css.add ['.menubutton', '.menulabel'],
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
    Template.menu.helpers
      buttonSize: => "[#{@options.menuHeight},#{@options.menuHeight}]"
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
    @items = []
    Template.menuTop.helpers
      items: => @items
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
      items: => _.extend {act:'menuitem inactive'}, item for item in @items
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
  addRoute: (route, icon, label) ->
    @items.push {rt: route, ic: icon, lbl: label}
  removeRoute: (route) ->
    found = _.indexOf @items, (_.find @items, (item) -> item.rt is route)
    unless found is -1
      @items.splice found, 1
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
  setMenuItem: (route) ->
    found = _.indexOf @items, (_.find @items, (item) -> item.rt is route)
    if rwindow.screen 'lte', 'xsmall'
      for item, idx in @items
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
        posX = (@items.length-found-1)*@options.labelWidth + \
          (@items.length-found-1)*@options.labelSpacing
        @menuUnderline.setTransform (famous.core.Transform.translate -posX,\
          0, 0), @options.transition
  setOptions: (options) -> @_optionsManager.patch options

# Exposed class as a Singleton
class @RwdSimpleMenu
  instance = null
  @get: (options) ->
    if instance  is null
      instance = new _Menu options
    else
      instance.setOptions options
