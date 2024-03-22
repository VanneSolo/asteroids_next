-- Fonction qui calcul le point milieu de deux points.
function Milieu(x1, y1, x2, y2)
  local xI = (x1+x2)/2
  local yI = (y1+y2)/2
  return xI, yI
end

-- Fonction qui renvoie la distance entre deux points.
function Distance(x1, y1, x2, y2)
  return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end

function Dist_Vectors(vec1, vec2)
  dx = vec2.x - vec1.x
  dy = vec2.y - vec1.y
  return math.sqrt(dx^2 + dy^2)
end

-- Fonction qui renvoie la somme des deux côtés de l'angle droit.
function Dist_Manhattan(x1, y1, x2, y2)
  return math.abs(x2-x1) + math.abs(y2-y1)
end

-- Fonction Distance améliorée, avec des coefficients modifiables.
-- pour obtenir divers types de disances. a et b sont des coefficient
-- de déformation pour respectivement les longueurs en x et en y. k est
-- la puissance à laquelle on veut élever la distance.
function Dist_K(x1, y1, x2, y2, a, b, k)
  return ((a^k)*math.abs(x2-x1)^k + (b^k)*math.abs(y2-y1)^k) ^ (1/k)
end

-- Fonction qui calcule la distance quand k tend vers l'infini.
function Dist_Infinie(x1, y1, x2, y2, a, b)
  return math.max(a*math.abs(x2-x1), b*math.abs(y2-y1))
end

-- Fonction générale de tweening. tps_depart divisé par tps_fin donne la
-- dilatation horizontale. C donne la dilatation verticale, debut indique
-- le point de depart en y de la courbe et k indique à quelle puissance on
-- élève la dilatation horizontale. arrivee est le point d'arrivée de la
-- courbe.
function Tween_Power(k, tps_depart, tps_fin, debut, arrivee)
  local C = arrivee-debut
  return C*math.pow(tps_depart/tps_fin, k) + debut
end

-- Fonction qui calcul l'opposé de la tangente en prenant en compte
-- les cas dans lesquels x = 0.
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

-- Fonction qui adpte proportionnellement une valeur sur une échelle donnée.
-- Elle prend en paramètres une valeur quelconque et deux autres valeurs qui
-- vont servir de minimum et de maximum à l'echelle sur laquelle on projeter
-- la valeur de départ.
function Norm_Number(pValue, pMin, pMax)
  return (pValue-pMin)/(pMax-pMin)
end

-- Fonction d'interpolation linéaire. Elle fait le contraire de la fonction norm. Ele
-- prend une valeur normalisée sur une échelle et renvoie le nombre auquel elle
-- correspond sur cete échelle.
function Lerp(pNorm, pMin, pMax)
  return (pMax-pMin)*pNorm + pMin
end

-- Fonction qui prend une valeur sur une échelle, la normalise puis la convertie en une
-- valeur proportionnelle sur une autre échelle.
function Map(pValue, pSource_Min, pSource_Max, pDestin_Min, pDestin_Max)
  return Lerp(Norm_Number(pValue, pSource_Min, pSource_Max), pDestin_Min, pDestin_Max)
end

-- Fonction qui permet de caper une valeur sur une échellle de valeurs données. Elle
-- prend en paramètres la valeur à caper et les valeurs minimum et maximum sur lesquelles
-- la valeur de départ doit être capée. Pour cela on retourne le minimum entre le maximum
-- de la valeur de départ ou la valeur basse du range et la valeur max du range.
function Clamp(pValue, pMin, pMax)
  return math.min(math.max(pValue, pMin), pMax)
end

-- Fonction qui renvoie si un point se superpose avec un cercle. En paramètres on passe
-- les coordonnées x et y du point et du centre du cercle et le rayon du cercle. On 
-- renvoie vrai si la distance entre les deux opints est inférieure au rayon, sinon on
-- retourne false.
function Point_Vs_Circle(x1, y1, x2, y2, pRayon)
  if Distance(x1, y1, x2, y2) <= pRayon then
    return true
  end
  return false
end

function Circle_Collision(x1, y1, x2, y2, pRayon1, pRayon2)
  if Distance(x1, y1, x2, y2) <= pRayon1+pRayon2 then
    return true
  end
  return false
end

function In_Range(value, pMin, pMax)
  if value >= math.min(pMin, pMax) and value <= math.max(pMin, pMax) then
    return true
  end
  return false
end

function Point_In_Rect(x, y, pRect)
  if In_Range(x, pRect.x, pRect.x+pRect.w) and
    In_Range(y, pRect.y, pRect.y+pRect.h) then
      return true
  end
  return false
end

function Segment_Overlap(min_1, max_1, min_2, max_2)
  if math.max(min_1, max_1) >= math.min(min_2, max_2) and
    math.min(min_1, max_1) <= math.max(min_2, max_2) then
      return true
  end
  return false
end

function Rect_Intersect(rect_1, rect_2)
  if Range_Intersect(rect_1.x, rect_1.x+rect_1.w, rect_2.x, rect_2.x+rect_2.w) and
    Range_Intersect(rect_1.y, rect_1.y+rect_1.h, rect_2.y, rect_2.y+rect_2.h) then
      return true
  end
end

function Deg_To_Rad(degres)
  return degres/180 * math.pi
end

function Rad_To_Deg(radians)
  return radians*180 / math.pi
end

function Round_To_Places(value, places)
  mult = math.pow(10, places)
  return math.floor(value*mult)/mult
end

function Round_Nearest(value, nearest)
  return math.floor(value/nearest) * nearest
end

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

function Quadratic_Bezier(p1, p2, p3, t, pfinal)
  pfinal.x = math.pow(1-t, 2)*p1.x + 
                      (1-t)*2*t*p2.x + 
                      t*t*p3.x
  pfinal.y = math.pow(1-t, 2)*p1.y + 
                      (1-t)*2*t*p2.y + 
                      t*t*p3.y
  return pfinal
end

function Cubic_Bezier(p1, p2, p3, p4, t, pfinal)
  pfinal = pfinal or {}
  pfinal.x = math.pow(1-t, 3)*p1.x + 
              math.pow(1-t, 2)*3*t*p2.x + 
              (1-t)*3*t*t*p3.x + 
              t*t*t*p4.x
  pfinal.y = math.pow(1-t, 3)*p1.y + 
              math.pow(1-t, 2)*3*t*p2.y + 
              (1-t)*3*t*t*p3.y + 
              t*t*t*p4.y
  return pfinal
end

function Draw_Circle(ptype, x, y, rayon)
  love.graphics.circle(ptype, x, y, rayon)
end

function Linear_Tween(t, b, c, d)
  return c*t /d + b
end

function Ease_In_Quad(t, b, c, d)
  return c*(t/d)*t + b
end

function Ease_Out_Quad(t, b, c, d)
  return -c*(t/d)*(t-2)+b
end

function Ease_In_And_Out_Quad(t, b, c, d)
  t = t/d*2
  if t < 1 then
    return c/2*t*t + b
  end
  if t >= 1 then
    t = t-1
    return -c/2 * (t*(t-2)-1) + b
  end
end