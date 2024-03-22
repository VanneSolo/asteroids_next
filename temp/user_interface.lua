local GUI = {}
-- Création d'un groupe de panels et de boutons.
function GUI.New()
  local groupe = {}
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
  
  return groupe
end
-- Création d'un nouvel élément de GUI avec des caractéristiques de base.
local function New_Element(p_x, p_y)
  local element = {}
  element.x = p_x
  element.y = p_y
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
-- Création d'un nouveau panel dans l'ui.
function GUI.New_Panel(p_x, p_y, p_w, p_h, p_color)
  local panel = New_Element(p_x, p_y)
  panel.w = p_w
  panel.h = p_h
  panel.color = p_color
  panel.img = nil
  panel.is_hover = false
  panel.lst_events = {}
  
  function panel:Set_Images(p_image)
    self.img = p_image
    self.w = p_image:getWidth()
    self.h = p_image:getHeight()
  end
  
  function panel:Set_Event(p_event_type, p_function)
    self.lst_events[p_event_type] = p_function
  end
  
  function panel:Update_State(dt)
    local mx, my = love.mouse.getPosition()
    if Point_Vs_Rect(mx, my, self.x, self.y, self.w, self.h) then
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
  
  function panel:Update(dt)
    self:Update_State()
  end
  
  function panel:Draw()
    if self.visible == false then return end
    self:Display()
  end
  
  function panel:Display()
    --love.graphics.print("x: "..tostring(self.x)..", y: "..tostring(self.y)..", w: "..tostring(self.w)..", h: "..tostring(self.h), 150, 5)
    if self.color ~= nil then
      love.graphics.setColor(self.color)
    else
      love.graphics.setColor(1, 1, 1)
    end
    if self.img == nil then
      love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
    else
      love.graphics.setColor(1, 1, 1)
      love.graphics.draw(self.img, self.x, self.y)
    end
  end
  
  return panel
end

function GUI.New_Text(p_x, p_y, p_w, p_h, p_text, p_font, p_h_align, p_v_align, p_color)
  local texte = GUI.New_Panel(p_x, p_y, p_w, p_h)
  texte.text = p_text
  texte.font = p_font
  texte.text_w = p_font:getWidth(p_text)
  texte.text_h = p_font:getHeight(p_text)
  texte.h_align = p_h_align
  texte.v_align = p_v_align
  texte.color = p_color
  
  function texte:Draw()
    if self.visible == false then return end
    self:Display()
  end
  
  function texte:Display()
    love.graphics.setFont(self.font)
    if self.color ~= nil then
      love.graphics.setColor(self.color)
    else
      love.graphics.setColor(1, 1, 1)
    end
    local x = self.x
    local y = self.y
    if self.h_align == "center" then
      x = x + ((self.w-self.text_w)/2)
    end
    if self.v_align == "center" then
      y = y + ((self.h-self.text_h)/2)
    end
    love.graphics.print(self.text, x, y)
  end
  
  return texte
end

function GUI.New_Button(p_x, p_y, p_w, p_h, p_texte, p_font, p_color)
  local button = GUI.New_Panel(p_x, p_y, p_w, p_h)
  button.texte = p_texte
  button.font = p_font
  button.label = GUI.New_Text(p_x, p_y, p_w, p_h, p_texte, p_font, "center", "center", p_color)
  button.img_default = nil
  button.img_hover = nil
  button.img_pressed = nil
  button.is_pressed = false
  button.old_button_state = false
  
  function button:Set_Images(p_img_default, p_img_hover, p_img_pressed)
    self.img_default = p_img_default
    self.img_hover = p_img_hover
    self.img_pressed = p_img_pressed
    self.w = p_img_default:getWidth()
    self.h = p_img_default:getHeight()
  end
  
  function button:Update(dt)
    self.label.text = button.texte
    self:Update_State(dt)
    if self.is_hover and love.mouse.isDown(1) and self.is_pressed == false and self.old_button_state == false then
      self.is_pressed = true
      if self.lst_events["pressed"] ~= nil then
        self.lst_events["pressed"]("begin")
      end
    else
      if self.is_pressed == true and love.mouse.isDown(1) == false then
        self.is_pressed = false
        if self.lst_events["pressed"] ~= nil then
          self.lst_events["pressed"]("end")
        end
      end
    end
    self.old_button_state = love.mouse.isDown(1)
  end
  
  function button:Draw()
    love.graphics.setColor(1, 1, 1)
    if self.is_pressed then
      if self.img_pressed == nil then
        self:Display()
        love.graphics.setColor(1, 1, 1, 0.2)
        love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
      else
        love.graphics.draw(self.img_pressed, self.x, self.y)
      end
    elseif self.is_hover then
      if self.img_hover == nil then
        self:Display()
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", self.x+2, self.y+2, self.w-4, self.h-4)
      else
        love.graphics.draw(self.img_hover, self.x, self.y)
      end
    else
      if self.img_default == nil then
        self:Display()
      else
        love.graphics.draw(self.img_default, self.x, self.y)
      end
    end
    self.label:Draw()
  end
  
  return button
