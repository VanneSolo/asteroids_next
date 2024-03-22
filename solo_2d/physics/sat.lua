--[[
  Création de polygones réguliers.
]]
function Create_Regular_Polygon_Points(nb_points, rayon, rotation)
  local angle = (math.pi*2) / nb_points
  local poly_verts = {}
  for i=1,nb_points do
    local verts = Vector(rayon*math.cos(angle*i + rotation), rayon*math.sin(angle*i + rotation))
    table.insert(poly_verts, verts)
  end
  return poly_verts
end

--[[
  Création de rectangles.
]]

function Create_Rectangle_Points(longueur, largeur)
  local half_diag = math.sqrt((longueur/2)*(longueur/2) + (largeur/2)*(largeur/2))
  angle_diagonales = math.acos((longueur/2)/half_diag)
  local rect_verts = {}
  rect_verts[1] = Vector(half_diag*math.cos(angle_diagonales), half_diag*math.sin(angle_diagonales))
  rect_verts[2] = Vector(-half_diag*math.cos(angle_diagonales), half_diag*math.sin(angle_diagonales))
  rect_verts[3] = Vector(-half_diag*math.cos(angle_diagonales), -half_diag*math.sin(angle_diagonales))
  rect_verts[4] = Vector(half_diag*math.cos(angle_diagonales), -half_diag*math.sin(angle_diagonales))
  return rect_verts
end

