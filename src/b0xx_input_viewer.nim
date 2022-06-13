import sdl2_nim/[sdl, sdl_image]
import inputhandler

const initFlags =
  when defined(daemon):
    sdl.INIT_GAMECONTROLLER
  else:
    sdl.INIT_VIDEO and sdl.INIT_EVENTS and sdl.INIT_GAMECONTROLLER

type Viewer* = ref object
  window: sdl.Window
  renderer: sdl.Renderer
  shouldExit: bool

proc render(this: Viewer) =
  # TODO: Render shapes etc representing buttons.
  # Use a Table[GameControllerButton, bool] for visibility.
  this.renderer.renderPresent()

proc tearDown(this: Viewer) =
  when not defined(daemon):
    this.renderer.destroyRenderer()
    this.window.destroyWindow()
    sdl_image.quit()
  sdl.quit()

proc loop*(this: Viewer) =
  Input.addKeyPressedListener(
    K_ESCAPE,
    proc(key: Keycode, state: KeyState) =
      this.shouldExit = true
  )

  Input.addControllerTriggerListener(
    ControllerTrigger.LEFT,
    (proc(value: CompletionRatio) =
      echo value
    ),
    0.0
  )

  Input.addControllerTriggerListener(
    ControllerTrigger.RIGHT,
    (proc(value: CompletionRatio) =
      echo value
    ),
    0.0
  )

  var event: Event

  while not this.shouldExit:
    while pollEvent(addr event) != 0:
      Input.processEvent(event)

    when not defined(daemon):
      this.render()
  this.tearDown()

when isMainModule:
  if not sdl.setHint(HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS, "1"):
    raise newException(Exception, "Failed to enable " & HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS)

  if sdl.init(initFlags) != 0:
    raise newException(Exception, "Failed to init sdl")

  if sdl_image.init(sdl_image.INIT_PNG) == 0:
    raise newException(Exception, "Failed to init sdl_image")

  initInputHandlerSingleton()

  let viewer = Viewer()

  # Create window
  viewer.window = sdl.createWindow(
    "B0XX Input Viewer",
    sdl.WINDOWPOS_UNDEFINED,
    sdl.WINDOWPOS_UNDEFINED,
    # TODO: Make sure these dimensions are fine.
    488,
    244,
    0
  )

  if isNil(viewer.window):
    raise newException(Exception, "Failed to create window")

  viewer.renderer = sdl.createRenderer(
    viewer.window,
    -1,
    sdl.RENDERER_ACCELERATED or sdl.RENDERER_PRESENTVSYNC
  )

  if isNil(viewer.renderer):
    raise newException(Exception, "Failed to create the renderer")

  if viewer.renderer.setRenderDrawColor(0x00, 0x00, 0x00, 0xFF) == -1:
    raise newException(Exception, "Failed to set renderer draw color")

  viewer.loop()
