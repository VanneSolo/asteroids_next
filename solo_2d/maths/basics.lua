--[[

  Concevoir une fonction pour arrondir les nombres décimaux. Compreendre à quoi servent/comment fonctionnent
  Round_Nearest et Random_Dist.

]]

--[[

  Le dot product et le determinant sont deux façons de projeter un vecteur sur un autre.
    Pour deux vecteurs v1 et v2:
    -> Si leur dot est égal à 1 et que leur determinant est égal à 0 alors ils sont égaux. -> v1 = v2
    -> Si leur dot est égal à -1 et que leur determinant est égal à 0 alors ils sont opposés. v2 <- -> v1
    -> Si leur dot est égal à 0 et que leur determinant est égal à 1 alors v2 est perpendiculaire à v1 sur sa gauche. v2 _| v1
    -> Si leur dot est égal à 0 et que leur determinant est égal à -1 alors v2 est perpendiculaire à v1 sur sa droite. v1 |_ v2

]]

function Dot(v1, v2)
  return v1.x*v2.x + v1.y*v2.y
end

function Determinant(v1, v2)
  return v1.x*v2.y - v1.y*v2.x
end

function Dot_Normalized(v1, v2)
  v1.normalize()
  v2.normalize()
  return Dot(v1, v2)
end

--[[

  Renvoie si un vecteur regarde en direction d'un autre vecteur. Penser à mettre le vecteur qu'on
  passe au paramètre bras dans une table qui contient aussi un champ length.

]]

function Is_Looking_For(target, origine, bras, range)
  local mobile_to_origine = Sub(target, origine)
  mobile_to_origine.normalize()
  local mobile_direction = Vector(bras.length*math.cos(bras.rotation), bras.length*math.sin(bras.rotation))
  mobile_direction.normalize()
  local is_looking = Dot_Normalized(mobile_direction, mobile_to_origine)
  if is_looking > range then
    return true
  end
  return false
end

--[[

  Calcul de la normale d'un segment.
  Les deux fonctions suivantes réfléchissent ou difractent un
  vecteur par rapport à la normale d'un segment (qu'il convient
  donc de calculer en premier lieu).

]]

function Vecteur_Normal(vec_1, vec_2)
  local normal = Sub(vec_2, vec_1)
  return Vector(-normal.y, normal.x)
end

function Reflect_Vector(laser, normale)
  local vec = Vector(0, 0)
  local dot_p = Dot(normale, laser)
  vec.x = laser.x - (2*dot_p)*normale.x
  vec.y = laser.y - (2*dot_p)*normale.y
  vec = Opp(vec)
  vec.normalize()
  return vec
end

function Difract_Vector(laser, normale)
  local vec = Vector(0, 0)
  local dot_p = Dot(normale, laser)
  vec.x = laser.x - (2*dot_p)*normale.x
  vec.y = laser.y - (2*dot_p)*normale.y
  vec.normalize()
  return vec
end

-- Retourne le point milieu de deux points.
function Milieu(x1, y1, x2, y2)
  local xI = (x1+x2)/2
  local yI = (y1+y2)/2
  return xI, yI
end

