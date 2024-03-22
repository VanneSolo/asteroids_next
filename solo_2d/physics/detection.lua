--[[
  Collision entre deux points.
]]
function Point_Vs_Point(p1, p2, p_dist)
  if Dist(p1, p2) < p_dist then
    return true
  end
  return false
end

--[[
  Fonction de détection d'une collision entre un point et un cercle.
]]
function Point_Vs_Circle(p_point, p_cercle, p_rayon)
  if Dist(p_point, p_cercle) <= p_rayon then
    return true
  end
  return false
end

--[[
  Fonction de détection de collisions entre deux cercles.
]]
function Circle_Vs_Circle(p_cercle_1, p_cercle_2, p_rayon_1, p_rayon_2)
  if Dist(p_cercle_1, p_cercle_2) <= p_rayon_1+p_rayon_2 then
    return true
  end
  return false
end

--[[
  Fonction de détection de collisions entre un point et un rectangle.
]]
function Point_Vs_Rect(p_point, p_rect)
  if p_point.x > p_rect.position.x and p_point.x < p_rect.position.x+p_rect.size.x and p_point.y > p_rect.position.y and p_point.y < p_rect.position.y+p_rect.size.y then
    return true
  end
  return false
end

--[[
  Fonction de détection de collisions entre deux rectangles.
]]
function Rect_Vs_Rect(rect_1, rect_2)
  if rect_1.position.x+rect_1.size.x > rect_2.position.x and rect_1.position.x < rect_2.position.x+rect_2.size.x and rect_1.position.y+rect_1.size.y > rect_2.position.y and rect_1.position.y < rect_2.position.y+rect_2.size.y then
    return true
  end
  return false
end

--[[
  Détection de collisions entre un cercle et un rectangle.
]]
function Circle_Vs_Rectangle(p_cercle, p_rayon, p_rect)
  local test = Vector(p_cercle.position.x, p_cercle.position.y)
  
  if p_cercle.position.x < p_rect.position.x then
    test.x = p_rect.position.x
  elseif p_cercle.position.x > p_rect.position.x+p_rect.size.x then
    test.x = p_rect.position.x+p_rect.size.x
  end
  if p_cercle.position.y < p_rect.position.y then
    test.y = p_rect.position.y
  elseif p_cercle.position.y > p_rect.position.y+p_rect.size.y then
    test.y = p_rect.position.y+p_rect.size.y
  end
  
  local diff = Sub(p_cercle.position, test)
  local dist = math.sqrt(diff.x*diff.x + diff.y*diff.y)
  
  if dist <= p_rayon then
    return true
  end
  return false
end

--[[
  Détection de collisions entre un point et une ligne.
]]
function Point_Vs_Line(p_point, p_ligne_p1, p_ligne_p2)
  local dist_1 = Dist(p_point.position, p_ligne_p1.position)
  local dist_2 = Dist(p_point.position, p_ligne_p2.position)
  local line_length = Dist(p_ligne_p1.position, p_ligne_p2.position)
  local offset = 0.05
  
  if dist_1+dist_2 >= line_length-offset and dist_1+dist_2 <= line_length+offset then
    return true
  end
  return false
end

--[[
  Détection de collisions entre un cercle et une ligne.
]]
function Circle_Vs_Line(p_centre, p_rayon, p_ligne_p1, p_ligne_p2)
  if p_centre.pos == nil then
    local inside_1 = Point_Vs_Circle(p_ligne_p1.position, p_centre, p_rayon)
    local inside_2 = Point_Vs_Circle(p_ligne_p2.position, p_centre, p_rayon)
  else
    local inside_1 = Point_Vs_Circle(p_ligne_p1.position, p_centre.position, p_rayon)
    local inside_2 = Point_Vs_Circle(p_ligne_p2.position, p_centre.position, p_rayon)
  end
  
  if inside_1 or inside_2 then
    return true
  end
  
  local line_length = Dist(p_ligne_p1.pos, p_ligne_p2.pos)
  local center_to_p1 = 0
  if p_centre.position == nil then
    center_to_p1 = Sub(p_centre, p_ligne_p1.position)
  else
    center_to_p1 = Sub(p_centre.position, p_ligne_p1.position)
  end
  local p2_to_p1 = Sub(p_ligne_p2.position, p_ligne_p1.position)
  local dot = Dot(center_to_p1, p2_to_p1) / math.pow(line_length, 2)
  local closest = {} 
  closest.pos = Add(p_ligne_p1.position, Mul(dot, p2_to_p1))
  
  local on_segment = Point_Vs_Line(closest, p_ligne_p1, p_ligne_p2)
  if not on_segment then
    return false
  end
  local diff = 0
  if p_centre.position == nil then
    diff = Sub(closest.position, p_centre)
  else
    diff = Sub(closest.position, p_centre.position)
  end
  local dist = math.sqrt(diff.x*diff.x + diff.y*diff.y)
  if dist <= p_rayon then
    return true
  end
  return false
