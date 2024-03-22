-- Petit moteur de physique.
engine = {
  base_x=450,
  base_y=100,
  range=100,
  angle=0,
  speed=0.05,
  x=550,
  y=100,
  pinned=true
}

ronds = {}
ronds[1] = {x=100, y=100, oldx=100+RND()*50-25, oldy=100+RND()*50-25}
ronds[2] = {x=200, y=100, oldx=200, oldy=100}
ronds[3] = {x=200, y=200, oldx=200, oldy=200}
ronds[4] = {x=100, y=200, oldx=100, oldy=200}
ronds[5] = {x=400, y=100, oldx=400, oldy=100}
ronds[6] = {x=290, y=100, oldx=290, oldy=100}

sticks = {}
sticks[1] = {p0=ronds[1], p1=ronds[2], long=Dist_Vectors(ronds[1], ronds[2])}
sticks[2] = {p0=ronds[2], p1=ronds[3], long=Dist_Vectors(ronds[2], ronds[3])}
sticks[3] = {p0=ronds[3], p1=ronds[4], long=Dist_Vectors(ronds[3], ronds[4])}
sticks[4] = {p0=ronds[4], p1=ronds[6], long=Dist_Vectors(ronds[4], ronds[6])}
sticks[5] = {p0=ronds[1], p1=ronds[3], long=Dist_Vectors(ronds[1], ronds[3])}
sticks[6] = {p0=ronds[3], p1=ronds[4], long=Dist_Vectors(ronds[3], ronds[4])}
sticks[7] = {p0=ronds[4], p1=ronds[1], long=Dist_Vectors(ronds[4], ronds[1])}
sticks[8] = {p0=ronds[1], p1=ronds[3], long=Dist_Vectors(ronds[1], ronds[3])}
sticks[9] = {p0=engine, p1=ronds[5], long=Dist_Vectors(engine, ronds[5])}
sticks[10] = {p0=ronds[5], p1=ronds[6], long=Dist_Vectors(ronds[5], ronds[6])}
sticks[11] = {p0=ronds[6], p1=ronds[1], long=Dist_Vectors(ronds[6], ronds[1])}

chat = {}
chat.x = ronds[1].x
chat.y = ronds[1].y
chat.img = love.graphics.newCanvas(100, 100)
function Load_Chat()
  love.graphics.setCanvas(chat.img)
  love.graphics.circle("fill", 50, 50, 50)
  love.graphics.setColor(1, 0, 0)
  love.graphics.circle("fill", 30, 30, 5)
  love.graphics.circle("fill", 70, 30, 5)
  love.graphics.setColor(1, 1, 1)
  love.graphics.setCanvas()
end

function Update_Engine(dt, p_engine)
  p_engine.x = p_engine.base_x + math.cos(p_engine.angle) * p_engine.range
  p_engine.y = p_engine.base_y + math.sin(p_engine.angle) * p_engine.range
  p_engine.angle = p_engine.angle + p_engine.speed
end

function Update_Points(dt, p_table, p_friction, p_grav)
  for i=1,#p_table do
    local r = p_table[i]
    local vx = (r.x - r.oldx) * p_friction
    local vy = (r.y - r.oldy) * p_friction
    r.oldx = r.x
    r.oldy = r.y
    r.x = r.x + vx
    r.y = r.y + vy
    r.y = r.y + p_grav
  end
end

function Update_Img(ent_1, ent_2)
  ent_1.x = ent_2[1].x
  ent_1.y = ent_2[1].y
end

function Constrain_Points(p_table, p_bounce, p_friction)
  for i=1,#p_table do
    local r = p_table[i]
    if (not r.pinned) then
      local vx = (r.x - r.oldx) * p_friction
      local vy = (r.y - r.oldy) * p_friction
      if r.x>largeur then
        r.x = largeur
        r.oldx = r.x+vx * p_bounce
      elseif r.x<0 then
        r.x = 0
        r.oldx = r.x+vx * p_bounce
      end
      if r.y>hauteur then
        r.y = hauteur
        r.oldy = r.y+vy * p_bounce
      elseif r.y<0 then
        r.y = 0
        r.oldy = r.y+vy * p_bounce
      end
    end  
  end
