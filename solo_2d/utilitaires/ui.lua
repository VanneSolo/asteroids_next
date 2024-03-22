local Console = {}

Console.line = 0
Console.coll = 0
Console.grille = nil

Console.cursor = {}
Console.cursor.line = 1
Console.cursor.coll = 1

function Console.Init(pLine, pColl, pHeightPixel)
  Console.line = pLine
  Console.coll = pColl
  
  Console.font = love.graphics.newFont("04B_03B_.TTF", pHeightPixel, "none")
  love.graphics.setFont(Console.font)
  Console.char_width = Console.font:getWidth("W")
  Console.char_height = Console.font:getHeight("W")
  
  love.window.setMode(pColl*Console.char_width, pLine*Console.char_height)
  
  Console.canvas = love.graphics.newCanvas(pColl*Console.char_width, pLine*Console.char_height)
  Console.grille = {}
  for l=1,pLine do
    Console.Clear_Line(l)
  end
  
  Console.Update_Canvas()
end

function Console.Write_Line(pTexte)
  local n = 1
  for c=Console.cursor.coll,Console.cursor.coll+string.len(pTexte) do
    local char = string.sub(pTexte, n, n)
    Console.grille[Console.cursor.line][c] = char
    n = n + 1
  end
  Console.Next_Line()
  Console.Update_Canvas()
end

function Console.Next_Line()
  Console.cursor.line = Console.cursor.line + 1
  Console.cursor.coll = 1
  if Console.cursor.line > Console.line then
    Console.Scroll()
    Console.cursor.line = Console.line
  end
end

function Console.Clear_Line(pLine)
  Console.grille[pLine] = {}
  for c=1,Console.coll do
    Console.grille[pLine][c] = " "
  end
end

function Console.Scroll()
  for l=2,Console.line do
    Console.grille[l-1] = Console.grille[l]
  end
  Console.Clear_Line(Console.line)
  Console.Update_Canvas()
  if Console.cursor.line > 1 then
    Console.cursor.line = Console.cursor.line - 1
  end
end

function Console.Update_Canvas()
  love.graphics.setCanvas(Console.canvas)
  love.graphics.clear()
  love.graphics.setColor(1, 1, 1)
  for l=1,Console.line do
    for c=1,Console.coll do
      local offset = Console.char_width - Console.font:getWidth(Console.grille[l][c])
      love.graphics.print(Console.grille[l][c], ((c-1)*Console.char_width)+offset, (l-1)*Console.char_height)
    end
  end
  love.graphics.setCanvas()
end

function Console.Draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(Console.canvas)
  love.graphics.rectangle("fill", (Console.cursor.coll-1)*Console.char_width, (Console.cursor.line-1)*Console.char_height, Console.char_width, Console.char_height)
end

return Console

function love.load()
  texte = ""
  message = ""
  input_pseudo = false
end

function love.update(dt)
  
end

function love.draw()
  if input_pseudo then
    love.graphics.print("Entrez votre pseudo > "..texte, 10, 10)
    love.graphics.print(message, 10, 25)
  end
end

function love.keypressed(key)
  if key == "backspace" then
    message = ""
    local p = utf_8.offset(texte, -1)
    if p then
      texte = string.sub(texte, 1, p-1)
    end
  end
  if key == "return" and input_pseudo then
    if string.len(texte) >= 5 then
      if string.len(texte) <=10 then
        print("Le pseudo est: "..texte)
        input_pseudo = false
      else
      message = "Le pesudo est trop long"
      end
    else
      message = "Pas assez de caractères."
    end
  end
end

function love.textinput(t)
  if input_pseudo == false then
    return
  end
  texte = texte..t
  --message = ""
end

function love.mousepressed(x, y, button)
  if button == 1 then
    Ajoute_Pseudo()
    message = ""
  end
end

function Ajoute_Pseudo()
  texte = ""
  message = ""
  input_pseudo = true
end

function love.load()
  largeur = love.graphics.getWidth()
  hauteur = love.graphics.getHeight()
  
  font_normal = love.graphics.getFont()
  font_game = love.graphics.newFont("Alien Remix.ttf", 16)
  
  liste_pop_score = {}
  liste_particules = {}
  
  pop_lifetime = 1
  explosion_lifetime = 1
end

function love.update(dt)
  Update_Pop_Score(dt)
  Update_Particules(dt)
end

function love.draw()
  love.graphics.setFont(font_game)
  Affiche_Pop_Score()
  Affiche_Particules()
  --love.graphics.setFont(font_normal)
end

function love.keypressed(key)
  
end

function love.mousepressed(x, y)
  Ajoute_Pop_Score(1000, x, y-30)
  for i=1,50 do
    Ajoute_Particule(x, y, 3)
  end
end

function Init_Game()
  liste_pop_score = {}
end

function Ajoute_Pop_Score(pScore, pX, pY)
  local score = {}
  score.valeur = pScore
  local largeur_text = font_game:getWidth(tostring(score.valeur))
  score.x = pX - (largeur_text/2)
  score.y = pY
  score.lifetime = 0
  table.insert(liste_pop_score, score)
end

function Update_Pop_Score(dt)
  for i=#liste_pop_score,1,-1 do
    local pop = liste_pop_score[i]
    pop.y = pop.y - 1
    pop.lifetime = pop.lifetime + dt
    if pop.lifetime > pop_lifetime then
      table.remove(liste_pop_score, i)
    end
  end
end

function Affiche_Pop_Score()
  for i=1,#liste_pop_score do
    local pop = liste_pop_score[i]
    local alpha = 1 - (pop.lifetime/pop_lifetime)
    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.print(pop.valeur, pop.x, pop.y)
    love.graphics.setColor(1, 1, 1, 1)
  end
end

function Ajoute_Particule(pX, pY, pR)
  local particule = {}
  particule.x = pX
  particule.y = pY
  particule.r = pR
  particule.lifetime = 0
  particule.vx = love.math.random(-100, 100)
  particule.vy = love.math.random(-100, 100)
  table.insert(liste_particules, particule)
end

function Update_Particules(dt)
  for i=#liste_particules,1,-1 do
    local particule = liste_particules[i]
    particule.x = particule.x + particule.vx*dt
    particule.y = particule.y - particule.vy*dt
    particule.lifetime = particule.lifetime + dt
    if particule.lifetime > explosion_lifetime then
      table.remove(liste_particules, i)
    end
  end
end

function Affiche_Particules()
  for i=1,#liste_particules do
    local particule = liste_particules[i]
    local alpha = 1 - (particule.lifetime/explosion_lifetime)
    love.graphics.setColor(0.8, 0.2, 0, alpha)
    love.graphics.circle("fill", particule.x, particule.y, particule.r)
    love.graphics.setColor(0.8, 0.2, 0, alpha)
  end
end