end

--[[
  Verifie si l'une des extrémités d'un segment est compris entre les deux points d'un autre segment.
]]
function Segment_Overlap(min_1, max_1, min_2, max_2)
  if math.max(min_1, max_1) >= math.min(min_2, max_2) and
    math.min(min_1, max_1) <= math.max(min_2, max_2) then
      return true
  end
  return false
end

--[[
  Calcule d'intersection entre deux lignes.
]]

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

--[[
  Calcul du point d'intersection entre une droite et un segment.
]]
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

--[[
  Fonction qui calcule le point d'intersection entre deux segments.
]]
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

--[[
  Détection de collision entre une ligne et un rectangle.
]]
function Line_Vs_Rectangle(p_ligne_p1, p_ligne_p2, p_rect_pos, p_rect_size)
  local rect_haut_gauche = Vector(p_rect_position.x, p_rect_position.y)
  local rect_haut_droite = Vector(p_rect_position.x+p_rect_size.x, p_rect_position.y)
  local rect_bas_gauche = Vector(p_rect_position.x, p_rect_position.y+p_rect_size.y)
  local rect_bas_droite = Vector(p_rect_position.x+p_rect_size.x, p_rect_position.y+p_rect_size.y)
  
  local right = Segment_Intersect(p_ligne_p1, p_ligne_p2, rect_haut_droite, rect_bas_droite)
  local down = Segment_Intersect(p_ligne_p1, p_ligne_p2, rect_bas_gauche, rect_bas_droite)
  local left = Segment_Intersect(p_ligne_p1, p_ligne_p2, rect_haut_gauche, rect_bas_gauche)
  local up = Segment_Intersect(p_ligne_p1, p_ligne_p2, rect_haut_gauche, rect_haut_droite)
  
  if right or down or left or up then
    return true
  end
  return false
end

--[[
  Détection de collision entre un point et un polygone.
]]
function Point_Vs_Polygon(p_point, p_polygone)
  local collision = false
  
  local suivant = 1
  for current=1,#p_polygone do
    local suivant = current + 1
    if suivant == #p_polygone+1 then
      suivant = 1
    end
    
    local v_current = p_polygone[current]
    local v_suivant = p_polygone[suivant]
    
    if (v_current.y>p_point.y)~=(v_suivant.y>p_point.y) and p_point.x < (v_suivant.x-v_current.x)*(p_point.y-v_current.y)/(v_suivant.y-v_current.y) + v_current.x then
      collision = not collision
    end
    
  end
  return collision
end

--[[
  Détection de collision entre un cercle et un polygone.
]]
function Circle_Vs_Polygon(p_polygone, p_centre, p_rayon)
  local suivant = 1
  
  for current=1,#p_polygone do
    suivant = current+1
    if suivant == #p_polygone+1 then
      suivant = 1
    end
    local v_current = {}
    v_current.position = Vector(p_polygone[current].x, p_polygone[current].y)
    
    local v_suivant = {}
    v_suivant.position = Vector(p_polygone[suivant].x, p_polygone[suivant].y)
    
    local collision = Circle_Vs_Line(p_centre, p_rayon, v_current, v_suivant)
    if collision then
      return true
    end
  end
  local center_inside = Point_Vs_Polygon(p_centre, p_polygone)
  if center_inside then
    return true
  end
  return false
end

