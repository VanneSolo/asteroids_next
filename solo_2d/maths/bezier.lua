--[[

  Lerp_Line -> On prend trois points (x1, y1, x2, y2, x3, y3), qui serviront à créer
  deux segment qui se suivent. On crée deux autres points (pA, pB) qui glisseront sur
  les deux segments précédemment crées. On initialise aussi une variable t qui servira
  à update la position de pA et pB.
  
  Dans l'update on augmente à chaque frames t et on Lerp la position de pA et pB.

]]
function Lerp_Line(x1, y1, x2, y2, x3, y3)
  local p1 = Point(x1, y1)
  local p2 = Point(x2, y2)
  local p3 = Point(x3, y3)
  local pA = {p1.x, p1.y}
  local pB = {p2.x, p2.y}
  local t = 0
  local ghost = {}
  ghost.Update = function(dt)
    t = t + 0.01
    t = math.min(t, 1)
    pA.x = Lerp(t, p1.x, p2.x)
    pA.y = Lerp(t, p1.y, p2.y)
    pB.x = Lerp(t, p2.x, p3.x)
    pB.y = Lerp(t, p2.y, p3.y)
  end
  ghost.Draw = function()
    love.graphics.circle("fill", p1.x, p1.y, 4)
    love.graphics.circle("fill", p2.x, p2.y, 4)
    love.graphics.circle("fill", p3.x, p3.y, 4)
    love.graphics.circle("fill", pA.x, pA.y, 4)
    love.graphics.circle("fill", pB.x, pB.y, 4)
    love.graphics.line(p1.x, p1.y, p2.x, p2.y)
    love.graphics.line(p2.x, p2.y, p3.x, p3.y)
    love.graphics.line(pA.x, pA.y, pB.x, pB.y)
    
    Indique_Point(p1, "p1", 0, 25)
    Indique_Point(p2, "p2", 0, -25)
    Indique_Point(p3, "p3", -50, 25)
    Indique_Point(pA, "pA", 0, 25)
    Indique_Point(pB, "pB", -50, -25)
    Affiche_Variable("time", t, 5, 5)
  end
  return ghost
end

--[[

  Construct_Bezier. Même principe que Lerp_Line en plus avancé:
  --> On part avec quatre points (donc trois segments).
  --> Ensuite on a trois points mobiles: A, B, C qui vont parcourir les trois segments.
  --> Encore deux autres points mobiles, M et N qui vont parcourir les segments AB et BC.
  --> Enfin un dernier point mobile qui va slider sur MN.
  --> Système d'animation de la courbe plus poussé:
      - Gérer si on anime les mouvements des différents points (Start Demo).
      - Dans l'update, on gère l'aller retour de t et on lerp les positions des points
        A, B, C M, N et final.

]]
function Construct_Bezier(x1, y1, x2, y2, x3, y3, x4, y4)
  local p1 = Point(x1, y1)
  local p2 = Point(x2, y2)
  local p3 = Point(x3, y3)
  local p4 = Point(x4, y4)
  local pA = {p1.x, p1.y}
  local pB = {p2.x, p2.y}
  local pC = {}
  local pM = {}
  local pN = {}
  local pfinal = {}
  local t = 0
  local max_t = 0
  local dir  = 0.01
  local animate = false
  local ghost = {}
  ghost.Start_Demo = function(key)
    if key == "space" then
      if animate == false then
        animate = true
      else
        animate = false
      end
    end
  end
  ghost.Update = function(dt)
    if animate then
      max_t = max_t + dir
      if max_t >= 1 then
        max_t = 1
        dir = dir*-1
      elseif max_t <= 0 then
        max_t = 0
        dir = dir*-1
      end
    end
    for t=0, max_t, 0.01 do
      pA.x = Lerp(t, p1.x, p2.x)
      pA.y = Lerp(t, p1.y, p2.y)
      pB.x = Lerp(t, p2.x, p3.x)
      pB.y = Lerp(t, p2.y, p3.y)
      
      pC.x = Lerp(t, p3.x, p4.x)
      pC.y = Lerp(t, p3.y, p4.y)
      pM.x = Lerp(t, pA.x, pB.x)
      pM.y = Lerp(t, pA.y, pB.y)
      pN.x = Lerp(t, pB.x, pC.x)
      pN.y = Lerp(t, pB.y, pC.y)
      
      pfinal.x = Lerp(t, pM.x, pN.x)
      pfinal.y = Lerp(t, pM.y, pN.y)
    end
  end
  ghost.Draw = function()
    love.graphics.circle("fill", p1.x, p1.y, 4)
    love.graphics.circle("fill", p2.x, p2.y, 4)
    love.graphics.circle("fill", p3.x, p3.y, 4)
    love.graphics.circle("fill", p4.x, p4.y, 4)
    love.graphics.circle("fill", pA.x, pA.y, 4)
    love.graphics.circle("fill", pB.x, pB.y, 4)
    love.graphics.circle("fill", pC.x, pC.y, 4)
    love.graphics.circle("fill", pM.x, pM.y, 4)
    love.graphics.circle("fill", pN.x, pN.y, 4)
    love.graphics.circle("fill", pfinal.x, pfinal.y, 4)
    love.graphics.line(p1.x, p1.y, p2.x, p2.y)
    love.graphics.line(p2.x, p2.y, p3.x, p3.y)
    love.graphics.line(p3.x, p3.y, p4.x, p4.y)
    love.graphics.line(pA.x, pA.y, pB.x, pB.y)
    love.graphics.line(pB.x, pB.y, pC.x, pC.y)
    love.graphics.line(pM.x, pM.y, pN.x, pN.y)
    love.graphics.line(p1.x, p1.y, pfinal.x, pfinal.y)
    
    Indique_Point(p1, "p1", 0, 25)
    Indique_Point(p2, "p2", 0, -25)
    Indique_Point(p3, "p3", -50, 25)
    Indique_Point(p4, "p4", -50, -25)
    Indique_Point(pA, "pA", -100, 10)
    Indique_Point(pB, "pB", -100, 10)
    Affiche_Variable("time", max_t, 5, 5)
    Affiche_Variable("animate", animate, 5, 5+16)
  end
  return ghost
