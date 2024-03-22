function New_Button(p_ui_origin, p_offset_x, p_offset_y, p_w, p_h, p_texte, p_font, p_shape)
	local button = Widget_Template(p_ui_origin, p_offset_x, p_offset_y, p_w, p_h)
  button.shape = p_shape or "rect"
  button.texte = p_texte
  button.font = p_font
  button.label = New_Text(p_ui_origin, p_offset_x, p_offset_y, p_w, p_h, "center", "center", p_texte, p_font)
  button.img_default = nil
  button.img_hover = nil
  button.img_pressed = nil
  button.is_pressed = false
  button.old_button_state = false
  --button.offset = Vector(0, 0)
  local test_shape = 0
  
  function button:Set_Colors(p_color_edge, p_color_default, p_color_hover, p_color_pressed)
    self.col_edge = p_color_edge
    self.col_default = p_color_default
    self.col_hover = p_color_hover
    self.col_pressed = p_color_pressed
  end
  
  function button:Set_Shape(p_shape)
    self.shape = p_shape
  end
  
  function button:Set_Images(p_img_default, p_img_hover, p_img_pressed)
    self.img_default = p_img_default
    self.img_hover = p_img_hover
    self.img_pressed = p_img_pressed
    self.size = Vector(p_img_default:getWidth(), p_img_default:getHeight())
  end
  
  function button:Update_State(dt)
		local mx, my = love.mouse.getPosition()
    
    if self.shape == "rect" then
      test_shape = Point_Vs_Rect(mx, my, self.pos.x, self.pos.y, self.size.x, self.size.y)
    elseif self.shape == "circle" then
      test_shape = Point_Vs_Circle(mx, my, self.pos.x, self.pos.y, self.size.x)
    end
    
		self.is_hover = false    
    
    if self.is_pressed == true and love.mouse.isDown(1) == false then
      self.is_pressed = false
      if self.lst_events["pressed"] ~= nil then
        self.lst_events["pressed"]("end")
      end
      self.old_button_state = love.mouse.isDown(1)
    elseif test_shape then
      self.is_hover = true
      if self.is_hover and love.mouse.isDown(1) and self.is_pressed == false and self.old_button_state == false then
        self.is_pressed = true
        if self.lst_events["pressed"] ~= nil then
          self.lst_events["pressed"]("begin")
        end
      end
    end
  end
  
  function button:Display()
    love.graphics.setColor(1, 1, 1)
    if self.is_pressed then
      if self.img_pressed == nil then
        if self.col_pressed ~= nil then
          love.graphics.setColor(self.col_pressed)
        else
          love.graphics.setColor(0.75, 0.75, 0)
        end
        if self.shape == "rect" then
          love.graphics.rectangle("fill", self.pos.x, self.pos.y, self.size.x, self.size.y)
        elseif self.shape == "circle" then
          love.graphics.circle("fill", self.pos.x, self.pos.y, self.size.x)
        end
        if self.col_edge ~= nil then
          love.graphics.setColor(self.col_edge)
        else
          love.graphics.setColor(1, 0, 0)
        end
        if self.shape == "rect" then
          love.graphics.rectangle("line", self.pos.x, self.pos.y, self.size.x, self.size.y)
        elseif self.shape == "circle" then
          love.graphics.circle("line", self.pos.x, self.pos.y, self.size.x)
        end
				love.graphics.setColor(1, 1, 1)
      else
        love.graphics.draw(self.img_pressed, self.pos.x, self.pos.y)
      end
    elseif self.is_hover then
      if self.img_hover == nil then
        if self.col_hover ~= nil then
          love.graphics.setColor(self.col_hover)
        else
          love.graphics.setColor(0.75, 0, 0)
        end
        if self.shape == "rect" then
          love.graphics.rectangle("fill", self.pos.x, self.pos.y, self.size.x, self.size.y)
        elseif self.shape == "circle" then
          love.graphics.circle("fill", self.pos.x, self.pos.y, self.size.x)
        end
				if self.col_edge ~= nil then
          love.graphics.setColor(self.col_edge)
        else
          love.graphics.setColor(1, 0, 0)
        end
        if self.shape == "rect" then
          love.graphics.rectangle("line", self.pos.x, self.pos.y, self.size.x, self.size.y)
        elseif self.shape == "circle" then
          love.graphics.circle("line", self.pos.x, self.pos.y, self.size.x)
        end
				love.graphics.setColor(1, 1, 1)
      else
        love.graphics.draw(self.img_hover, self.pos.x, self.pos.y)
      end
    else
      if self.img_default == nil then
        if self.col_default ~= nil then
          love.graphics.setColor(self.col_default)
        else
          love.graphics.setColor(1, 1, 1)
        end
        if self.shape == "rect" then
          love.graphics.rectangle("fill", self.pos.x, self.pos.y, self.size.x, self.size.y)
        elseif self.shape == "circle" then
          love.graphics.circle("fill", self.pos.x, self.pos.y, self.size.x)
        end
				if self.col_edge ~= nil then
          love.graphics.setColor(self.col_edge)
        else
          love.graphics.setColor(1, 0, 0)
        end
        if self.shape == "rect" then
          love.graphics.rectangle("line", self.pos.x, self.pos.y, self.size.x, self.size.y)
        elseif self.shape == "circle" then
          love.graphics.circle("line", self.pos.x, self.pos.y, self.size.x)
        end
				love.graphics.setColor(1, 1, 1)
      else
        love.graphics.draw(self.img_default, self.pos.x, self.pos.y)
      end
    end
    love.graphics.setColor(1, 1, 1)
    self.label:Draw()
    
    love.graphics.print(tostring(test_shape), self.pos.x+self.size.x, self.pos.y)
    love.graphics.print(tostring(self.is_hover), self.pos.x+self.size.x, self.pos.y+16)
    love.graphics.print(tostring(self.is_pressed)..", "..tostring(love.mouse.isDown(1)), self.pos.x+self.size.x, self.pos.y+16*2)
  end
	
  function button:Mouse_Pressed(x, y, button)
    --print("something")
    --[[local souris = Vector(x, y)
    if button == 1 then
      if self.shape == "rect" then
        if x > self.pos.x and x < self.pos.x+self.size.x and y > self.pos.y and y < self.pos.y+self.size.y then
          print("bite")
          self.offset = Sub(souris, self.pos)
        end
      elseif self.shape == "circle" then
        
      end
    end]]
  end
  
  return button
end