end

function Update_Sticks(dt, p_table)
  for i=1,#p_table do
    local s = p_table[i]
    local dx = s.p1.x - s.p0.x
    local dy = s.p1.y - s.p0.y
    local dist = math.sqrt(dx*dx + dy*dy)
    local diff = s.long - dist
    local percent = diff/dist/2
    local offset_x = dx*percent
    local offset_y = dy*percent
   
    if (not s.p0.pinned) then
      s.p0.x = s.p0.x - offset_x
      s.p0.y = s.p0.y - offset_y
    end
    
    if (not s.p1.pinned) then  
      s.p1.x = s.p1.x + offset_x
      s.p1.y = s.p1.y + offset_y
    end
  end
end

function Draw_Points(p_points)
  for i=1,#p_points do
    local r = p_points[i]
    love.graphics.circle("fill", r.x, r.y, 5)
  end
end

function Draw_Sticks(p_sticks)
  for i=1,#p_sticks do
    s = p_sticks[i]
    love.graphics.line(s.p0.x, s.p0.y, s.p1.x, s.p1.y)
  end
end

function Draw_Forms(p_forme)
  love.graphics.setColor(p_forme.color)
  love.graphics.polygon("fill", p_forme.path[1].x, p_forme.path[1].y, p_forme.path[2].x, p_forme.path[2].y, p_forme.path[3].x, p_forme.path[3].y, p_forme.path[4].x, p_forme.path[4].y)
  love.graphics.setColor(1, 1, 1)
end

function Draw_Image(p_image)
  local dx = p_image.path[2].x - p_image.path[1].x
  local dy = p_image.path[2].y - p_image.path[1].y
  local angle = math.atan2(dy, dx)
  love.graphics.draw(p_image.img, p_image.path[1].x, p_image.path[1].y, angle)
end

function Draw_Engine(p_engine)
  love.graphics.arc("line", p_engine.base_x, p_engine.base_y, p_engine.range, 0, math.pi*2)
  love.graphics.arc("line", p_engine.x, p_engine.y, 5, 0, math.pi*2)
end

function Physics_World(p_engine, p_points, p_sticks, p_sprite)
  local display_points = true
  local display_sticks = true
  local display_forme = true
  local display_engine = true
  local display_img = true
  
  local bounce = 0.9
  local gravity = 0.5
  local friction = 0.999
  local speed = 0.1
  local angle = 0
  local forme = {
    path = {p_points[1], p_points[2], p_points[3], p_points[4]},
    color = {0, 1, 0}
  }
  local image = {
    path = {p_points[1], p_points[2], p_points[3], p_points[4]},
    img = p_sprite.img
  }
  local ghost = {}
  ghost.Update = function(dt)
    Update_Engine(dt, p_engine)
    Update_Points(dt, p_points, friction, gravity)
    for i=1,5 do
      Constrain_Points(p_points, bounce, friction)
      Update_Sticks(dt, p_sticks)
    end
    Update_Img(p_sprite, p_points)
  end
  ghost.Draw = function()
    if display_points then
      Draw_Points(p_points)
    end
    if display_sticks then
      Draw_Sticks(p_sticks)
    end
    if display_engine then
      Draw_Engine(p_engine)
    end
    if display_forme then
      Draw_Forms(forme)
    end
    if display_img then
      Draw_Image(image)
    end
    
    love.graphics.print("display points on/off: p", 5, 5)
    love.graphics.print("display sticks on/off: s", 5, 5+16)
    love.graphics.print("display engine on/off: e", 5, 5+16*2)
    love.graphics.print("display forme on/off: f", 5, 5+16*3)
    love.graphics.print("display img on/off: i", 5, 5+16*4)
  end
  ghost.Keypressed = function(key)
    if key == "p" then
      display_points = not display_points
    elseif key == "s" then
      display_sticks = not display_sticks
    elseif key == "e" then
      display_engine = not display_engine
    elseif key == "f" then
      display_forme = not display_forme
    elseif key == "i" then
      display_img = not display_img
    end
  end
  return ghost
end