--[[

  couleurs:
    bouton: contour, background idle, background is_pressed
    rail: contour, backgorund barre, remplissage barre
  
]]

function New_Slider(p_ui_origin, p_offset_x, p_offset_y, p_wb, p_hb, p_texte, p_font, p_wr, p_hr, p_rail_max_value, p_orientation, p_shape)
  local slider = Widget_Template(p_ui_origin, p_offset_x, p_offset_y, p_w, p_h)
  slider.offset = Vector(0, 0)
  slider.rail = New_Progress_Bar(p_ui_origin, p_offset_x, p_offset_y, p_wr, p_hr, p_rail_max_value, p_orientation)
  if p_orientation == "horizontal" then
    if p_shape == "rect" then
      slider.button = New_Button(p_ui_origin, p_offset_x+p_rail_max_value-(p_wb/2), p_offset_y-(p_hb/2)+(p_hr/2), p_wb, p_hb, p_texte, p_font, p_shape)
    elseif p_shape == "circle" then
      slider.button = New_Button(p_ui_origin, p_offset_x+p_rail_max_value, p_offset_y, p_wb, p_hb, p_texte, p_font, p_shape)
    end
  elseif p_orientation == "vertical" then
    if p_shape == "rect" then
      slider.button = New_Button(p_ui_origin, p_offset_x-(p_wb/2)+(p_hr/2), p_offset_y+p_rail_max_value-(p_hb/2), p_wb, p_hb, p_texte, p_font, p_shape)
    elseif p_shape == "circle" then
      slider.button = New_Button(p_ui_origin, p_offset_x+(p_hr/2), p_offset_y+p_rail_max_value, p_wb, p_hb, p_texte, p_font, p_shape)
    end
  end
  
  function slider:Set_Images(p_img_background, p_img_barre, p_img_default, p_img_hover, p_img_pressed)
    slider.rail:Set_Images(p_img_background, p_img_barre)
    slider.button:Set_Image(p_img_default, p_img_hover, p_img_pressed)
  end
  
  function slider:Update_State(dt)
    slider.rail:Update_State(dt)
    slider.button:Update_State(dt)
    
    if slider.button.is_pressed then
      local mx, my = love.mouse.getPosition()
      if slider.rail.orientation == "horizontal" then
        if slider.button.shape == "rect" then
          slider.button.pos.x = mx - self.offset.x - slider.button.size.x/2
          slider.button.pos.x = Clamp(slider.button.pos.x, slider.rail.x-slider.button.size.x/2, slider.rail.x+slider.rail.w-slider.button.size.x+slider.button.size.x/2)
          
          slider.rail.value = mx - slider.rail.pos.x
          slider.rail.value = Clamp(slider.rail.value, 0, slider.rail.w)
        elseif slider.button.shape == "circle" then
          slider.button.pos.x = mx - self.offset.x - slider.button.size.x/2
          slider.button.pos.x = Clamp(slider.button.pos.x, slider.rail.x, slider.rail.x+slider.rail.w)
          
          slider.rail.value = mx - slider.rail.pos.x
          slider.rail.value = Clamp(slider.rail.value, 0, slider.rail.w)
        end
      elseif slider.rail.orientation == "vertical" then
        if slider.button.shape == "rect" then
          slider.button.pos.x = slider.rail.x+slider.rail.w/2 - slider.button.size.x/2
          slider.button.pos.y = my - slider.offset.y - slider.button.size.y/2
          slider.button.pos.y = Clamp(slider.button.pos.y, slider.rail.y-slider.button.size.y/2, slider.rail.y+slider.rail.h-slider.button.size.y+slider.button.size.y/2)
          
          slider.rail.value = my - slider.rail.pos.y
          slider.rail.value = Clamp(slider.rail.value, 0, slider.rail.h)
        elseif slider.button.shape == "circle" then
          slider.button.pos.x = slider.rail.x+slider.rail.w/2
          
          slider.button.pos.y = my - slider.offset.y - slider.button.size.x/2
          slider.button.pos.y = Clamp(slider.button.pos.y, slider.rail.y, slider.rail.y+slider.rail.h)
          
          slider.rail.value = my - slider.rail.pos.y
          slider.rail.value = Clamp(slider.rail.value, 0, slider.rail.h)
        end
      end
    end
  end
  
  function slider:Display()
    self.rail:Display()
    self.button:Display()
    love.graphics.setColor(1, 1, 1)
  end
  
  function slider:Mouse_Pressed(x, y, button)
    if button == 1 then
      if self.rail.orientation == "horizontal" then
        if self.button.shape == "rect" then
          if x > self.button.pos.x and x < self.button.pos.x+self.button.size.x and y > self.button.pos.y and y < self.button.pos.y+self.button.size.y then
            self.offset.x = x - (self.button.pos.x+self.button.size.x/2)
          end
        elseif self.button.shape == "circle" then
          if Point_Vs_Circle(x, y, self.button.pos.x, self.button.pos.y, self.button.size.x) then
            self.offset.x = x - (self.button.pos.x+self.button.size.x/2)
          end
        end
      elseif self.rail.orientation == "vertical" then
        if self.button.shape == "rect" then
          if x > self.button.pos.x and x < self.button.pos.x+self.button.size.x and y > self.button.pos.y and y < self.button.pos.y+self.button.size.y then
            self.offset.y = y - (self.button.pos.y+self.button.size.y/2)
          end
        elseif self.button.shape == "circle" then
          if Point_Vs_Circle(x, y, self.button.pos.x, self.button.pos.y, self.button.size.x) then
            self.offset.y = y - (self.button.pos.y+self.button.size.x/2)
          end
        end
      end
    end
  end
  
  return slider
end