io.stdout:setvbuf('no')
if arg[arg] == "-debug" then require("mobdebug").start() end
love.graphics.setDefaultFilter("nearest")


-- Renvoie l'angle entre deux points par rapport à l'horizontale.
function math.angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end

-- Renvoie la distance entre deux points.
--function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end
function math.dist(x1,y1, x2,y2) 
  n1 = math.abs(x2-x1)
  n2 = math.abs(y2-y1)
  n3 = (n1^2) + (n2^2)
  return math.sqrt(n3) 
end

-- Permet de gérer des chronomètres.
function Chrono(time, callback)
  local expired = false
  local timer = {}
  
  function timer.update(dt)
    if time < 0 then
      expired = true
      callback()
    end
    time = time-dt
    return time
  end
  
  function timer.is_Expired()
    return expired
  end
  
  return timer
end

-- Vérifie si deux bounding box overlap.
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

-- Vérifie si deux lignes se coupent.
function findIntersect(l1p1x,l1p1y, l1p2x,l1p2y, l2p1x,l2p1y, l2p2x,l2p2y, seg1, seg2)
	local a1,b1,a2,b2 = l1p2y-l1p1y, l1p1x-l1p2x, l2p2y-l2p1y, l2p1x-l2p2x
	local c1,c2 = a1*l1p1x+b1*l1p1y, a2*l2p1x+b2*l2p1y
	local det,x,y = a1*b2 - a2*b1
	if det==0 then return false, "The lines are parallel." end
	x,y = (b2*c1-b1*c2)/det, (a1*c2-a2*c1)/det
	if seg1 or seg2 then
		local min,max = math.min, math.max
		if seg1 and not (min(l1p1x,l1p2x) <= x and x <= max(l1p1x,l1p2x) and min(l1p1y,l1p2y) <= y and y <= max(l1p1y,l1p2y)) or
		   seg2 and not (min(l2p1x,l2p2x) <= x and x <= max(l2p1x,l2p2x) and min(l2p1y,l2p2y) <= y and y <= max(l2p1y,l2p2y)) then
			return false, "The lines don't intersect."
		end
	end
	return x,y
end

-- Globales qui contiennent les dimensions de la fenêtre.
largeur = love.graphics.getWidth()
hauteur = love.graphics.getHeight()

-- Données et création de l'image du canon.
canon = {}
canon.w = 80
canon.h = 20
canon.x = largeur/2
canon.y = hauteur/2
canon.angle = 0
canon.tir = false
canon.img = love.graphics.newCanvas(canon.w, canon.h)
function Load_Canon()
  love.graphics.setCanvas(canon.img)
  love.graphics.rectangle("fill", 0, 0, canon.w, canon.h)
  love.graphics.setColor(1, 0, 0)
  love.graphics.rectangle("fill", 2, 2, 10, 10)
  love.graphics.setColor(1, 1, 1)
  love.graphics.setCanvas()
end

-- Données et création de l'image de la balle.
balle = {}
balle.w = 20
balle.h = 20
balle.r = 10
balle.x = largeur/2 - balle.w/2
balle.y = hauteur/2 - balle.h/2
balle.vx = 0
balle.vy = 0
balle.dir = 0
balle.touche = false
balle.img = love.graphics.newCanvas(balle.w, balle.h)
function Load_Balle()
  love.graphics.setCanvas(balle.img)
  love.graphics.setColor(0, 1, 0)
  love.graphics.circle("fill", 10, 10, balle.r)
  love.graphics.setColor(1, 1, 1)
  love.graphics.setCanvas()
end
to_raquette = false

-- Données et création de l'image de la raquette.
raquete_ia = {}
raquete_ia.w = 10
raquete_ia.h = 50
raquete_ia.x = 15
raquete_ia.y = hauteur/2-raquete_ia.h/2
raquete_ia.vx = 0
raquete_ia.vy = 0
raquete_ia.move = false
raquete_ia.err_factor = 15
raquete_ia.tps_react = 0.5
raquete_ia.haut = {x1=raquete_ia.x, y1=raquete_ia.y, x2=raquete_ia.x+raquete_ia.w, y2=raquete_ia.y}
raquete_ia.droite = {x1=raquete_ia.x+raquete_ia.w, y1=raquete_ia.y, x2=raquete_ia.x+raquete_ia.w, y2=raquete_ia.y+raquete_ia.h}
raquete_ia.bas = {x1=raquete_ia.x, y1=raquete_ia.y+raquete_ia.h, x2=raquete_ia.x+raquete_ia.w, y2=raquete_ia.y+raquete_ia.h}
raquete_ia.img = love.graphics.newCanvas(raquete_ia.w, raquete_ia.h)
function Load_Raquette()
  love.graphics.setCanvas(raquete_ia.img)
  love.graphics.rectangle("fill", 0, 0, raquete_ia.w, raquete_ia.h)
  love.graphics.setCanvas()
