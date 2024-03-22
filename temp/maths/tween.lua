require "math_sup"

function Tween_Power(k, tps_depart, tps_fin, debut, arrivee)
  local C = arrivee-debut
  return C*math.pow(tps_depart/tps_fin, k) + debut
end

-- distance * time / duration + valeur départ
-- t = (temps) temps, c'est en incrémentant cette variable qu'on anime le tweening.
-- b = (valeur_depart) valeur de départ
-- c = (longueur_tween) distance à parcourir
-- d = (duree) durée du mouvement

--[[ TWEENING LINEAIRE ]]
function Linear(temps, valeur_depart, longueur_tween, duree)
  return longueur_tween * temps / duree + valeur_depart
end
  
--[[ TWEENING QUADRATIQUE ]]

function In_Quad(temps, valeur_depart, longueur_tween, duree)
  temps = temps / duree
  return longueur_tween * math.pow(temps, 2) + valeur_depart
end

function Out_Quad(temps, valeur_depart, longueur_tween, duree)
  temps = temps / duree
  return -longueur_tween * temps * (temps-2) + valeur_depart
end

function In_Out_Quad(temps, valeur_depart, longueur_tween, duree)
  temps = temps / duree * 2
  if temps < 1 then
    return longueur_tween / 2 * math.pow(temps, 2) + valeur_depart
  else
    return -longueur_tween / 2 * ((t-1) * (t-3) - 1) + valeur_depart
  end
end

function Out_In_Quad(temps, valeur_depart, longueur_tween, duree)
  if temps < duree / 2 then
    return Out_Quad(temps*2, valeur_depart, longueur_tween/2, duree)
  else
    return In_Quad((temps*2)-duree, valeur_depart+longueur_tween/2, longueur_tween/2, duree)
  end
end

--[[ TWEENING CUBIQUE ]]

function In_Cubic(temps, valeur_depart, longueur_tween, duree)
  temps = temps / duree
  return longueur_tween * math.pow(temps, 3) + valeur_depart
end

function Out_Cubic(temps, valeur_depart, longueur_tween, duree)
  temps = temps / duree - 1
  return longueur_tween * (math.pow(temps, 3)+1) + valeur_depart
end

function In_Out_Cubic(temps, valeur_depart, longueur_tween, duree)
  temps = temps / duree * 2
  if temps < 1 then
    return longueur_tween / 2 * temps * temps * temps + valeur_depart
  else
    temps = temps - 2
    return longueur_tween / 2 * (temps * temps * temps + 2) + valeur_depart
  end
end

function Out_In_Cubic(temps, valeur_depart, longueur_tween, duree)
  if temps < duree / 2 then
    return Out_Cubic(temps*2, valeur_depart, longueur_tween/2, duree)
  else
    return In_Cubic((temps*2)-duree, valeur_depart+longueur_tween/2, longueur_tween/2, duree)
  end
end

--[[ TWEENING QUART ]]

function In_Quart(temps, valeur_depart, longueur_tween, duree)
  temps = temps / duree
  return longueur_tween * math.pow(temps, 4) + valeur_depart
end

function Out_Quart(temps, valeur_depart, longueur_tween, duree)
  temps = temps / duree - 1
  return -longueur_tween * (math.pow(temps, 4)-1) + valeur_depart
end

function In_Out_Quart(temps, valeur_depart, longueur_tween, duree)
  temps = temps / duree * 2
  if temps < 1 then
    return longueur_tween/2 * math.pow(temps, 4) + valeur_depart
  else
    temps = temps - 2
    return -longueur_tween/2 * (math.pow(temps, 4)-2) + valeur_depart
  end
end

function Out_In_Quart(temps, valeur_depart, longueur_tween, duree)
  if temps < duree / 2 then
    return Out_Quart(temps*2, valeur_depart, longueur_tween/2, duree)
  else
    return In_Quart((temps*2)-duree, valeur_depart+longueur_tween/2, longueur_tween/2, duree)
  end
end

--[[ TWEENING QUINT ]]

function In_Quint(temps, valeur_depart, longueur_tween, duree)
  temps = temps / duree
  return longueur_tween * math.pow(temps, 5) + valeur_depart
end

function Out_Quint(temps, valeur_depart, longueur_tween, duree)
  temps = temps / duree - 1
  return longueur_tween * (math.pow(temps, 5)+1) + valeur_depart
end

function In_Out_Quint(temps, valeur_depart, longueur_tween, duree)
  temps = temps / duree * 2
  if temps < 1 then
    return longueur_tween / 2 * math.pow(temps, 5) + valeur_depart
  else
    temps = temps - 2
	return longueur_tween / 2 * (math.pow(temps, 5)+2) + valeur_depart
  end
end

function Out_In_Quint(temps, valeur_depart, longueur_tween, duree)
  if temps < duree / 2 then
    return Out_Quint(temps*2, valeur_depart, longueur_tween/2, duree)
  else
    return In_Quint((temps*2)-duree, valeur_depart+longueur_tween/2, longueur_tween/2, duree)
  end
end

--[[ TWEENING SINUS ]]

function In_Sinus(temps, valeur_depart, longueur_tween, duree)
  return -longueur_tween * math.cos(temps / duree * (math.pi/2)) + longueur_tween + valeur_depart
end

