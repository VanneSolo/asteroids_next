--[[
                                        USER INTERFACE
  
  -Débugger le reset des couleurs à (1, 1, 1)
  -Corriger le bug de position si on passe à la méthode Set_Shape un argument
   différent de celui passé à la création du bouton.
  -Corriger le bug d'affichage du texte dans un bouton rond.
  -Corriger les barres de progressions ronde.
  -Ajouter la possibilité de naviguer dans l'UI au clavier ou à la manette.
  -Faire les tests avec des images à la place des primitives de Löve2D.
  -Ecrire une documentation pour utiliser l'UI.

]]

--[[

                                    PHYSIQUE/MATHEMATIQUES
  
  Récupérer tout ce que j'ai comme algo de maths et de physique et nettoyer tout ce merdier (sauf
  mes essais sur box2D à ce stade).
  Reprendre la dernière playlist de vidéos de maths de Freya Holmer.
  Lire le code source de box2D.

]]

function Clamp(valeur, minimum, maximum)
  return math.max(minimum, math.min(valeur, maximum))
end

function Point_Vs_Rect(px, py, rx, ry, rw, rh)
  if px > rx and px < rx+rw and py > ry and py < ry+rh then
    return true
  end
  return false
end

function Point_Vs_Circle(px, py, cx, cy, rayon)
  local dist_x = cx - px
  local dist_y = cy - py
  local dist = math.sqrt(dist_x*dist_x + dist_y*dist_y)
  if dist < rayon then
    return true
  end
  return false
end

require "vector"
ui = require("user_interface.gui_base")

inconsolata = love.graphics.newFont("Inconsolata-Medium.ttf")

v1 = Vector(2, 3)
v2 = Vector(7, 5)
v3 = Add(v1, v2)
v4 = Sub(v1, v2)
v5 = Mul(v1, 5)
v6 = Mul(5, v1)
v7 = Div(v2, 2)
v8 = Div(2, v2)
v9 = Opp(v3)
v10 = vector_null

v1.Multiply_By(2)
--------------------------------------------
---------------------------------------------
function Hover1_Begin_State()
	--print("bite")
end

function Hover1_End_State()
	--print("sorti")
end

function Mouse_Hover1(p_type)
	if p_type == "begin" then
		Hover1_Begin_State()
	end
	if p_type == "end" then
		Hover1_End_State()
	end
end
----------------------------------------------
--------------------------------------------
function Hover2_Begin_State()
	random_panel_2.widget.col_background = random_panel_2.widget.col_background_2
end

function Hover2_End_State()
	random_panel_2.widget.col_background = random_panel_2.widget.col_background_1
end

function Mouse_Hover2(p_type)
	if p_type == "begin" then
		Hover2_Begin_State()
	end
	if p_type == "end" then
		Hover2_End_State()
	end
end

--------------------------------------------------------------------

function Hover3_Begin_State()
	random_panel_3.widget.col_background = random_panel_3.widget.col_background_2
end

function Hover3_End_State()
	random_panel_3.widget.col_background = random_panel_3.widget.col_background_1
end

function Mouse_Hover3(p_type)
	if p_type == "begin" then
		Hover3_Begin_State()
	end
	if p_type == "end" then
		Hover3_End_State()
	end
end

--------------------------------------------------------
--------------------------------------------------------
function Click_Begin_State()
	button_test.widget.col_background = button_test.widget.col_background_2
	button_test.widget.label.text = "bleu"
end

function Click_End_State()
	button_test.widget.col_background = button_test.widget.col_background_1
	button_test.widget.label.text = "bite"
end

function Mouse_Pressed(p_type)
	if p_type == "begin" then
		Click_Begin_State()
	end
	if p_type == "end" then
		Click_End_State()
	end
end

-------------------------------------------------------------------------

function Click_Begin_State2()
	button_test2.widget.col_background = button_test2.widget.col_background_2
	button_test2.widget.label.text = "brunch"
end

function Click_End_State2()
	button_test2.widget.col_background = button_test2.widget.col_background_1
	button_test2.widget.label.text = "caca"
end

function Mouse_Pressed2(p_type)
	if p_type == "begin" then
		Click_Begin_State2()
	end
	if p_type == "end" then
		Click_End_State2()
	end
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
function Croix_On()
	croix.widget:Set_State(true)
end

function Croix_Off()
	croix.widget:Set_State(false)
end

function Box_Pressed(p_type)
	if p_type == "on" then
		Croix_On()
	end
	if p_type == "off" then
		Croix_Off()
	end
end

