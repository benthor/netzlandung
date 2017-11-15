function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

function love.load()
  love.keyboard.setKeyRepeat( true )

  plane = {
    position = {x=0, y=0},
    speed = 50,
    course = 135,
    waypoint = {},
    steering = 100,
    returning = true,
  }
  ship = {
    position = {x = 0, y = 0},
    speed = 10,
    course = 135,
    approach = 500,
  }


  function ship.update(dt)
    local speed = ship.speed * dt
    ship.position.x = ship.position.x + math.sin(math.rad(ship.course)) * speed
    ship.position.y = ship.position.y - math.cos(math.rad(ship.course)) * speed
  end

  function ship.draw()
    love.graphics.setColor(0,0,255)
    love.graphics.translate(ship.position.x, ship.position.y)
    love.graphics.rotate(math.rad(ship.course))
    love.graphics.rectangle("fill", -20, -40, 40, 80)
    love.graphics.line(0,0,0,ship.approach)
    love.graphics.rotate(-math.rad(ship.course))
    love.graphics.translate(-ship.position.x, -ship.position.y)
  end

  function plane.update(dt)
    local speed = plane.speed * dt
    plane.position.x = plane.position.x + math.sin(math.rad(plane.course)) * speed
    plane.position.y = plane.position.y - math.cos(math.rad(plane.course)) * speed
    if next(plane.waypoint) ~= nil  then
      angle = (360+math.deg(math.atan2(plane.waypoint.x - plane.position.x, plane.position.y - plane.waypoint.y))) % 360
      print(angle, plane.course)

      if (angle - plane.course + 360) % 360 < (plane.course - angle + 360) % 360 then
        plane.course = (plane.course + plane.steering * dt) % 360
      else
        plane.course = (plane.course - plane.steering * dt) % 360
      end
    end
  end

  function plane.draw()
    love.graphics.setColor(0, 255, 0)

    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    if next(plane.waypoint) ~= nil then
      love.graphics.points(plane.waypoint.x, plane.waypoint.y)
      love.graphics.line(plane.position.x, plane.position.y, plane.waypoint.x, plane.waypoint.y)
    end
    -- rotate around the center of the screen by angle radians
    love.graphics.translate(plane.position.x, plane.position.y)
    love.graphics.rotate(math.rad(plane.course))
    --love.graphics.rectangle("fill", plane.position.x, plane.position.y, 10, 10)
    love.graphics.rectangle("fill", -5, -10, 10, 20)
    love.graphics.rotate(-math.rad(plane.course))
    love.graphics.translate(-plane.position.x, -plane.position.y)
    --love.graphics.translate(-width/2, -height/2)
    -- draw a white rectangle slightly off center
    --love.graphics.setColor(0xff, 0xff, 0xff)
    --love.graphics.rotate(plane.course)

    --love.graphics.rotate(-plane.course)
  end

  function plane.flyto(x, y)
    plane.waypoint.x = x
    plane.waypoint.y = y
  end

  x, y, w, h = 20, 20, 60, 20
end

-- Increase the size of the rectangle every frame.
function love.update(dt)
  plane.update(dt)
  ship.update(dt)
  if plane.returning then
    distance = math.dist(plane.position.x, plane.position.y, ship.position.x, ship.position.y) / 2 
    distance = distance + math.abs(ship.course - plane.course) * (100/distance)
    plane.waypoint.x = ship.position.x - distance * math.sin(math.rad(ship.course))
    plane.waypoint.y = ship.position.y + distance * math.cos(math.rad(ship.course))
  end
end
 
-- Draw a coloured rectangle.
function love.draw()
  love.graphics.setColor(255, 0, 0)
  love.graphics.line(plane.position.x, plane.position.y, ship.position.x, ship.position.y)
  love.graphics.setColor(0, 255, 0)
  love.graphics.points((plane.position.x + ship.position.x) / 2, (plane.position.y + ship.position.y) / 2)
  plane.draw()
  ship.draw()
  if plane.returning then
    love.graphics.setColor(255, 255, 255)
    --love.graphics.points((plane.position.x + ship.position.x) / 2, (plane.position.y + ship.position.y) / 2)
    distance = math.dist(plane.position.x, plane.position.y, ship.position.x, ship.position.y) / 2 
    distance = distance + math.abs(ship.course - plane.course) * (100/distance)
    --distance = math.dist(plane.position.x, plane.position.y, ship.position.x, ship.position.y) / 2
    love.graphics.line(ship.position.x, ship.position.y, ship.position.x - distance * math.sin(math.rad(ship.course)), ship.position.y + distance * math.cos(math.rad(ship.course)))

  end
  --love.graphics.rectangle("fill", x, y, w, h)
end

function love.keypressed(key, scancode, isrepeat)
  if key == "up" then
    ship.speed = ship.speed + 10
  end
  if key == "down" then
    ship.speed = ship.speed - 10
  end
  if key == "left" then
    ship.course = (ship.course + 359) % 360
  end
  if key == "right" then
    ship.course = (ship.course + 1) % 360
  end
  if key == "return" then
    plane.returning = not plane.returning
    print("returning", plane.returning)
  end
end

function love.mousepressed( x, y, button, istouch )
  plane.flyto(x, y)
  --plane.waypoint.x = x
  --plane.waypoint.y = y
end
