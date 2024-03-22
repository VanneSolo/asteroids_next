function Local_To_World(local_origine, point, r)
  local new_point = Vector(point.x, point.y)
  new_point.Set_Angle(r.Get_Angle()+point.Get_Angle())
  return local_origine+new_point
end

-- Crée un nouveau système de coordonnées représenté à l'écran par deux lignes.
function New_Coord_System(x, y, longueur_repere, angle)
  local ghost = {}
  ghost.pos = Vector(x, y)
  ghost.axe_x = Vector(ghost.pos.x+longueur_repere, ghost.pos.y)
  ghost.axe_y = Vector(ghost.pos.x, ghost.pos.y+longueur_repere)
  ghost.angle = angle
  ghost.rotation_x = Vector(0, 0)
  ghost.rotation_y = Vector(0, 0)
  ghost.Update = function(dt, key_up, key_down)
    if love.keyboard.isDown(key_up) then
      ghost.angle = ghost.angle + 0.01
    end
    if love.keyboard.isDown(key_down) then
      ghost.angle = ghost.angle - 0.01
    end
    ghost.rotation_x = Vector(longueur_repere*math.cos(ghost.angle), longueur_repere*math.sin(ghost.angle))
    ghost.rotation_y = Vector(longueur_repere*math.cos(ghost.angle+math.pi/2), longueur_repere*math.sin(ghost.angle+math.pi/2))
    
    ghost.axe_x.x = ghost.pos.x+ghost.rotation_x.x
    ghost.axe_x.y = ghost.pos.y+ghost.rotation_x.y
    
    ghost.axe_y.x = ghost.pos.x+ghost.rotation_y.x
    ghost.axe_y.y = ghost.pos.y+ghost.rotation_y.y
  end
  ghost.Draw = function(color_1)
    love.graphics.setColor(color_1)
    love.graphics.line(ghost.pos.x, ghost.pos.y, ghost.axe_x.x, ghost.axe_x.y)
    love.graphics.line(ghost.pos.x, ghost.pos.y, ghost.axe_y.x, ghost.axe_y.y)
    love.graphics.print("x", ghost.axe_x.x, ghost.axe_x.y)
    love.graphics.print("y", ghost.axe_y.x, ghost.axe_y.y)
    love.graphics.setColor(1, 1, 1)
  end
  return ghost
end

-- Converti les coordonnées d'un point entre une position globale et locale
function Convert_Point(x, y)
  local ghost = {}
  ghost.point = Vector(0, 0)
  ghost.pos = Vector(x, y)
  ghost.id = "global"
  ghost.Update = function(dt, new_origine, up, right, down, left)
    ghost.convert = Local_To_World(new_origine.pos, ghost.pos, new_origine.rotation_x)
    if ghost.id == "global" then
      ghost.point = ghost.pos
    elseif ghost.id == "local" then
      ghost.point = ghost.convert
    end
    
    if love.keyboard.isDown(up) then
      ghost.pos.y = ghost.pos.y - 10
    end
    if love.keyboard.isDown(right) then
      ghost.pos.x = ghost.pos.x + 10
    end
    if love.keyboard.isDown(down) then
      ghost.pos.y = ghost.pos.y + 10
    end
    if love.keyboard.isDown(left) then
      ghost.pos.x = ghost.pos.x - 10
    end
  end
  ghost.Draw = function(color)
    love.graphics.setColor(color)
    love.graphics.circle("fill", ghost.point.x, ghost.point.y, 10)
    love.graphics.setColor(1, 1, 1)
  end
  ghost.Keypressed = function(key, switch)
    if key == switch then
      if ghost.id == "global" then
        ghost.id = "local"
      elseif ghost.id == "local" then
        ghost.id = "global"
      end
    end
  end
  return ghost
end

-- fonction qui renvoie la localisation d'un point par rapport à un système de coordonnées alternatif.
function Return_Local_Coords(point, origine)
  local relative_coords = point-origine.pos
  local norm_x = origine.rotation_x
  local norm_y = origine.rotation_y
  norm_x.normalize()
  norm_y.normalize()
  local x = Dot(relative_coords, norm_x)
  local y = Dot(relative_coords, norm_y)
  return Vector(x, y)
end

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

