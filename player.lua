-- INITIALISATION DU PLAYER
local player = {}
local bullet = require "bullet"

-- DEFINITION DES PARAMETRES DU PLAYER
function player:Load()
  player.body = love.physics.newBody(world, largeur/2, hauteur/2, "dynamic")
  player.body:setUserData(player)
  player.points = Create_1D_Table(Create_Regular_Polygon_Points(3, 25, 0))
  player.shape = love.physics.newPolygonShape(player.points)
  player.fixture = love.physics.newFixture(player.body, player.shape, 2)
  player.fixture:setUserData(player)
  player.sound = love.audio.newSource("sounds/player_ship_2.wav", "static")
  player.img = love.graphics.newImage("red_ship.png")
  player.speed = 0
  player.speed_max = 400
  player.id = "player"
  player.pv = 5
  player.nb_lives = 3
end

-- ROTATION DU PLAYER
function player:Update(dt)
  if love.keyboard.isDown("left") then
    player.body:setAngle(player.body:getAngle()-0.1)
  end
  if love.keyboard.isDown("right") then
    player.body:setAngle(player.body:getAngle()+0.1)
  end
  
  
  -- UPDATE DE LA POSITION DU PLAYER EN PRENANT EN COMPTE LA ROTATION
  if love.keyboard.isDown("up") then
    player.speed = 20
    player.body:applyLinearImpulse(player.speed*math.cos(player.body:getAngle()), player.speed*math.sin(player.body:getAngle()))
    -- RECUPERATION DE LA VELOCITE DU PLAYER
    local x, y = player.body:getLinearVelocity()
    -- CAP DE LA VELOCITE QUAND X OU Y DEPASSE UNE CERTAINE VALEUR
    if x >= player.speed_max then
      player.body:setLinearVelocity(player.speed_max, y)
    end
    if x <= -player.speed_max then
      player.body:setLinearVelocity(-player.speed_max, y)
    end
    if y >= player.speed_max then
      player.body:setLinearVelocity(x, player.speed_max)
    end
    if y <= -player.speed_max then
      player.body:setLinearVelocity(x, -player.speed_max)
    end
    
    -- CAP DE LA VELOCITE QUAND X ET Y DEPASSENT UNE CERTAINE VALEUR
    if x >= player.speed_max and y >= player.speed_max then
      player.body:setLinearVelocity(player.speed_max, player.speed_max)
    end
    if x >= player.speed_max and y <= -player.speed_max then
      player.body:setLinearVelocity(player.speed_max, -player.speed_max)
    end
    if x <= -player.speed_max and y >= player.speed_max then
      player.body:setLinearVelocity(-player.speed_max, player.speed_max)
    end
    if x <= -player.speed_max and y <= -player.speed_max then
      player.body:setLinearVelocity(-player.speed_max, -player.speed_max)
    end
    
    -- SON DU MOTEUR DU PLAYER
    player.sound:play()
  else
    -- ARRET DU VAISSEAU SI ON LACHE LA TOUCHE UP
    player.speed = player.speed * 0.95
    if player.speed < 0.5 then
      player.speed = 0
    end
    local x, y = player.body:getLinearVelocity()
    player.body:setLinearVelocity(x*0.95, y*0.95)
    if x < 0.5 then
      x = 0
    end
    if y < 0.5 then
      y = 0
    end
  end
  
  -- COUPE LA ROTATION QUAND ON LACHE LA TOUCHE LEFT OU RIGHT POUR EVITER
  -- QUE LE VAISSEAU CONTINUE A TOURNER
  player.body:setAngularVelocity(0)
  
  -- REAPPARITION DU VAISSEAU S'IL SORT DE L'ECRAN
  if player.body:getX() > largeur then
    player.body:setX(0)
  elseif player.body:getX() < 0 then
    player.body:setX(largeur)
  end
  
  if player.body:getY() > hauteur then
    player.body:setY(0)
  elseif player.body:getY() < 0 then
    player.body:setY(hauteur)
  end
  
  bullet:Update(dt, player)
end

-- AFFICHAGE DU PLAYER
function player:Draw()
  bullet:Draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(player.img, player.body:getX(), player.body:getY(), player.body:getAngle(), 1, 1, player.img:getWidth()/2-5, player.img:getHeight()/2)
  
  --love.graphics.print("nombre de munitions: "..tostring(#bullet.rack), 5, 5+16)
end

function player:Keypressed(key)
  if key == "space" then
    table.insert(bullet.rack, bullet:Create(self))
  end
end

return player