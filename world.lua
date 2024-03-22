local world = {}

function world:Load()
-- CREATION DU WORLD
  world = love.physics.newWorld(0, 0, true)
  world:setCallbacks(Begin_Contact, End_Contact, Pre_Solve, Post_Solve)
end

function world:Update(dt)
  -- UPDATE DU WORLD
  world:update(dt)
end

return world