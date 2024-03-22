io.stdout:setvbuf('no')
if arg[#arg] == "-debug" then require("mobdebug").start() end

love.graphics.setDefaultFilter("nearest")

-- Images loading
local imgTiles = {}
imgTiles["1"] = love.graphics.newImage("images/tile1.png")
imgTiles["2"] = love.graphics.newImage("images/tile2.png")
imgTiles["3"] = love.graphics.newImage("images/tile3.png")
imgTiles["4"] = love.graphics.newImage("images/tile4.png")
imgTiles["5"] = love.graphics.newImage("images/tile5.png")
imgTiles["="] = love.graphics.newImage("images/tile=.png")
imgTiles["["] = love.graphics.newImage("images/tile[.png")
imgTiles["]"] = love.graphics.newImage("images/tile].png")
imgTiles["H"] = love.graphics.newImage("images/tileH.png")
imgTiles["#"] = love.graphics.newImage("images/tile#.png")
imgTiles["g"] = love.graphics.newImage("images/tileg.png")
imgTiles[">"] = love.graphics.newImage("images/tile-arrow-right.png")
imgTiles["<"] = love.graphics.newImage("images/tile-arrow-left.png")

-- Map and levels
local map = {}
local level = {}
local currentLevel = 0
local lstSprites = {}
local player = nil

local TILESIZE = 16

-- Globals
local bJumpReady

-- Collision detection function;
-- Returns true if two boxes overlap, false if they don't;
-- x1,y1 are the top-left coords of the first box, while w1,h1 are its width and height;
-- x2,y2,w2 & h2 are the same, but for the second box.
-- FROM https://love2d.org/wiki/BoundingBox.lua 
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

local levels = {
    "The beginning",
    "Welcome in hell"
  }

function ChargeNiveau(pNum)
  if pNum > #levels then
    print("There is no level "..pNum)
    return
  end
  currentLevel = pNum
  map = {}
  local filename = "levels/level"..tostring(pNum)..".txt"
  for line in love.filesystem.lines(filename) do 
    map[#map + 1] = line
  end
  -- Look for the sprites in the map
  lstSprites = {}
  level = {}
  level.playerStart = {}
  level.playerStart.col = 0
  level.playerStart.lig = 0
  level.coins = 0
  for l=1,#map do
    for c=1,#map[1] do
      local char = string.sub(map[l],c,c)
      if char == "P" then
        level.playerStart.col = c
        level.playerStart.lig = l
        player = CreatePlayer(c,l)
      elseif char == "c" then
        CreateCoin(c,l)
        level.coins = level.coins + 1
      elseif char == "D" then
        CreateDoor(c,l)
      elseif char == "@" then
        CreatePNJ(c,l)
      end
    end
  end
--  CreatePlayer(level.playerStart.col,level.playerStart.lig)
end

function NextLevel()
  currentLevel = currentLevel + 1
  if currentLevel > #levels then
    currentLevel = 1
    print("TODO: Victory screen, all level completed")
  end
  ChargeNiveau(currentLevel)
end

function isSolid(pID)
  if pID == "0" then return false end
  if pID == "1" then return true end
  if pID == "5" then return true end
  if pID == "4" then return true end
  if pID == "=" then return true end
  if pID == "[" then return true end
  if pID == "]" then return true end
  return false
end

function isJumpThrough(pID)
  if pID == "g" then return true end
  return false
end

function isLadder(pID)
  if pID == "H" then return true end
  if pID == "#" then return true end
  return false
end

function isInvisible(pID)
  --if pID == ">" or pID == "<" then return true end
  return false
end

function CreateSprite(pType, pX, pY)
  local mySprite = {}
  
  mySprite.x = pX
  mySprite.y = pY
  mySprite.vx = 0
  mySprite.vy = 0
  mySprite.gravity = 0
  mySprite.isJumping = false
  mySprite.type = pType
  mySprite.standing = false
  mySprite.flip = false
  
  mySprite.currentAnimation = ""
  mySprite.frame = 0
  mySprite.animationSpeed = 1/8
  mySprite.animationTimer = mySprite.animationSpeed
  mySprite.animations = {}
  mySprite.images = {}
  
  mySprite.AddImages = function(psDir, plstImage)
    for k,v in pairs(plstImage) do
      local fileName = psDir.."/"..v..".png"
      mySprite.images[v] = love.graphics.newImage(fileName)
    end
  end
  
  mySprite.AddAnimation = function(psDir, psName, plstImages)
    mySprite.AddImages(psDir, plstImages)
    mySprite.animations[psName] = plstImages
  end
  
  mySprite.PlayAnimation = function(psName)
    if mySprite.currentAnimation ~= psName then
      mySprite.currentAnimation = psName
      mySprite.frame = 1
    end
  end
    
  table.insert(lstSprites, mySprite)
  
  return mySprite
end

function CreatePlayer(pCol, pLig)
  local myPlayer = CreateSprite("player", (pCol-1) * TILESIZE, (pLig-1) * TILESIZE)
  myPlayer.gravity = 500
  myPlayer.AddAnimation("images/player", "idle", { "idle1", "idle2", "idle3", "idle4" })
  myPlayer.AddAnimation("images/player", "run", { "run1", "run2", "run3", "run4", "run5", "run6", "run7", "run8", "run9", "run10" })
  myPlayer.AddAnimation("images/player", "climb", { "climb1", "climb2" })
  myPlayer.AddAnimation("images/player", "climb_idle", { "climb1" })
  myPlayer.PlayAnimation("idle")
  bJumpReady = true
  return myPlayer
end

function CreateCoin(pCol, pLig)
  local myCoin = CreateSprite("coin", (pCol-1) * TILESIZE, (pLig-1) * TILESIZE)
  myCoin.AddAnimation("images/coin", "idle", { "coin1", "coin2", "coin3", "coin4" })
  myCoin.PlayAnimation("idle")
end

function CreateDoor(pCol, pLig)
  local myDoor = CreateSprite("door", (pCol-1) * TILESIZE, (pLig-1) * TILESIZE)
  myDoor.AddAnimation("images/door", "close", { "door-close" })
  myDoor.AddAnimation("images/door", "open", { "door-open" })
  myDoor.PlayAnimation("close")
end

function CreatePNJ(pCol, pLig)
  local myPNJ = CreateSprite("PNJ", (pCol-1) * TILESIZE, (pLig-1) * TILESIZE)
  myPNJ.AddAnimation("images/pnj", "walk", { "walk0", "walk1", "walk2", "walk3", "walk4", "walk5" })
  myPNJ.PlayAnimation("walk")
  myPNJ.direction = "right"
  myPNJ.CheckInternalCollision = collidePNJ
end

function OpenDoor()
  for nSprite=#lstSprites,1,-1 do
    local sprite = lstSprites[nSprite]
    if sprite.type == "door" then
      sprite.PlayAnimation("open")
    end
  end
end

function InitGame(pNiveau)
  ChargeNiveau(pNiveau)
end

function love.load()
  love.window.setMode(1200,900)
  love.window.setTitle("Mini platformer (c) Gamecodeur 2017")
  InitGame(1)
end

function AlignOnLine(pSprite)
  local lig = math.floor((pSprite.y + TILESIZE/2) / TILESIZE) + 1
  pSprite.y = (lig-1)*TILESIZE
end

function AlignOnColumn(pSprite)
  local col = math.floor((pSprite.x + TILESIZE/2) / TILESIZE) + 1
  pSprite.x = (col-1)*TILESIZE
end

function updatePNJ(pSprite, dt)
  if pSprite.direction == "right" then
    pSprite.vx = 25
  elseif pSprite.direction == "left" then
    pSprite.vx = -25
  end
end

function collidePNJ(pSprite, dt)
  -- Tile under the player
  local idUnder = getTileAt(pSprite.x + TILESIZE/2, pSprite.y + TILESIZE)
  local idOverlap = getTileAt(pSprite.x + TILESIZE/2, pSprite.y + TILESIZE-1)
  
  pSprite.vx = 0
  local isCollide = false
  
  if idOverlap == ">" then
    pSprite.direction = "right"
    pSprite.flip = false
    pSprite.x = pSprite.x + 2
    isCollide = true
  elseif idOverlap == "<" then
    pSprite.direction = "left"
    pSprite.flip = true
    pSprite.x = pSprite.x - 2
    isCollide = true
  end
    
  return isCollide
end

function updatePlayer(pPlayer, dt)
  -- Locals for Physics
  local accel = 200
  local friction = 120
  local maxSpeed = 50
  local jumpSpeed = -190
  
  -- Tile under the player
  local idUnder = getTileAt(pPlayer.x + TILESIZE/2, pPlayer.y + TILESIZE)
  local idOverlap = getTileAt(pPlayer.x + TILESIZE/2, pPlayer.y + TILESIZE-1)
  
  -- Stop Jump?
  if pPlayer.isJumping and (CollideBelow(pPlayer) or isLadder(idUnder)) then
    pPlayer.isJumping = false
  end
  -- Friction
  if pPlayer.vx > 0 then
    pPlayer.vx = pPlayer.vx - friction * dt
    if pPlayer.vx < 0 then pPlayer.vx = 0 end
  end
  if pPlayer.vx < 0 then
    pPlayer.vx = pPlayer.vx + friction * dt
    if pPlayer.vx > 0 then pPlayer.vx = 0 end
  end
  local newAnimation = "idle"
  -- Keyboard
  if love.keyboard.isDown("right") then
    pPlayer.vx = pPlayer.vx + accel*dt
    if pPlayer.vx > maxSpeed then pPlayer.vx = maxSpeed end
    pPlayer.flip = false
    newAnimation = "run"
  end
  if love.keyboard.isDown("left") then
    pPlayer.vx = pPlayer.vx - accel*dt
    if pPlayer.vx < -maxSpeed then pPlayer.vx = -maxSpeed end
    pPlayer.flip = true
    newAnimation = "run"
  end
  -- Check if the player overlap a ladder
  local isOnLadder = isLadder(idUnder) or isLadder(idOverlap)
  if isLadder(idOverlap) == false and isLadder(idUnder) then
    pPlayer.standing = true
  end
  -- Jump
  if love.keyboard.isDown("up") and pPlayer.standing and bJumpReady and isLadder(idOverlap) == false then
    pPlayer.isJumping = true
    pPlayer.gravity = 500
    pPlayer.vy = jumpSpeed
    pPlayer.standing = false
    bJumpReady = false
  end
  -- Climb
  if isOnLadder and pPlayer.isJumping == false then
    pPlayer.gravity = 0
    pPlayer.vy = 0
    bJumpReady = false
  end
  if isLadder(idUnder) and isLadder(idOverlap) then
    newAnimation = "climb_idle"
  end
  if love.keyboard.isDown("up") and isOnLadder == true and pPlayer.isJumping == false then
    pPlayer.vy = -50
    newAnimation = "climb"
  end
  if love.keyboard.isDown("down") and isOnLadder == true then
    pPlayer.vy = 50
    newAnimation = "climb"
  end
  -- Not climbing
  if isOnLadder == false and pPlayer.gravity == 0 and pPlayer.isJumping == false then
    pPlayer.gravity = 500
  end
  -- Ready for next jump
  if love.keyboard.isDown("up") == false and bJumpReady == false and pPlayer.standing == true then
    bJumpReady = true
  end
  pPlayer.PlayAnimation(newAnimation)
end

function getTileAt(pX, pY)
  local col = math.floor(pX / TILESIZE) + 1
  local lig = math.floor(pY / TILESIZE) + 1
  if col>0 and col<=#map[1] and lig>0 and lig<=#map then
    local id = string.sub(map[lig],col,col)
    return id
  end
  return 0
end

function CollideRight(pSprite)
  local id1 = getTileAt(pSprite.x + TILESIZE, pSprite.y + 3)
  local id2 = getTileAt(pSprite.x + TILESIZE, pSprite.y + TILESIZE - 2)
  if isSolid(id1) or isSolid(id2) then return true end
  return false
end

function CollideLeft(pSprite)
  local id1 = getTileAt(pSprite.x-1, pSprite.y + 3)
  local id2 = getTileAt(pSprite.x-1, pSprite.y + TILESIZE - 2)
  if isSolid(id1) or isSolid(id2) then return true end
  return false
end

function CollideBelow(pSprite)
  local id1 = getTileAt(pSprite.x + 1, pSprite.y + TILESIZE)
  local id2 = getTileAt(pSprite.x + TILESIZE-2, pSprite.y + TILESIZE)
  if isSolid(id1) or isSolid(id2) then return true end
  if isJumpThrough(id1) or isJumpThrough(id2) then
    local lig = math.floor((pSprite.y + TILESIZE/2) / TILESIZE) + 1
    local yLine = (lig-1)*TILESIZE
    local distance = pSprite.y - yLine
    if distance >= 0 and distance < 10 then
      return true
    end
  end
  return false
end

function CollideAbove(pSprite)
  local id1 = getTileAt(pSprite.x + 1, pSprite.y-1)
  local id2 = getTileAt(pSprite.x + TILESIZE-2, pSprite.y-1)
  if isSolid(id1) or isSolid(id2) then return true end
  return false
end

function updateSprite(pSprite, dt)
  -- Locals for Collisions
  local oldX = pSprite.x
  local oldY = pSprite.y

  -- Animation
  if pSprite.currentAnimation ~= "" then
    pSprite.animationTimer = pSprite.animationTimer - dt
    if pSprite.animationTimer <= 0 then
      pSprite.frame = pSprite.frame + 1
      pSprite.animationTimer = pSprite.animationSpeed
      if pSprite.frame > #pSprite.animations[pSprite.currentAnimation] then
        pSprite.frame = 1
      end
    end
  end

  -- Specific behavior for the player
  if pSprite.type == "player" then
    updatePlayer(pSprite, dt)
  elseif pSprite.type == "PNJ" then
    updatePNJ(pSprite, dt)
  end
  
  -- Calculate the movement steps
  local distanceX = pSprite.vx * dt
  local distanceY = pSprite.vy * dt
  
  -- Avoid long jumps (to allow sprites collisions)
  if distanceX > TILESIZE/2 then distanceX = TILESIZE/2 end
  if distanceY > TILESIZE/2 then distanceY = TILESIZE/2 end
    
  -- Collision detection using simple and not optimized CCD
  
  -- Get the last internal collide result
  local collide = false --pSprite.collide

  -- Right
  local destX = pSprite.x + distanceX
  if distanceX > 0 and collide == false then
    while pSprite.x < destX do
      collide = CollideRight(pSprite)
      if collide == false and pSprite.CheckInternalCollision ~= nil then
        collide = pSprite.CheckInternalCollision(pSprite, dt)
      end
      if collide == true then
        pSprite.vx = 0
        break
      else
        pSprite.x = pSprite.x + 0.05
      end
    end
  elseif distanceX < 0 and collide == false then
    while pSprite.x > destX do
      collide = CollideLeft(pSprite)
      if collide == false and pSprite.CheckInternalCollision ~= nil then
        collide = pSprite.CheckInternalCollision(pSprite, dt)
      end
      if collide == true then
        pSprite.vx = 0
        break
      else
        pSprite.x = pSprite.x - 0.05
      end
    end
  end
  
  -- Vertical CCD
  local destY = pSprite.y + distanceY
  -- Above (go up)
  if distanceY < 0 then
    while pSprite.y > destY do
      collide = CollideAbove(pSprite)
      if collide == false and pSprite.CheckInternalCollision ~= nil then
        collide = pSprite.CheckInternalCollision(pSprite, dt)
      end
      if collide == true then
        pSprite.vy = 0
        break
      else
        pSprite.y = pSprite.y - 0.05
      end
    end
  end
  collide = false
  -- Below (go down)
  -- Check if need to start falling
  if pSprite.standing == true or pSprite.vy > 0 then
    collide = CollideBelow(pSprite)
    if collide then
      pSprite.standing = true
      pSprite.vy = 0
      AlignOnLine(pSprite)
    else
      if pSprite.gravity ~= 0 then
        pSprite.standing = false
      end
    end
  end
  if distanceY > 0 then
    while pSprite.y < destY do
      collide = CollideBelow(pSprite)
      if collide == false and pSprite.CheckInternalCollision ~= nil then
        collide = pSprite.CheckInternalCollision(pSprite, dt)
      end
      if collide == true then
        pSprite.standing = true
        pSprite.vy = 0
        break
      else
        pSprite.y = pSprite.y + 0.05
      end
    end
  end
    
  collide = false
  -- Sprite falling
  if pSprite.standing == false then
    pSprite.vy = pSprite.vy + pSprite.gravity * dt
  end
end

function love.update(dt)
  for nSprite=#lstSprites,1,-1 do
    local sprite = lstSprites[nSprite]
    updateSprite(sprite, dt)
  end
  -- Check collision with the player
  for nSprite=#lstSprites,1,-1 do
    local sprite = lstSprites[nSprite]
    if sprite.type ~= "player" then
      -- Check rectangle collision
      if CheckCollision(player.x, player.y, TILESIZE, TILESIZE, sprite.x, sprite.y, TILESIZE, TILESIZE) then
        if sprite.type == "coin" then
          table.remove(lstSprites, nSprite)
          level.coins = level.coins - 1
          if level.coins == 0 then
            -- Open door!
            OpenDoor()
          end
        elseif sprite.type == "door" then
          if level.coins == 0 then
            NextLevel()
          end
        elseif sprite.type == "PNJ" then
          print("YOU ARE DEAD")
        end
      end
    end
  end  
end

function drawSprite(pSprite)
  local imgName = pSprite.animations[pSprite.currentAnimation][pSprite.frame]
  local img = pSprite.images[imgName]
  local halfw = img:getWidth()  / 2
  local halfh = img:getHeight() / 2
  local flipCoef = 1
  if pSprite.flip then flipCoef = -1 end
  love.graphics.draw(
    img, -- Image
    pSprite.x + halfw, -- horizontal position
    pSprite.y + halfh, -- vertical position
    0, -- rotation (none = 0)
    1 * flipCoef, -- horizontal scale
    1, -- vertical scale (normal size = 1)
    halfw, halfh -- horizontal and vertical offset
    )
end

function love.draw()
  love.graphics.scale(3,3)
  
  for l=1,#map do
    for c=1,#map[1] do
      local char = string.sub(map[l],c,c)
      if tonumber(char) ~= 0 and isInvisible(char) == false then
        if imgTiles[char] ~= nil then
          love.graphics.draw(imgTiles[char],(c-1)*TILESIZE,(l-1)*TILESIZE)
        end
      end
    end
  end
  for nSprite=#lstSprites,1,-1 do
    local sprite = lstSprites[nSprite]
    drawSprite(sprite)
  end
  love.graphics.print("Level "..currentLevel..": "..levels[currentLevel], 5, (TILESIZE * 18) - 3)
	local stats = love.graphics.getStats()
	love.graphics.print("drawcalls " .. stats.drawcalls, 1, 1)
end