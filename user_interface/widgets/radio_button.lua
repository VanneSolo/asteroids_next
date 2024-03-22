function New_Radio_Button(p_ui_origin, p_offset_x, p_offset_y, p_w, p_h, p_nb_buttons, p_orientation, p_spacing)
  local radio_button = {}
  radio_button.buttons = {}
  for i=1,p_nb_buttons do
    local rb = New_Checkbox(p_ui_origin, p_offset_x, p_offset_y, p_w, p_h)
    table.insert(radio_button.buttons, rb)
  end

  function Active_Button(p_type)
    for i=1,#radio_button.buttons do
      if radio_button.buttons[i].is_hover then
        if p_type == "on" or p_type == "off" then
          radio_button.buttons[i].is_pressed = true
        end
      else
        radio_button.buttons[i].is_pressed = false
      end
    end
  end
  
  for i=1,#radio_button.buttons do
    if p_orientation == "horizontal" then
      radio_button.buttons[i].pos.x = radio_button.buttons[i].pos.x + ((i-1)*(radio_button.buttons[i].size.x+p_spacing))
    elseif p_orientation == "vertical" then
      radio_button.buttons[i].pos.y = radio_button.buttons[i].pos.y + ((i-1)*(radio_button.buttons[i].size.y+p_spacing))
    end
    radio_button.buttons[i]:Set_Event("pressed", Active_Button)
  end
  
  function radio_button:Update_State(dt)
    for i=1,p_nb_buttons do
      radio_button.buttons[i]:Update_State(dt)
    end
  end
  
  function radio_button:Display()
    for i=1,p_nb_buttons do
      radio_button.buttons[i]:Display()
    end
  end
  
  function radio_button:Mouse_Pressed(x, y, button)
    
  end
  
  return radio_button
end