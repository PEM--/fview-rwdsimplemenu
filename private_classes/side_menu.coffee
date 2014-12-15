FView.ready ->
  MainMenu = RwdSimpleMenu._class.MainMenu
  class RwdSimpleMenu._class.SideMenu extends famous.core.View
    @DEFAULT_OPTIONS:
      sideMenuZindex: 150
      sideMenuWidth: 200
      sideMenuBgColor: CSSC.darkgray
      sideMenuColor: CSSC.silver
      sideMenuSelBgColor: CSSC.gray
      sideMenuSelColor: CSSC.white
      transition: curve: 'easeInOut', duration: 300
    constructor: (@options) ->
      super @options
      @placeHolder = MainMenu._getPlaceholder 'RwdSimpleMenuSideMenu'
