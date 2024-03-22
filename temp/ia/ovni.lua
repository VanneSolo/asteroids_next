local ovni = {
  velocite = {},
  transform = {}
}

function ovni:Load()
  self.velocite = {force = Vector(90, 90), acceleration = 0}
  self.transform = New_Object_Transform(0, 0, 0, 0, 4.5, 0.5, 0.5)
  
  self.size = Vector(ovni_img:getWidth(), ovni_img:getHeight())
  
  self.origine = Vector(self.size.x/2, self.size.y/2)
  
  self.collider = false
  self.visible = false
  self.tempo = 1
  self.points = 1000
  self.state = "check_collider"
  
  self.reload_time = 1.5
  self.ready = 0
end

function ovni:IA(dt)
  if self.tempo <= 7 and self.visible then
    self.state = "new_direction"
    self.tempo = 0
  end
  
  if self.state == "check_collider" and self.visible then
    if self.tempo - game.level <= 5 then return end
    
    for i,v in ipairs(asteroid_object.cailloux) do
      local min_dist = 50*v.transform.scale.x
      if math.Dist_Vector(v.transform.move, self.transform.move) then
        self.state = "hyperespace"
      end
    end
  end
  
  if self.state == "new_direction" then
    local _rn = math.random(3)
    if _rn == 1 then
      self.velocite.force.x = -self.velocite.force.x
    elseif _rn == 2 then
      self.velocite.force.y = -self.velocite.force.y
    else
      self.velocite.force = Opp(self.velocite.force)
    end
    self.state = "check_collider"
  end
  
  if self.state == "hyperespace" and self.visible then
    local _rn = math.random(2)
    if _rn == 1 and self.tempo >10 then
      self.transform.move.x = math.random(0+32, game.fenetre.size.x)
      self.transform.move.y = math.random(0+32, game.fenetre.size.y)
      self.tempo = 9
      self.state = "check_collider"
    end
  end
  self:Shoot(dt)
end

function ovni:Shoot(dt)
  if self.ready > 0 then
    self.ready = self.ready - dt
  end
  
  if self.ready <= 0 then
    table.insert(bullet_object.weapon.bullets, bullet_object.Create())
    local nb_bullet = #bullet_object.weapon.bullets
    local new_bullet = bullet_object.weapon.bullets[nb_bullet]
    
    new_bullet.ID = "bullet_ovni"
    self.ready = self.reload_time
    if self.scale == 1 then
      local _rn = math.random(3)
      if _rn == 1 then
        new_bullet.velocite.force.x = -1
      elseif _rn == 2 then
        new_bullet.velocite.force.y = -1
      else
        new_bullet.velocite.force.x = -1
        new_bullet.velocite.force.y = -1
      end
      new_bullet.velocite.force.Multiply_By(new_bullet.velocite.acceleration)
    else
      local angle = math.Angle_Vector(self.transform.move, plane_object.transform.move)
      if math.random(3) == 1 then
        new_bullet.velocite.force.x = math.cos(angle) * new_bullet.velocite.acceleration
        new_bullet.velocite.force.y = math.sin(angle) * new_bullet.velocite.acceleration
      else
        new_bullet.velocite.force.x = math.cos(angle*2) * new_bullet.velocite.acceleration
        new_bullet.velocite.force.y = math.sin(angle*2) * new_bullet.velocite.acceleration
      end
    end
    
    new_bullet.transform.move.x = self.transform.move.x
    new_bullet.transform.move.y = self.transform.move.y
  end
end

function ovni:New()
  self.visible = true
  self.collider = false
  
  self.score = (game.score.points<10000) and 1 or math.random(2)
  
  self.transform.move.x = 0
  self.transform.move.y = math.random(game.fenetre.size.y)
  
  if math.random(2) == 1 then self.velocite.force.x = -self.velocite.force.x end
  
  local _sc = (self.score == 1) and 1 or 0.5
  local _v1 = (self.score == 1) and 90 or 120
  local _pt = (self.score == 1) and 200 or 1000
  
  self.transform.scale.x = _sc
  self.transform.scale.y = _sc
  self.velocite.x = _v1
  self.velocite.y = _v1
  self.points = _pt
end

function ovni:Sound(dt)
  local _snd = (self.score == 1) and "snd_ovni_big" or "snd_ovni_small"
  game.assets_manager:Get_Sound(_snd):play()
end

function ovni:Update(dt)
  if self.tempo > 0 then
    self.tempo = self.tempo - dt
  end
  
  if self.visible then
    self:Sound(dt)
    if self.collider == true then
      self.visible = false
    end
    self:IA(dt)
    self.transform.move.Add_To(Mul(self.velocite.force, dt))
    Wrap_Around(self)
  end
  
  if self.tempo <= 0 then
    self.tempo = math.random(10, 15)
    if (#asteroid_object.cailloux < (5+((game.level - 1)*game.vies)) ) and self.visible == false then
      self:New()
    end
  end
end

function ovni:Draw()
  if self.visible then
    LG.draw(ovni_img,
            self.transform.move.x,
            self.transform.move.y,
            self.transform.rotation.x,
            self.transform.scale.x, self.transform.scale.y,
            self.origine.x, self.origine.y)
  end
end

function ovni:Debug()
  if game.debug then
    LG.print("Visible ovni: "..tostring(self.visible), 9, 80)
  end
end

return ovni