function New_Panel(p_ui_origin, p_offset_x, p_offset_y, p_w, p_h)
  local panel = Widget_Template(p_ui_origin, p_offset_x, p_offset_y, p_w, p_h)
  panel.shape = "rect"
  
  function panel:Set_Colors(p_color_edge, p_color_background_1, p_color_background_2)
    self.col_edge = p_color_edge
    self.col_background = p_color_background_1
    self.col_background_1 = p_color_background_1
    self.col_background_2 = p_color_background_2
  end
  
  function panel:Set_Shape(p_shape)
    self.shape = p_shape
  end
  
  function panel:Set_Images(p_image)
    self.img = p_image
    self.size = Vector(p_image:getWidth(), p_image:getHeight())
  end
	
  function panel:Update_State(dt)
    local mx, my = love.mouse.getPosition()
    if Point_Vs_Rect(mx, my, self.pos.x, self.pos.y, self.size.x, self.size.y) then
      if self.is_hover == false then
        self.is_hover = true
        if self.lst_events["hover"] ~= nil then
          self.lst_events["hover"]("begin")
        end
      end
    else
      if self.is_hover == true then
        self.is_hover = false
        if self.lst_events["hover"] ~= nil then
          self.lst_events["hover"]("end")
        end
      end
    end
  end
  
  function panel:Display()
    if self.img == nil then
      if self.col_background ~= nil then
        love.graphics.setColor(self.col_background)
      else
        love.graphics.setColor(0.8, 0.8, 0.8)
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
    else
      love.graphics.draw(self.img, self.pos.x, self.pos.y)
    end
    love.graphics.setColor(1, 1, 1)
  end
  
  function panel:Mouse_Pressed(x, y, button)
    
  end
  
  return panel
end