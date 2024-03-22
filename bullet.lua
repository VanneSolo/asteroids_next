local bullets = {}

bullets.rack = {}

function bullets:LoadEmitter(emitter)
  
end

-- INITIALISATION ET FONCTION DE CREATION DES BULLETS
function bullets:Create(emitter)
  local bullet = {}
  bullet.body = love.physics.newBody(world, emitter.body:getX()+emitter.img:getWidth()*math.cos(emitter.body:getAngle()), emitter.body:getY()+emitter.img:getWidth()*math.sin(emitter.body:getAngle()), "dynamic")
  bullet.body:isBullet(true)
  bullet.body:setUserData(bullet)
  bullet.shape = love.physics.newCircleShape(3)
  bullet.fixture = love.physics.newFixture(bullet.body, bullet.shape, 1)
  bullet.fixture:setUserData(bullet)
  bullet.speed = 7
  bullet.lifespan = 1
  bullet.snd = love.audio.newSource("player_shoot.wav", "stream")
  bullet.id  = "bullet"
  return bullet
end

-- UPDATE DE LA POSITION DES BULLETS ET DE LEUR DUREE DE VIE, JOUE UN SON DE TIR
function bullets:Update(dt, emitter)
  for i=#bullets.rack,1,-1 do
    self.rack[i].snd:play()
    self.rack[i].body:setAngle(emitter.body:getAngle())
    self.rack[i].body:applyLinearImpulse(self.rack[i].speed*math.cos(self.rack[i].body:getAngle()), self.rack[i].speed*math.sin(self.rack[i].body:getAngle()))
    self.rack[i].lifespan = self.rack[i].lifespan - 0.1
    
    -- REAPPARITION DU VAISSEAU S'IL SORT DE L'ECRAN
    if self.rack[i].body:getX() > largeur then
      self.rack[i].body:setX(0)
    elseif self.rack[i].body:getX() < 0 then
      self.rack[i].body:setX(largeur)
    end
    
    if self.rack[i].body:getY() > hauteur then
      self.rack[i].body:setY(0)
    elseif self.rack[i].body:getY() < 0 then
      self.rack[i].body:setY(hauteur)
    end
    
    -- GERE LEUR DESTRUCTION A LA FIN DE LEUR DUREE DE VIE
    if self.rack[i].lifespan <= 0 then
      table.remove(self.rack, i)
    end
  end
end
  
-- AFFICHAGE DES BULLETS
function bullets:Draw()
  love.graphics.setColor(0, 1, 0, 1)
  for i=1,#self.rack do
    love.graphics.circle("fill", self.rack[i].body:getX(), self.rack[i].body:getY(), self.rack[i].shape:getRadius())
  end
end

return bullets