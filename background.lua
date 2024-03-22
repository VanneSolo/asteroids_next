local background = {}

function background:Load()
  -- CREATION DU STARFIELD
  starfield = {}
  nb_stars = 100
  star_trebble = 0.1
  for i=1,nb_stars do
    local star = {}
    star.r = math.random(1, 3)
    star.x = math.random(star.r, largeur-star.r)
    star.y = math.random(star.r, hauteur-star.r)
    star.color = {math.random(0.8, 1), math.random(0.8, 1), math.random(0.8, 1), 1}
    table.insert(starfield, star)
  end
end

function background:Update(target, dt)
  -- UPDATE DE LA POSITION DES ETOILES EN FONCTION DU PLAYER ET REAPPARITION
  -- SI ELLES SORRTENT DE L'ECRAN
  for i=1,#starfield do
    if target.speed > 0 then
      if starfield[i].r == 1 then
        starfield[i].x = starfield[i].x - target.speed*math.cos(target.body:getAngle())
        starfield[i].y = starfield[i].y - target.speed*math.sin(target.body:getAngle())
      elseif starfield[i].r == 2 then
        starfield[i].x = starfield[i].x - (target.speed*1.1)*math.cos(target.body:getAngle())
        starfield[i].y = starfield[i].y - (target.speed*1.1)*math.sin(target.body:getAngle())
      elseif starfield[i].r == 3 then
        starfield[i].x = starfield[i].x - (target.speed*1.3)*math.cos(target.body:getAngle())
        starfield[i].y = starfield[i].y - (target.speed*1.3)*math.sin(target.body:getAngle())
      end
    end
  
    if starfield[i].x > largeur then
      starfield[i].x = 0
    end
    if starfield[i].x < 0 then
      starfield[i].x = largeur
    end
    if starfield[i].y > hauteur then
      starfield[i].y = 0
    end
    if starfield[i].y < 0 then
      starfield[i].y = hauteur
    end
  end
  
  -- AJOUTE UN PETIT MOUVEMENT ALEATOIRE AUX ETOILES QUAND LE VAISSEAU NE BOUGE PAS
  
  for i=1,#starfield do
    pile_ou_face = love.math.random(1, 2)
    if pile_ou_face == 1 then
      star_trebble = -0.1
    elseif pile_ou_face == 2 then
      star_trebble = 0.1
    end
    starfield[i].x = starfield[i].x + star_trebble
    starfield[i].y = starfield[i].y + star_trebble
  end
end
  
function background:Draw()
  -- AFFICHAGE DU CHAMP D'ETOILES
  for i=1,#starfield do
    love.graphics.setColor(starfield[i].color)
    love.graphics.circle("fill", starfield[i].x, starfield[i].y, starfield[i].r)
  end
end
  
return background