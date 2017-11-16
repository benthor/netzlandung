function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

function love.load()
  width = love.graphics.getWidth()
  height = love.graphics.getHeight()
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
    position = {x = width, y = height},
    speed = 20,
    course = 280,
    approach = 500,
  }
  points = {}


  function mkpoint(point)
    table.insert(points, {x = point.x, y = point.y, radius = 3, segments = 5})
  end

  function points.draw()
    for i,point in ipairs(points) do
      love.graphics.setColor(255,0,0)
      --love.graphics.circle("fill", point.x, point.y, point.radius, point.segments)
      love.graphics.points(point.x, point.y)
    end
  end

  function updatePosition(t, dt)
    local speed = t.speed * dt
    t.position.x = t.position.x + math.sin(math.rad(t.course)) * speed
    t.position.y = t.position.y - math.cos(math.rad(t.course)) * speed
  end

  function angle(point1, point2)
    return (360+math.deg(math.atan2(point1.x - point2.x, point2.y - point1.y))) % 360
  end

  function approachDistance(plane, ship)
    distance = math.dist(plane.position.x, plane.position.y, ship.position.x, ship.position.y) / 2
    diff = math.abs(ship.course - plane.course)
    if diff > 180 then
      diff = math.min(ship.course, plane.course) + 360 - math.max(ship.course, plane.course)
    end
    return distance + diff * (100/distance)
  end

  function ship.update(dt)
    updatePosition(ship, dt)
  end

  function ship.draw()
    love.graphics.setColor(0,0,255)
    love.graphics.translate(ship.position.x, ship.position.y)
    love.graphics.rotate(math.rad(ship.course))
    love.graphics.rectangle("fill", -20, -40, 40, 80)
    --love.graphics.line(0,0,0,ship.approach)
    love.graphics.rotate(-math.rad(ship.course))
    love.graphics.translate(-ship.position.x, -ship.position.y)
  end

  function plane.update(dt)
    updatePosition(plane, dt)
    if next(plane.waypoint) ~= nil  then
      local angle = angle(plane.waypoint, plane.position)
      if (angle - plane.course) % 360 < (plane.course - angle) % 360 then
        plane.course = (plane.course + plane.steering * dt) % 360
      else
        plane.course = (plane.course - plane.steering * dt) % 360
      end
    end
    mkpoint(plane.position)
  end

  function plane.draw()
    love.graphics.setColor(0, 255, 0)

    if next(plane.waypoint) ~= nil then
      love.graphics.points(plane.waypoint.x, plane.waypoint.y)
      love.graphics.line(plane.position.x, plane.position.y, plane.waypoint.x, plane.waypoint.y)
    end
    love.graphics.translate(plane.position.x, plane.position.y)
    love.graphics.rotate(math.rad(plane.course))
    love.graphics.rectangle("fill", -5, -10, 10, 20)
    love.graphics.rotate(-math.rad(plane.course))
    love.graphics.translate(-plane.position.x, -plane.position.y)
  end

  function plane.flyto(x, y)
    plane.waypoint.x = x
    plane.waypoint.y = y
  end

end

-- Increase the size of the rectangle every frame.
function love.update(dt)
  plane.update(dt)
  ship.update(dt)
  if plane.returning then
    distance = approachDistance(plane, ship)
    plane.waypoint.x = ship.position.x - distance * math.sin(math.rad(ship.course))
    plane.waypoint.y = ship.position.y + distance * math.cos(math.rad(ship.course))
  end
end
 
-- Draw a coloured rectangle.
function love.draw()
  points.draw()
  love.graphics.setColor(255, 0, 0)
  love.graphics.line(plane.position.x, plane.position.y, ship.position.x, ship.position.y)
  love.graphics.setColor(0, 255, 0)
  love.graphics.points((plane.position.x + ship.position.x) / 2, (plane.position.y + ship.position.y) / 2)
  plane.draw()
  ship.draw()
  if plane.returning then
    love.graphics.setColor(255, 255, 255)
    distance = approachDistance(plane, ship)
    --love.graphics.points((plane.position.x + ship.position.x) / 2, (plane.position.y + ship.position.y) / 2)
    --distance = math.dist(plane.position.x, plane.position.y, ship.position.x, ship.position.y) / 2 
    --distance = distance + math.abs(ship.course - plane.course) * (100/distance)
    --distance = distance + math.min(math.abs(ship.course - plane.course),math.abs(ship.course % 180 - plane.course % 180)) * (100/distance)
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
  if key == "escape" or key == "q" then
    love.event.quit()
  end
end

function love.mousepressed( x, y, button, istouch )
  plane.flyto(x, y)
  --plane.waypoint.x = x
  --plane.waypoint.y = y
end