function love.load()
  largeur = love.graphics.getWidth()
  hauteur = love.graphics.getHeight()
  nb_lignes = 10
  nb_colonnes = 10
  tuile_w = 25
  tuile_h = 25
  
  map = {}
  map[1] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
  map[2] = {1, 0, 0, 0, 0, 0, 0, 0, 0, 1}
  map[3] = {1, 0, 1, 0, 0, 0, 0, 0, 0, 1}
  map[4] = {1, 0, 1, 0, 0, 0, 0, 0, 0, 1}
  map[5] = {1, 0, 1, 1, 1, 1, 1, 0, 0, 1}
  map[6] = {1, 0, 0, 0, 0, 0, 1, 0, 0, 1}
  map[7] = {1, 1, 1, 1, 1, 1, 1, 0, 0, 1}
  map[8] = {1, 0, 0, 0, 0, 0, 0, 0, 0, 1}
  map[9] = {1, 0, 0, 0, 0, 0, 0, 0, 0, 1}
  map[10] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
  
  joueur = {}
  joueur.colonne = 2
  joueur.ligne = 2
  joueur.x = (joueur.colonne-1) * tuile_w
  joueur.y = (joueur.ligne-1) * tuile_h
  joueur.move_to_ligne = 2
  joueur.move_to_colonne = 2
  joueur.move = false
  joueur.vitesse = 130
end

function love.update(dt)
  if joueur.move == false then
    Repositionne_Joueur()
    if love.keyboard.isDown("up") then
      joueur.move_to_ligne = joueur.move_to_ligne - 1
      joueur.move = true
    elseif love.keyboard.isDown("right") then
      joueur.move_to_colonne = joueur.move_to_colonne + 1
      joueur.move = true
    elseif love.keyboard.isDown("down") then
      joueur.move_to_ligne = joueur.move_to_ligne + 1
      joueur.move = true
    elseif love.keyboard.isDown("left") then
      joueur.move_to_colonne = joueur.move_to_colonne - 1
      joueur.move = true
    end
  end
  
  local case = map[joueur.move_to_ligne][joueur.move_to_colonne]
  if case ~= 0 then
    joueur.move_to_ligne = joueur.ligne
    joueur.move_to_colonne = joueur.colonne
    joueur.move = false
  end
  
  if joueur.move == true then
    if joueur.move_to_colonne > joueur.colonne then
      joueur.x = joueur.x + joueur.vitesse*dt
      if math.floor(joueur.x/tuile_w)+1 >= joueur.move_to_colonne then
        joueur.colonne = joueur.move_to_colonne
        joueur.move = false
      end
    elseif joueur.move_to_colonne < joueur.colonne then
      joueur.x = joueur.x - joueur.vitesse*dt
      if math.ceil(joueur.x/tuile_w)+1 <= joueur.move_to_colonne then
        joueur.colonne = joueur.move_to_colonne
        joueur.move = false
      end
    elseif joueur.move_to_ligne > joueur.ligne then
      joueur.y = joueur.y + joueur.vitesse*dt
      if math.floor(joueur.y/tuile_h)+1 >= joueur.move_to_ligne then
        joueur.ligne = joueur.move_to_ligne
        joueur.move = false
      end
    elseif joueur.move_to_ligne < joueur.ligne then
      joueur.y = joueur.y - joueur.vitesse*dt
      if math.ceil(joueur.y/tuile_h)+1 <= joueur.move_to_ligne then
        joueur.ligne = joueur.move_to_ligne
        joueur.move = false
      end
    end
  end
end

function love.draw()
  for l=1,nb_lignes do
    for c=1,nb_colonnes do
      if map[l][c] == 1 then
        love.graphics.setColor(0.75, 0.75, 0.75)
        love.graphics.rectangle("fill", (c-1)*tuile_w, (l-1)*tuile_h, tuile_w, tuile_h)
        love.graphics.setColor(1, 1, 1)
      elseif map[l][c] == 0 then
        love.graphics.setColor(0.95, 0.85, 0.15)
        love.graphics.rectangle("fill", (c-1)*tuile_w, (l-1)*tuile_h, tuile_w, tuile_h)
        love.graphics.setColor(1, 1, 1)
      end
    end
  end
  love.graphics.setColor(1, 0, 0)
  love.graphics.rectangle("fill", joueur.x, joueur.y, tuile_w, tuile_h)
  love.graphics.setColor(1, 1, 1)
  
  love.graphics.print("x: "..tostring(joueur.x), 5, tuile_h*10)
  love.graphics.print("y: "..tostring(joueur.y), 5, (tuile_h*10)+16)
  love.graphics.print("colonne: "..tostring(joueur.colonne), 5, (tuile_h*10)+(16*2))
  love.graphics.print("ligne: "..tostring(joueur.ligne), 5, (tuile_h*10)+(16*3))
  love.graphics.print("colonne vers: "..tostring(joueur.move_to_colonne), 5, (tuile_h*10)+(16*4))
  love.graphics.print("ligne vers: "..tostring(joueur.move_to_ligne), 5, (tuile_h*10)+(16*5))
  love.graphics.print("etat move: "..tostring(joueur.move), 5, (tuile_h*10)+(16*6))
end

function love.keypressed(key)
  
end

function love.mousepressed(x, y, button)
  
end

function Repositionne_Joueur()
  joueur.x = (joueur.colonne-1) * tuile_w
  joueur.y = (joueur.ligne-1) * tuile_h
end