end

--[[

  Draw_Bezier_By_CP --> dessine une courbe de bézier qui passe réellement par les
                        trois points passés en paramètres. Pour ce faire, on multiplie
                        par deux les coordonnées du point du milieu et on soustrait la
                        somme des coordonnées des points un et trois qu'on divise par
                        deux.

]]
function Draw_Bezier_By_CP(x1, y1, x2, y2, x3, y3)
  local p1 = Point(x1, y1)
  local p2 = Point(x2, y2)
  local p3 = Point(x3, y3)
  local cp = {}
  cp.x = p2.x*2 - (p1.x+p3.x)/2
  cp.y = p2.y*2 - (p1.y+p3.y)/2
  local bezier_curve = love.math.newBezierCurve(p1.x, p1.y, cp.x, cp.y, p3.x, p3.y)
  local ghost = {}
  ghost.Draw = function()
    Draw_Points(p1, 3)
    Draw_Points(p2, 3)
    Draw_Points(p3, 3)
    Draw_Points(cp, 3)
    
    Draw_Lines(p1, cp)
    Draw_Lines(cp, p3)
    Render_Bezier(bezier_curve)
  end
  return ghost
end

--[[

  Multipoints_Curve. Permet de créer une courbe de bézier avec de multilpes points de contrôle.

]]
function Multipoints_Curve(p_table)
  display_points = true
  display_lines = true
  display_bezier = true
  
  local control_points = {}
  for i=2, #p_table-2 do
    local p = {x = (p_table[i].x+p_table[i+1].x)/2, y = (p_table[i].y+p_table[i+1].y)/2}
    table.insert(control_points, p)
  end
  
  local init_curves = {}
  init_curves[1] = love.math.newBezierCurve(p_table[1].x, p_table[1].y, p_table[2].x, p_table[2].y, control_points[1].x, control_points[1].y)
  for i=1,#control_points-1 do
    local curve = love.math.newBezierCurve(control_points[i].x,control_points[i].y,p_table[i+2].x,p_table[i+2].y, control_points[i+1].x, control_points[i+1].y)
    table.insert(init_curves, curve)
  end
  init_curves[#init_curves+1] = love.math.newBezierCurve(control_points[#control_points].x, control_points[#control_points].y, p_table[#p_table-1].x, p_table[#p_table-1].y, p_table[#p_table].x, p_table[#p_table].y)
  
  local ghost = {}
  
  ghost.Draw = function()
    if display_points then
      for i=1,#p_table do
        love.graphics.setColor(0, 0, 1)
        Draw_Points(p_table[i], 3)
        love.graphics.print(i, p_table[i].x+10, p_table[i].y)
      end
      for i=1,#control_points do
        love.graphics.setColor(0, 1, 0)
        Draw_Points(control_points[i], 3)
      end
    end
    love.graphics.setColor(1, 1, 1)
    if display_lines then
      for i=1,#p_table-1 do
        Draw_Lines(p_table[i], p_table[i+1])
      end
    end
    love.graphics.setColor(1, 1, 1)
    if display_bezier then
      for i=1,#init_curves do
        love.graphics.setColor(1, 0, 0)
        love.graphics.line(init_curves[i]:render())
      end
    end
    love.graphics.setColor(1, 1, 1)
  end
  
  ghost.Keys = function(key)
    if key == "kp1" then
      if display_bezier then
        display_bezier = false
      else
        display_bezier = true
      end
    elseif key == "kp2" then
      if display_lines then
        display_lines = false
      else
        display_lines = true
      end
    elseif key == "kp3" then
      if display_points then
        display_points = false
      else
        display_points = true
      end
    end
  end
  
  return ghost
end

--[[

  Créer une courbe de bézier dont les points de contrôle peuvent être bougés avec la souris.

]]
function Dragable_Bezier(p_rayon)
  local handle = {}
  for i=1,4 do
    local h = {}
    h.p = Point(largeur*RND(), hauteur*RND())
    h.colored = false
    table.insert(handle, h)
  end
  local handle_r = p_rayon
  local curve = love.math.newBezierCurve(handle[1].p.x, handle[1].p.y, handle[2].p.x, handle[2].p.y, handle[3].p.x, handle[3].p.y, handle[4].p.x, handle[4].p.y)
  local ghost = {}
  ghost.Update = function(dt)
    local mouse_x, mouse_y = love.mouse.getPosition()
    for i=1,#handle do
      local grabbed = handle[i]
      grabbed.colored = false
    end
    
    if love.mouse.isDown(1) then
      for i=1,#handle do
        local grabbed = handle[i]
        if Point_Vs_Circle(mouse_x, mouse_y, grabbed.p.x, grabbed.p.y, handle_r) then
          grabbed.colored = true
          grabbed.p.x = mouse_x
          grabbed.p.y = mouse_y
        end
      end
    end
    
    curve = love.math.newBezierCurve(handle[1].p.x, handle[1].p.y, handle[2].p.x, handle[2].p.y, handle[3].p.x, handle[3].p.y, handle[4].p.x, handle[4].p.y)
  end
  ghost.Draw = function()
    for i=1,#handle do
      local grabbed = handle[i]
      if grabbed.colored then
        love.graphics.setColor(1, 0, 0)
      else
        love.graphics.setColor(1, 1, 1)
      end
      Draw_Points(grabbed.p, handle_r)
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.line(curve:render())
  end
  return ghost
end

--[[

  Draw_Bezier. Autre fonction de creation eet d'afichage de courbe de Bézier. Il faut
  que je vérifie comment ça marche exactement, j'ai l'impresion qu'il manque des trucs.

]]
function Draw_Bezier(p_table_points, p_dir)
  local bezier_curve = love.math.newBezierCurve(p_table_points)
  local time = 0
  local move = p_dir
  local pfinal = {}
  local ghost = {}
  ghost.Update = function(dt, p_type_move)
    if p_type_move == "fixe" then
      time = 1.01
    elseif p_type_move == "restart" then
      time = time + move
      if time >= 1 then
        time = 0
      end
    elseif p_type_move == "va_et_vient" then
      time = time + move
      if time >= 1 or time <= 0 then
        move = -move
      end
    end
  end
  ghost.Draw = function(p_draw_points, color)
    if p_draw_points then
      for i=1,#p_table_points do
        if i % 2 ~= 0 then
          if color then
            if i == 1 then
              love.graphics.setColor(1, 0, 0)
            elseif i == #p_table_points-1 then
              love.graphics.setColor(0, 1, 0)
            else
              love.graphics.setColor(1, 1, 1)
            end
          end
          love.graphics.circle("fill", p_table_points[i], p_table_points[i+1], 5)
          love.graphics.print(tostring((i/2-0.5)+1), p_table_points[i]+25, p_table_points[i+1])
        end
      end
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.line(bezier_curve:render())
    local points = {}
    for i=1,#p_table_points do
      if i % 2 ~= 0 then
        local p = Point(p_table_points[i], p_table_points[i+1])
        table.insert(points, p)
      end
    end
    if #p_table_points/2 == 3 then
      for i=0,time,move do
        Quadratic_Bezier(points[1], points[2], points[3], i, pfinal)
        love.graphics.circle("line", pfinal.x, pfinal.y, 10)
      end
    elseif #p_table_points/2 == 4 then
      for i=0,time,math.abs(move) do
        Cubic_Bezier(points[1], points[2], points[3], points[4], i, pfinal)
        love.graphics.circle("line", pfinal.x, pfinal.y, 10)
      end
    end
  end
  return ghost
end

--[[

  Création de courbes de Bézier, ce bout de code doit venir d'un live gamecodeur.
  -> On crée une courbe de Bézier made in love2d.
  -> Une variable progression qui va servir à générer les différents points de la courbe.
  -> Une table qui va contenir les points de la courbe.
  -> Des valeurs aléatoires pour la couleur des différents points.
  -> Un appel à la fonction Genere_Courbe; je ne suis pas certain qu'il soit très utile,
      faudra que je vérifie.
      
  -> Dans l'update, à chaque frame on maj progression. Ensuite on récupère
     les coordonnées de chaque point de la courbe. A partir de ces coordonnées,
     on crée des particules le long de la courbe. On met à jour les paramètres
     de chaque particule. On supprime les particules devenues inutiles. De temps
     en temps on reset progression et on genère une nouvelle courbe.

]]
function love.load()
  largeur = love.graphics.getWidth()
  hauteur = love.graphics.getHeight()
  
  courbe = love.math.newBezierCurve({1, hauteur/2, largeur/2, 1, largeur, hauteur/2})
  --love.graphics.setPointSize(3)
  progression = 0
  liste_particules = {}
  r = love.math.random()
  g = love.math.random()
  b = love.math.random()
  
  Genere_Courbe()
end

function love.update(dt)
  local x,y = courbe:evaluate(progression)
  for i=1,5 do
    Ajoute_Particules(x, y)
  end
  progression = progression + 0.01
  if progression > 1 then
    progression = 0
    Genere_Courbe()
  end
  for i=#liste_particules,1,-1 do
    p = liste_particules[i]
    p.vie = p.vie - dt
    p.x = p.x + p.vx*dt
    p.y = p.y + p.vy*dt
    if p.vie <= 0 then
      table.remove(liste_particules, i)
    end
  end
end

function love.draw()
  local x,y = courbe:evaluate(progression)
  --love.graphics.circle("fill", x, y, 3)
  
  love.graphics.setColor(r, g, b)
  for i=1,#liste_particules do
    local p = liste_particules[i]
    love.graphics.circle("fill", p.x, p.y, 2)
  end
  love.graphics.setColor(1, 1, 1)
  
  --[[
  
  love.graphics.line(courbe:render())
  love.graphics.setColor(1, 0, 0)
  for i=0,1,0.01 do
    local x,y = courbe:evaluate(i)
    love.graphics.points(x, y)
  end
  love.graphics.setColor(1, 1, 1)
  
  ]]
end

function love.keypressed(key)
  
end

function love.mousepressed(x, y, button)
  
end

function Genere_Courbe()
  local x = love.math.random(-400, largeur+400)
  local y = love.math.random(0, hauteur)
  courbe = love.math.newBezierCurve(largeur/2, hauteur, x, y, largeur/2, 1)
end

function Ajoute_Particules(pX, pY)
  local p = {}
  p.x = love.math.random(pX-5, pX+5)
  p.y = love.math.random(pY-5, pY+5)
  p.vx = love.math.random(-50, 50)
  p.vy = love.math.random(-50, 50)
  p.vie = love.math.random(0.05, 0.3)
  table.insert(liste_particules, p)
end

--[[

  Autre façon de créer des courbes de Bézier qui vient d'un autre
  live de gamecodeur.
  
  Il y a un premier groupe de booleen qui serviront à afficher ou non
  les différents composant de la courbe de bézier.
  
  Ensuite on a les trois points qui servent d'ancres pour la courbe (p0, p1, p2),
  les deux points mobiles sur p0p1 et p1p2 (q0, q1) eet le point mobile sur q0q1
  qui est en fait le "crayon" qui la dessine la courbe elle-même.
  
  Pour finir il y a la liste qui va contenir tout les points de la courbe, la variable
  t qui sert dans un premier temps de compteur dans la fonction Calcule_Bezier pour créer
  les points de la courbe et dans un second temps de compteur dans l'update pour l'animation
  de l'affichage de la courbe.
  
  Dans l'update, on incremente t. Arrivé à une certaine valeur, on reset t à 0 et on vide la
  liste des points. Ensuite on recrée un nouveau set de points pour générer une nouvelle courbe.

]]
function lerp(a,b,t) return (1-t)*a + t*b end

function love.load()
  largeur = love.graphics.getWidth()
  hauteur = love.graphics.getHeight()
  love.graphics.setPointSize(2)
  
  b_show_p0_p1 = false
  b_show_p1_p2 = false
  b_show_q0_q1 = false
  b_show_p0 = false
  b_show_p1 = false
  b_show_p2 = false
  b_show_q0 = false
  b_show_q1 = false
  b_show_b = false
  anim_courbe = false
  
  p0 = {x = 10, y = hauteur/2}
  p1 = {x = 300, y = 10}
  p2 = {x = largeur-10, y = hauteur/2}
  
  q0 = {x = p0.x, y = p0.y}
  q1 = {x = p1.x, y = p1.y}
  
  b = {x = q0.x, y = q0.y}
  
  liste_points = {}
  
  t = 0
  
  Calcule_Bezier()
end

function love.update(dt)
  if anim_courbe == true then
    t = t + dt/4
    if t > 1 then
      liste_points = {}
      t = 0
    end
    
    q0.x = lerp(p0.x, p1.x, t)
    q0.y = lerp(p0.y, p1.y, t)
    
    q1.x = lerp(p1.x, p2.x, t)
    q1.y = lerp(p1.y, p2.y, t)
    
    b.x = lerp(q0.x, q1.x, t)
    b.y = lerp(q0.y, q1.y, t)
    table.insert(liste_points, {x = b.x, y = b.y})
  end
end

function love.draw()
  love.graphics.setColor(0.8, 0.8, 0.8)
  if b_show_p0 == true then
    love.graphics.circle("fill", p0.x, p0.y, 3)
  end
  if b_show_p1 == true then
    love.graphics.circle("fill", p1.x, p1.y, 3)
  end
  if b_show_p2 == true then
    love.graphics.circle("fill", p2.x, p2.y, 3)
  end
  
  if b_show_p0_p1 == true then
    love.graphics.line(p0.x, p0.y, p1.x, p1.y)
  end
  if b_show_p1_p2 == true then
    love.graphics.line(p1.x, p1.y, p2.x, p2.y)
  end
  
  love.graphics.setColor(0, 1, 0)
  if b_show_q0 == true then
    love.graphics.circle("fill", q0.x, q0.y, 3)
  end
  if b_show_q1 == true then
    love.graphics.circle("fill", q1.x, q1.y, 3)
  end
  
  
  if b_show_q0_q1 == true then
    love.graphics.line(q0.x, q0.y, q1.x, q1.y)
  end
  
  love.graphics.setColor(1, 0, 0)
  for i=1,#liste_points do
    b = liste_points[i]
    love.graphics.points(b.x, b.y)
  end
  
  love.graphics.setColor(0, 0, 1)
  if b_show_b == true then
    love.graphics.circle("fill", b.x, b.y, 3)
  end
  
  love.graphics.setColor(1, 1, 1)
end

function love.keypressed(key)
  if key == "kp1" then
    b_show_p0_p1 = not b_show_p0_p1
  end
  if key == "kp2" then
    b_show_p1_p2 = not b_show_p1_p2
  end
  if key == "kp3" then
    b_show_q0_q1 = not b_show_q0_q1
  end
  if key == "kp4" then
    b_show_p0 = not b_show_p0
  end
  if key == "kp5" then
    b_show_p1 = not b_show_p1
  end
  if key == "kp6" then
    b_show_p2 = not b_show_p2
  end
  if key == "kp7" then
    b_show_q0 = not b_show_q0
  end
  if key == "kp8" then
    b_show_q1 = not b_show_q1
  end
  if key == "kp9" then
    b_show_b = not b_show_b
  end
  if key == "kp0" then
    anim_courbe = not anim_courbe
  end
end

function love.mousepressed(x, y, button)
  
end

function Calcule_Bezier()
  liste_points = {}
  
  for t=0,1,0.01 do
    q0.x = lerp(p0.x, p1.x, t)
    q0.y = lerp(p0.y, p1.y, t)
    
    q1.x = lerp(p1.x, p2.x, t)
    q1.y = lerp(p1.y, p2.y, t)
    
    b.x = lerp(q0.x, q1.x, t)
    b.y = lerp(q0.y, q1.y, t)
    table.insert(liste_points, {x = b.x, y = b.y})
  end
end