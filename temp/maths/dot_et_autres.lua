io.stdout:setvbuf('no')
love.graphics.setDefaultFilter("nearest")
if arg[arg] == "-debug" then require("mobdebug").start() end

require("vector")
require("math_sup")

largeur = love.graphics.getWidth()
hauteur = love.graphics.getHeight()

-- paramètres des carrés qui constituent la grille.
carre = {}
carre.x = 0
carre.y = 0
carre.w = 50
carre.h = 50

-- nombre de colonnes et de lignes composant la grille.
nb_col = largeur/carre.w
nb_line = hauteur/carre.h

-- fonction qui calcule le dot product de deux vecteurs.
function Dot(v1, v2)
  return v1.x*v2.x + v1.y*v2.y
end

-- fonction qui calcule le cross product de deux vecteurs.
function Determinant(v1, v2)
  return v1.x*v2.y - v1.y*v2.x
end

-- fonction qui normalise deux vecteurs avant de calculer leur dot product.
function Dot_Normalized(v1, v2)
  v1.normalize()
  v2.normalize()
  return Dot(v1, v2)
end

-- fonction qui place un point non plus en fonction de l'origine mais à partir d'un nouveau système
-- de coordonnées.
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

-- fonction qui permet de vérifier si un vecteur regarde dans une certaine direction.
function Is_Looking_For(origine, mobile, bras)
  local mobile_to_origine = origine-mobile
  mobile_to_origine.normalize()
  local mobile_direction = Vector(bras.w*math.cos(bras.rotation), bras.w*math.sin(bras.rotation))
  mobile_direction.normalize()
  local is_looking = Dot_Normalized(mobile_direction, mobile_to_origine)
  if is_looking > 0.995 then
    return true
  end
  return false
end

-- fonction qui calcule le point d'intersection entre deux droites.
function Line_Intersect(vec1, vec2, vec3, vec4)
  local A1 = vec2.y - vec1.y
  local B1 = vec1.x - vec2.x
  local C1 = A1*vec1.x + B1*vec1.y
  
  local A2 = vec4.y - vec3.y
  local B2 = vec3.x - vec4.x
  local C2 = A2*vec3.x + B2*vec3.y
  
  local denominateur = A1*B2 - A2*B1
  if denominateur == 0 then
    return false
  else
    local intersection_point = Vector((B2*C1 - B1*C2)/denominateur, (C2*A1 - C1*A2)/denominateur)
    return intersection_point
  end
  return false
end

-- fonction qui calcule le point d'intersection entre une droite et un segment.
function Line_Vs_Segment(vec1, vec2, vec3, vec4)
  local pt = Line_Intersect(vec1, vec2, vec3, vec4)
  if pt ~= false then
    range_x = (pt.x-vec3.x)/(vec4.x-vec3.x)
    range_y = (pt.y-vec3.y)/(vec4.y-vec3.y)
    if (range_x >= 0 and range_x <= 1) or (range_y >= 0 and range_y <= 1) then
      local pt_on_segment = Vector(pt.x, pt.y)
      return pt_on_segment
    end
  end
end

-- fonction qui calcule le point d'intersection entre deux segments.
function Segment_Intersect(vec1, vec2, vec3, vec4)
  local pt = Line_Intersect(vec1, vec2, vec3, vec4)
  if pt ~= false then
    range_x1 = (pt.x-vec1.x)/(vec2.x-vec1.x)
    range_y1 = (pt.y-vec1.y)/(vec2.y-vec1.y)
    range_x2 = (pt.x-vec3.x)/(vec4.x-vec3.x)
    range_y2 = (pt.y-vec3.y)/(vec4.y-vec3.y)
    if ((range_x1 >= 0 and range_x1 <= 1) or (range_y1 >= 0 and range_y1 <= 1)) and ((range_x2 >= 0 and range_x2 <= 1) or (range_y2 >= 0 and range_y2 <= 1)) then
      local pt_on_segment = Vector(pt.x, pt.y)
      return pt_on_segment
    end
  end
end

-- fonction qui donne les coordonnées du vecteur normale d'une ligne
function Vecteur_Normal(vec_1, vec_2, up_left, down_right)
  local normal_x = vec_2.x-vec_1.x
  local normal_y = vec_2.y-vec_1.y
  if up_left then
    return Vector(normal_y, -normal_x)
  elseif down_right then
    return Vector(-normal_y, normal_x)
  end
end

-- fonction qui fait rebondir un laser sur une surface.
function Reflect_Vector(laser, normale)
  local vec = Vector(0, 0)
  local dot_p = Dot(normale, laser)
  vec.x = laser.x - (2*dot_p)*normale.x
  vec.y = laser.y - (2*dot_p)*normale.y
  vec = -vec
  vec.normalize()
  return vec
end

