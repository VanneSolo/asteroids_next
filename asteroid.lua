local asteroids = {}

-- CREATION D'UN ASTEROIDE
function asteroids:Create(pos_x, pos_y)
  local vx = love.math.random(1, 2)
  local vy = love.math.random(1, 2)
  local asteroid = {}
  asteroid.body = love.physics.newBody(world, pos_x, pos_y, "kinematic")
  asteroid.body:setUserData(asteroid)
  asteroid.shape = love.physics.newCircleShape(30)
  asteroid.fixture = love.physics.newFixture(asteroid.body, asteroid.shape, 10)
  asteroid.fixture:setUserData(asteroid)
  asteroid.id = "asteroid"
  if vx == 1 then
    asteroid.velx = -50
  elseif vx == 2 then
    asteroid.velx = 50
  end
  if vy == 1 then
    asteroid.vely = -50
  elseif vy == 2 then
    asteroid.vely = 50
  end
  asteroid.pv = 4
  asteroid.nb_lives = 3
  asteroid.is_alive = true
  return asteroid
end

-- CREATION DES ASTEROIDES
asteroids.liste = {}

function asteroids:Load(nb_ast)
  for i=1,nb_ast do
    table.insert(self.liste, self:Create(love.math.random(0, largeur), love.math.random(0, hauteur)))
  end
end

-- DEPLACEMENT DE L'ASTEROIDE
function asteroids:Update(dt)
  for i=1,#self.liste do
    if self.liste[i].body:isDestroyed() == false then
      self.liste[i].body:setLinearVelocity(self.liste[i].velx, self.liste[i].vely)
      if self.liste[i].body:getX() > largeur+self.liste[i].shape:getRadius() then
        self.liste[i].body:setX(-self.liste[i].shape:getRadius())
      end
      if self.liste[i].body:getX() < -self.liste[i].shape:getRadius() then
        self.liste[i].body:setX(largeur+self.liste[i].shape:getRadius())
      end
      if self.liste[i].body:getY() > hauteur+self.liste[i].shape:getRadius() then
        self.liste[i].body:setY(-self.liste[i].shape:getRadius())
      end
      if self.liste[i].body:getY() < -self.liste[i].shape:getRadius() then
        self.liste[i].body:setY(hauteur+self.liste[i].shape:getRadius())
      end
      if self.liste[i].is_alive == false then
        self.liste[i].body:destroy()
      end
    end
  end
  
end

-- AFFICHAGE DE L'ASTEROIDE
function asteroids:Draw()
  for i=1,#self.liste do
    if self.liste[i].body:isDestroyed() == false then
      love.graphics.setColor(1, 0.33, 0.47)
      love.graphics.circle("fill", self.liste[i].body:getX(), self.liste[i].body:getY(), self.liste[i].shape:getRadius())
      love.graphics.setColor(0, 0, 0.5)
      love.graphics.print("ast"..tostring(i), self.liste[i].body:getX(), self.liste[i].body:getY())
    end
  end
end

return asteroids