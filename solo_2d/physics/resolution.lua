--[[
  Force un cercle à rester dans les limites d'un rectangle.
]]
function Clamp_Circle_Inside_Rect(k1, k2, pRond, pRect)
  pRond.x = Clamp(k1, pRect.x+pRond.r, pRect.x+pRect.w-pRond.r)
  pRond.y = Clamp(k2, pRect.y+pRond.r, pRect.y+pRect.h-pRond.r)
end

--[[
  Force un cercle -ou un rectangle- à rebondir contre les paroies de la fenêtre.
]]
function Bounce_Circle(p_entity, rebunding)
  if p_entity.position.x + p_entity.rayon >= largeur then
    p_entity.position.Set_X(largeur-p_entity.rayon)
    p_entity.velocite.Set_X(p_entity.velocite.Get_X()*rebunding)
  elseif p_entity.position.x - p_entity.rayon <= 0 then
    p_entity.position.Set_X(p_entity.rayon)
    p_entity.velocite.Set_X(p_entity.velocite.Get_X()*rebunding)
  end
  if p_entity.position.y + p_entity.rayon >= hauteur then
    p_entity.position.Set_Y(hauteur-p_entity.rayon)
    p_entity.velocite.Set_Y(p_entity.velocite.Get_Y()*rebunding)
  elseif p_entity.position.y - p_entity.rayon <= 0 then
    p_entity.position.Set_Y(p_entity.rayon)
    p_entity.velocite.Set_Y(p_entity.velocite.Get_Y()*rebunding)
  end
end
--
function Bounce_Rect(p_entity, rebunding)
  if p_entity.position.x + p_entity.size.x >= largeur then
    p_entity.position.Set_X(largeur-p_entity.size.x)
    p_entity.velocite.Set_X(p_entity.velocite.Get_X()*rebunding)
  elseif p_entity.position.x - p_entity.size.x <= 0 then
    p_entity.position.Set_X(p_entity.size.x)
    p_entity.velocite.Set_X(p_entity.velocite.Get_X()*rebunding)
  end
  if p_entity.position.y + p_entity.size.y >= hauteur then
    p_entity.position.Set_Y(hauteur-p_entity.size.y)
    p_entity.velocite.Set_Y(p_entity.velocite.Get_Y()*rebunding)
  elseif p_entity.position.y - p_entity.size.y <= 0 then
    p_entity.position.Set_Y(p_entity.size.y)
    p_entity.velocite.Set_Y(p_entity.velocite.Get_Y()*rebunding)
  end
end

--[[
  Inverse la vélocité d'une particule quand elle touche les bords de la fenêtre.
]]
function Check_Edges(p)
  if p.position.Get_X()+p.rayon > largeur then
    p.position.Set_X(largeur-p.rayon)
    p.velocite.Set_X(p.velocite.Get_X()*-0.95)
  end
  if p.position.Get_X()-p.rayon < 0 then
    p.position.Set_X(p.rayon)
    p.velocite.Set_X(p.velocite.Get_X()*-0.95)
  end
  if p.position.Get_Y()+p.rayon > hauteur then
    p.position.Set_Y(hauteur-p.rayon)
    p.velocite.Set_Y(p.velocite.Get_Y()*-0.95)
  end
end

--[[
  Crée un polygone dont les sommets sont reliés par des élastiques. Ne pas dépasser trois côtés ça crée des figures biscornues.
]]
function Create_A_Poly_Spring(nb_springs, x, y, p_rayon, p_speed, p_direction, p_gravite, p_friction, p_k, p_separation)
  local springs = {}
  for i=1, nb_springs do
    p = Particule(x, y, 0, 0, p_rayon, 0, 0, 0, 0, p_speed, p_direction, p_gravite)
    p.friction = p_friction
    table.insert(springs, p)
  end
  local ghost = {}
  ghost.New_Spring_Pos = function(mx, my)
    for i=1,#springs do
      springs[i].position.Set_X(mx)
      springs[i].position.Set_Y(my)
    end
  end
  ghost.Update = function(dt)
    for i=1,#springs do
      if springs[i+1] ~= nil then
        Spring(springs[i], springs[i+1], p_separation, p_k)
      else
        Spring(springs[i], springs[1], p_separation, p_k)
      end
      Check_Edges(springs[i])
      springs[i].Update(dt)
    end
  end
  ghost.Draw = function()
    for i=1,#springs do
      love.graphics.circle("fill", springs[i].position.Get_X(), springs[i].position.Get_Y(), springs[i].rayon)
      love.graphics.setColor(1, 0, 0)
      love.graphics.print(tostring(i), springs[i].position.Get_X(), springs[i].position.Get_Y())
      love.graphics.setColor(1, 1, 1)
      
      if springs[i+1] ~= nil then
        love.graphics.line(springs[i].position.Get_X(), springs[i].position.Get_Y(), springs[i+1].position.Get_X(), springs[i+1].position.Get_Y())
      else
        love.graphics.line(springs[i].position.Get_X(), springs[i].position.Get_Y(), springs[1].position.Get_X(), springs[1].position.Get_Y())
      end
    end
  end
  return ghost
end