end

--[[      LOAD      ]]
-- Chargement des trois images.
function love.load()
  Load_Canon()
  Load_Raquette()
  Load_Balle()
end

--[[      UPDATE        ]]
function love.update(dt)
  raquete_ia.haut = {x1=raquete_ia.x, y1=raquete_ia.y, x2=raquete_ia.x+raquete_ia.w, y2=raquete_ia.y}
  raquete_ia.droite = {x1=raquete_ia.x+raquete_ia.w, y1=raquete_ia.y, x2=raquete_ia.x+raquete_ia.w, y2=raquete_ia.y+raquete_ia.h}
  raquete_ia.bas = {x1=raquete_ia.x, y1=raquete_ia.y+raquete_ia.h, x2=raquete_ia.x+raquete_ia.w, y2=raquete_ia.y+raquete_ia.h}
  -- Récupération de la position du curseur et de l'angle du canon par rapport au curseur.
  mouse_x, mouse_y = love.mouse.getPosition()
  canon.angle = math.angle(canon.x, canon.y, mouse_x, mouse_y)
  
  if canon.tir then
    --balle.vx = balle.vx * 1.005
    --balle.vy = balle.vy * 1.005
    
    -- Mise à jour de la position de la balle.
    balle.x = balle.x + balle.vx
    balle.y = balle.y + balle.vy
    
    -- Vérifie les collisions entre la balle et les bords de l'écran.
    if balle.x > largeur-balle.w then
      balle.x = largeur-balle.w
      balle.vx = -balle.vx
      balle.touche = true
    elseif balle.x < 0 then
      canon.tir = false
      balle.vx = 0
      balle.vy = 0
      balle.x = largeur/2 - balle.w/2
      balle.y = hauteur/2 - balle.h/2
      
      raquete_ia.y = hauteur/2-raquete_ia.h/2
      raquete_ia.move = false
      raquete_ia.tps_react = 0.5
    end
    
    if balle.y > hauteur-balle.h then
      balle.y = hauteur-balle.h
      balle.vy = -balle.vy
      balle.touche = true
    elseif balle.y < 0 then
      balle.y = 0
      balle.vy = -balle.vy
      balle.touche = true
    end
  end
  
  -- Calcul du point d'intersection entre la trajectoire de la balle et celle de la raquette.
  balle_target_x, balle_target_y = findIntersect(0, -2000, 0, 2000, balle.x, balle.y, balle.x+balle.vx*balle.dir, balle.y+balle.vy*balle.dir, false, false)
  
  -- Contrôle si la balle se dirige ou non vers la raquette.
  if balle.vx < 0 then
    to_raquette = true
  else
    to_raquette = false
  end
  
  -- Si la balle vient vers la raquette, on déclenche le temps de réaction de la raquette.
  if to_raquette then
    raquete_ia.tps_react = raquete_ia.tps_react - dt
    if raquete_ia.tps_react <= 0 then
      raquete_ia.tps_react = 0
      raquete_ia.move = true
    end
    
    -- Si la balle heurte un mur, on relance le temps de réaction.
    if balle.touche then
      raquete_ia.move = false
      balle.touche = false
      raquete_ia.tps_react = 0.5
    end
    
    -- Contrainte de la raquette dans l'écran.
    if raquete_ia.y <=0 then
      raquete_ia.y = 0
      raquete_ia.vy = 0
    elseif raquete_ia.y >= hauteur-raquete_ia.h then
      raquete_ia.y = hauteur-raquete_ia.h
      raquete_ia.vy = 0
    end
    
    -- Si un point d'intersection entre les trajectoires de la balle et de la raquette est trouvé, on modifie en conséquence la vitesse de la raquette.
    if type(balle_target_y) == "number" and type(balle_target_x) == "number" and raquete_ia.move then
      if raquete_ia.y > balle_target_y+marge then
        raquete_ia.vy = -15
      elseif raquete_ia.y < balle_target_y-raquete_ia.h+marge then
        raquete_ia.vy = 15
      else
        raquete_ia.vy = 0
      end
      -- Vérifie si la balle se dirige vers la raquette.
      contact_haut_x, contact_haut_y = findIntersect(balle.x, balle.y, balle_target_x, balle_target_y, raquete_ia.haut.x1, raquete_ia.haut.y1, raquete_ia.haut.x2, raquete_ia.haut.y2, false, true)
      contact_droite_x, contact_droite_y = findIntersect(balle.x, balle.y, balle_target_x, balle_target_y, raquete_ia.droite.x1, raquete_ia.droite.y1, raquete_ia.droite.x2, raquete_ia.droite.y2, false, true)
      contact_bas_x, contact_bas_y = findIntersect(balle.x, balle.y, balle_target_x, balle_target_y, raquete_ia.bas.x1, raquete_ia.bas.y1, raquete_ia.bas.x2, raquete_ia.bas.y2, false, true)
      -- Si un contact a lieu, on inverse la vitesse.
      if type(contact_droite_x) == "number" and type(contact_droite_y) == "number" then
        if balle.y >= raquete_ia.y and balle.y <= raquete_ia.y+raquete_ia.h and math.dist(balle.x, balle.y, contact_droite_x, contact_droite_y) <= balle.r then
          balle.vx = -balle.vx
        end
      end
      if type(contact_haut_x) == "number" and type(contact_haut_y) == "number" then
        if balle.vy > 0 and math.dist(balle.x, balle.y, contact_haut_x, contact_haut_y) <= balle.r then
          balle.vy = -balle.vy
        end
      end
      if type(contact_bas_x) == "number" and type(contact_bas_y) == "number" then
        if balle.vx <= 0 and math.dist(balle.x, balle.y, contact_bas_x, contact_bas_y) <= balle.r then
          balle.vy = -balle.vy
        end
      end
    else
      raquete_ia.vy = 0
    end
  -- Mise à jour de la position de la raquette.
  raquete_ia.y = raquete_ia.y + raquete_ia.vy
  end
