function New_Checkbox(p_ui_origin, p_offset_x, p_offset_y, p_w, p_h)
	local checkbox = Widget_Template(p_ui_origin, p_offset_x, p_offset_y, p_w, p_h)
  checkbox.img_default = nil
  checkbox.img_pressed = nil
  checkbox.is_pressed = false
  checkbox.old_button_state = false
  checkbox.shape = "rect"
  
  function checkbox:Set_Shape(p_shape)
    self.shape = p_shape
  end
  
  function checkbox:Set_Images(p_img_default, p_img_pressed)
    self.img_default = p_img_default
    self.img_pressed = p_img_pressed
    self.size = Vector(p_img_default:getWidth(), p_img_pressed:getHeight())
  end
  
  function checkbox:Set_State(p_state)
    self.is_pressed = p_state
  end
	
  function checkbox:Update_State(dt)
		local mx, my = love.mouse.getPosition()
		self.is_hover = false
    if Point_Vs_Rect(mx, my, self.pos.x, self.pos.y, self.size.x, self.size.y) then
			self.is_hover = true
			if self.is_hover and love.mouse.isDown(1) and self.is_pressed == false and self.old_button_state == false then
      if self.lst_events["pressed"] ~= nil then
        self.lst_events["pressed"]("on")
      end
			elseif self.is_hover and love.mouse.isDown(1) and self.is_pressed == true and self.old_button_state == false then
				self.is_pressed = false
				if self.lst_events["pressed"] ~= nil then
					self.lst_events["pressed"]("off")
				end
			end
			self.old_button_state = love.mouse.isDown(1)
		end
  end
	
  function checkbox:Display()
    love.graphics.setColor(1, 1, 1)
    if self.is_pressed then
      if self.img_pressed == nil then
        if self.shape == "rect" then
          love.graphics.rectangle("line", self.pos.x, self.pos.y, self.size.x, self.size.y)
          love.graphics.setColor(1, 0, 0)
          love.graphics.line(self.pos.x, self.pos.y, self.pos.x+self.size.x, self.pos.y+self.size.y)
          love.graphics.line(self.pos.x+self.size.x, self.pos.y, self.pos.x, self.pos.y+self.size.y)
        elseif self.shape == "circle" then
          love.graphics.circle("line", self.pos.x, self.pos.y, self.size.x)
          love.graphics.setColor(1, 0, 0)
          love.graphics.line(self.pos.x-self.size.x, self.pos.y, self.pos.x+self.size.x, self.pos.y)
          love.graphics.line(self.pos.x, self.pos.y-self.size.x, self.pos.x, self.pos.y+self.size.x)
        end
      else
        love.graphics.draw(self.img_pressed, self.pos.x, self.pos.y)
      end
    else
      if self.img_default == nil then
        if self.shape == "rect" then
          love.graphics.rectangle("line", self.pos.x, self.pos.y, self.size.x, self.size.y)
        elseif self.shape == "circle" then
          love.graphics.circle("line", self.pos.x, self.pos.y, self.size.x)
        end
      else
        love.graphics.draw(self.img_default, self.pos.x, self.pos.y)
      end
    end
    love.graphics.setColor(1, 1, 1)
  end
  
  function checkbox:Mouse_Pressed(x, y, button)
    
  end
  
  return checkbox
end