FView.ready ->
  MainMenu = RwdSimpleMenu._class.MainMenu
  Hamburger = RwdSimpleMenu._class.Hamburger
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
    constructor: (@options) ->
      super @options
      # Get and check if main menu placeholder is available
      @placeHolder = MainMenu._getPlaceholder 'RwdSimpleMenuMainMenu'
      @placeHolder.node.add @
      @css = new CSSC
      @menuNode = @_createMainMod()
      @_createHomeButton()
      @_createMenuItems()
    _createMainMod: ->
      @mainMod = new famous.modifiers.StateModifier
        align: [.5,0]
        origin: [.5,0]
        size: [
          (Math.min rwindow.innerWidth()
          @options.maxWidth), @options.menuHeight
        ]
      Tracker.autorun =>
        curWidth = Math.min rwindow.innerWidth(), @options.maxWidth
        @mainMod.setSize [curWidth, @options.menuHeight]
      @add @mainMod
    _createHomeButton: ->
      homeButtonMod = new famous.modifiers.StateModifier
        align: [0,0]
        origin: [0,0]
        size: [@options.logoWidth, @options.logoHeight]
        opacity: 0
      homeButtonSurf = new famous.core.Surface
        classes: ['rwd-simple-menu-logo']
        content: MainMenu._getHtmlFromTemplate 'RwdSimpleMenuLogo'
      (@menuNode.add homeButtonMod).add homeButtonSurf
      homeButtonSurf.on 'click', -> Router.go '/'
      homeButtonMod.setOpacity 1, @options.transition
      @css.add '.rwd-simple-menu-logo', cursor: 'pointer'
    _createMenuItems: ->
      seqMod = new famous.modifiers.StateModifier
        align: [1,0]
        origin: [1,0]
        opacity: 1
      seqView = new famous.views.SequentialLayout
        itemSpacing: @options.labelSpacing
        direction: famous.utilities.Utility.Direction.X
      (@menuNode.add seqMod).add seqView
      @hamburgerSeq = [new Hamburger @options]
      @menuSeq = []
      Tracker.autorun =>
        isSmall = rwindow.screen 'lte', @options.minWidth
        #currSeq = if isSmall then @hamburgerSeq else @menuSeq
        currSeq = @hamburgerSeq
        seqMod.setOpacity 0, @options.transition, =>
          seqView.sequenceFrom currSeq
          seqMod.setOpacity 1, @options.transition
