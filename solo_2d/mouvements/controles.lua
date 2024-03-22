--[[

  Fonction 

]]

function Move_Player_2(forward, part)
  thrusting = false
  turning_right = false
  turning_left = false
  
  if love.keyboard.isDown("up") then
    thrusting = true
  end
  if love.keyboard.isDown("right") then
    turning_right = true
  end
  if love.keyboard.isDown("left") then
    turning_left = true
  end
  
  if thrusting then
    forward.Set_Norme(0.1)
  else
    forward.Set_Norme(0)
  end
  if turning_right then
    part.rotation = part.rotation + 0.05
  end
  if turning_left then
    part.rotation = part.rotation - 0.05
  end
  
  forward.Set_Angle(part.rotation)
  part.Accelerate(forward)
end

function Move_Point_From_A_To_B(x1, y1, x2, y2)
  local p1 = Point(x1, y1)
  local p2 = Point(x2, y2)
  local pA = {p1.x, p1.y}
  local t = 0
  local ghost = {}
  ghost.Update = function(dt)
    t = t + 0.02
    t = math.min(t, 1)
    pA.x = Lerp(t, p1.x, p2.x)
    pA.y = Lerp(t, p1.y, p2.y)
  end
  ghost.Draw = function()
    love.graphics.circle("fill", p1.x, p1.y, 4)
    love.graphics.circle("fill", p2.x, p2.y, 4)
    love.graphics.circle("fill", pA.x, pA.y, 4)
    love.graphics.line(p1.x, p1.y, pA.x, pA.y)
  end
  return ghost
end

function Point_To_Target(tx, ty, pos_x, pos_y, p_ease)
  local target = Point(tx, ty)
  local position = Point(pos_x, pos_y)
  local ease = p_ease
  local ghost = {}
  ghost.Update = function(dt)
    local dx, dy = target.x - position.x, target.y - position.y
    local vx, vy = dx * ease, dy * ease
    
    position.x = position.x + vx
    position.y = position.y + vy
  end
  ghost.Draw = function()
    Draw_Points(position, 10)
  end
  ghost.Mouse_Pressed = function(x, y, button)
    mouse_x, mouse_y = love.mouse.getPosition()
    if button == 1 then
      target.x = mouse_x
      target.y = mouse_y
    end
  end
  return ghost
end

-- Crée une suite de points qui se dirige vers le curseur de 
-- la souris.
function Snake_Points(p_nb_ronds, p_ease)
  local target = {}
  target.x = 0
  target.y = 0
  local leader = {}
  leader.x = target.x
  leader.y = target.y
  local lst_ronds = {}
  local nb_ronds = p_nb_ronds
  local ease = p_ease
  for i=1,nb_ronds do
    local p = {}
    p.x = 0
    p.y = 0
    table.insert(lst_ronds, p)
  end
  local ghost = {}
  ghost.Update = function(dt)
    local mouse_x, mouse_y = love.mouse.getPosition()
    if love.mouse.isDown(1) then
      target.x = mouse_x
      target.y = mouse_y
    end
    
    leader.x = target.x
    leader.y = target.y
    for i=1,#lst_ronds do
      local r = lst_ronds[i]
      r.x = r.x + (leader.x-r.x) * ease
      r.y = r.y + (leader.y-r.y) * ease
      
      leader.x = r.x
      leader.y = r.y
    end
  end
  ghost.Draw = function()
    for i=1,#lst_ronds do
      local r = lst_ronds[i]
      Draw_Points(r, 5)
    end
  end
  return ghost
end

-- Applique un coef d'easing au déplacement d'un point.
function Ease_To(p_pos, p_target, p_ease)
  dx = p_target.x - p_pos.x
  dy = p_target.y - p_pos.y
  
  p_pos.x = p_pos.x + dx * p_ease
  p_pos.y = p_pos.y + dy * p_ease
  
  if math.abs(dx) < 0.1 and math.abs(dy) < 0.1 then
    dx, dy = 0, 0
    p_pos.x = p_target.x
    p_pos.y = p_target.y
    return false
  end
  return true
end

-- Déplace un point vers le curseur de la souris.
function Point_To_Target_2(pos_x, pos_y, tar_x, tar_y, p_ease)
  local target = {}
  target.x = tar_x
  target.y = tar_y
  local position = {}
  position.x = pos_x
  position.y = pos_y
  local ease = p_ease
  local easing = true
  local ghost = {}
  ghost.Update = function(dt)
    easing = Ease_To(position, target, ease)
  end
  ghost.Draw = function()
    Draw_Points(position, 10)
    love.graphics.print("easing: "..tostring(easing), 5, 5)
  end
  ghost.Mouse_Pressed = function(x, y, button)
    target.x = x
    target.y = y
    if easing == false then
      easing = true
    end
  end
  return ghost
end