-- fonction qui difracte un vecteur.
function Difract_Vector(laser, normale)
  local vec = Vector(0, 0)
  local dot_p = Dot(normale, laser)
  vec.x = laser.x - (2*dot_p)*normale.x
  vec.y = laser.y - (2*dot_p)*normale.y
  vec.normalize()
  return vec
end

-- fleche qui s'affiche sur le point du player et qui indique dans quelle direction il regarde.
player = {}
player.pos = Vector(100, 100)
player.fleche = {}
player.fleche.img = love.graphics.newCanvas(50, 10)
player.fleche.w = player.fleche.img:getWidth()
player.fleche.h = player.fleche.img:getHeight()
player.fleche.rotation = 0


function Load_Fleche()
  love.graphics.setCanvas(player.fleche.img)
  love.graphics.line(0, 5, 50, 5)
  love.graphics.line(45, 0, 50, 5)
  love.graphics.line(45, 10, 50, 5)
  love.graphics.setCanvas()
end

line_test = {}
line_test.p1 = Vector(350, 500)
line_test.p2 = Vector(600, 350)
-- disp: vitesse de déplacement du trigger et du player.
-- inside et regarde: flags qui permmettent de savoir si le joueur
-- est à l'intérieur de la zone du trigger ou s'il regarde dans sa direction.
disp = 1
inside = false
regarde = false
normal_dir = ""
vec_normal = Vector(0, 0)

-- ############## LOAD ##############
function love.load()
  Load_Fleche()
  
  trigger = Vector(0, 0)
  
  world_to_local = Vector(250, 100)
  test_point = world_to_local
  
  coord_test = New_Coord_System(450, 50, 75, 0.5)
  point_test = Convert_Point(150, 80)
end

-- ############## UPDATE ##############
function love.update(dt)
  regarde = false
  -- contrôles du joueur.
  -- déplacements.
  if love.keyboard.isDown("right") then
    player.pos.x = player.pos.x + disp
  end
  if love.keyboard.isDown("down") then
    player.pos.y = player.pos.y + disp
  end
  if love.keyboard.isDown("left") then
    player.pos.x = player.pos.x - disp
  end
  if love.keyboard.isDown("up") then
    player.pos.y = player.pos.y - disp
  end
  
  -- rotation.
  if love.keyboard.isDown("p") then
    player.fleche.rotation = player.fleche.rotation + 0.01
  end
  if love.keyboard.isDown("m") then
    player.fleche.rotation = player.fleche.rotation - 0.01
  end
  -- déplacement de "l'origine".
  if love.keyboard.isDown("d") then
    trigger.x = trigger.x + disp
  end
  if love.keyboard.isDown("s") then
    trigger.y = trigger.y + disp
  end
  if love.keyboard.isDown("q") then
    trigger.x = trigger.x - disp
  end
  if love.keyboard.isDown("z") then
    trigger.y = trigger.y - disp
  end
  
  -- déplacement de l'image de la flèche en fonction du joueur.
  player.fleche.x = player.pos.x
  player.fleche.y = player.pos.y
  
  -- vecteur qui indique la direction entre le player et le trigger ("l'origine")
  player_to_trigger_dir = trigger-player.pos
  --print(player_to_trigger_dir.x, player_to_trigger_dir.y)
  player_to_trigger_dir.normalize()
  
  -- vecteur qui indique la direction dans laquelle regarde le joueur.
  player_look_dir = Vector(player.fleche.w*math.cos(player.fleche.rotation), player.fleche.w*math.sin(player.fleche.rotation))
  player_look_dir.normalize()
  
  regarde = Is_Looking_For(trigger, player.pos, player.fleche)
  player_local_coords = Return_Local_Coords(player.pos, coord_test)
  coord_test.Update(dt, "a", "e")
  point_test.Update(dt, coord_test, "kp8", "kp6", "kp2", "kp4")
  
  --test_int_line = Line_Intersect(player.pos, player.pos+player_look_dir*50, line_test.p1, line_test.p2)
  --test_int_line = Line_Vs_Segment(player.pos, player.pos+player_look_dir*50, line_test.p1, line_test.p2)
  test_int_line = Segment_Intersect(player.pos, player.pos+player_look_dir*50, line_test.p1, line_test.p2)
  
  l1 = Vector(0, 0)
  l1.x = line_test.p1.x
  l1.y = line_test.p1.y
  l1.normalize()
  
  l2 = Vector(0, 0)
  l2.x = line_test.p2.x
  l2.y = line_test.p2.y
  l2.normalize()
  
  p1_to_p2 = line_test.p2-line_test.p1
  p1_to_player = player.pos-line_test.p1
  cp = Determinant(p1_to_p2, p1_to_player)
  if cp < 0 then
    print("au dessus")
    vec_normal = Vecteur_Normal(line_test.p1, line_test.p2, true, false)
  else
    print("au dessous")
    vec_normal = Vecteur_Normal(line_test.p1, line_test.p2, false, true)
  end
  vec_normal.normalize()
  
  if test_int_line ~= nil then
    intersection_to_p2 = line_test.p2-test_int_line
    intersection_to_player = player.pos-test_int_line
    loc_det = Determinant(intersection_to_p2, intersection_to_player)
    if loc_det < 0 then
      int_normale = Vecteur_Normal(test_int_line, line_test.p2, true, false)
    else
      int_normale = Vecteur_Normal(test_int_line, line_test.p2, false, true)
    end
    int_normale.normalize()
    
    rebond = Reflect_Vector(intersection_to_player, int_normale)
    difract = Difract_Vector(intersection_to_player, int_normale)
    print(rebond.x, rebond.y)
  end
