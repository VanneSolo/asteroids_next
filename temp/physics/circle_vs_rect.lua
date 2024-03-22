io.stdout:setvbuf('no')
if arg[arg] == "-debug" then require("mobdebug").start() end
love.graphics.setDefaultFilter("nearest")

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function math.normalize(x,y) local l=(x*x+y*y)^.5 if l==0 then return 0,0,0 else return x/l,y/l,l end end

--function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end
function math.dist(x1,y1, x2,y2) return math.sqrt((x2-x1)^2 + (y2-y1)^2) end

function Circle_Vs_Rect(circle_x, circle_y, rayon, rect_x, rect_y, rect_w, rect_h)
  test_x = circle_x
  test_y = circle_y
  
  if circle_x < rect_x then
    test_x = rect.x
  elseif circle_x > rect_x+rect_w then
    test_x = rect_x+rect_w
  end
  
  if circle_y < rect_y then
    test_y = rect_y
  elseif circle_y > rect_y+rect_h then
    test_y = rect_y+rect_h
  end
  
  dist_x = circle_x - test_x
  dist_y = circle_y - test_y
  distance = math.sqrt((dist_x^2)+(dist_y^2))
  
  if distance <= rayon then
    return true
  else
    return false
  end
end

function Move_Player(up, right, down, left, player, dt)
  player.vx = 0
  player.vy = 0
  local speed = 25
  
  if love.keyboard.isDown(up) then
    player.vy = -speed * dt
  end
  if love.keyboard.isDown(right) then
    player.vx = speed * dt
  end
  if love.keyboard.isDown(down) then
    player.vy = speed * dt
  end
  if love.keyboard.isDown(left) then
    player.vx = -speed * dt
  end
  player.vx, player.vy = math.normalize(player.vx, player.vy)
  
  player.x = player.x + player.vx
  player.y = player.y + player.vy
end

function love.load()
  largeur = love.graphics.getWidth()
  hauteur = love.graphics.getHeight()
  
  rect = {}
  rect.w = 150
  rect.h = 100
  rect.x = largeur/2 - rect.w/2
  rect.y = hauteur/2 - rect.h/2
  
  rect_bb = {}
  rect_bb.w = 250
  rect_bb.h = 200
  rect_bb.x = rect.x-50
  rect_bb.y = rect.y-50
  
  circle = {}
  circle.r = 25
  circle.x = 100
  circle.y = 100
  circle.vx = 0
  circle.vy = 0
  
  circle_bb = {}
  circle_bb.w = circle.r*4
  circle_bb.h = circle.r*4
  circle_bb.x = circle.x-(circle.r*2)
  circle_bb.y = circle.y-(circle.r*2)
  
  v_guessed_position = {x=0, y=0}
  v_current_position = {x=0, y=0}
  v_target_position = {x=0, y=0}
  v_nearest_point = {x=0, y=0}
  v_ray_to_nearest = {x=0, y=0}
  overlap = 0
end

function love.update(dt)
  Move_Player("up", "right", "down", "left", circle, dt)
  
  circle_bb.x = circle.x-(circle.r*2)
  circle_bb.y = circle.y-(circle.r*2)
  
  v_guessed_position = {x=circle.x+circle.vx*dt, y=circle.y+circle.vy*dt}
  v_current_position = {x=math.floor(circle.x), y=math.floor(circle.y)}
  v_target_position = {x=v_guessed_position.x, y=v_guessed_position.y}
  
  boum_bb = CheckCollision(circle_bb.x, circle_bb.y, circle_bb.w, circle_bb.h, rect_bb.x, rect_bb.y, rect_bb.w, rect_bb.h)
  boum = Circle_Vs_Rect(circle.x, circle.y, circle.r, rect.x, rect.y, rect.w, rect.h)
  if boum then
    v_nearest_point = {x=math.max(rect.x, math.min(v_guessed_position.x, rect.x+rect.w)), y=math.max(rect.y, math.min(v_guessed_position.y, rect.y+rect.h))}
    v_ray_to_nearest = {x=v_nearest_point.x-v_guessed_position.x, y=v_nearest_point.y-v_guessed_position.y}
    magnitude = math.dist(0, 0, v_ray_to_nearest.x, v_ray_to_nearest.y)
    overlap = circle.r - magnitude
    if type(overlap) ~= "number" then
      overlap = 0
    end
    if overlap > 0 then
      norm_ray_x, norm_ray_y = math.normalize(v_ray_to_nearest.x, v_ray_to_nearest.y)
      v_guessed_position = {x=v_guessed_position.x-(norm_ray_x*overlap), y=v_guessed_position.y-(norm_ray_y*overlap)}
    end
    circle.x = v_guessed_position.x
    circle.y = v_guessed_position.y
  end
