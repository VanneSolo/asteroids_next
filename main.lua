--[[
                                        USER INTERFACE
  
  -Débugger le reset des couleurs à (1, 1, 1)
  -Corriger le bug de position si on passe à la méthode Set_Shape un argument
   différent de celui passé à la création du bouton.
  -Corriger le bug d'affichage du texte dans un bouton rond.
  -Corriger les barres de progressions ronde.
  -Ajouter la possibilité de naviguer dans l'UI au clavier ou à la manette.
  -Faire les tests avec des images à la place des primitives de Löve2D.
  -Ecrire une documentation pour utiliser l'UI.

]]

largeur = love.graphics.getWidth()
hauteur = love.graphics.getHeight()

require "vector"
--require "solo_2d.maths.basics"
--require "solo_2d.maths.bezier"
--require "solo_2d.maths.tweening"
--require "solo_2d.physics.detection"
--require "solo_2d.physics.resolution"
require "solo_2d.physics.sat"
require "solo_2d.utilitaires.utils"
ui = require("user_interface.gui_base")

world = require "world"
player = require "player"
--require "alien"
asteroids = require "asteroid"
background = require "background"

inconsolata = love.graphics.newFont("Inconsolata-Medium.ttf")
saucer_sound = love.audio.newSource("sounds/saucer_sound.wav", "static")
music_1 = love.audio.newSource("sounds/05_03_2023.wav", "stream")

-- LOAD
function love.load()
  debug = false
  -- CREATION DU WORLD
  world = love.physics.newWorld(0, 0, true)
  world:setCallbacks(Begin_Contact, End_Contact, Pre_Solve, Post_Solve)
  
  background:Load()
  asteroids:Load(4)
  player:Load()
end

-- UPDATE
function love.update(dt)
  background:Update(player, dt)
  asteroids:Update(dt)
  player:Update(dt)
  
  -- UPDATE DU WORLD
  world:update(dt)
end

-- DRAW
function love.draw()
  background:Draw()
  asteroids:Draw()
  player:Draw()
  
  -- REMISE DE LA COULEUR PAR DEFAUT
  love.graphics.setColor(1, 1, 1, 1)
  
  if debug then
    love.graphics.print("vitesse du joueur: "..tostring(math.floor(player.speed)), 5, 5)
    for i=1,#asteroids.liste do
      love.graphics.print("asteroid "..tostring(i), 5+(i-1) * 115, 5+16)
      love.graphics.print("nb vies: "..tostring(asteroids.liste[i].nb_lives), (i-1) * 115, 5+16*2)
      love.graphics.print("pv: "..tostring(asteroids.liste[i].pv), 25+(i-1) * 115, 5+16*3)
      love.graphics.print("alive: "..tostring(asteroids.liste[i].is_alive), (i-1) * 115, 5+16*4)
      love.graphics.print("detruit: "..tostring(asteroids.liste[i].body:isDestroyed()), (i-1) * 115, 5+16*5)
      --love.graphics.print("position: "..tostring(math.floor(asteroids.liste[i].body:getX()))..", "..tostring(math.floor(asteroids.liste[i].body:getY())), (i-1) * 115, 5+16*6)
    end
  end
  --love.graphics.print("nombre d'astéroides: "..tostring(#asteroids.liste), 5, 5)
  
end

-- MOUSEPRESSED
function love.mousepressed(x, y, button)
end

-- KEYPRESSED
function love.keypressed(key)
  if key == "d" then
    debug = not debug
  end
  
  player:Keypressed(key)
end


-- PHYSICS CALLBACKS // ordre d'appel: begin, pre_solve et post_solve en alternance et en continu tout le temps que dure
--                                     la collision entre les deux objets et end à la fin.
function Begin_Contact(a, b, collision)
  if a:getBody():getUserData().id == "asteroid" and b:getBody():getUserData().id == "bullet" or a:getBody():getUserData().id == "bullet" and b:getBody():getUserData().id == "asteroid" then
    if a:getBody():getUserData().id == "asteroid" then
      a:getBody():getUserData().pv = a:getBody():getUserData().pv - 1
      if a:getBody():getUserData().pv <= 0 then
        a:getBody():getUserData().nb_lives = a:getBody():getUserData().nb_lives - 1
        if a:getBody():getUserData().nb_lives > 0 then
          a:getBody():getUserData().pv = 4
        else
          a:getBody():getUserData().nb_lives = 0
          a:getBody():getUserData().pv = 0
        end
      end
    elseif b:getBody():getUserData().id == "asteroid" then
      b:getBody():getUserData().pv = b:getBody():getUserData().pv - 1
      if b:getBody():getUserData().pv <= 0 then
        b:getBody():getUserData().nb_lives = b:getBody():getUserData().nb_lives - 1
        if b:getBody():getUserData().nb_lives > 0 then
          b:getBody():getUserData().pv = 4
        else
          b:getBody():getUserData().nb_lives = 0
          b:getBody():getUserData().pv = 0
        end
      end
    end
  end
end

function End_Contact(a, b, collision)
  if a:getBody():isDestroyed() == false and a:getBody():getUserData().id == "asteroid" then
    if a:getBody():getUserData().nb_lives <= 0 then
      a:getBody():getUserData().is_alive = false
    end
  elseif b:getBody():isDestroyed() == false and b:getBody():getUserData().id == "asteroid" then
    if b:getBody():getUserData().nb_lives <= 0 then
      b:getBody():getUserData().is_alive = false
    end
  end
end

function Pre_Solve(a, b, collision)
  
end

function Post_Solve(a, b, collision, normal_impulse, tangent_impulse)
  
end