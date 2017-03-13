-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- ██╗   ██╗ █████╗ ██████╗ ██╗ █████╗ ██████╗ ██╗     ███████╗███████╗
-- ██║   ██║██╔══██╗██╔══██╗██║██╔══██╗██╔══██╗██║     ██╔════╝██╔════╝
-- ██║   ██║███████║██████╔╝██║███████║██████╔╝██║     █████╗  ███████╗
-- ╚██╗ ██╔╝██╔══██║██╔══██╗██║██╔══██║██╔══██╗██║     ██╔══╝  ╚════██║
--  ╚████╔╝ ██║  ██║██║  ██║██║██║  ██║██████╔╝███████╗███████╗███████║
--   ╚═══╝  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝╚══════╝


-- Get the screen metrics
local WIDTH = display.actualContentWidth 
local HEIGHT = display.actualContentHeight 
local xMin = display.screenOriginX 
local yMin = display.screenOriginY 
local xMax = xMin + WIDTH 
local yMax = yMin + HEIGHT 
local xCenter = (xMin + xMax) / 2 
local yCenter = (yMin + yMax) / 2

-- variables for the score
local score = {}
score.hits = 0
score.misses = 0
score.percent = math.floor(score.hits / (score.hits + score.misses))
score.text = "Hits: " .. score.hits .. "Misses: " .. score.misses .. "Percent Hit: " .. score.percent

-- image objects
local bg
local canon

-- groups
local bullets = display.newGroup()
local targets = display.newGroup()
targets.russian = { "russian-hat.png", 500 / 5.5, 500 / 5.5, 4, -13, 3 }
targets.german = { "german-hat.png", 2400 / 26, 1478 / 26, 4, -40, 5 }
targets.runescape = {"rs-hat.png", 400 / 9, 400 / 9, 4, -45, 5}
targets.types = { "russian", "german", "runescape" }
                  
-- ███████╗██╗   ██╗███╗   ██╗ ██████╗████████╗██╗ ██████╗ ███╗   ██╗███████╗
-- ██╔════╝██║   ██║████╗  ██║██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
-- █████╗  ██║   ██║██╔██╗ ██║██║        ██║   ██║██║   ██║██╔██╗ ██║███████╗
-- ██╔══╝  ██║   ██║██║╚██╗██║██║        ██║   ██║██║   ██║██║╚██╗██║╚════██║
-- ██║     ╚██████╔╝██║ ╚████║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║███████║
-- ╚═╝      ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

-- refreshes game score depending on value passed into it.
score.update = function(value)
	if value == 1 then

	elseif value == -1 then
		score.misses = score.misses + 1
	end

	score.percent = math.floor(score.hits / (score.hits + score.misses))
	score.text = "Hits: " .. score.hits .. "Misses: " .. score.misses .. "Percent Hit: " .. score.percent
end

-- utility function to help add objects in one line
function addImage( file, width, height, x, y, r, group )
	local img

	if group ~= nil then
		img = display.newImageRect( group, file, width, height )
	else
		img = display.newImageRect( file, width, height )
	end

	img.x, img.y, img.rotation = x, y, r

	return img
end

-- creates all image objects
function drawImages( ... )
	bg = addImage( "bg.jpg", 1920, 1080, xCenter, yCenter, 0, nil)
	bg:toBack( )
	canon = addImage("elefun.png", 70, 145, xCenter, yMax, 0, nil)
	canon.anchorY = 0.75
end

-- whenever the bullet goes off the screen
function bulletMiss( obj )
	obj:removeSelf( ) -- deletes image
	score.update(-1) -- adds one miss to score
end

function targetDone( t )
	t:removeSelf( )
	print( targets.numChildren )
end

-- makes then returns the bullet
function newBullet( )
	local b = addImage( "butterfly.png", 100 / 3, 89 / 3, canon.x, canon.y - canon.height + 40, canon.rotation, bullets )
	--b = display.newImageRect( bullets, "butterfly.png", 100 / 3, 89/3 )
	return b
end

-- runs whenever screen is tapped, it moves the elefant and fires a bullet from it's trunk
function fire( event )
	-- check if touch began otherwise do nothing
	if event.phase ~= "began" then
		return nil
	end

	-- move canon
	transition.to(canon, { x = event.x, time = 500})

	-- fire bullet 
	transition.to(newBullet(), {x = canon.x, y =  canon.y - HEIGHT - 50, time = 2000, onComplete = bulletMiss}) -- moves bullet

	-- put canon on top
	canon:toFront()
end

function positionTarget( t, type )
	-- positions target off screen randomly
	t.x, t.y = math.random( t[1].width + xMax, t[1].width + xMax + 400), math.random( yMin, yMax - canon.height )

	transition.to(t, {x = xMin - math.random(100, 400), rotation = math.random(360, 6000), 
			time = math.random(2000, 3500), onComplete = targetDone})
end

function newTarget(  )
	local t = display.newGroup() -- new display group for the target

	spr = targets[ tostring(targets.types[math.random(1,3)]) ] -- creates a target of a random class

	addImage( "putin.png", 320 / 5, 396 / 5, 0, 0, 0, t)
	addImage( spr[1], spr[2], spr[3], spr[4], spr[5], spr[6], t)

	targets:insert( t )

	positionTarget(t)
end

function moveTargets(  )
	for i = 1, targets.numChildren do
		if targets[i] ~= nil then
			targets[i].x = targets[i].x - 10
			targets[i].rotation = targets[i].rotation + 1
		end
	end
end

-- checks for collisions
function testForHits(  )
	print(targets.numChildren)
end

-- -- runs whenever a new frame is drawn
function enterFrame( event )
	newTarget()
	--moveTargets()
end

-- ██╗███╗   ██╗██╗████████╗ ██████╗  █████╗ ███╗   ███╗███████╗
-- ██║████╗  ██║██║╚══██╔══╝██╔════╝ ██╔══██╗████╗ ████║██╔════╝
-- ██║██╔██╗ ██║██║   ██║   ██║  ███╗███████║██╔████╔██║█████╗  
-- ██║██║╚██╗██║██║   ██║   ██║   ██║██╔══██║██║╚██╔╝██║██╔══╝  
-- ██║██║ ╚████║██║   ██║   ╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗
-- ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝

function initGame()
	-- hide status bar
	display.setStatusBar( display.HiddenStatusBar )

	-- draw display objects
	drawImages()

	-- event listeners
	Runtime:addEventListener( "touch", fire )
	Runtime:addEventListener( "enterFrame", enterFrame)
end

initGame()