# Exposed class as a Singleton
class @RwdSimpleMenu
  @_class:
    MainMenu: null
    TopMenu: null
    SideMenu: null
    Hamburger: null
  _inst = null
  _isViewPortReady = false
  _watchdog = null
  _readyQueue = []
  _readyDep = new Tracker.Dependency
  _options = {}
  # Only provide access to the menu if the viewport size is known.
  @get: (callback, options) ->
    unless callback?
      FView.log.error 'Provide callback: function(menu) { ... }'
      throw new Error 'No callback received at menu instantiation'
    # Spare current options if they exist
    _options = options if options?
    # Execute callback immediately if viewport is ready
    return RwdSimpleMenu._run callback if _isViewPortReady
    # Check current viewport size, it must be defined before
    #  creating the menu.
    [width, height] = [rwindow.innerWidth(), rwindow.innerHeight()]
    if width is undefined or height is undefined
      _readyQueue.push callback
      # If not alread created, set a watchdog every 4 engine ticks
      #  that ckecks readyness
      if _watchdog is null
        FView.ready ->
          _watchdog = setInterval ->
            [width, height] = [rwindow.innerWidth(), rwindow.innerHeight()]
            FView.log.debug "Viewport size: #{width}X#{height}"
            if width isnt undefined and height isnt undefined
              FView.log.debug 'Viewport size settled'
              # Viewport is finally ready, execute all spared callbacks
              clearInterval _watchdog
              _isViewPortReady = true
              _readyDep.changed()
              while _readyQueue.length
                sparedcallback = _readyQueue.shift()
                RwdSimpleMenu._run sparedcallback
          , 64
      return
  @_run: (callback) ->
    if _inst  is null
      _inst = new RwdSimpleMenu._class.MainMenu _options
    else
      _inst.setOptions _options
    callback _inst
