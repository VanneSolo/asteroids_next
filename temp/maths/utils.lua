require "maths"

-- Crée une tuile carrée.
function Cree_Tuile(pI, pJ, pT_Size, pAlpha)
  local tuile = {}
  tuile.x = (pJ-1)*pT_Size
  tuile.y = (pI-1)*pT_Size
  tuile.alpha = pAlpha
  return tuile
end

-- Fonction qui permet de créer une grille de tuiles. On défini d'abord une
-- table vide. Pour chaque ligne, on crée une nouvelle table vide. Dans une
-- seconde boucle, pour chaque colonne, on crée une tuile.
function Tile_Map(pLignes, pColonne, pTile_Size)
  local map = {}
  for i=1,pLignes do
    local ligne = {}
    table.insert(map, ligne)
    for j=1,pColonne do
      local tile = Cree_Tuile(i, j, pTile_Size, love.math.random()-0.5)
      table.insert(map[i], tile)
    end
  end
  -- Affichage de la grille. On place la fonction dans une nouvelle table (ici m)
  -- que l'on retourne ensuite pour qu'elle soit accessible à partir de la variable
  -- qui aura servi à appeler la fonction Tile_Map.
  local m = {}
  m.Draw = function()
    for i=1,pLignes do
      for j=1,pColonne do
        love.graphics.setColor(1, 0, 0, map[i][j].alpha)
        love.graphics.rectangle("fill", map[i][j].x, map[i][j].y, pTile_Size, pTile_Size)
      end
    end
    love.graphics.setColor(1, 1, 1, 1)
  end
  return m
end

-- Renvoie une table clonée. On passe une table en paramètre puis on renvoie une nouvelle
-- table créée localement dans laquelle on a copié un à un tous les éléments de la première
-- table.
function Copie_Table(pTable)
  local new_table = {}
  for i=1,#pTable do
    table.insert(new_table, pTable[i])
  end
  return new_table
end

-- Renvoie la plus petite ou la plus grande valeur d'un tableau. Dans chaque cas on copie
-- d'abord la table sur laquelle on veut travailler pour ne pas la modifier. Ensuite on trie
-- la table dans l'ordre croissant. Pour récupérer le plus petit élément on retourne la
-- première valeur de la table copiée, pour récupérer le plus grand élément on retourne la
-- dernière valeur de la table copiée.
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

