function Draw_Circle(ptype, x, y, rayon)
  love.graphics.circle(ptype, x, y, rayon)
end

function Swap(a, b)
  local temp = a
  a = b
  b= temp
  return a, b
end

function Copie_Table(pTable)
  local new_table = {}
  for i=1,#pTable do
    table.insert(new_table, pTable[i])
  end
  return new_table
end

function Table_Min_Value(pTable)
  local copie = Copie_Table(pTable)
  table.sort(copie)
  local minimum = copie[1]
  return minimum
end

function Table_Max_Value(pTable)
  local copie = Copie_Table(pTable)
  table.sort(copie)
  local maximum = copie[#copie]
  return maximum
end

function Include_Points_In_Table(p1, p2, p3, ...)
  local liste_acceuil = {p1, p2, p3, ...}
  local liste_retour = {}
  for i=1,#liste_acceuil do
    table.insert(liste_retour, liste_acceuil[i].x)
    table.insert(liste_retour, liste_acceuil[i].y)
  end
  return liste_retour
end

function Create_1D_Table(p_table)
  local new_tab = {}
  for i=1,#p_table do
    table.insert(new_tab, p_table[i].x)
    table.insert(new_tab, p_table[i].y)
  end
  return new_tab
end

function Make_2D_Mountains(pTable, pRange_X, pRange_Y, pK_Range_Y, pOffset_Y)
  local mini = Table_Min_Value(pTable)
  local maxi = Table_Max_Value(pTable)
  local p = {}
  local p2 = {}
  for i=1,#pTable do
    sections = {}
    sections.norm_value = Norm_Number(pTable[i], mini, maxi)
    sections.x = (pRange_X/(#pTable-1))*(i-1)
    sections.y = ((pRange_Y/pK_Range_Y)-((pRange_Y/pK_Range_Y)*sections.norm_value)) + pOffset_Y
    table.insert(p2, sections)
  end
  -- Fonctions d'affichage du terrain. Pour dessiner les lignes et remplir le bas du terrain, on part
  -- du point qui correspond au tour de boucle en cour et on trace jusqu'au suivant. Il faut donc arrêter
  -- la boucle une itération avant le nombre d'élément dans la table pour éviter d'aller chercher un 
  -- point qui n'existe pas. Pour les polygones, il faut dessiner les points dans le sens des aiguilles
  -- montres pour qu'ils soient reliés à la suite.
  p.Draw_Lines = function()
    for i=1,#p2-1 do
      love.graphics.line(p2[i].x, p2[i].y, p2[i+1].x, p2[i+1].y)
    end
  end
  p.Draw_Points = function()
    for i=1,#p2 do
      love.graphics.setPointSize(3)
      love.graphics.setColor(1, 0, 0)
      love.graphics.points(p2[i].x, p2[i].y)
      love.graphics.setColor(1, 1, 1)
    end
  end
  p.Draw_Terrain = function(height)
    for i=1,#p2-1 do
      love.graphics.setColor(0, 1, 0)
      love.graphics.polygon("fill", p2[i].x, p2[i].y, p2[i+1].x, p2[i+1].y, p2[i+1].x, height, p2[i].x, height)
      love.graphics.setColor(1, 1, 1)
    end
  end
  
  return p
end

function Point_Grossissant(pMin_X, pMin_Y, pMax_X, pMax_Y, pMin_Radius, pMax_Radius, pMax_Time)
  local settings = {}
  settings.x = pMin_X
  settings.y = pMin_Y
  settings.r = pMin_Radius
  settings.g_alppha = 0
  settings.min_alppha = 0
  settings.max_alppha = 1
  settings.t = 0
  local p = {}
  p.Update = function(dt)
    settings.g_alpha = Lerp(settings.t, settings.min_alpha, settings.max_alpha)
    settings.x = Lerp(settings.t, pMin_X, pMax_X)
    settings.y = Lerp(settings.t, pMin_Y, pMax_Y)
    settings.r = Lerp(settings.t, pMin_Radius, pMax_Radius)
    settings.t = settings.t+0.01
    if settings.t >= pMax_Time then
      settings.t = 0
    end
  end
  p.Draw = function()
    love.graphics.setColor(1, 1, 1, settings.g_alpha)
    love.graphics.circle("fill", settings.x, settings.y, settings.r)
    love.graphics.setColor(1, 1, 1, 1)
  end
end



-- Algorithme de tri à bulles.
function Bubble_Sort(p_array)
  loop = #p_array
  for i=1,loop-1 do
    for j=1,loop-1 do
      if p_array[j] > p_array[j+1] then
        p_array[j], p_array[j+1] = Swap(p_array[j], p_array[j+1])
      end
    end
  end
  wesh = {}
  wesh.affiche = function()
    for i=1, loop do
      print(p_array[i])
    end
  end
  return wesh
end

function Draw_Bell_Curve()
  results = {}
  for i=0, 100 do
    results[i] = 0
  end
  local ghost = {}
  ghost.Add_Result = function()
    local iterations = 3
    local total = 0
    for i = 0, iterations-1 do
      total = total + Random_Range(0, 100)
    end
    result = math.floor(total/iterations)
    results[result] = results[result]+1
  end

  ghost.Draw_Curve = function()
    w = largeur/100
    for i=1, 100 do
      h = results[i] * -10
      love.graphics.rectangle("fill", w*i, hauteur, w, h)
    end
  end
  return ghost
end

function Create_Mobile(x1, y1, x2, y2, p_k, p_length, p_wx, p_wy, p_rayon, p_speed, p_dir, p_gravite)
  local spring_point_1 = Vector(x1, y1)
  local spring_point_2 = Vector(x2, y2)
  local k = p_k
  local spring_length = p_length
  local weight = Particule(p_wx, p_wy, 0, 0, p_rayon, 0, 0, 0, 0, p_speed, p_dir, p_gravite)
  weight.Add_Spring(spring_point_1, k, spring_length)
  weight.Add_Spring(spring_point_2, k, spring_length)
  local ghost = {}
  ghost.Update = function(dt)
    spring_point_1.x, spring_point_1.y = love.mouse.getPosition()
    weight.Update(dt)
  end
  ghost.Draw = function()
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", weight.position.x, weight.position.y, weight.rayon)
    love.graphics.setColor(0, 1, 0)
    love.graphics.circle("fill", spring_point_2.x, spring_point_2.y, 4)
    love.graphics.setColor(0, 0, 1)
    love.graphics.line(spring_point_2.x, spring_point_2.y, weight.position.x, weight.position.y)
    love.graphics.line(weight.position.x, weight.position.y, spring_point_1.x, spring_point_1.y)
    love.graphics.setColor(1, 1, 1)
  end
  return ghost
end

function White_Noise_TV(px, py, pmax_r, p_nombre)
  local white_point = {}
  local nb_white_point = p_nombre
  for i=1,nb_white_point do
    local p = {}
    p.rayon = math.sqrt(love.math.random()) * pmax_r
    local angle = Random_Range(0, math.pi*2)
    p.x = px + math.cos(angle) * p.rayon
    p.y = py + math.sin(angle) * p.rayon
    table.insert(white_point, p)
  end
  local ghost = {}
  ghost.Update = function(dt)
    for i=1,#white_point do
      local p = white_point[i]
      p.rayon = math.sqrt(love.math.random()) * pmax_r
      angle = Random_Range(0, math.pi*2)
      p.x = px + math.cos(angle) * p.rayon
      p.y = py + math.sin(angle) * p.rayon
    end
  end
  ghost.Draw = function()
    for i=1,#white_point do
      local p = white_point[i]
      love.graphics.circle("fill", p.x, p.y, 1)
    end
  end
  return ghost
end

function Display_Points_On_Circle(nb_points, px, py, p_rayon_cercle, p_rayon_particule)
  local rond = {}
  for i=1,nb_points do
    local p = {}
    p.angle = math.pi*2 / nb_points*i
    p.x = px + math.cos(p.angle) * p_rayon_cercle
    p.y = py + math.sin(p.angle) * p_rayon_cercle
    table.insert(rond, p)
  end
  local ghost = {}
  ghost.Draw = function()
    for i=1,#rond do
      local p = rond[i]
      love.graphics.circle("fill", p.x, p.y, p_rayon_particule)
    end
  end
  return ghost
end



function Indique_Point(p, texte, offset_x, offset_y)
  love.graphics.print(texte..": "..tostring(math.floor(p.x))..", "..tostring(math.floor(p.y)), p.x+offset_x, p.y+offset_y)
end

-- Affiche le contenu d'une variable à l'écran.
function Affiche_Variable(texte, v, x, y)
  love.graphics.print(texte..": "..tostring(v), x, y)
end

function Draw_Points(p, rayon)
  love.graphics.circle("fill", p.x, p.y, rayon)
end

-- Fonction qui dessine une ligne.
function Draw_Lines(p1, p2)
  love.graphics.line(p1.x, p1.y, p2.x, p2.y)
end

-- Fonction qui dessine une courbe de bézier.
function Render_Bezier(curve)
  love.graphics.line(curve:render())
end

function RND()
  return love.math.random()
end

function Get_Clicked_Point(px, py, ptable)
  for i=1,#ptable do
    local r = ptable[i]
    local dx = r.x - px
    local dy = r.y - py
    local dist = math.sqrt(dx*dx + dy*dy)
    if dist < 10 then
      return r
    end
  end
end

function Cree_Etoile(px, py, r, nb_points)
  local x = px
  local y = py
  local angle = 0
  local p = {}
  for i=1,nb_points do
    angle = (math.pi*2*i) / nb_points
    local t = {}
    if i%2 == 0 then
      t.x =  r * math.cos(angle)
      t.y =  r * math.sin(angle)
    else
      t.x =  (r/2) * math.cos(angle)
      t.y =  (r/2) * math.sin(angle)
    end
    table.insert(p, t)
  end
  local p_offset = {}
  for i=1,nb_points do
    local offset = {}
    offset.x = 0
    offset.y = 0
    table.insert(p_offset, offset)
  end
  local ghost = {}
  ghost.Update = function(dt, player)
    mouse_x, mouse_y = love.mouse.getPosition()
    if player then
      x = mouse_x
      y = mouse_y
    else
      x = px
      y = py
    end
    for i=1,#p do
      p_offset[i].x = p[i].x + x
      p_offset[i].y = p[i].y + y
    end
  end
  ghost.Draw = function()
    love.graphics.circle("fill", x, y, 5)
    for i=1,#p do
      love.graphics.circle("fill", p_offset[i].x, p_offset[i].y, 5)
      if i == #p then
        love.graphics.line(p_offset[i].x, p_offset[i].y, p_offset[1].x, p_offset[1].y)
      else
        love.graphics.line(p_offset[i].x, p_offset[i].y, p_offset[i+1].x, p_offset[i+1].y)
      end
    end
  end
  ghost.Points = function()
    return p_offset
  end
  return ghost
end

function Create_Rect(x, y, w, h, dir)
  local ghost = {}
  ghost.position = Vector(x, y)
  ghost.size = Vector(w, h)
  ghost.velocite = Vector(0, 0)
  
  ghost.haut = {x1=ghost.position.x, y1=ghost.position.y, x2=ghost.position.x+ghost.size.x, y2=ghost.position.y}
  ghost.droite = {x1=ghost.position.x+ghost.size.x, y1=ghost.position.y, x2=ghost.position.x+ghost.size.x, y2=ghost.position.y+ghost.size.y}
  ghost.bas = {x1=ghost.position.x, y1=ghost.position.y+ghost.size.y, x2=ghost.position.x+ghost.size.x, y2=ghost.position.y+ghost.size.y}
  ghost.gauche = {x1=ghost.position.x, y1=ghost.position.y, x2=ghost.position.x, y2=ghost.position.y+ghost.size.y}
  
  if dir then
    ghost.direction = {x1=ghost.position.x+ghost.size.x/2, y1=ghost.position.y+ghost.size.y/2, x2=ghost.position.x+ghost.size.x/2+ghost.velocite.x, y2=ghost.position.y+ghost.size.y+ghost.velocite.y}
  end
  
  ghost.verticies = {}
  ghost.verticies[1] = Vector(ghost.position.x, ghost.position.y)
  ghost.verticies[2] = Vector(ghost.position.x+ghost.size.x, ghost.position.y)
  ghost.verticies[3] = Vector(ghost.position.x+ghost.size.x, ghost.position.y+ghost.size.y)
  ghost.verticies[4] = Vector(ghost.position.x, ghost.position.y+ghost.size.y)
  ------------------------------------------------------------------------------------------------------
  ghost.Update = function(dt)
    ghost.haut = {x1=ghost.position.x, y1=ghost.position.y, x2=ghost.position.x+ghost.size.x, y2=ghost.position.y}
    ghost.droite = {x1=ghost.position.x+ghost.size.x, y1=ghost.position.y, x2=ghost.position.x+ghost.size.x, y2=ghost.position.y+ghost.size.y}
    ghost.bas = {x1=ghost.position.x, y1=ghost.position.y+ghost.size.y, x2=ghost.position.x+ghost.size.x, y2=ghost.position.y+ghost.size.y}
    ghost.gauche = {x1=ghost.position.x, y1=ghost.position.y, x2=ghost.position.x, y2=ghost.position.y+ghost.size.y}
    if dir then
      ghost.direction = {x1=ghost.position.x+ghost.size.x/2, y1=ghost.position.y+ghost.size.y/2, x2=ghost.position.x+ghost.size.x/2+ghost.velocite.x, y2=ghost.position.y+ghost.size.y/2+ghost.velocite.y}
    end
    ghost.verticies[1] = Vector(ghost.position.x, ghost.position.y)
    ghost.verticies[2] = Vector(ghost.position.x+ghost.size.x, ghost.position.y)
    ghost.verticies[3] = Vector(ghost.position.x+ghost.size.x, ghost.position.y+ghost.size.y)
    ghost.verticies[4] = Vector(ghost.position.x, ghost.position.y+ghost.size.y)
  end
  -------------------------------------------------------------------------------------------------------
  ghost.Draw = function()
    love.graphics.line(ghost.haut.x1, ghost.haut.y1, ghost.haut.x2, ghost.haut.y2)
    love.graphics.line(ghost.droite.x1, ghost.droite.y1, ghost.droite.x2, ghost.droite.y2)
    love.graphics.line(ghost.bas.x1, ghost.bas.y1, ghost.bas.x2, ghost.bas.y2)
    love.graphics.line(ghost.gauche.x1, ghost.gauche.y1, ghost.gauche.x2, ghost.gauche.y2)
    if dir then
      love.graphics.setColor(1, 0, 0)
      love.graphics.line(ghost.direction.x1, ghost.direction.y1, ghost.direction.x2, ghost.direction.y2)
      love.graphics.setColor(1, 1, 1)
    end
  end
  return ghost
end




function Set_Target(p_table)
  p_table.x = Random_Range(200, largeur)
  p_table.y = hauteur
  p_table.rayon = Random_Range(10, 40)
end

-- Fonction qui gère les forces à appliquer à un boulet au moment du tir.
function Shoot(p_value, p_munition, p_canon)
  local force = Map(p_value, -1, 1, 2, 20)
  p_munition.position.x = p_canon.x + math.cos(p_canon.angle)*40
  p_munition.position.y = p_canon.y + math.sin(p_canon.angle)*40
  p_munition.Set_Speed(force)
  p_munition.Set_Heading(p_canon.angle)
end

-- Fonction qui permet de diriger le canon.
function Aim_Gun(p_mouse_x, p_mouse_y, p_canon)
  p_canon.angle = Clamp(math.atan2(p_mouse_y-p_canon.y, p_mouse_x-p_canon.x), -math.pi/2, -0.3)
end

-- Fonction qui vérifie si un boulet entre en collision avec la cible.
function Check_Target(p_mun, p_table)
  if Circle_Collision(p_mun.position.x, p_mun.position.y, p_table.x, p_table.y, p_mun.rayon, p_table.rayon) then
    Set_Target(p_table)
  end
end

-- Objet qui crée un tout petit jeu qui consiste à tirer dans une cible.
function Shoot_Game(gx, gy, g_angle, g_img, p_rayon, p_speed, p_gravite)
  local gun = {}
  gun.x = gx
  gun.y = gy
  gun.angle = g_angle
  gun.img = g_img
  function Load_Gun()
    love.graphics.setCanvas(gun.img)
    love.graphics.rectangle("fill", 0, 0, gun.img:getWidth(), gun.img:getHeight())
    love.graphics.setCanvas()
  end
  local cannonball = Particule(gun.x, gun.y, 0, 0, p_rayon, 0, 0, 0, 0, p_speed, gun.angle, p_gravite)
  local is_shooting = false
  local force_angle = 0
  local force_speed = 0.1
  local raw_force = 0
  local target = {}
  target.x = Random_Range(200, largeur)
  target.y = hauteur
  target.rayon = Random_Range(10, 40)
  
  local ghost = {}
  ghost.Init = function()
    Set_Target(target)
    Load_Gun()
  end
  ghost.Update = function(dt)
    if is_shooting == false then
      force_angle = force_angle + force_speed
    end
    
    raw_force = math.sin(force_angle)
    if is_shooting then
      cannonball.Update(dt)
      Check_Target(cannonball, target)
    end
    
    if cannonball.position.y+cannonball.rayon > hauteur then
      is_shooting = false
    end
  end
  ghost.Draw = function()
    love.graphics.rectangle("fill", 10, hauteur-10, 20, -100)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", 10, hauteur-10, 20, Map(raw_force, -1, 1, 0, -100))
    love.graphics.setColor(1, 1, 1)
    
    love.graphics.circle("fill", gun.x, gun.y, 24)
    love.graphics.draw(gun.img, gun.x, gun.y-8, gun.angle)
    love.graphics.circle("fill", cannonball.position.x, cannonball.position.y, cannonball.rayon)
    
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("line", target.x, target.y, target.rayon)
    love.graphics.setColor(1, 1, 1)
  end
  ghost.Fire = function(p_key)
    if p_key == "space" then
      if is_shooting == false then
        Shoot(raw_force, cannonball, gun)
        is_shooting = true
      end
    end
  end
  ghost.Move_Canon = function(px, py, p_button)
    if p_button == 1 then
      Aim_Gun(px, py, gun)
    end
  end
  return ghost
end