end

function love.draw()
  if boum_bb then
    love.graphics.setColor(0, 1, 1)
  else
    love.graphics.setColor(0, 1, 0)
  end
  love.graphics.rectangle("line", rect_bb.x, rect_bb.y, rect_bb.w, rect_bb.h)
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("line", circle_bb.x, circle_bb.y, circle_bb.w, circle_bb.h)
  if boum then
    love.graphics.setColor(1, 0, 0)
  else
    love.graphics.setColor(1, 0, 1)
  end
  love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h)
  love.graphics.setColor(1, 1, 0)
  love.graphics.circle("fill", circle.x, circle.y, circle.r)
  love.graphics.setColor(1, 1, 1)
  
  love.graphics.print("boum: "..tostring(boum), 5, 5)
  love.graphics.print("circle.x: "..tostring(circle.x), 5, 5+16)
  love.graphics.print("circle.y: "..tostring(circle.y), 5, 5+16*2)
  love.graphics.print("v_guessed_position.x: "..tostring(v_guessed_position.x), 5, 5+16*3)
  love.graphics.print("v_guessed_position.y: "..tostring(v_guessed_position.y), 5, 5+16*4)
  love.graphics.print("v_current_position.x: "..tostring(v_current_position.x), 5, 5+16*5)
  love.graphics.print("v_current_position.y: "..tostring(v_current_position.y), 5, 5+16*6)
  love.graphics.print("v_nearest_point.x: "..tostring(v_nearest_point.x), 5, 5+16*7)
  love.graphics.print("v_nearest_point.y: "..tostring(v_nearest_point.y), 5, 5+16*8)
  love.graphics.print("v_ray_to_nearest.x: "..tostring(v_ray_to_nearest.x), 5, 5+16*9)
  love.graphics.print("v_ray_to_nearest.y: "..tostring(v_ray_to_nearest.y), 5, 5+16*10)
  love.graphics.print("magnitude: "..tostring(magnitude), 5, 5+16*11)
  love.graphics.print("overlap: "..tostring(overlap), 5, 5+16*12)
end

function Line_Intersect(p0, p1, p2, p3, segment_A, segment_B)
  local A1 = p1.y - p0.y
  local B1 = p0.x - p1.x
  local C1 = A1*p0.x + B1*p0.y
  
  local A2 = p3.y - p2.y
  local B2 = p2.x - p3.x
  local C2 = A2*p2.x + B2*p2.y
  
  local denominateur = A1*B2 - A2*B1
  if denominateur == 0 then
    return false
  end
  
  local intersect_x = (B2*C1 - B1*C2) / denominateur
  local intersect_y = (A1*C2 - A2*C1) / denominateur
  
  local rx_0 = (intersect_x - p0.x) / (p1.x - p0.x)
  local ry_0 = (intersect_y - p0.y) / (p1.y - p0.y)
  local rx_1 = (intersect_x - p2.x) / (p3.x - p2.x)
  local ry_1 = (intersect_y - p2.y) / (p3.y - p2.y)
  if segment_A and not ((rx_0 >= 0 and rx_0 <= 1) or (ry_0 >= 0 and ry_0 <= 1)) then
    return false
  end
  if segment_B and not ((rx_1 >= 0 and rx_1 <= 1) or (ry_1 >= 0 and ry_1 <= 1)) then
    return false
  end
  
  return {x = intersect_x, y = intersect_y}
end