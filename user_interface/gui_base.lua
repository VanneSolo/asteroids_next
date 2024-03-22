require "user_interface.widgets.button"
require "user_interface.widgets.checkbox"
require "user_interface.widgets.panel"
require "user_interface.widgets.progress_bar"
require "user_interface.widgets.texte"
require "user_interface.widgets.slider"
require "user_interface.widgets.radio_button"


function New_Element(p_type, p_ui_origin, p_offset_x, p_offset_y, p_w, p_h, ...)
  local element = {}
  element.widget = nil
	if p_type == "button" then
		element.widget = New_Button(p_ui_origin, p_offset_x, p_offset_y, p_w, p_h, ...)
	elseif p_type == "checkbox" then
		element.widget = New_Checkbox(p_ui_origin, p_offset_x, p_offset_y, p_w, p_h, ...)
	elseif p_type == "panel" then
		element.widget = New_Panel(p_ui_origin, p_offset_x, p_offset_y, p_w, p_h, ...)
	elseif p_type == "progress_bar" then
		element.widget = New_Progress_Bar(p_ui_origin, p_offset_x, p_offset_y, p_w, p_h, ...)
	elseif p_type == "texte" then
		element.widget = New_Text(p_ui_origin, p_offset_x, p_offset_y, p_w, p_h, ...)
  elseif p_type == "slider" then
    element.widget = New_Slider(p_ui_origin, p_offset_x, p_offset_y, p_w, p_h, ...)
  elseif p_type == "radio" then
    element.widget = New_Radio_Button(p_ui_origin, p_offset_x, p_offset_y, p_w, p_h, ...)
	end
  element.visible = true
  function element:Set_Visible(p_visible)
    self.visible = p_visible
  end
  function element:Update(dt)
  end
  function element:Draw()
  end
  return element
end

function Widget_Template(p_ui_origin, p_offset_x, p_offset_y, p_w, p_h)
	local widget = {}
  widget.pos = Vector(p_ui_origin.pos.x + p_offset_x, p_ui_origin.pos.y + p_offset_y)
  widget.size = Vector(p_w, p_h)
  widget.img = nil
  widget.is_hover = false
  widget.lst_events = {}
	function widget:Set_Event(p_event_type, p_function)
    self.lst_events[p_event_type] = p_function
  end
	function widget:Update(dt)
    self:Update_State(dt)
  end
	function widget:Draw()
    if self.visible == false then return end
    self:Display()
  end
  function widget:MousePressed(x, y, button)
    self:Mouse_Pressed(x, y, button)
  end
	return widget
end

local GUI = {}
function GUI.New(p_x, p_y)
  local groupe = {}
	groupe.pos = Vector(p_x, p_y)
  groupe.elements = {}
  
  function groupe:Add_Element(p_element)
    table.insert(self.elements, p_element)
  end
  
  function groupe:Set_Visible(p_visible)
    for n,v in pairs(groupe.elements) do
      v:Set_Visible(p_visible)
    end
  end
  
  function groupe:Update(dt)
    for n,v in pairs(groupe.elements) do
      v:Update(dt)
    end
  end
  
  function groupe:Draw()
    love.graphics.push()
    for n,v in pairs(groupe.elements) do
      v:Draw()
    end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
  end
  
  function groupe:MousePressed(x, y, button)
    for n,v in pairs(groupe.elements) do
      v:MousePressed(x, y, button)
    end
  end
  
  return groupe
end
return GUI