end


-- ############## DRAW ##############
function love.draw()
  -- affichage de la grille.
  for i=1,nb_line do
    for j=1,nb_col do
      love.graphics.rectangle("line", (j-1)*carre.w + carre.x, (i-1)*carre.h + carre.y, carre.w, carre.h)
    end
  end
  
  -- bleu: vecteur normalisé qui indique la direction de "l'origine" depuis le joueur.
  love.graphics.setColor(0, 0, 1)
  love.graphics.line(player.pos.x, player.pos.y, player.pos.x+player_to_trigger_dir.x*50, player.pos.y+player_to_trigger_dir.y*50)
  if test_int_line ~= nil then
    love.graphics.line(test_int_line.x, test_int_line.y, test_int_line.x+int_normale.x*50, test_int_line.y+int_normale.y*50)
    love.graphics.setColor(1, 1, 0)
    love.graphics.line(test_int_line.x, test_int_line.y, test_int_line.x+rebond.x*50, test_int_line.y+rebond.y*50)
    love.graphics.setColor(0, 1, 0)
    love.graphics.line(test_int_line.x, test_int_line.y, test_int_line.x+difract.x*50, test_int_line.y+difract.y*50)
    love.graphics.setColor(1, 1, 1)
  end
  -- blue ciel: vecteur normalisé qui donne la direction de l'image de la flèche.
  love.graphics.setColor(0, 1, 1)
  love.graphics.line(player.pos.x, player.pos.y, player.pos.x+player_look_dir.x*150, player.pos.y+player_look_dir.y*150)
  love.graphics.circle("fill", player.pos.x+player_look_dir.x, player.pos.y+player_look_dir.y, 15)
  -- rouge: trigger, on peut considérer ce point comme "l'origine".
  love.graphics.setColor(1, 0, 0)
  love.graphics.circle("fill", trigger.x, trigger.y, 8)
  
  love.graphics.line(line_test.p1.x, line_test.p1.y, line_test.p2.x, line_test.p2.y)
  --love.graphics.line(line_test.p1.x, line_test.p1.y, line_test.p1.x+vec_normal.x*50, line_test.p1.y+vec_normal.y*50)
  if test_int_line ~= nil then
    love.graphics.circle("line", test_int_line.x, test_int_line.y, 17)
    love.graphics.line(line_test.p1.x, line_test.p1.y, line_test.p1.x+vec_normal.x*50, line_test.p1.y+vec_normal.y*50)
  end
  -- vert: point qui indique la position du joueur et flèche qui indique dans quelle direction il rergarde.
  love.graphics.setColor(0, 1, 0)
  love.graphics.circle("fill", player.pos.x, player.pos.y, 15)
  love.graphics.draw(player.fleche.img, player.fleche.x, player.fleche.y, player.fleche.rotation, 1, 1, 0, player.fleche.h/2)
  
  -- couleur noir et affichage d'un cadre sur lequel écrire quelques info de debug. 
  love.graphics.setColor(0, 0, 0, 0.5)
  love.graphics.rectangle("fill", 585, 455, 200, 130)
  -- couleur blanc. Affichage d'un liseré blanc autour du cadre de debug et des infos qui m'intéresse.
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("line", 585, 455, 200, 130)
  love.graphics.print("inside: "..tostring(inside), 595, 465)
  love.graphics.print("disp: "..tostring(disp), 595, 465+16)
  love.graphics.print("regarde: "..tostring(regarde), 675, 465)
  love.graphics.print("j1 local x: "..tostring(player_local_coords.x), 595, 465+16*2)
  love.graphics.print("j2 local x: "..tostring(player_local_coords.y), 595, 465+16*3)
  
  coord_test.Draw({1, 0, 0})
  point_test.Draw({1, 0, 0})
end

-- ############## KEYPRESED ##############
function love.keypressed(key)
  -- augmentation ou diminution de la vitesse de déplacement du trigger et du player.
  if key == "kp+" and disp < 5 then
    disp = disp+1
  end
  if key == "kp-" and disp > 1 then
    disp = disp-1
  end
  
  point_test.Keypressed(key, "kp5")
end