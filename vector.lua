function Vector(pX, pY)
  local vector = {}
  vector.x = pX
  vector.y = pY
  -----------------------------------------------------------------
  function vector.Set_X(pValue)
    vector.x = pValue
  end
  
  function vector.Set_Y(pValue)
    vector.y = pValue
  end
  -----------------------------------------------------------------
  function vector.Get_X()
    return vector.x
  end
  
  function vector.Get_Y()
    return vector.y
  end
  -----------------------------------------------------------------
  function vector.Add_To(vec2)
    vector.x = vector.x + vec2.x
    vector.y = vector.y + vec2.y
  end
  
  function vector.Subtract_To(vec2)
    vector.x = vector.x - vec2.x
    vector.y = vector.y - vec2.y
  end
  
  function vector.Multiply_By(k)
    vector.x = vector.x*k
    vector.y = vector.y*k
  end
  
  function vector.Divide_By(k)
    vector.x = vector.x/k
    vector.y = vector.y/k
  end
  -----------------------------------------------------------------
  function vector.Set_Angle(pAngle)
    local longueur = vector.Get_Norme()
    vector.x = math.cos(pAngle)*longueur
    vector.y = math.sin(pAngle)*longueur
  end
  
  function vector.Get_Angle()
    return math.atan2(vector.y, vector.x)
  end
  -----------------------------------------------------------------
  function vector.Set_Norme(pLongueur)
    local angle = vector.Get_Angle()
    vector.x = math.cos(angle)*pLongueur
    vector.y = math.sin(angle)*pLongueur
  end
  
  function vector.Get_Norme()
    return math.sqrt(vector.x^2 + vector.y^2)
  end
  -----------------------------------------------------------------
  function vector.normalize()
    local N = vector.Get_Norme()
    vector.x = vector.x/N
    vector.y = vector.y/N
  end
  
  return vector
end

vector_null = Vector(0, 0)

function Add(v1, v2)
	local somme = Vector(0, 0)
	somme.x = v1.x + v2.x
	somme.y = v1.y + v2.y
	return somme
end

function Sub(v1, v2)
	local difference = Vector(0, 0)
	difference.x = v1.x - v2.x
	difference.y = v1.y - v2.y
	return difference
end

function Mul(arg_1, arg_2)
	local produit = Vector(0, 0)
	if type(arg_1) == "table" and type(arg_2) == "number" then
		produit.x = arg_1.x * arg_2
		produit.y = arg_1.y * arg_2
	elseif type(arg_1) == "number" and type(arg_2) == "table" then
		produit.x = arg_1 * arg_2.x
		produit.y = arg_1 * arg_2.y
	end
	return produit
end

function Div(arg_1, arg_2)
	local quotient = Vector(0, 0)
	if type(arg_1) == "table" and type(arg_2) == "number" then
		quotient.x = arg_1.x / arg_2
		quotient.y = arg_1.y / arg_2
	elseif type(arg_1) == "number" and type(arg_2) == "table" then
		quotient.x = arg_1 / arg_2.x
		quotient.y = arg_1 / arg_2.y
	end
	return quotient
end

function Opp(vec)
	local oppose = Vector(-vec.x, -vec.y)
	return oppose
end