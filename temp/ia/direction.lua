function Stop(pEntite)
  pEntite.vx = 0
  pEntite.vy = 0
end

function Haut(pEntite)
  pEntite.vx = 0
  pEntite.vy = -general_speed
end

function Droite(pEntite)
  pEntite.vx = general_speed
  pEntite.vy = 0
end

function Bas(pEntite)
  pEntite.vx = 0
  pEntite.vy = general_speed
end

function Gauche(pEntite)
  pEntite.vx = -general_speed
  pEntite.vy = 0
end

function Haut_Gauche(pEntite)
  pEntite.vx = -general_speed
  pEntite.vy = -general_speed
end

function Haut_Droite(pEntite)
  pEntite.vx = general_speed
  pEntite.vy = -general_speed
end

function Bas_Droite(pEntite)
  pEntite.vx = general_speed
  pEntite.vy = general_speed
end

function Bas_Gauche(pEntite)
  pEntite.vx = -general_speed
  pEntite.vy = general_speed
end