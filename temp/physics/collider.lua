function Collider_Astres_Bullets_Plane(dt)
  Collider_Astres_Bullets(dt)
  Collider_Astres_Plane(dt)
  Collider_Astres_Ovni(dt)
  Collider_Bullet_Plane_Ovni(dt)
  Collider_Plane_Ovni(dt)
  Collider_Bullet_Ovni_Plane(dt)
end

function Collider_Plane_Ovni(dt)
  if ovni_object.visible == false then return end
  if plane_object.collider == true then return end
  
  local min_dist = 25*ovni_object.transform.scale.x
  if math.Dist_Vector(plane_object.transform.move, ovni_object.transform.move) < min_dist then
    game:Dec_Live()
    explode_object:Start(
                                        plane_object.transform.move.x-80,
                                        plane_object.transform.move.y-80,
                                        plane_object.transform.scale.x+4)
    plane_object.collider = true
  end
end

function Collider_Bullet_Ovni_Plane(dt)
  if plane_object.collider == true then return end
  
  for i = #bullet_object.weapon.bullets,1,-1 do
    if bullet_object.weapon.bullets[i].ID == "bullet_ovni" then
      local min_dist = 25*plane_object.transform.scale.x
      if math.Dist_Vector(bullet_object.weapon.bullets[i].transform.move, plane_object.transform.move) < min_dist then
        game:Dec_Live()
        explode_object:Start(
                                        plane_object.transform.move.x-80,
                                        plane_object.transform.move.y-80,
                                        plane_object.transform.scale.x+4)
        plane_object.collider = true
        table.remove(bullet_object.weapon.bullets, i)
      end
    end
  end
end

function Collider_Bullet_Plane_Ovni(dt)
  if ovni_object.visible == false then return end
  
  for i = #bullet_object.weapon.bullets,1,-1 do
    if bullet_object.weapon.bullets[i].ID == "bullet_plane" then
      local min_dist = 25*ovni_object.transform.scale.x
      if math.Dist_Vector(bullet_object.weapon.bullets[i].transform.move, ovni_object.transform.move) < min_dist then
        game:Add_Score(ovni_object.points)
        explode_large_sound:play()
        ovni_object.collider = true
        table.remove(bullet_object.weapon.bullets, i)
      end
    end
  end
end

function Collider_Astres_Ovni(dt)
  if ovni_object.collider == true then return end
  
  for i = #asteroid_object.cailloux,1,-1 do
    local min_dist = 25*asteroid_object.cailloux[i].transform.scale.x
    if math.Dist_Vector(asteroid_object.cailloux[i].transform.move, ovni_object.transform.move) < min_dist then
      ovni_object.collider = true
      explode_object:Start(
                                        ovni_object.transform.move.x-80,
                                        ovni_object.transform.move.y-80, 2)
    end
  end
end

function Collider_Astres_Plane(dt)
  if plane_object.collider == true then return end
  
  for i=#asteroid_object.cailloux,1,-1 do
    local min_dist = 25*asteroid_object.cailloux[i].transform.scale.x
    if math.Dist_Vector(asteroid_object.cailloux[i].transform.move, plane_object.transform.move) < min_dist then
      game:Dec_Live()
      explode_object:Start(
                                        plane_object.transform.move.x-80,
                                        plane_object.transform.move.y-80,
                                        plane_object.transform.scale.x+4)
      plane_object.collider = true
    end
  end
end

function Collider_Astres_Bullets(dt)
  for i=#asteroid_object.cailloux,1,-1 do
    for j=#bullet_object.weapon.bullets,1,-1 do
      if asteroid_object.cailloux[i] == nil or bullet_object.weapon.bullets[j] == nil then return end
      
      local Nouveau_Caillou = game.assets_manager:Get_Object("asteroid"):Create()
      
      local min_dist = 25*asteroid_object.cailloux[i].transform.scale.x
      if math.Dist_Vector(bullet_object.weapon.bullets[j].transform.move, asteroid_object.cailloux[i].transform.move) < min_dist then
        if bullet_object.weapon.bullets[j].ID == "bullet_plane" then
          game:Add_Score(asteroid_object.cailloux[i].nb_points)
        end
        table.remove(bullet_object.weapon.bullets, j)
        
        explode_object:Start(
                      asteroid_object.cailloux[i].transform.move.x-10*asteroid_object.cailloux[i].transform.scale.x,
                      asteroid_object.cailloux[i].transform.move.y-10*asteroid_object.cailloux[i].transform.scale.y,
                      asteroid_object.cailloux[i].transform.scale.x)
        
        asteroid_object.cailloux[i].transform.scale.x = asteroid_object.cailloux[i].transform.scale.x - 1
        asteroid_object.cailloux[i].transform.scale.y = asteroid_object.cailloux[i].transform.scale.y - 1
        
        if asteroid_object.cailloux[i].points == 20 then
          asteroid_object.cailloux[i].points = 50
        elseif asteroid_object.cailloux[i].points == 50 then
          asteroid_object.cailloux[i].points = 100
        end
        
        if asteroid_object.cailloux[i].transform.scale.x then
          Nouveau_Caillou.points = asteroid_object.cailloux[i].points
          
          Nouveau_Caillou.transform.move = Add(asteroid_object.cailloux[i].transform.move, Mul(asteroid_object.cailloux[i].transform.scale, 20))
          
          Nouveau_Caillou.transform.rotation.x = asteroid_object.cailloux[i].transform.rotation.x
          Nouveau_Caillou.transform.rotation.y = asteroid_object.cailloux[i].transform.rotation.y
          Nouveau_Caillou.transform.rotation.speed = asteroid_object.cailloux[i].transform.rotation.speed
          
          Nouveau_Caillou.transform.scale.x = asteroid_object.cailloux[i].transform.scale.x
          Nouveau_Caillou.transform.scale.y = asteroid_object.cailloux[i].transform.scale.y
          
          Nouveau_Caillou.velocite.x = asteroid_object.cailloux[i].velocite.force.x
          Nouveau_Caillou.velocite.y = asteroid_object.cailloux[i].velocite.force.y + 5
          
          Nouveau_Caillou.velocite.acceleration = love.math.random(1, 4)
          
          asteroid_object:New(Nouveau_Caillou)
        end
      end
    end
  end
end