--[[
  Update la position des vertices d'un polygone.
]]
function Create_Polygon(table_point, pos_x, pos_y, angle, pid)
  local ghost = {}
  ghost.verticies = {}
  ghost.forme = table_point
  ghost.centre = Vector(pos_x, pos_y)
  ghost.position = Vector(0, 0)
  ghost.size = Vector(0, 0)
  ghost.angle = angle
  ghost.ID = pid
  ghost.verticies_x = {}
  ghost.verticies_y = {}
  
  ghost.Update = function(dt)
    ghost.verticies = {}
    for j=1,#ghost.forme do
      local p = Vector(
        (ghost.forme[j].x*math.cos(ghost.angle)) - (ghost.forme[j].y*math.sin(ghost.angle)) + ghost.centre.x,
        (ghost.forme[j].x*math.sin(ghost.angle)) + (ghost.forme[j].y*math.cos(ghost.angle)) + ghost.centre.y
      )
      table.insert(ghost.verticies, p)
    end
    
    ghost.verticies_x = {}
    ghost.verticies_y = {}
    for i=1,#ghost.verticies do
      table.insert(ghost.verticies_x, ghost.verticies[i].x)
      table.insert(ghost.verticies_y, ghost.verticies[i].y)
    end
    table.sort(ghost.verticies_x)
    table.sort(ghost.verticies_y)
    ghost.position = Vector(ghost.verticies_x[1], ghost.verticies_y[1])
    ghost.size = Vector(ghost.verticies_x[#ghost.verticies_x]-ghost.verticies_x[1], ghost.verticies_y[#ghost.verticies_y]-ghost.verticies_y[1])
  end
  
  ghost.Draw = function()
    for i=1,#ghost.verticies do
      if i == #ghost.verticies then
        love.graphics.line(ghost.verticies[i].x, ghost.verticies[i].y, ghost.verticies[1].x, ghost.verticies[1].y)
      else
        love.graphics.line(ghost.verticies[i].x, ghost.verticies[i].y, ghost.verticies[i+1].x, ghost.verticies[i+1].y)
      end
    end
    for i=1,#ghost.verticies_x do
      --love.graphics.print(tostring(verticies_x[i]), 5, 5+16*(i-1))
      --love.graphics.rectangle("line", ghost.verticies_x[1], ghost.verticies_y[1], ghost.verticies_x[#ghost.verticies_x]-ghost.verticies_x[1], ghost.verticies_y[#ghost.verticies_y]-ghost.verticies_y[1])
      --love.graphics.rectangle("line", ghost.verticies_x[1], ghost.verticies_y[1], ghost.size.x, ghost.size.y)
    end
  end
  return ghost
end

--[[
  Implémentation du théorème des axes séparés.
]]
function SAT_Overlap(p1, p2)
  local poly_1 = p1
  local poly_2 = p2
  
  for shape=1,2 do
    if shape == 2 then
      poly_1, poly_2 = Swap(poly_1, poly_2)
    end
    
    for a=1,#poly_1.verticies do
      local b = a+1 % #poly_1.verticies
      if b > #poly_1.verticies then
        b = 1
      end
      
      local projected_axis = Vecteur_Normal(poly_1.verticies[a], poly_1.verticies[b])
      projected_axis.normalize()
      
      local min_p1 = math.huge
      local max_p1 = -math.huge
      for p=1,#poly_1.verticies do
        local q = poly_1.verticies[p].x*projected_axis.x + poly_1.verticies[p].y*projected_axis.y
        min_p1 = math.min(min_p1, q)
        max_p1 = math.max(max_p1, q)
      end
      
      local min_p2 = math.huge
      local max_p2 = -math.huge
      for p=1,#poly_2.verticies do
        local q = poly_2.verticies[p].x*projected_axis.x + poly_2.verticies[p].y*projected_axis.y
        min_p2 = math.min(min_p2, q)
        max_p2 = math.max(max_p2, q)
      end
      
      if not (max_p2>=min_p1) and (max_p1>=min_p2) then
        return false
      end
    end
    
  end
  return true
end

--[[
  Résolution des collisions entre deux polygones par la méthode du théorème des axes séparés. Utiliser Create_Poly_Points et
  Create_Polygone pour que ça fonctionne proprement.
]]
function SAT_Resolution(p1, p2)
  local poly_1 = p1
  local poly_2 = p2
  local overlap = math.huge
  
  for shape=1,2 do
    if shape == 2 then
      poly_1, poly_2 = Swap(poly_1, poly_2)
    end
    
    for a=1,#poly_1.verticies do
      local b = a+1
      if b > #poly_1.verticies then
        b = 1
      end
      local projected_axis = Vecteur_Normal(poly_1.verticies[a], poly_1.verticies[b])
      projected_axis.normalize()
      local min_p1 = math.huge
      local max_p1 = -math.huge
      for p=1,#poly_1.verticies do
        local q = poly_1.verticies[p].x*projected_axis.x + poly_1.verticies[p].y*projected_axis.y
        min_p1 = math.min(min_p1, q)
        max_p1 = math.max(max_p1, q)
      end
      
      local min_p2 = math.huge
      local max_p2 = -math.huge
      for p=1,#poly_2.verticies do
        local q = poly_2.verticies[p].x*projected_axis.x + poly_2.verticies[p].y*projected_axis.y
        min_p2 = math.min(min_p2, q)
        max_p2 = math.max(max_p2, q)
      end
      
      overlap = math.min(math.min(max_p1, max_p2)-math.max(min_p1, min_p2), overlap)
      if not (max_p2>=min_p1) and (max_p1>=min_p2) then
        return false
      end
    end
    
  end
  local dist = Vector(p2.centre.x-p1.centre.x, p2.centre.y-p1.centre.y)
  local s = math.sqrt(dist.x*dist.x + dist.y*dist.y)
  if overlap ~= math.huge and overlap ~= -math.huge then
    p1.centre.x = p1.centre.x - ((overlap*dist.x) / s)
    p1.centre.y = p1.centre.y - ((overlap*dist.y) / s)
  end
  return false
end

----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------

--[[
  Détection de collision entre deux polygones par leur diagonales.
]]
function Diags_Overlap(p1, p2)
  local poly_1 = p1
  local poly_2 = p2
  
  for shape=1,2 do
    if shape == 2 then
      poly_1, poly_2 = Swap(poly_1, poly_2)
    end
    
    for p=1,#poly_1.verticies do
      local diag_p1_start = poly_1.position
      local diag_p1_end = poly_1.verticies[p]
      
      for q=1,#poly_2.verticies do
        local side_p2_start = poly_2.verticies[q]
        local side_p2_end =  0 
        if q+1 > #poly_2.verticies then
          side_p2_end = poly_2.verticies[1]
        else
          side_p2_end = poly_2.verticies[q+1]
        end
        local h = (side_p2_end.x-side_p2_start.x)*(diag_p1_start.y-diag_p1_end.y) - (diag_p1_start.x-diag_p1_end.x)*(side_p2_end.y-side_p2_start.y)
        local t1 = ( (side_p2_start.y-side_p2_end.y)*(diag_p1_start.x-side_p2_start.x) + (side_p2_end.x-side_p2_start.x)*(diag_p1_start.y-side_p2_start.y) ) / h
        local t2 = ( (diag_p1_start.y-diag_p1_end.y)*(diag_p1_start.x-side_p2_start.x) + (diag_p1_end.x-diag_p1_start.x)*(diag_p1_start.y-side_p2_start.y) ) / h
        
        if (t1 >= 0 and t1 <1 and t2 >= 0 and t2 < 1) then
          return true
        end
        
      end
      
    end
    
  end
  return false
end

--[[
  Résolution des collisions entre deux polygones par la méthodes des diagonales.s
]]
function Diags_Resolution(p1, p2)
  local poly_1 = p1
  local poly_2 = p2
  
  for shape=1,2 do
    if shape == 2 then
      poly_1, poly_2 = Swap(poly_1, poly_2)
    end
    
    for p=1,#poly_1.verticies do
      local diag_p1_start = poly_1.position
      local diag_p1_end = poly_1.verticies[p]
      local displacement = Vector(0, 0)
      
      for q=1,#poly_2.verticies do
        local side_p2_start = poly_2.verticies[q]
        local side_p2_end =  0 
        if q+1 > #poly_2.verticies then
          side_p2_end = poly_2.verticies[1]
        else
          side_p2_end = poly_2.verticies[q+1]
        end
        local h = (side_p2_end.x-side_p2_start.x)*(diag_p1_start.y-diag_p1_end.y) - (diag_p1_start.x-diag_p1_end.x)*(side_p2_end.y-side_p2_start.y)
        local t1 = ( (side_p2_start.y-side_p2_end.y)*(diag_p1_start.x-side_p2_start.x) + (side_p2_end.x-side_p2_start.x)*(diag_p1_start.y-side_p2_start.y) ) / h
        local t2 = ( (diag_p1_start.y-diag_p1_end.y)*(diag_p1_start.x-side_p2_start.x) + (diag_p1_end.x-diag_p1_start.x)*(diag_p1_start.y-side_p2_start.y) ) / h
        
        if (t1 >= 0 and t1 <1 and t2 >= 0 and t2 < 1) then
          displacement.x = displacement.x + (1-t1) * (diag_p1_end.x-diag_p1_start.x)
          displacement.y = displacement.y + (1-t1) * (diag_p1_end.y-diag_p1_start.y)
        end
        
      end
      if shape == 1 then
        p1.position.x = p1.position.x + displacement.x*(-1)
        p1.position.y = p1.position.y + displacement.y*(-1)
      else
        p1.position.x = p1.position.x + displacement.x*1
        p1.position.y = p1.position.y + displacement.y*1
      end
    end
    
  end
  return false
end