end

function GUI.New_Checkbox(p_x, p_y, p_w, p_h)
  local checkbox = GUI.New_Panel(p_x, p_y, p_w, p_h)
  checkbox.img_default = nil
  checkbox.img_pressed = nil
  checkbox.is_pressed = false
  checkbox.old_button_state = false
  
  function checkbox:Set_Images(p_img_default, p_img_pressed)
    self.img_default = p_img_default
    self.img_pressed = p_img_pressed
    self.w = p_img_default:getWidth()
    self.h = p_img_pressed:getWidth()
  end
  
  function checkbox:Set_State(p_state)
    self.is_pressed = p_state
  end
  
  function checkbox:Update(dt)
    self:Update_State(dt)
    if self.is_hover and love.mouse.isDown(1) and self.is_pressed == false and self.old_button_state == false then
      self.is_pressed = true
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
  
  function checkbox:Draw()
    love.graphics.setColor(1, 1, 1)
    if self.is_pressed then
      if self.img_pressed == nil then
        self:Draw()
        love.graphics.setColor(1, 1, 1, 0.2)
        love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
      else
        love.graphics.draw(self.img_pressed, self.x, self.y)
      end
    else
      if self.img_default == nil then
        self:Draw()
      else
        love.graphics.draw(self.img_default, self.x, self.y)
      end
    end
  end
  
  return checkbox
end

function GUI.New_Progress_Bar(p_x, p_y, p_w, p_h, p_max, p_color, p_color_2)
  local progress_bar = GUI.New_Panel(p_x, p_y, p_w, p_h)
  progress_bar.color = p_color
  progress_bar.color_2 = p_color_2
  progress_bar.max = p_max
  progress_bar.value = p_max
  progress_bar.img_background = nil
  progress_bar.img_barre = nil
  
  function progress_bar:Set_Images(p_img_background, p_img_barre)
    progress_bar.img_background = nil
    progress_bar.img_barre = nil
    self.w = p_img_background:getWidth()
    self.h = p_img_background:getHeight()
  end
  
  function progress_bar:Set_Value(p_value)
    if p_value >= 0 and p_value <= self.max then
      self.value = p_value
    else
      print("progress_barre:set_value error: out of range")
    end
  end
  
  function progress_bar:Draw()
    love.graphics.setColor(1, 1, 1)
    local bar_size = (self.w/2) * (self.value/self.max)
    if self.img_background ~= nil and self.img_barre ~= nil then
      love.graphics.draw(self.img_background, self.x, self.y)
      local bar_quad = love.graphics.newQuad(0, 0, bar_size, self.h, self.w, self.h)
      love.graphics.draw(self.img_barre, bar_quad, self.x, self.y)
    else
      self:Draw()
      if self.color ~= nil then
        love.graphics.setColor(self.color_2)
      else
        love.graphics.setColor(1, 1, 1)
      end
      love.graphics.rectangle("fill", self.x+1, self.y+1, bar_size, self.h-2)
    end
  end
  
  return progress_bar
end

return GUI