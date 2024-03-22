function New_Text(p_ui_origin, p_offset_x, p_offset_y, p_w, p_h, p_h_align, p_v_align, p_text, p_font)
	local texte = Widget_Template(p_ui_origin, p_offset_x, p_offset_y, p_w, p_h)
  texte.text = p_text
  texte.font = p_font
  texte.text_size = Vector(p_font:getWidth(p_text), p_font:getHeight(p_text))
  texte.h_align = p_h_align
  texte.v_align = p_v_align
  
  function texte:Set_Color(p_color)
    texte.color = p_color
  end
  
  function texte:Update_State(dt)
  end
  
  function texte:Display()
    love.graphics.setFont(self.font)
    if self.color ~= nil then
      love.graphics.setColor(self.color)
    else
      love.graphics.setColor(1, 1, 1)
    end
    local x = self.pos.x
    local y = self.pos.y
    if self.h_align == "center" then
      x = x + ((self.size.x-self.text_size.x)/2)
    end
    if self.v_align == "center" then
      y = y + ((self.size.y-self.text_size.y)/2)
    end
    love.graphics.print(self.text, x, y)
  end
  love.graphics.setColor(1, 1, 1)
  
  function texte:Mouse_Pressed(x, y, button)
    
  end
  return texte
end