--[[
  Détection de collision entre un rectangle et un polygone.
]]
function Rect_Vs_Polygon(p_polygone, p_rect_pos, p_rect_size)
  local suivant = 1
  for current=1,#p_polygone do
    suivant = current + 1
    if suivant == #p_polygone+1 then
      suivant = 1
    end
    local v_current = Vector(p_polygone[current].x, p_polygone[current].y)
    local v_suivant = Vector(p_polygone[suivant].x, p_polygone[suivant].y)
    local collision = Line_Vs_Rectangle(v_current, v_suivant, p_rect_pos, p_rect_size)
    if collision then
      return true
    end
    
    local inside = Point_Vs_Polygon(p_rect_pos, p_polygone)
    if inside then
      return true
    end
  end
  return false
end

--[[
  Détection de collision entre une ligne et un polygone.
]]
function Line_Vs_Polygon(p_polygone, p_ligne_p1, p_ligne_p2)
  suivant = 1
  for current=1,#p_polygone do
    suivant = current+1
    if suivant == #p_polygone+1 then
      suivant = 1
    end
    
    local v_current = Vector(p_polygone[current].x, p_polygone[current].y)
    local v_suivant = Vector(p_polygone[suivant].x, p_polygone[suivant].y)
    local collision = Segment_Intersect(p_ligne_p1, p_ligne_p2, v_current, v_suivant)
    if collision then
      return true
    end
  end
  return false
end

--[[
  Détection de collision entre deux polygones.
]]
function Polygon_Vs_Polygon(poly_1, poly_2)
  local suivant = 1
  for current=1,#poly_1 do
    suivant = current + 1
    if suivant == #poly_1+1 then
      suivant = 1
    end
    
    local v_current = poly_1[current]
    local v_suivant = poly_1[suivant]
    local collision = Line_Vs_Polygon(poly_2, v_current, v_suivant)
    if collision then
      return true
    end
    local inside = Point_Vs_Polygon(poly_1[1], poly_2)
    if inside then
      return true
    end
  end
  return false
end

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
--[[
  Détection de collision entre deux polygones concaves.
]]
function Check_Star_Collision(star_a, star_b)
  for i=1,#star_a do
    local p0 = star_a[i]
    local p1 = star_a[i+1]
    if  i == #star_a then
      p0 = star_a[i]
      p1 = star_a[1]
    end
    
    for j=1,#star_b do
      local p2 = star_b[j]
      local p3 = star_b[j+1]
      if j == #star_b then
        p2 = star_b[j]
        p3 = star_b[1]
      end
      
      if Line_Intersect(p0, p1, p2, p3, true, true) then
        return true
      end
    end
  end
  return false
end

--[[
  Construit les normales des côtés d'un rectangle.
]]
function Construct_Normal(player, target)
  local contact_normal = Vector(0, 0)
  local inv_dir = Vector(0, 0)
  inv_dir.x = 1/player.velocite.x
  inv_dir.y = 1/player.velocite.y
  
  local t_near = Vector(0, 0)
  t_near.x = (target.position.x-(player.position.x+player.size.x/2)) * inv_dir.x
  t_near.y = (target.position.y-(player.position.y+player.size.y/2)) * inv_dir.y
  
  local t_far = Vector(0, 0)
  t_far.x = ((target.position.x+target.size.x)-(player.position.x+player.size.x/2)) * inv_dir.x
  t_far.y = ((target.position.y+target.size.y)-(player.position.y+player.size.y/2)) * inv_dir.y
  
  if type(t_near.x) ~= "number" or type(t_near.y) ~= "number" then return false end
  if type(t_far.x) ~= "number" or type(t_far.y) ~= "number" then return false end
  
  if t_near.x > t_far.x then t_near.x, t_far.x = Swap(t_near.x, t_far.x) end
  if t_near.y > t_far.y then t_near.y, t_far.y = Swap(t_near.y, t_far.y) end
  
  if t_near.x > t_far.y or t_near.y > t_far.x then return false end
  
  local t_hit_near = math.max(t_near.x, t_near.y)
  local t_hit_far = math.min(t_far.x, t_far.y)
  
  if t_hit_far < 0 then return false end
  
  if t_near.x > t_near.y then
    if inv_dir.x < 0 then
      contact_normal = Vector(1, 0)
    else
      contact_normal = Vector(-1, 0)
    end
  elseif t_near.x < t_near.y then
    if inv_dir.y < 0 then
      contact_normal = Vector(0, 1)
    else
      contact_normal = Vector(0, -1)
    end
  end
  return contact_normal
end