function Out_Sinus(temps, valeur_depart, longueur_tween, duree)
  return longueur_tween * math.sin(temps / duree * (math.pi/2)) + valeur_depart
end

function In_Out_Sinus(temps, valeur_depart, longueur_tween, duree)
  return -longueur_tween / 2 * (math.cos(math.pi * temps / duree) - 1) + valeur_depart
end

function Out_In_Sinus(temps, valeur_depart, longueur_tween, duree)
  if temps < duree / 2 then
    return Out_Sinus(temps*2, valeur_depart, longueur_tween/2, duree)
  else
    return In_Sinus((temps*2)-duree, valeur_depart+longueur_tween/2, longueur_tween/2, duree)
  end
end

--[[ TWEENING EXPO ]]

function In_Expo(temps, valeur_depart, longueur_tween, duree)
  if temps == 0 then
    return valeur_depart
  else
    return c * math.pow(2, 10*(temps/duree-1)) + valeur_depart - longueur_tween*0.001
  end
end

function Out_Expo(temps, valeur_depart, longueur_tween, duree)
  if temps == duree then
    return valeur_depart + longueur_tween
  else
    return longueur_tween * 1.001 * (-math.pow(2, -10*temps/duree) + 1) + valeur_depart
  end
end

function In_Out_Expo(temps, valeur_depart, longueur_tween, duree)
  if temps == 0 then
    return valeur_depart
  end
  if temps == duree then
    return valeur_depart + longueur_tween
  end
  temps = temps / duree * 2
  if temps < 1 then
    return longueur_tween / 2 * math.pow(2, 10*(temps-1)) + valeur_depart - longueur_tween*0.0005
  else
    temps = temps - 1
	return longueur_tween / 2 * 1.0005 * (-math.pow(2, -10*temps) + 2) + valeur_depart
  end
end

function Out_In_Expo(temps, valeur_depart, longueur_tween, duree)
  if temps < duree / 2 then
    return Out_Expo(temps*2, valeur_depart longueur_tween/2, duree)
  else
    return In_Expo((temps*2)-duree, valeur_depart+longueur_tween/2, longueur_tween/2, duree)
  end
end

--[[ TWEENING CIRCULAIRE ]]

function In_Circ(temps, valeur_depart, longueur_tween, duree)
  temps = temps / duree
  return -longueur_tween * (math.sqrt(1 - math.pow(temps, 2)) - 1) + valeur_depart
end

function Out_Circ(temps, valeur_depart, longueur_tween, duree)
  temps = temps / duree - 1
  return longueur_tween * math.sqrt(1 - math.pow(temps, 2)) + valeur_depart
end

function In_Out_Circ(temps, valeur_depart, longueur_tween, duree)
  temps = temps / duree * 2
  if temps < 1 then
    return -longueur_tween / 2 * (math.sqrt(1 - temps * temps) - 1) + valeur_depart
  else
    temps = temps - 2
	return longueur_tween / 2 * (math.sqrt(1 - temps * temps) + 1) + valeur_depart
  end
end

function Out_In_Circ(temps, valeur_depart, longueur_tween, duree)
  if temps < duree / 2 then
    return Out_Circ(temps*2, valeur_depart, longueur_tween/2, duree)
  else
    return In_Circ((temps*2)-duree, valeur_depart+longueur_tween/2, longueur_tween/2, duree)
  end
end

--[[ TWEENING ELASTIQUE ]]

-- Il y a en plus deux paramètre "amplitude" et "période". Il faudra étudier ces paramètres
-- pour comprendre leur utilité.

--[[ TWEENING BACK ]]

-- Il y a en plus un paramètre "s". Il faudra étudier ce paramètre
-- pour comprendre son utilité.

--[[ TWEENING BOUNCE ]]

function In_Bounce(temps, valeur_depart, longueur_tween, duree)
  return longueur_tween - Out_Bounce(duree-temps, 0, longueur_tween, duree) + valeur_depart
end

function Out_Bounce(temps, valeur_depart, longueur_tween, duree)
  temps = temps / duree
  if temps < 1 / 2.75 then
    return longueur_tween * (7.5625 * temps * temps) + valeur_depart
  elseif temps < 2 / 2.75 then
    temps = temps - (1.5/2.75)
	return longueur_tween * (7.5625 * temps * temps + 0.75) + valeur_depart
  elseif temps < 2.5 / 2.75 then
    temps = temps - (2.25/2.75)
	return longueur_tween * (7.5625 * temps * temps + 0.9375) + valeur_depart
  else
    temps = temps - (2.625/2.75)
	return longueur_tween * (7.5625 * temps * temps + 0.984375) + valeur_depart
  end
end

function In_Out_Bounce(temps, valeur_depart, longueur_tween, duree)
  if temps < duree / 2 then
    return In_Bounce(temps*2, 0, longueur_tween, duree) + valeur_depart
  else
    return Out_Bounce(temps*2-duree, 0, longueur_tween, duree) * 0.5 + longueur_tween * 0.5 + b
  end
end

function Out_In_Bounce(temps, valeur_depart, longueur_tween, duree)
  if temps < duree / 2 then
    return Out_Bounce(temps*2, valeur_depart, longueur_tween/2, duree)
  else
    return In_Bounce((temps*2)-duree,  valeur_depart+longueur_tween/2, longueur_tween/2, duree)
  end
end