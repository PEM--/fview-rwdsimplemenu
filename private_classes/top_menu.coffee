FView.ready ->
  MainMenu = RwdSimpleMenu._class.MainMenu
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
      @placeHolder = MainMenu._getAndCheckPlaceholder 'RwdSimpleMenuMainMenu'
      @placeHolder.node.add @
      @css = new CSSC
      @menuNode = @_createMainMod()
      @_createHomeButton()
      @_createMenuItems()
    _createMainMod: ->
      mainMod = new famous.modifiers.StateModifier
        align: [.5,.5]
        origin: [.5,.5]
      Tracker.autorun =>
        curWidth = Math.min rwindow.innerWidth(), @options.maxWidth
        mainMod.setSize [curWidth, @options.menuHeight]
      @add mainMod
    _createHomeButton: ->
      homeButtonMod = new famous.modifiers.StateModifier
        align: [0,.5]
        origin: [0,.5]
        size: [@options.logoWidth, @options.logoHeight]
        opacity: 0
      tpl = Template['RwdSimpleMenuLogo']
      if tpl is undefined
        FView.log.error 'Please set logo as template RwdSimpleMenuLogo'
        throw new Error 'No logo RwdSimpleMenuLogo'
      html = Blaze.toHTML Template['RwdSimpleMenuLogo']
      homeButtonSurf = new famous.core.Surface
        classes: ['rwd-simple-menu-logo']
        size: [@options.logoWidth, @options.logoHeight]
        content: html
      (@menuNode.add homeButtonMod).add homeButtonSurf
      homeButtonSurf.on 'click', -> Router.go '/'
      homeButtonMod.setOpacity 1, @options.transition
      @css.add '.rwd-simple-menu-logo', cursor: 'pointer'
    _createMenuItems: ->
      seqMod = new famous.modifiers.StateModifier
        align: [1,.5]
        origin: [1,.5]
        size: [true, @options.logoHeight]
        opacity: 1
      seqView = new famous.views.SequentialLayout
        itemSpacing: @options.labelSpacing
      (@menuNode.add seqMod).add seqView

      @hamburgerSeq = []
      @menuSeq = []
      Tracker.autorun =>
        isSmall = rwindow.screen 'lte', @options.minWidth
        currSeq = if isSmall then @hamburgerSeq else @menuSeq
        seqMod.setOpacity 0, @options.transition, =>
          seqView.sequenceFrom currSeq
          seqMod.setOpacity 1, @options.transition