-- Crée une forme de terrain montagneux vue de profil. La fonction prend cinq paramètres:
-- Une table de nompbres qui seront ramenés à des valeurs entre 0 et la hauteur de l'écran.
-- Une longueur x et une longueur y pour définir sur quelle longueur et quelle hauteur le
-- terrain va être créer.
-- Un coefficient y pour éventuellement réduire l'échelle du terrain verticalement.
-- Un offset y pour décaler l'origine en y du terrain.
-- On commence par récupérer la plus grande et la plus petite des valeurs de la table dans
-- deux variables. Ensuite on crée deux tables (ici p et p2). La première contiendra les
-- fonctions qui permettront de dessiner le terrain. La seconde est remplie par une boucle 
-- qui pour chaque valeur de la table de départ crée une nouvelle table qui contient les valeurs
-- x et y de chaque point du terrain.
-- Pour obtenir la coordonnée x des points, on divise le range_x par le nombre d'éléments dans la
-- table puis on multiplie le résultat par le tour de boucle en cours. On soustrait 1 au nombre
-- d'éléments dans la table et à l'indice de tour de boucle en cours pour bien caler le terrain
-- sur les extrémités du range_x.
-- Pour la coordonnée y, on normalise chaque valeur sur la hauteur de l'écran. On multiplie cette 
-- valeur par range_y (ici la hauteur de l'écran) et on soustrait cette nouvelle valeur du range_y.
-- On peut diviser le range_y par un coefficient pour réduire léchelle verticale du terrain et 
-- ajouter un offset_y opur décaler l'affichage du terrain verticalement.
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

-- Dessine un point qui devient de plus en plus gros et opaque au fil du temps et qui respawn
-- quand il temps atteint une certaine valeur.
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

-- Fonction qui permet d'empêcher un cercle de sortir d'un rectangle.
function Clamp_Circle_Inside_Rect(k1, k2, pRond, pRect)
  pRond.x = Clamp(k1, pRect.x+pRond.r, pRect.x+pRect.w-pRond.r)
  pRond.y = Clamp(k2, pRect.y+pRond.r, pRect.y+pRect.h-pRond.r)
end

-- Applique un mouvement de va-et-vient.
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

-- Echange les valeurs entre deux variables.
function Swap(a, b)
  local temp = a
  a = b
  b= temp
  return a, b
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

-- Fait rebondir un cercle contre les bords de l'écran.
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

-- Si un cercle sort par un bord de l'écran, il réapparait par le bord opposé.
function Regen_Circle(p_entity)
  if p_entity.position.x >= largeur + p_entity.rayon then
    p_entity.position.Set_X(-p_entity.rayon)
  elseif p_entity.position.x <= -p_entity.rayon then
    p_entity.position.Set_X(largeur + p_entity.rayon)
  end
  if p_entity.position.y >= hauteur + p_entity.rayon then
    p_entity.position.Set_Y(-p_entity.rayon)
  elseif p_entity.position.y <=  - p_entity.rayon then
    p_entity.position.Set_Y(hauteur + p_entity.rayon)
  end
end

-- Fait rebondir un rectangle sur les bords de l'écran.
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

-- Si un rectangle sort par un bord de l'écran, il réapparait par l'autre bord.
function Regen_Rect(p_entity)
  if p_entity.position.x >= largeur + p_entity.size.x then
    p_entity.position.Set_X(-p_entity.size.x)
  elseif p_entity.position.x <= -p_entity.size.x then
    p_entity.position.Set_X(largeur + p_entity.size.x)
  end
  if p_entity.position.y >= hauteur + p_entity.size.y then
    p_entity.position.Set_Y(-p_entity.size.y)
  elseif p_entity.position.y <=  - p_entity.size.y then
    p_entity.position.Set_Y(hauteur + p_entity.size.y)
  end
end

-- Bouge le sprite du joueur.
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

-- Fonction qui dessine progressivement un graphique en 
-- forme de cloche.
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

-- Dessine une grille à base de lignes et snappe un cercle sur
-- l'intersection la plus proche du cirseur.
function Snap_Cursor_On_Grid(px, py)
  local ghost = {}
  ghost.Update_Cursor_Pos = function()
    px, py = love.mouse.getPosition()
    x = Round_Nearest(px, grid_size)
    y = Round_Nearest(py, grid_size)
    return x, y
  end
  ghost.Draw_Grid_With_Lines = function(limite_boucle_1, limite_boucle_2, pas)
    for i=1, limite_boucle_1, pas do
      love.graphics.line(i, 0, i, limite_boucle_2)
    end
    for j=1, limite_boucle_2, pas do
      love.graphics.line(0, j, limite_boucle_1, j)
    end
  end
  return ghost
end

-- Lie deux points par une force élastique.
function Create_Spring(p_ancre_x, p_ancre_y, p_weight_x, p_weight_y, p_weight_rayon, p_weight_speed, p_weight_direction, k, p_weight_friction)
  local spring_p = Vector(p_ancre_x, p_ancre_y)
  local weight = Particule(p_weight_x, p_weight_y, 0, 0, p_weight_rayon, 0, 0, 0, 0, p_weight_speed, p_weight_direction, 0)
  weight.friction = p_weight_friction
  local ghost = {}
  ghost.New_Spring_Pos = function(mx, my)
    spring_p.Set_X(mx)
    spring_p.Set_Y(my)
  end
  ghost.Update = function(dt)
    local dist = spring_p - weight.position
    local spring_f = dist*k
    weight.velocite.Add_To(spring_f)
    weight.Update(dt)
  end
  ghost.Draw = function()
    love.graphics.circle("fill", weight.position.Get_X(), weight.position.Get_Y(), weight.rayon)
    love.graphics.circle("fill", spring_p.Get_X(), spring_p.Get_Y(), 10)
    love.graphics.line(weight.position.Get_X(), weight.position.Get_Y(), spring_p.Get_X(), spring_p.Get_Y())
  end
  return ghost
end

-- Crée une force élastique entre deux particuless.
function Spring_Force(p1, p2, p_separation, p_k)
  local dist = p1.position - p2.position
  dist.Set_Norme(dist.Get_Norme()-p_separation)
  local spring_force = dist * p_k
  p2.velocite.Add_To(spring_force)
  p1.velocite.Subtract_To(spring_force)
end

-- Vérifie qu'une particule ne sorte pas des limites de l'écran
-- et la remet dans le droit chemin sinon.
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

-- Crée un polygone dont les sommets sont reliés par des élastiques. Ne pas dépasser trois côtés,
-- ça crée des figures biscornues.
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

-- Crée un poids relié à deux ancres par des élastiques. L'une des ancres est crée aléatoirement
-- dans la fenêtre, l'autre suit le curseur de la souris.
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

-- Fonction qui contient les caractéristiques de la cible.
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

-- Défini certaines caractéristiques d'une particule.
function Set_Flow_Element(p_part)
  p_part.rayon = 7
  p_part.Set_Speed(Random_Range(7, 8))
  p_part.Set_Heading(math.pi/2+Random_Range(-0.1, 0.1))
end

-- Objet qui fait graviter un flot de particules autour d'un ou plusieurs
-- point d'attractions qui sont passés en paramètre de l(objet par
-- l'intermédiaire d'une table.
function Create_Flow(p_table, p_nb, px, py)
  local emitter = {}
  emitter.x = px
  emitter.y = py
  local particules = {}
  local nb_particules = p_nb
  
  for i=1,nb_particules do
    p = Particule(emitter.x, emitter.y, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    Set_Flow_Element(p)
    for i=1,#p_table do
      local s = p_table[i]
      p.Add_Gravitation(s)
    end
    table.insert(particules, p)
  end
  
  local ghost = {}
  ghost.Update = function(dt)
    for i=1,nb_particules do
      local p = particules[i]
      p.Update(dt)
      if p.position.x < 0 or p.position.x > largeur or p.position.y < 0 or p.position.y > hauteur then
        p.position.Set_X(emitter.x)
        p.position.Set_Y(emitter.y)
        Set_Flow_Element(p)
      end
    end
  end
  ghost.Draw = function()
    for i=1,#p_table do
      love.graphics.setColor(1, 1, 0)
      local s = p_table[i]
      love.graphics.circle("fill", s.position.Get_X(), s.position.Get_Y(), s.rayon)
    end
    love.graphics.setColor(1, 1, 1)
    for i=1,nb_particules do
      local p = particules[i]
      love.graphics.circle("fill", p.position.Get_X(), p.position.Get_Y(), p.rayon)
    end
  end
  return ghost
end

-- Crée une sorte de bruit blanc comme des parasites de TV.
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

-- Crée une explosion dont le champ d'occupation des particules est carré.
function Explosion_Carree(nb_parts, etendue)
  particules = {}
  for i=1,nb_parts do
    p = Particule(largeur/2, hauteur/2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    p.velocite.x = Random_Range(-etendue, etendue)
    p.velocite.y = Random_Range(-etendue, etendue)
    table.insert(particules, p)
  end
  local ghost = {}
  ghost.Update = function(dt)
    for i=1, #particules do
      local p = particules[i]
      p.Update(dt)
    end
  end
  ghost.Draw = function()
    for i=1,#particules do
      local p = particules[i]
      love.graphics.circle("fill", p.position.x, p.position.y, 3)
    end
  end
  return ghost
end

-- Dispose des points en cercle.
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

--Crée un point avec ses coordonnées x et y.
function Point(x1, y1)
  local table = {}
  table.x = x1
  table.y = y1
  return table
end

-- Prend des points en entrée et renvoie une table avec les coordonnées
-- de tous les points à la suite.
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

-- Dessine des courbes de bézier.
function Draw_Bezier(p_table_points, p_dir)
  local bezier_curve = love.math.newBezierCurve(p_table_points)
  local time = 0
  local move = p_dir
  local pfinal = {}
  local ghost = {}
  ghost.Update = function(dt, p_type_move)
    if p_type_move == "fixe" then
      time = 1.01
    elseif p_type_move == "restart" then
      time = time + move
      if time >= 1 then
        time = 0
      end
    elseif p_type_move == "va_et_vient" then
      time = time + move
      if time >= 1 or time <= 0 then
        move = -move
      end
    end
  end
  ghost.Draw = function(p_draw_points, color)
    if p_draw_points then
      for i=1,#p_table_points do
        if i % 2 ~= 0 then
          if color then
            if i == 1 then
              love.graphics.setColor(1, 0, 0)
            elseif i == #p_table_points-1 then
              love.graphics.setColor(0, 1, 0)
            else
              love.graphics.setColor(1, 1, 1)
            end
          end
          love.graphics.circle("fill", p_table_points[i], p_table_points[i+1], 5)
          love.graphics.print(tostring((i/2-0.5)+1), p_table_points[i]+25, p_table_points[i+1])
        end
      end
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.line(bezier_curve:render())
    local points = {}
    for i=1,#p_table_points do
      if i % 2 ~= 0 then
        local p = Point(p_table_points[i], p_table_points[i+1])
        table.insert(points, p)
      end
    end
    if #p_table_points/2 == 3 then
      for i=0,time,move do
        Quadratic_Bezier(points[1], points[2], points[3], i, pfinal)
        love.graphics.circle("line", pfinal.x, pfinal.y, 10)
      end
    elseif #p_table_points/2 == 4 then
      for i=0,time,math.abs(move) do
        Cubic_Bezier(points[1], points[2], points[3], points[4], i, pfinal)
        love.graphics.circle("line", pfinal.x, pfinal.y, 10)
      end
    end
  end
  return ghost
end

-- Déplace un point sur une distance.
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

-- Fait se mouvoir un segement par interpolation linéaire
-- avec deux autres segments.
function Lerp_Line(x1, y1, x2, y2, x3, y3)
  local p1 = Point(x1, y1)
  local p2 = Point(x2, y2)
  local p3 = Point(x3, y3)
  local pA = {p1.x, p1.y}
  local pB = {p2.x, p2.y}
  local t = 0
  local ghost = {}
  ghost.Update = function(dt)
    t = t + 0.01
    t = math.min(t, 1)
    pA.x = Lerp(t, p1.x, p2.x)
    pA.y = Lerp(t, p1.y, p2.y)
    pB.x = Lerp(t, p2.x, p3.x)
    pB.y = Lerp(t, p2.y, p3.y)
  end
  ghost.Draw = function()
    love.graphics.circle("fill", p1.x, p1.y, 4)
    love.graphics.circle("fill", p2.x, p2.y, 4)
    love.graphics.circle("fill", p3.x, p3.y, 4)
    love.graphics.circle("fill", pA.x, pA.y, 4)
    love.graphics.circle("fill", pB.x, pB.y, 4)
    love.graphics.line(p1.x, p1.y, p2.x, p2.y)
    love.graphics.line(p2.x, p2.y, p3.x, p3.y)
    love.graphics.line(pA.x, pA.y, pB.x, pB.y)
    
    Indique_Point(p1, "p1", 0, 25)
    Indique_Point(p2, "p2", 0, -25)
    Indique_Point(p3, "p3", -50, 25)
    Indique_Point(pA, "pA", 0, 25)
    Indique_Point(pB, "pB", -50, -25)
    Affiche_Variable("time", t, 5, 5)
  end
  return ghost
end

-- Indique les coordonnées d'un point près de celui-ci.
function Indique_Point(p, texte, offset_x, offset_y)
  love.graphics.print(texte..": "..tostring(math.floor(p.x))..", "..tostring(math.floor(p.y)), p.x+offset_x, p.y+offset_y)
end

-- Affiche le contenu d'une variable à l'écran.
function Affiche_Variable(texte, v, x, y)
  love.graphics.print(texte..": "..tostring(v), x, y)
end

-- Affiche les éléments de construction d'une double courbe de bézier.
function Construct_Bezier(x1, y1, x2, y2, x3, y3, x4, y4)
  local p1 = Point(x1, y1)
  local p2 = Point(x2, y2)
  local p3 = Point(x3, y3)
  local p4 = Point(x4, y4)
  local pA = {p1.x, p1.y}
  local pB = {p2.x, p2.y}
  local pC = {}
  local pM = {}
  local pN = {}
  local pfinal = {}
  local t = 0
  local max_t = 0
  local dir  = 0.01
  local animate = false
  local ghost = {}
  ghost.Start_Demo = function(key)
    if key == "space" then
      if animate == false then
        animate = true
      else
        animate = false
      end
    end
  end
  ghost.Update = function(dt)
    if animate then
      max_t = max_t + dir
      if max_t >= 1 then
        max_t = 1
        dir = dir*-1
      elseif max_t <= 0 then
        max_t = 0
        dir = dir*-1
      end
    end
    for t=0, max_t, 0.01 do
      pA.x = Lerp(t, p1.x, p2.x)
      pA.y = Lerp(t, p1.y, p2.y)
      pB.x = Lerp(t, p2.x, p3.x)
      pB.y = Lerp(t, p2.y, p3.y)
      
      pC.x = Lerp(t, p3.x, p4.x)
      pC.y = Lerp(t, p3.y, p4.y)
      pM.x = Lerp(t, pA.x, pB.x)
      pM.y = Lerp(t, pA.y, pB.y)
      pN.x = Lerp(t, pB.x, pC.x)
      pN.y = Lerp(t, pB.y, pC.y)
      
      pfinal.x = Lerp(t, pM.x, pN.x)
      pfinal.y = Lerp(t, pM.y, pN.y)
    end
  end
  ghost.Draw = function()
    love.graphics.circle("fill", p1.x, p1.y, 4)
    love.graphics.circle("fill", p2.x, p2.y, 4)
    love.graphics.circle("fill", p3.x, p3.y, 4)
    love.graphics.circle("fill", p4.x, p4.y, 4)
    love.graphics.circle("fill", pA.x, pA.y, 4)
    love.graphics.circle("fill", pB.x, pB.y, 4)
    love.graphics.circle("fill", pC.x, pC.y, 4)
    love.graphics.circle("fill", pM.x, pM.y, 4)
    love.graphics.circle("fill", pN.x, pN.y, 4)
    love.graphics.circle("fill", pfinal.x, pfinal.y, 4)
    love.graphics.line(p1.x, p1.y, p2.x, p2.y)
    love.graphics.line(p2.x, p2.y, p3.x, p3.y)
    love.graphics.line(p3.x, p3.y, p4.x, p4.y)
    love.graphics.line(pA.x, pA.y, pB.x, pB.y)
    love.graphics.line(pB.x, pB.y, pC.x, pC.y)
    love.graphics.line(pM.x, pM.y, pN.x, pN.y)
    love.graphics.line(p1.x, p1.y, pfinal.x, pfinal.y)
    
    Indique_Point(p1, "p1", 0, 25)
    Indique_Point(p2, "p2", 0, -25)
    Indique_Point(p3, "p3", -50, 25)
    Indique_Point(p4, "p4", -50, -25)
    Indique_Point(pA, "pA", -100, 10)
    Indique_Point(pB, "pB", -100, 10)
    Affiche_Variable("time", max_t, 5, 5)
    Affiche_Variable("animate", animate, 5, 5+16)
  end
  return ghost
end

-- Fonction qui dessine un point.
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

-- Crée une courbe de bézier qui passe bien par trois point grâce
-- à la présence d'un quatrième point qui sert à diriger la courbe.
function Draw_Bezier_By_CP(x1, y1, x2, y2, x3, y3)
  local p1 = Point(x1, y1)
  local p2 = Point(x2, y2)
  local p3 = Point(x3, y3)
  local cp = {}
  cp.x = p2.x*2 - (p1.x+p3.x)/2
  cp.y = p2.y*2 - (p1.y+p3.y)/2
  local bezier_curve = love.math.newBezierCurve(p1.x, p1.y, cp.x, cp.y, p3.x, p3.y)
  local ghost = {}
  ghost.Draw = function()
    Draw_Points(p1, 3)
    Draw_Points(p2, 3)
    Draw_Points(p3, 3)
    Draw_Points(cp, 3)
    
    Draw_Lines(p1, cp)
    Draw_Lines(cp, p3)
    Render_Bezier(bezier_curve)
  end
  return ghost
end

-- Permet de créer une courbe de bézier avec de multilpes points de contrôle.
function Multicurve(p_table)
  display_points = true
  display_lines = true
  display_bezier = true
  
  local control_points = {}
  for i=2, #p_table-2 do
    local p = {x = (p_table[i].x+p_table[i+1].x)/2, y = (p_table[i].y+p_table[i+1].y)/2}
    table.insert(control_points, p)
  end
  
  local init_curves = {}
  init_curves[1] = love.math.newBezierCurve(p_table[1].x, p_table[1].y, p_table[2].x, p_table[2].y, control_points[1].x, control_points[1].y)
  for i=1,#control_points-1 do
    local curve = love.math.newBezierCurve(control_points[i].x,control_points[i].y,p_table[i+2].x,p_table[i+2].y, control_points[i+1].x, control_points[i+1].y)
    table.insert(init_curves, curve)
  end
  init_curves[#init_curves+1] = love.math.newBezierCurve(control_points[#control_points].x, control_points[#control_points].y, p_table[#p_table-1].x, p_table[#p_table-1].y, p_table[#p_table].x, p_table[#p_table].y)
  
  local ghost = {}
  
  ghost.Draw = function()
    if display_points then
      for i=1,#p_table do
        love.graphics.setColor(0, 0, 1)
        Draw_Points(p_table[i], 3)
        love.graphics.print(i, p_table[i].x+10, p_table[i].y)
      end
      for i=1,#control_points do
        love.graphics.setColor(0, 1, 0)
        Draw_Points(control_points[i], 3)
      end
    end
    love.graphics.setColor(1, 1, 1)
    if display_lines then
      for i=1,#p_table-1 do
        Draw_Lines(p_table[i], p_table[i+1])
      end
    end
    love.graphics.setColor(1, 1, 1)
    if display_bezier then
      for i=1,#init_curves do
        love.graphics.setColor(1, 0, 0)
        love.graphics.line(init_curves[i]:render())
      end
    end
    love.graphics.setColor(1, 1, 1)
  end
  
  ghost.Keys = function(key)
    if key == "kp1" then
      if display_bezier then
        display_bezier = false
      else
        display_bezier = true
      end
    elseif key == "kp2" then
      if display_lines then
        display_lines = false
      else
        display_lines = true
      end
    elseif key == "kp3" then
      if display_points then
        display_points = false
      else
        display_points = true
      end
    end
  end
  
  return ghost
end

-- Génère un nombre aléatoire.
function RND()
  return love.math.random()
end

-- Crée une courbe de bézier sur laquelle on peut influer en temps réel.
function Dragable_Bezier(p_rayon)
  local handle = {}
  for i=1,4 do
    local h = {}
    h.p = Point(largeur*RND(), hauteur*RND())
    h.colored = false
    table.insert(handle, h)
  end
  local handle_r = p_rayon
  local curve = love.math.newBezierCurve(handle[1].p.x, handle[1].p.y, handle[2].p.x, handle[2].p.y, handle[3].p.x, handle[3].p.y, handle[4].p.x, handle[4].p.y)
  local ghost = {}
  ghost.Update = function(dt)
    local mouse_x, mouse_y = love.mouse.getPosition()
    for i=1,#handle do
      local grabbed = handle[i]
      grabbed.colored = false
    end
    
    if love.mouse.isDown(1) then
      for i=1,#handle do
        local grabbed = handle[i]
        if Point_Vs_Circle(mouse_x, mouse_y, grabbed.p.x, grabbed.p.y, handle_r) then
          grabbed.colored = true
          grabbed.p.x = mouse_x
          grabbed.p.y = mouse_y
        end
      end
    end
    
    curve = love.math.newBezierCurve(handle[1].p.x, handle[1].p.y, handle[2].p.x, handle[2].p.y, handle[3].p.x, handle[3].p.y, handle[4].p.x, handle[4].p.y)
  end
  ghost.Draw = function()
    for i=1,#handle do
      local grabbed = handle[i]
      if grabbed.colored then
        love.graphics.setColor(1, 0, 0)
      else
        love.graphics.setColor(1, 1, 1)
      end
      Draw_Points(grabbed.p, handle_r)
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.line(curve:render())
  end
  return ghost
end

-- Fait se déplacer un point vers les coordonnées d'un clic de souris
-- avec un effet de ralentissement vers l'arrivée.
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

-- Fonction qui gère le tween.
function Tween(pEntity, p_Property, p_target, duration, easingFunc)
  local start = p_Property
  local change = p_target - start
  local start_time = love.timer.getTime()
  local ghost = {}
  local time = 0
  ghost.Update = function(dt)
    time = love.timer.getTime() - start_time
    if time < duration then
      p_Property = easingFunc(time, start, change, duration)
    else
      time = duration
      p_Property = easingFunc(time, start, change, duration)
    end
  end
  ghost.Draw = function(ptype)
    if ptype == "trans" then
      pEntity.trans = p_Property
    elseif ptype == "x" then
      pEntity.x = p_Property
    elseif ptype == "y" then
      pEntity.y = p_Property
    end
    
    love.graphics.setColor(1, 1, 1, pEntity.trans)
    love.graphics.circle("fill", pEntity.x, pEntity.y, 20)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("time: "..tostring(time), 5, 5)
    love.graphics.print("duration: "..tostring(duration), 5, 5+16)
    love.graphics.print("start: "..tostring(start), 5, 5+16*2)
    love.graphics.print("change: "..tostring(change), 5, 5+16*3)
  end
  return ghost
end

-- Permet de vérifier si le clic gauche souris se trouve sur un point donné.
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

-- Vérifie si deux lignes se coupent.
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

-- Petit objet qui affiche un cercle au pint d'intersection entre deux segments.
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

-- Fonction qui permet de vérifier si deux polygones sont en collision
function Check_Star_Collision(star_a, star_b)
  for i=1,#star_a do
    local p0 = star_a[i]
    local p1 = star_a[i+1]
    if  i == #star_a then
      p0 = star_a[i]
      p1 = star_a[1]
    end
    
    for j=1,#star_b do
      local p2 = star_b[j]
      local p3 = star_b[j+1]
      if j == #star_b then
        p2 = star_b[j]
        p3 = star_b[1]
      end
      
      if Line_Intersect(p0, p1, p2, p3, true, true) then
        return true
      end
    end
  end
  return false
end

-- Objet qui premet de créer, de mettre à jour la position et d'afficher une étoile.
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

-- Projète une particule sur une ligne
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

-- Déplacer un joueur avec les flèches directionnelles.
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

-- Création d'un rectangle.
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

-- Bouge et tourne un sprite
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

-- Création d'un polygone.
function Create_Polygon(table_point, pos_x, pos_y, angle, pid)
  local ghost = {}
  ghost.verticies = {}
  ghost.forme = table_point
  ghost.position = Vector(pos_x, pos_y)
  ghost.angle = angle
  ghost.overlap = false
  ghost.ID = pid
  
  ghost.Update = function(dt)
    ghost.verticies = {}
    for j=1,#ghost.forme do
      local p = Vector(
        (ghost.forme[j].x*math.cos(ghost.angle)) - (ghost.forme[j].y*math.sin(ghost.angle)) + ghost.position.x,
        (ghost.forme[j].x*math.sin(ghost.angle)) + (ghost.forme[j].y*math.cos(ghost.angle)) + ghost.position.y
      )
      table.insert(ghost.verticies, p)
    end
    ghost.overlap = false
  end
  ghost.Draw = function()
    for i=1,#ghost.verticies do
      if i == #ghost.verticies then
        love.graphics.line(ghost.verticies[i].x, ghost.verticies[i].y, ghost.verticies[1].x, ghost.verticies[1].y)
      else
        love.graphics.line(ghost.verticies[i].x, ghost.verticies[i].y, ghost.verticies[i+1].x, ghost.verticies[i+1].y)
      end
    end
    love.graphics.points(ghost.position.x, ghost.position.y)
  end
  return ghost
end

function Create_Poly_Points(nb_points, rayon, rotation)
  local angle = (math.pi*2) / nb_points
  local poly_verts = {}
  for i=1,nb_points do
    local verts = Vector(rayon*math.cos(angle*i + rotation), rayon*math.sin(angle*i + rotation))
    table.insert(poly_verts, verts)
  end
  return poly_verts
end