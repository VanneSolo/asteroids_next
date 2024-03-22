function New_Progress_Bar(p_ui_origin, p_offset_x, p_offset_y, p_w, p_h, p_max, p_orientation)
	local progress_bar = Widget_Template(p_ui_origin, p_offset_x, p_offset_y, p_w, p_h)
  progress_bar.max = p_max
  progress_bar.value = p_max
  progress_bar.is_stepped = false
  progress_bar.img_background = nil
  progress_bar.img_barre = nil
  progress_bar.shape = "rect"
  progress_bar.x = progress_bar.pos.x
  progress_bar.y = progress_bar.pos.y
  progress_bar.w = progress_bar.size.x
  progress_bar.h = progress_bar.size.y
  progress_bar.length = (progress_bar.w-2) * (progress_bar.value/progress_bar.w)
  progress_bar.orientation = p_orientation
  progress_bar.const_w = progress_bar.w
  progress_bar.const_h = progress_bar.h
  
  function progress_bar:Set_Colors(p_color_edge, p_color_background_1, p_color_background_2)
    self.col_edge = p_color_edge
    self.col_fond = p_color_background_1
    self.col_jauge = p_color_background_2
  end
  
  function progress_bar:Set_Shape(p_shape)
    self.shape = p_shape
  end
  
  function progress_bar:Set_Images(p_img_background, p_img_barre)
    self.img_background = nil
    self.img_barre = nil
    self.size = Vector(p_img_background:getWidth(), p_img_background:getHeight())
  end
  
  function progress_bar:Set_Value(p_value)
    if p_value >= 0 and p_value <= self.max then
      self.value = p_value
    else
      print("progress_barre:set_value error: out of range")
    end
  end
  
  function progress_bar:Set_Stepped(p_bool)
    self.is_stepped = p_bool
  end
  
	function progress_bar:Update_State(dt)
    if p_orientation == "horizontal" then
      self.x = self.x
      self.y = self.y
      self.w = self.w
      self.h = self.h
    elseif p_orientation == "vertical" then
      self.x = self.x
      self.y = self.y
      self.w = self.const_h
      self.h = self.const_w
    end
    
    self.length = (self.const_w-2) * (self.value/self.const_w)
	end
	
  function progress_bar:Display()
    
    love.graphics.setColor(1, 1, 1)
    if self.is_stepped then
      self.length = (math.floor(math.floor(self.length)/10)*10)
    end
    
    if self.img_background ~= nil and self.img_barre ~= nil then
      --love.graphics.draw(self.img_background, barre_x, barre_y)
      --local barre_quad = love.graphics.newQuad(0, 0, barre_size, barre_h, barre_w, barre_h)
      --love.graphics.draw(self.img_barre, barre_quad, barre_x, barre_y)
    else
      if self.col_fond ~= nil then
        love.graphics.setColor(self.col_fond)
      else
        love.graphics.setColor(0.8, 0.8, 0.8)
      end
      if self.shape == "rect" then
        love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
      elseif self.shape == "circle" then
        love.graphics.circle("fill", self.x, self.y, self.w)
      end
      if self.col_jauge ~= nil then
        love.graphics.setColor(self.col_jauge)
      else
        love.graphics.setColor(0.75, 0, 0)
      end
      if p_orientation == "horizontal" then
        if self.shape == "rect" then
          love.graphics.rectangle("fill", self.x+1, self.y+1, self.length, self.h-2)
        elseif self.shape == "circle" then
          love.graphics.circle("fill", self.x+1, self.y+1, self.length)
        end
      elseif p_orientation == "vertical" then
        if self.shape == "rect" then
          love.graphics.rectangle("fill", self.x+1, self.y+1, self.w-2, self.length)
        elseif self.shape == "circle" then
          love.graphics.circle("fill", self.x+1, self.y+1, self.length)
        end
      end
      if self.col_edge ~= nil then
        love.graphics.setColor(self.col_edge)
      else
        love.graphics.setColor(1, 0, 0)
      end
      if self.shape == "rect" then
        love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
      elseif self.shape == "circle" then
        love.graphics.circle("line", self.x, self.y, self.w)
      end
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(tostring(self.const_w), self.pos.x, self.pos.y)
    love.graphics.print(tostring(self.length), self.pos.x, self.pos.y+16)
  end
  
  function progress_bar:Mouse_Pressed(x, y, button)
    
  end
  
  return progress_bar
end