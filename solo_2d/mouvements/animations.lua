function Cree_Sprite()
  local sprite = {}
  sprite.images = {}
  sprite.image = nil
  sprite.x = 0
  sprite.y = 0
  sprite.animations = {}
  sprite.animation_loop = {}
  sprite.animation_end = {}
  sprite.current_animation = ""
  sprite.current_frame = 1
  sprite.timer_animation = 0
  return sprite
end

function Set_Sprite(pSprite, pImage)
  pSprite.image = pImage
end

function Ajoute_Image(pSprite, pNom, pImage)
  pSprite.images[pNom] = pImage
end

function Ajoute_Animation(pSprite, pNom, pListeImages, pLoop)
  pSprite.animations[pNom] = pListeImages
  pSprite.animation_loop[pNom] = pLoop
  pSprite.animation_end[pNom] = false
end

function Start_Animation(pSprite, pNom)
  if pSprite.current_animation ~= pNom then
    pSprite.current_animation = pNom
    pSprite.current_frame = 1
    pSprite.timer_animation = 0
    pSprite.animation_end[pSprite.current_animation] = false
  end
end

function Update_Animation(pSprite, dt)
  pSprite.timer_animation = pSprite.timer_animation + dt
  if pSprite.timer_animation > 0.1 then
    pSprite.current_frame = pSprite.current_frame + 1
    local nb_images_animation = #pSprite.animations[pSprite.current_animation]
    if pSprite.current_frame > nb_images_animation then
      if pSprite.animation_loop[pSprite.current_animation] == true then
        pSprite.current_frame = 1
      else
        pSprite.current_frame = nb_images_animation
        pSprite.animation_end[pSprite.current_animation] = true
      end
    end
    pSprite.timer_animation = 0
  end
end

function Draw_Sprite(pSprite)
  if pSprite.image ~= nil then
    love.graphics.draw(pSprite.image, pSprite.x, pSprite.y)
  else
    local current_anim = pSprite.current_animation
    local anim = pSprite.animations[current_anim]
    local nom_frame = anim[pSprite.current_frame]
    local image = pSprite.images[nom_frame]
    love.graphics.draw(image, pSprite.x, pSprite.y)
  end
end