------------------------------------------------------------------
------------------------------------------------------------------
function love.load()
	test = ui.New(35, 30)
  
  text_p = New_Element("texte", test, 50, 200, 150, 25, "center", "center", "zzccmx", inconsolata)
  text_p.widget:Set_Color({1, 0, 0})
  test:Add_Element(text_p.widget)
  
	random_panel = New_Element("panel", test, 100, 0, 50, 25)
	random_panel.widget:Set_Event("hover", Mouse_Hover1)
	random_panel.widget:Set_Colors({1, 0, 0}, {0, 1, 0}, {1, 0, 1})
	test:Add_Element(random_panel.widget)
	
	random_panel_2 = New_Element("panel", test, 100, 75, 50, 25)
	random_panel_2.widget:Set_Event("hover", Mouse_Hover2)
  random_panel_2.widget:Set_Colors({1, 1, 0}, {1, 0, 0}, {1, 0, 1})
	test:Add_Element(random_panel_2.widget)
  
  random_panel_3 = New_Element("panel", test, 0, 75, 50, 25)
	random_panel_3.widget:Set_Event("hover", Mouse_Hover3)
  random_panel_3.widget:Set_Colors({1, 0, 0}, {0, 1, 1}, {0, 0, 1})
	test:Add_Element(random_panel_3.widget)
	
	button_test = New_Element("button", test, 100, 150, 50, 25, "bite", inconsolata)
	button_test.widget:Set_Event("pressed", Mouse_Pressed)
  --button_test.widget:Set_Shape("circle")
  button_test.widget:Set_Colors({0, 1, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 1})
  button_test.widget.label:Set_Color({0.9, 0.2, 0.95})
	test:Add_Element(button_test.widget)
	
  button_test2 = New_Element("button", test, 0, 150, 50, 25, "caca", inconsolata)
	button_test2.widget:Set_Event("pressed", Mouse_Pressed2)
  button_test2.widget:Set_Colors({1, 1, 0}, {0.5, 0, 1}, {0.5, 0, 1}, {0, 0, 1})
  button_test2.widget.label:Set_Color({1, 0, 0})
	test:Add_Element(button_test2.widget)
  
	croix = New_Element("checkbox", test, 100, 225, 25, 25)
	croix.widget:Set_Event("pressed", Box_Pressed)
	test:Add_Element(croix.widget)
	
	value_test = 2.9
	zouip = New_Element("progress_bar", test, 175, 50, 10, 10, value_test, "horizontal")
  --zouip.widget:Set_Stepped(true)
  --zouip.widget:Set_Shape("circle")
  zouip.widget:Set_Colors({0, 1, 0}, {1, 0, 0}, {0, 0, 1})
	test:Add_Element(zouip.widget)
  prout = 0.1
  
  value_essai = 38
	zouip2 = New_Element("progress_bar", test, 175, 150, 100, 25, value_essai, "horizontal")
  zouip2.widget:Set_Colors({1, 1, 0}, {1, 0, 1}, {0, 1, 1})
	test:Add_Element(zouip2.widget)
  
  start_button = 50
  bouton_poussoir = New_Element("slider", test, 275, 200, 25, 25, "", inconsolata, 100, 5, start_button, "vertical", "rect")
  bouton_poussoir.widget.rail:Set_Colors({1, 0, 0}, {1, 1, 0}, {1, 0.5, 0})
  bouton_poussoir.widget.button:Set_Colors({0, 0, 1}, {0, 1, 1}, {0, 1, 1}, {1, 0, 1})
  bouton_poussoir.widget.button:Set_Shape("circle")
  test:Add_Element(bouton_poussoir.widget)
  
  quatuor = New_Element("radio", test, 450, 50, 45, 45, 4, "horizontal", 12)
  for i=1,#quatuor.widget.buttons do
    test:Add_Element(quatuor.widget.buttons[i])
  end
end

function love.update(dt)
  zouip.widget.value = zouip.widget.value + prout
  
  if zouip.widget.value > 109 or zouip.widget.value < 2 then
    prout = -prout
  end
	test:Update(dt)
end

function love.draw()
  --love.graphics.print(tostring(math.floor(math.floor(zouip.widget.value)/10)), 5, 5)
  
	--[[love.graphics.print("v1: "..tostring(v1.x)..", "..tostring(v1.y), 5, 5)
	love.graphics.print("v2: "..tostring(v2.x)..", "..tostring(v2.y), 5, 5+16)
	love.graphics.print("v3: "..tostring(v3.x)..", "..tostring(v3.y), 5, 5+16*2)
	love.graphics.print("v4: "..tostring(v4.x)..", "..tostring(v4.y), 5, 5+16*3)
	love.graphics.print("v5: "..tostring(v5.x)..", "..tostring(v5.y), 5, 5+16*4)
	love.graphics.print("v6: "..tostring(v6.x)..", "..tostring(v6.y), 5, 5+16*5)
	love.graphics.print("v7: "..tostring(v7.x)..", "..tostring(v7.y), 5, 5+16*6)
	love.graphics.print("v8: "..tostring(v8.x)..", "..tostring(v8.y), 5, 5+16*7)
	love.graphics.print("v9: "..tostring(v9.x)..", "..tostring(v9.y), 5, 5+16*8)
	love.graphics.print("v10: "..tostring(v10.x)..", "..tostring(v10.y), 5, 5+16*9)
	
	love.graphics.print("vector null: "..tostring(vector_null.x)..", "..tostring(vector_null.y), 65, 5)]]
	
	test:Draw()
end

function love.mousepressed(x, y, button)
  test:MousePressed(x, y, button)
end

function love.keypressed(key)
	
end