end

--[[      DRAW      ]]
function love.draw()
  -- Affichage du canon et de la raquette.
  love.graphics.draw(canon.img, canon.x, canon.y, canon.angle, 1, 1, canon.w/2, canon.h/2)
  love.graphics.draw(raquete_ia.img, raquete_ia.x, raquete_ia.y)
  
  -- Affichage de la balle.
  if canon.tir then
    love.graphics.draw(balle.img, balle.x, balle.y)
  end
  
  -- Affichage d'une ligne entre la balle et le point d'inersection entre les trajectoires de la balle et de la raquette.
  if to_raquette then
    if type(balle_target_x) == "number" or type(balle_target_y) == "number" then
      love.graphics.setColor(1, 0, 0)
      love.graphics.line(balle.x+10, balle.y+10, balle_target_x, balle_target_y)
      love.graphics.setColor(1, 1, 1)
    end
  end
  
  --Affichage des bords haut, droit et bas de la raquette
  love.graphics.setColor(1, 1, 0)
  love.graphics.line(raquete_ia.haut.x1, raquete_ia.haut.y1, raquete_ia.haut.x2, raquete_ia.haut.y2)
  love.graphics.line(raquete_ia.droite.x1, raquete_ia.droite.y1, raquete_ia.droite.x2, raquete_ia.droite.y2)
  love.graphics.line(raquete_ia.bas.x1, raquete_ia.bas.y1, raquete_ia.bas.x2, raquete_ia.bas.y2)
  love.graphics.setColor(1, 1, 1)
  
  -- Affichage de quelques infos.
  
end

function love.keypressed(key)
  
end

function love.mousepressed(x, y, button)
  -- Déclenchement du tir.
  if button == 1 and canon.tir == false then
    canon.tir = true
    balle_x, balle_y = love.mouse.getPosition()
    balle.dir = math.angle(balle.x, balle.y, balle_x, balle_y)
    marge = love.math.random(-raquete_ia.err_factor, raquete_ia.err_factor)
    balle.vx = 8 * math.cos(balle.dir)
    balle.vy = 8 * math.sin(balle.dir)
  end
end