--[[
  Affiche un cercle sur le point d'intersection entre deux lignes.
]]
function Draw_Circle_On_Intersection_Point(p0, p1, p2, p3, ptable, segment_a, segment_b)
  local intersect = Line_Intersect(p0, p1, p2, p3, segment_a, segment_b)
  local click_point = {}
  local ghost = {}
  ghost.Update = function(dt)
    intersect = Line_Intersect(p0, p1, p2, p3, segment_a, segment_b)
    mouse_x, mouse_y = love.mouse.getPosition()
    if love.mouse.isDown(1) then
      click_point = Get_Clicked_Point(mouse_x, mouse_y, ptable)
      if click_point then
        click_point.x = mouse_x
        click_point.y = mouse_y
      end
    end
  end
  ghost.Draw = function(p_rayon)
    love.graphics.line(p0.x, p0.y, p1.x, p1.y)
    love.graphics.line(p2.x, p2.y, p3.x, p3.y)
    
    Draw_Points(p0, p_rayon)
    Draw_Points(p1, p_rayon)
    Draw_Points(p2, p_rayon)
    Draw_Points(p3, p_rayon)
    
    if intersect ~= false then
      love.graphics.circle("line", intersect.x, intersect.y, 15)
    end
  end
  return ghost
end

--[[
  Stop une particule si elle franchi une ligne.
]]
function Throw_Particule(ptable)
  local particule = {}
  particule.x = largeur/2
  particule.y = hauteur/2
  particule.vx = RND()*10-5
  particule.vy = RND()*10-5
  
  local touch = false
  local r0 = {x=particule.x, y=particule.y}
  local contact = {}
  local ghost = {}
  ghost.Update = function(dt)
    r0 = {x=particule.x, y=particule.y}
    particule.x = particule.x + particule.vx
    particule.y = particule.y + particule.vy
    r1 = {x=particule.x, y=particule.y}
    
    for i=1,#ptable do
      r2 = ptable[i].p0
      r3 = ptable[i].p1
      intersect = Line_Intersect(r0, r1, r2, r3, true, true)
      if intersect then
        particule.vx = 0
        particule.vy = 0
        touch = true
        local boum = {intersect.x, intersect.y}
        table.insert(contact, boum)
      end
    end
  end
  ghost.Draw = function()
    for i=1,#ptable do
      Draw_Lines(ptable[i].p0, ptable[i].p1)
    end
    love.graphics.rectangle("fill", particule.x-2, particule.y-2, 4, 4)
    if touch then
      love.graphics.setColor(1, 0, 0)
      love.graphics.circle("line", contact[1][1], contact[1][2], 20)
    end
    love.graphics.setColor(1, 1, 1)
  end
  ghost.Keypressed = function(key)
    if key == "space" then
      particule.x = largeur/2
      particule.y = hauteur/2
      particule.vx = RND()*10-5
      particule.vy = RND()*10-5
      touch = false
      contact = {}
    end
  end
  return ghost
end

--[[
  Résolution de collisions entre un cercle et un rectangle.
]]
function Resolve_Circle_Vs_Rect(dt, p_joueur, p_obstacle)
  local guessed_position = p_joueur.position + p_joueur.velocite*dt
  local current_position = p_joueur.position
  local target_position = guessed_position
  local nearest_point = Vector(0, 0)
  nearest_point.x = math.max(p_obstacle.position.x, math.min(guessed_position.x, p_obstacle.position.x+p_obstacle.size.x))
  nearest_point.y = math.max(p_obstacle.position.y, math.min(guessed_position.y, p_obstacle.position.y+p_obstacle.size.y))
  local ray_to_nearest = nearest_point - guessed_position
  local magnitude = ray_to_nearest.Get_Norme()
  local overlap = p_joueur.rayon-magnitude
  if type(overlap) ~= "number" then
    overlap = 0
  end
  if overlap > 0 then
    ray_to_nearest.normalize()
    guessed_position = guessed_position - ray_to_nearest*overlap
  end
  p_joueur.position = guessed_position
end

--[[
  Résout les collisions entre deux rectangles (pas tout à fait au point).
]]
function Resolve_Rect_Vs_Rect(player, obstacle)
  local ex = {}
  ex.pos = obstacle.position - player.size/2
  ex.size = obstacle.position + player.size
  local expanded_target = Create_Rect(ex.pos.x, ex.pos.y, ex.size.x, ex.size.y, false)
  
  local origin_x = player.position.x + player.size.x/2
  local origin_y = player.position.y + player.size.y/2
  local dir_x = player.position.x+player.size.x/2 + player.velocite.x
  local dir_y = player.position.y+player.size.y/2 + player.velocite.y
  
  local c = Line_Vs_Polygon(obstacle.verticies, origin_x, origin_y, dir_x, dir_y, false, false)
  if c then
    local contact_normal = Construct_Normal(player, expanded_target)
    b = Polygon_Vs_Polygon(player.verticies, obstacle.verticies, true, true)
    if b then
      local vel_length = player.velocite.Get_Norme()
      local overlap_length = Vector(c.x, c.y) - (player.position+player.size/2)
      local temps = overlap_length.Get_Norme()/vel_length
      if type(contact_normal) == "table" then
        if contact_normal.y > 0 then player.position.y = obstacle.position.y+obstacle.size.y end
        if contact_normal.x < 0 then player.position.x = obstacle.position.x-player.size.x end
        if contact_normal.y < 0 then player.position.y = obstacle.position.y-player.size.y end
        if contact_normal.x > 0 then player.position.x = obstacle.position.x+obstacle.size.x end
        
        player.velocite.x = player.velocite.x + contact_normal.x * math.abs(player.velocite.x) * (1-temps)
        player.velocite.y = player.velocite.y + contact_normal.y * math.abs(player.velocite.y) * (1-temps)
      end
    end
  end
end