# Exposed class as a Singleton
class @RwdSimpleMenu
  # Namespace class. At runtime, these classes are null: we are waiting
  #  for famous to get loaded.
  @_class:
    MainMenu: null
    TopMenu: null
    SideMenu: null
    Hamburger: null
  # Hold a single instance of the Singleton.
  _inst = null
  # No access and instantiation of the components will be performed untill
  #  the viewport is ready. We consider it ready only when the document size
  #  is set and the reactive window is set to other values than undefineed.
  _isViewPortReady = false
  # A watchdog is being used to poll at every 4 engine ticks that the viewport
  #  size is set.
  _watchdog = null
  # While waiting for the viewport to be ready, a queue handle the history of
  #  commands to execute.
  _readyQueue = []
  # The queue of commands doesn't handle options patching. Only one option
  #  is taken into account. This constraint should not be a problem if users
  #  mutualize their configuration ant a single location.
  _options = {}
  # Only provide access to the menu if the viewport size is known.
  @get: (callback, options) ->
    # If user call this instanciation without callback ensure a error message
    #  that will lead them to a fix.
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
          # Start the polling every 4 ticks.
          # 1 tick = 1 / 60 Hz = 16.6ms.
          _watchdog = setInterval ->
            [width, height] = [rwindow.innerWidth(), rwindow.innerHeight()]
            FView.log.debug "Viewport size: #{width}X#{height}"
            if width isnt undefined and height isnt undefined
              FView.log.debug 'Viewport size settled'
              # Viewport is finally ready, clear the polling.
              clearInterval _watchdog
              # Ensure that next instance getting back returns the
              #  callback results immediatly.
              _isViewPortReady = true
              # Now that the viewport is settled, call each function
              #  in the queue.
              while _readyQueue.length
                sparedcallback = _readyQueue.shift()
                RwdSimpleMenu._run sparedcallback
          , 64
  # Queue caller: ensure that at least an instance of the Singleton has
  #  been created and if so set its options instead of using the constructor.
  @_run: (callback) ->
    if _inst  is null
      _inst = new RwdSimpleMenu._class.MainMenu _options
    else
      _inst.setOptions _options
    callback _inst