--[[

  Différents type de distance. Pythagore, Manhattan (somme des deux côtés
  de l'angle droit), K (distance avec coefficients) et infinie (quand l'une
  des deux coordonnées tend vers l'infini).

]]

function Dist(vec1, vec2)
  dx = vec2.x - vec1.x
  dy = vec2.y - vec1.y
  return math.sqrt(dx^2 + dy^2)
end

function Dist_Manhattan(x1, y1, x2, y2)
  return math.abs(x2-x1) + math.abs(y2-y1)
end

function Dist_K(x1, y1, x2, y2, a, b, k)
  return ((a^k)*math.abs(x2-x1)^k + (b^k)*math.abs(y2-y1)^k) ^ (1/k)
end

function Dist_Infinie(x1, y1, x2, y2, a, b)
  return math.max(a*math.abs(x2-x1), b*math.abs(y2-y1))
end

-- Calcul de l'arctangeante qui prend en compte le cas où x = 0.
function Arc_Tan_2(pX, pY)
  if pX == 0 then
    if pY < 0 then
      return - math.pi/2
    else
      return math.pi/2
    end
  end
  if pX > 0 then
    return math.atan(pY/pX)
  end
  if pX < 0 then
    return math.pi + math.atan(pY/pX)
  end
end

--[[

  Fonctions de mises à l'échelle de nombres.
  -> Norm: donne la valeur "proportionnée" d'un nombre (pValue) sur une échelle donnée (pMin, pMax)
  -> Lerp: fait le contraire, le nombre de départ est considéré comme une proportion et la fonction retourne sa valeur décimale.
  -> Map: prend une valeur (pValue) sur une échelle (pSource_Min, pSource_Max) et la converti proportionnellement sur une autre
          échelle (pDestin_Min, pDestin_Max).
  -> Clamp: contraint une valeur (pValue) sur une échelle (pMin, pMax).

]]
function Norm_Number(pValue, pMin, pMax)
  return (pValue-pMin)/(pMax-pMin)
end

function Lerp(pNorm, pMin, pMax)
  return (pMax-pMin)*pNorm + pMin
end

function Map(pValue, pSource_Min, pSource_Max, pDestin_Min, pDestin_Max)
  return Lerp(Norm_Number(pValue, pSource_Min, pSource_Max), pDestin_Min, pDestin_Max)
end

function Clamp(pValue, pMin, pMax)
  return math.min(math.max(pValue, pMin), pMax)
end

-- Retourne si un nombre est compris entre deux valeurs.
function In_Range(value, pMin, pMax)
  if value >= math.min(pMin, pMax) and value <= math.max(pMin, pMax) then
    return true
  end
  return false
end

--[[
  
  Simplifie le calcul de la position d'un point qu'on veut faire tourner autour
  d'un autre. vec et vec_ doivent faire parti d'une même table.
  vec -> vecteur du point qui doit tourner.
  origine -> vecteur du point autour duquel vec doit tourner.
  vec_ -> valeur de l'angle.
  
  Pour update la position de vec, on fait les modifications sur vec_ en dehors de la fonction.
  
]]
function Rotate_Vector_From(vec, origine, vec_)
  vec.x = origine.x + vec_.length*math.cos(vec_.rotation)
  vec.y = origine.y + vec_.length*math.sin(vec_.rotation)
end

-- Convertion de valeur d'angles entre degrés et radians.
function Deg_To_Rad(degres)
  return degres/180 * math.pi
end

function Rad_To_Deg(radians)
  return radians*180 / math.pi
end

--[[

  Valeurs arrondies pour nombre flottant.
  -> Round_To_Places: prend une valeur flottante (valeur) et coupe le nombre de décimales au nombre voulu (places).
  -> Round_Nearest: à vérifier comment ça marche.

]]
function Round_To_Places(value, places)
  mult = math.pow(10, places)
  return math.floor(value*mult)/mult
end

function Round_Nearest(value, nearest)
  return math.floor(value/nearest) * nearest
end

--[[

  Création de nombres aléatoires.
  -> Random_In_Range: prend une échelle en paramètres (pMin, pMax) et renvoie un nombre aléatoire sur cette échelle.
  -> Random_Int: prend une échelle en paramètres (pMin, pMax) et renvoie un nombre entier aléatoire sur cette échelle.
  -> Random_Dist: à vérifier comment ça marche.

]]
function Random_In_Range(pMin, pMax)
  return pMin + love.math.random()*(pMax-pMin)
end

function Random_Int(pMin, pMax)
  return math.floor(pMin + love.math.random()*(pMax-pMin+1))
end

function Random_Dist(pMin, pMax, pIterations)
  local total = 1
  for i=1, pIterations do
    total = total + Random_In_Range(pMin, pMax)
  end
  return total/pIterations
end

-- ################################################
-- ################################################
function love.load()
  largeur = love.graphics.getWidth()
  hauteur = love.graphics.getHeight()
  
  liste = {}
  for i=1,10 do
    liste[i] = {}
    liste[i].valeur = i
    liste[i].couleur = "noire"
  end
  for i=11,20 do
    liste[i] = {}
    liste[i].valeur = i
    liste[i].couleur = "rouge"
  end
  
  --Melange(liste)
  
  tirage = love.math.random(1, #liste)
end

function love.update(dt)
  
end

function love.draw()
  love.graphics.setBackgroundColor(0.5, 0.5, 0.5)
  x = 10
  for i=1,#liste do
    if liste[i].couleur == "noire" then
      love.graphics.setColor(0, 0, 0)
    elseif liste[i].couleur == "rouge" then
      love.graphics.setColor(1, 0, 0)
    end
    love.graphics.print(liste[i].valeur, x, 10)
    x = x + 25
  end
  
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(tirage, 10, 25)
end

function love.keypressed(key)
  if key == "space" then
    Melange(liste)
  end
end

function Melange(pListe)
  for m=1,500 do
    local c1 = love.math.random(1, #pListe)
    local c2 = love.math.random(1, #pListe)
    local temp = pListe[c1]
    pListe[c1] = pListe[c2]
    pListe[c2] = temp
  end
end