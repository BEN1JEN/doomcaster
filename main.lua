local width = 800
local height = 640
local renderDist = 24
local tileMap = {}
local tileMapWidth = 64
local tileMapHeight = 64
local playerX = 3
local playerY = 3
local playerD = math.pi / 4
local fov = 60 / 180 * math.pi
local minimapSize = 256
local floorColour = {1, 1, 1}

function love.load()
	for x = 1, tileMapWidth do
		tileMap[x] = {}
		for y = 1, tileMapHeight do
			if x == 1 or x == tileMapWidth then
				tileMap[x][y] = {1, 1, 1}
			elseif y == 1 or y == tileMapHeight then
				tileMap[x][y] = {1, 1, 1}
			elseif math.random(1, 48) == 1 then
				tileMap[x][y] = {math.random(1, 256)/256, math.random(1, 256)/256, math.random(1, 256)/256}
			else
				tileMap[x][y] = false
			end
		end
	end
	print(math.floor(playerX-0.5), math.floor(playerY-0.5))
	tileMap[math.floor(playerX-0.5)+1][math.floor(playerY-0.5)+1] = false
	print(tileMap[2+1][2+1])
end

function love.update(delta)
	width, height = love.window.getMode()
	if love.keyboard.isDown("left") then
		playerD = playerD + delta * 2
	end
	if love.keyboard.isDown("right") then
		playerD = playerD - delta * 2
	end
	if love.keyboard.isDown("lshift") then
		speed = 6
	else
		speed = 2
	end
	local lastX, lastY = playerX, playerY
	if love.keyboard.isDown("w") then
		playerX = playerX + math.sin(playerD) * delta * speed
		playerY = playerY + math.cos(playerD) * delta * speed
	end
	if love.keyboard.isDown("s") then
		playerX = playerX - math.sin(playerD) * delta * speed
		playerY = playerY - math.cos(playerD) * delta * speed
	end
	if love.keyboard.isDown("a") then
		playerX = playerX + math.sin(playerD + math.pi/2) * delta * speed
		playerY = playerY + math.cos(playerD + math.pi/2) * delta * speed
	end
	if love.keyboard.isDown("d") then
		playerX = playerX - math.sin(playerD + math.pi/2) * delta * speed
		playerY = playerY - math.cos(playerD + math.pi/2) * delta * speed
	end
	if tileMap[math.floor(playerX + 0.5)] and tileMap[math.floor(playerX + 0.5)][math.floor(playerY + 0.5)] then
		playerX, playerY = lastX, lastY
	end
end

function love.draw()
	love.graphics.setColor(floorColour)
	love.graphics.rectangle("fill", 0, height-height/3-1, width, height-height/3-1)
	for y = height-height/3, height/2, -1 do
		local colour = {}
		for i, c in ipairs(floorColour) do
			local rangedY = (y-(height-height/3))/(height-height/3)*-4
			colour[i] = c * 1 - rangedY
		end
		colour[4] = 1
		love.graphics.setColor(colour)
		love.graphics.line(0, y, width, y)
	end
	for x = 1, width do
		local dist = 0
		local wallHeight = 0
		local wallColor = {0, 0, 0}
		local casting = true
		local maxWallHeight = height/3

		while casting do
			casting = dist < renderDist
			local castingDirection = (x / width - 0.5) * fov + playerD
			local castingX, castingY = playerX+math.sin(castingDirection)*dist, playerY+math.cos(castingDirection)*dist
			if tileMap[math.floor(castingX+0.5)] and tileMap[math.floor(castingX+0.5)][math.floor(castingY+0.5)] then
				casting = false
				wallHeight = maxWallHeight - dist / renderDist * maxWallHeight
				for i, c in ipairs(tileMap[math.floor(castingX+0.5)][math.floor(castingY+0.5)]) do
					wallColor[i] = c * (1 - dist / renderDist)
				end
				wallColor[4] = 1
			end
			dist = dist + 0.1
		end

		love.graphics.setColor(wallColor)
		love.graphics.line(width-x, height/2-wallHeight/2, width-x, height/2+wallHeight/2)
	end
	local minimapBlockSize = minimapSize / math.max(tileMapWidth, tileMapHeight)
	for x = 1, tileMapWidth do
		for y = 1, tileMapHeight do
			if tileMap[x] and tileMap[x][y] then
				love.graphics.setColor(tileMap[x][y])
				love.graphics.rectangle("fill", x*minimapBlockSize, y*minimapBlockSize, minimapBlockSize, minimapBlockSize)
			else
				love.graphics.setColor(0, 0, 0)
				love.graphics.rectangle("fill", x*minimapBlockSize, y*minimapBlockSize, minimapBlockSize, minimapBlockSize)
			end
		end
	end
	love.graphics.setColor(0.7, 0.9, 1, 0.1)
	love.graphics.polygon("fill",
	playerX*minimapBlockSize, playerY*minimapBlockSize,
	playerX*minimapBlockSize+math.sin(playerD-fov/2)*minimapBlockSize*6, playerY*minimapBlockSize+math.cos(playerD-fov/2)*minimapBlockSize*6,
	playerX*minimapBlockSize+math.sin(playerD+fov/2)*minimapBlockSize*6, playerY*minimapBlockSize+math.cos(playerD+fov/2)*minimapBlockSize*6)
	love.graphics.setColor(1, 0.25, 0.15)
	love.graphics.circle("fill", playerX*minimapBlockSize, playerY*minimapBlockSize, minimapBlockSize, 16)
	love.graphics.setColor(0.6, 1, 1)
end
