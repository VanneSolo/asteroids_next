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

function Particule(pX, pY, pWidth, pHeight, pRadius, pSprite, pAngle, pOx, pOy, pSpeed, pDirection, pGravity)
  -- Table particule qui continent toutes les données et les fonctions
  -- potentiellemnt nécessaire à la génération et au fonctionnement d'une
  -- particule.
  local particule = {}
  particule.position = Vector(pX, pY)
  particule.size = Vector(pWidth, pHeight)
  particule.rayon = pRadius
  particule.img = pSprite
  particule.rotation = pAngle
  particule.origine = Vector(pOx, pOy)
  particule.velocite = Vector(0, 0)
  particule.velocite.Set_Norme(pSpeed)
  particule.velocite.Set_Angle(pDirection)
  particule.gravity = Vector(0, pGravity)
  particule.masse = 1
  particule.friction = 0.98
  particule.springs = {}
  particule.gravitations  = {}
  
  -- Ajoute de la gravité à une particule.
  particule.Add_Gravitation = function(p)
    particule.Remove_Gravitation(p)
    table.insert(particule.gravitations, p)
  end
  
  -- Retire la gravité d'une particule.
  particule.Remove_Gravitation = function(p)
    for i=1,#particule.gravitations do
      if p == particule.gravitations[i] then
        table.remove(particule.gravitations, i)
        return
      end
    end
  end
  
  -- Ajoute une force élastique à une particule.
  particule.Add_Spring = function(p_point, p_k, p_length)
    particule.Remove_Spring(p_point)
    table.insert(particule.springs, {point=p_point, k=p_k, length=p_length})
  end
  
  -- Retire la force élastique d'une particule.
  particule.Remove_Spring = function(p_point)
    for i=1,#particule.springs do
      if p_point == particule.springs[i] then
        table.remove(particule.springs, i)
        return
      end
    end
  end
  
  -- Ajoute un point d'ancrage à une particule.
  particule.Spring_To = function(p_point, p_k, p_length)
    local d = p_point - particule.position
    dist = math.sqrt(d.x^2 + d.y^2)
    spring_force = (dist - p_length) * p_k
    particule.velocite.x = particule.velocite.x + d.x/dist*spring_force
    particule.velocite.y = particule.velocite.y + d.y/dist*spring_force
  end
  
  -- Gère les élastiques d'une particule en particulier.
  particule.Handle_Springs = function()
    for i=1,#particule.springs do
      local spring = particule.springs[i]
      particule.Spring_To(spring.point, spring.k, spring.length)
    end
  end
  
  -- Gère les attractoions que subie une particule.
  particule.Handle_Gravitations = function()
    for i=1,#particule.gravitations do
      particule.Gravite_Vers(particule.gravitations[i])
    end
  end
  
  -- Récupère la vitesse d'une particule.
  particule.Get_Speed = function()
    return math.sqrt(particule.velocite.x^2 + particule.velocite.y^2)
  end
  
  -- Défini la vitesse d'une particule.
  particule.Set_Speed = function(p_speed)
    local heading = particule.Get_Heading()
    particule.velocite.x = math.cos(heading) * p_speed
    particule.velocite.y = math.sin(heading) * p_speed
  end
  
  -- Récupère la direction (l'angle) d'une particule.
  particule.Get_Heading = function()
    return math.atan2(particule.velocite.y, particule.velocite.x)
  end
  
  -- Défini la direction (l'angle) d'une particule.
  particule.Set_Heading = function(p_heading)
    local speed = particule.Get_Speed()
    particule.velocite.x = math.cos(p_heading) * speed
    particule.velocite.y = math.sin(p_heading) * speed
  end
  
  -- La fonction Accelerate prend un parametre qui est ajouté à la vélocité
  -- de l'entité à déplacer. A chaque frame la nouvelle valeur de la vélocité
  -- est de nouveau augmentée de la valeur du paramètre accel.
  particule.Accelerate = function(accel)
    particule.velocite.Add_To(accel)
  end
  -- La fonction Update permet de mettre à jour la position de la particule.
  -- On multiplie la vélocité par la friction. On ajoute à la onuvelle vélocité
  -- la gravité puis on jaoute la vélocité à la position.
  particule.Update = function(dt)
    particule.Handle_Springs()
    particule.Handle_Gravitations()
    particule.velocite.Multiply_By(particule.friction)
    particule.velocite.Add_To(particule.gravity)
    particule.position.Add_To(particule.velocite)
  end
  -- La fonction Angle_Vers permet de récupérer l'angle formé par un segment
  -- passant par deux points et l'horizontale. Pour cela on calcule l'opposé
  -- de la tangeante dans un trizngle rectangle formé par la position des deux
  -- particules et un tropisième ppint crée par la soustraction des valeurs y
  -- des deux premiers point d'une part et la soustraction des valeurs x de 
  -- ces mêmes points d'autre part.
  particule.Angle_Vers = function(particule_2)
    return math.atan2(particule_2.position.Get_Y()-particule.position.Get_Y(), particule.position.Get_X()-particule.position.Get_X())
  end
  -- La fonction Distance_Vers récupère la distance entre deux points.
  particule.Distance_Vers = function(particule_2)
    local dx = particule_2.position.Get_X() - particule.position.Get_X()
    local dy = particule_2.position.Get_Y() - particule.position.Get_Y()
    return math.sqrt(dx*dx + dy*dy)
  end
  -- La fonction Gravite_Autour permet de faire tourner une particule autour d'une autre. On
  -- crée un vecteur de gravité et puis une variable numérique dans laquelle on récupère la 
  -- distance entre les deux particules concernées. Ensuite on donne au vecteur de gravité sa
  -- longueur: masse de la particule autour de laquelle la première particule va tourner
  -- divisée par la distance entre les deux particules au carré. Pour finir on ajoute le vecteur
  -- de gravité à la vélocité.
  particule.Gravite_Autour = function(particule_2)
    local grav = Vector(0, 0)
    local dist = particule.Distance_Vers(particule_2)
    grav.Set_Norme(particule_2.masse/(dist*dist))
    grav.Set_Angle(particule.Angle_Vers(particule_2))
    particule.velocite.Add_To(grav)
  end
  
  -- Autre fonction de gestion de la gravité entre deux particules.
  particule.Gravite_Vers = function(particule_2)
    local d = particule_2.position - particule.position
    local dist_sq = d.x^2 + d.y^2
    local dist = math.sqrt(dist_sq)
    local force = particule_2.masse / dist_sq
    local a = d / dist*force
    
    particule.velocite = particule.velocite + a
  end
  
  -- Fonction d'afffichage des particules. Pour l'instant seuls les cercles et les rectangles
  -- sont disponibles.
  particule.Draw = function(red, green, blue, pAlpha, pType)
    love.graphics.setColor(red, green, blue, pAlpha)
    if pType == "rect" then
      love.graphics.rectangle("fill", particule.position.x, particule.position.y, particule.size.x, particule.size.y)
    elseif pType == "circle" then
      love.graphics.circle("fill", particule.position.x, particule.position.y, particule.rayon)
    elseif pType == "image" then
      love.graphics.draw(particule.img, particule.position.x, particule.position.y, particule.rotation, 1, 1, particule.origine.x, particule.origine.y)
    end
    love.graphics.setColor(1, 1, 1, 1)
  end
  
  return particule
end

-- Fonction qui supprime les particules d'une liste.
function Remove_Dead_Particule(pElement)
  for i=#pElement,1,-1 do
    local p = pElement[i]
    if p.position.x - p.r >= largeur or
       p.position.x + p.r <= 0 or
       p.position.y - p.r >= hauteur or
       p.position.y + p.r <= 0 then
         table.remove(pElement,i)
    end
  end
end

function love.load()
  liste_particule = {}
  
  --Ajoute_Explosion(400, 300)
  --Ajoute_Explosion(100, 100)
end

function love.update(dt)
  for i=#liste_particule, 1, -1 do
    local particule = liste_particule[i]
    particule.x = particule.x + particule.vx
    particule.y = particule.y + particule.vy
    particule.vie = particule.vie - dt
    if particule.vie <= 0 then
      table.remove(liste_particule, i)
    end
  end
end

function love.draw()
  for i=1,#liste_particule do
    local particule = liste_particule[i]
    if particule.vie >= 0.1 then
      love.graphics.setColor(1, 1, 1)
    else
      love.graphics.setColor(1, 0, 0)
    end
    love.graphics.rectangle("fill", particule.x, particule.y, 5, 5)
  end
end

function Ajoute_Particule(pX, pY)
  particule = {}
  particule.x = pX
  particule.y = pY
  particule.vx = love.math.random(-300, 300)/100
  particule.vy = love.math.random(-300, 300)/100
  particule.vie = love.math.random(50, 300)/100
  table.insert(liste_particule, particule)
end

function Ajoute_Explosion(pX, pY)
  for i=1,50 do
    Ajoute_Particule(pX, pY)
  end
end

function love.mousepressed(x, y, button)
  if button == 1 then
    Ajoute_Explosion(x, y)
  end
end