-- Crée une ligne qui serpente vers le curseur de la souris.
function Ease_Line(tx, ty, p_ronds, p_ease)
  local target = {}
  target.x = tx
  target.y = ty
  local leader = {}
  leader.x = target.x
  leader.y = target.y
  local ease = p_ease
  local nb_ronds = p_ronds
  local lst_ronds = {}
  for i=1,nb_ronds do
    local r = {}
    r.x = 0
    r.y = 0
    table.insert(lst_ronds, r)
  end
  
  local ghost = {}
  ghost.Update = function(dt)
    leader.x = target.x
    leader.y = target.y
    
    for i=1,#lst_ronds do
      local p = lst_ronds[i]
      p.x = p.x + (leader.x - p.x) * ease
      p.y = p.y + (leader.y - p.y) * ease
      
      leader.x = p.x
      leader.y = p.y
    end
  end
  ghost.Draw = function()
    for i=1,#lst_ronds-1 do
      love.graphics.line(lst_ronds[i].x, lst_ronds[i].y, lst_ronds[i+1].x, lst_ronds[i+1].y)
    end
  end
  ghost.Mouse_Pressed = function(x, y, button)
    target.x = x
    target.y = y
  end
  return ghost
end

-- Permet de faire une tourner une image comme un volant selon le movement en x du curseur de la souris.
function Steering_Wheel(p_img, p_ease)
  local angle = 0
  local target_angle = 0
  local ease = p_ease
  local ghost = {}
  ghost.Update = function(dt)
    mouse_x = love.mouse.getX()
    target_angle = Map(mouse_x, 0, largeur, -math.pi, math.pi)
    angle = angle + (target_angle-angle) * ease
  end
  ghost.Draw = function()
    love.graphics.draw(p_img, (largeur/2)-(p_img:getWidth()/2), (hauteur/2)-(p_img:getHeight()/2), angle, 1, 1, p_img:getWidth()/2, p_img:getHeight()/2)
  end
  return ghost
end

function Move_Player(p_entity, p_speed, dt)
  p_entity.velocite = Vector(0, 0)
  if love.keyboard.isDown("up") then
    p_entity.velocite = p_entity.velocite + (Vector(0, -p_speed))
  end
  if love.keyboard.isDown("right") then
    p_entity.velocite = p_entity.velocite + (Vector(p_speed, 0))
  end
  if love.keyboard.isDown("down") then
    p_entity.velocite = p_entity.velocite + (Vector(0, p_speed))
  end
  if love.keyboard.isDown("left") then
    p_entity.velocite = p_entity.velocite + (Vector(-p_speed, 0))
  end
  if p_entity.velocite.Get_Norme() ~= 0 then
    p_entity.velocite.normalize()
    p_entity.velocite.Multiply_By(p_speed)
  end
  p_entity.position.Add_To(p_entity.velocite*dt)
end

function Rotate_And_Move(object, forward, backward, angle_up, angle_down, dt)
  if love.keyboard.isDown(angle_up) then
    object.angle = object.angle + 2*dt
  end
  if love.keyboard.isDown(angle_down) then
    object.angle = object.angle - 2*dt
  end
  
  if love.keyboard.isDown(forward) then
    object.position.x = object.position.x + math.cos(object.angle) * 60*dt
    object.position.y = object.position.y + math.sin(object.angle) * 60*dt
  end
  if love.keyboard.isDown(backward) then
    object.position.x = object.position.x - math.cos(object.angle) * 60*dt
    object.position.y = object.position.y - math.sin(object.angle) * 60*dt
  end
end

function Invert_Velocity(p_joueur, p_rect)
  if p_joueur.position.x > p_rect.position.x and p_joueur.position.x < p_rect.position.x+p_rect.size.x then
    p_joueur.velocite.y = -p_joueur.velocite.y
  else
    p_joueur.velocite.x = -p_joueur.velocite.x
  end
end

function Va_Et_Vient(dt, pEntity)
  pHor = false
  pVert = false
  if pEntity.velocite.x ~= 0 then
    pHor = true
  else
    pHor = false
  end
  if pEntity.velocite.y ~= 0 then
    pVert = true
  else
    pVert = false
  end
  if pHor then
    if pEntity.position.x >= 600 then
      pEntity.position.x = 600
      pEntity.velocite.x = -pEntity.velocite.x
    end
    if pEntity.position.x <= 200 then
      pEntity.position.x = 200
      pEntity.velocite.x = -pEntity.velocite.x
    end
  end
  if pVert then
    if pEntity.position.y >= 400 then
      pEntity.position.y = 400
      pEntity.velocite.y = -pEntity.velocite.y
    end
    if pEntity.position.y <= 200 then
      pEntity.position.y = 200
      pEntity.velocite.y = -pEntity.velocite.y
    end
  end
end

-- Applique un mouvemnt de va et vient géré par une fonction sinus.
function Va_Et_Vient_Sinus(pEntity, depart, max, start_time)
  pHor = false
  pVert = false
  if pEntity.velocite.x ~= 0 then
    pHor = true
    end_time = max/joueur.velocite.x * 4
  else
    pHor = false
  end
  if pEntity.velocite.y ~= 0 then
    pVert = true
    end_time = max/joueur.velocite.y * 4
  else
    pVert = false
  end
  pulsation = math.pi*2 / end_time
  
  local unnamed = {}
  unnamed.Update = function(dt)
    start_time = start_time + dt
    if pHor then
      pEntity.position.x = depart + max * math.sin(pulsation*start_time)
      if start_time > end_time then
        start_time = 0
      end
    end
    if pVert then
      pEntity.position.y = depart + max * math.sin(pulsation*start_time)
      if start_time > end_time then
        start_time = 0
      end
    end
  end
  return unnamed
end