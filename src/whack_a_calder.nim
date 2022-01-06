import std/[random]
import csfml/[audio]
import csfml

randomize()

type
  Calder = ref object
    sprite: Sprite
    xMovement: float
    yMovement: float

const
    BACKGROUND_COLOR = color(30, 30, 40)
    WINDOW_X: cint = 1000
    WINDOW_Y: cint = 800

let
    ctxSettings = ContextSettings(antialiasingLevel: 16)
    window = newRenderWindow(videoMode(WINDOW_X, WINDOW_Y), "Whack-a-Calder", settings = ctxSettings)

    calderTextures = [
      newTexture("res/calder_1.png"),
      newTexture("res/calder_2.png"),
      newTexture("res/calder_4.png"),
      newTexture("res/calder_5.png"),
    ]

    calderDeathSound = newSound(newSoundBuffer("res/calderDeath.wav"))

window.verticalSyncEnabled = true
window.framerateLimit = 60

proc newCalder(points: int): Calder =
  result = Calder(
    sprite: newSprite(calderTextures[rand(calderTextures.high)]),
    xMovement: min(rand(10)/10 * (points / 2) + points.toFloat, 24.0),
    yMovement: min(rand(10)/10 * (points / 2) + points.toFloat, 24.0),
  )

  result.sprite.origin = vec2(
    result.sprite.texture.size.x / 2,
    result.sprite.texture.size.y / 2,
  )

  result.sprite.position = vec2(rand(WINDOW_X), rand(WINDOW_Y))

proc draw(window: RenderWindow, calders: seq[Calder]) =
  for calder in calders:
    window.draw(calder.sprite)

var
    event: Event
    points = 0
    calders = newSeq[Calder]()

while window.open:
    if window.pollEvent(event):
        case event.kind:
        of EventType.Closed:
            window.close()
            break
        of EventType.KeyPressed:
            case event.key.code:
            of KeyCode.Escape:
                window.close()
                break
            else: discard
        else: discard

    if calders.len < 5:
      if rand(60) == 35:
        calders.add(newCalder(points))

    if mouse_isButtonPressed(MouseButton.Left):
      let mousePos = window.mouse_getPosition()
      var newCalders = newSeq[Calder]()

      for calder in calders:
        let b = calder.sprite.globalBounds
        
        if (
          mousePos.x.cfloat > b.left and
          mousePos.x.cfloat < (b.left + b.width) and
          mousePos.y.cfloat > b.top and
          mousePos.y.cfloat < (b.top + b.height)
        ):
          points += 1
          calderDeathSound.play()
        else:
          newCalders.add(calder)

      calders = newCalders

    # update calder's positions
    for calder in calders:
      if (
        calder.sprite.position.x + calder.xMovement > WINDOW_X.toFloat or
        calder.sprite.position.x + calder.xMovement < 0
      ):
        calder.xMovement = -calder.xMovement

      if (
        calder.sprite.position.y + calder.yMovement > WINDOW_Y.toFloat or
        calder.sprite.position.y + calder.yMovement < 0
      ):
        calder.yMovement = -calder.yMovement

      calder.sprite.position = vec2(
        calder.sprite.position.x + calder.xMovement,
        calder.sprite.position.y + calder.yMovement,
      )

    window.clear(BACKGROUND_COLOR)

    window.draw(calders)

    window.title = "Whack-a-Calder | Score: " & $points

    window.display()


calderDeathSound.stop()
calderDeathSound.destroy()

for t in calderTextures:
  t.destroy()

for c in calders:
  c.sprite.destroy()

window.destroy()
