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
local targets = {}
targets.russian = { "russian-hat.png", 500 / 5.5, 500 / 5.5, 4, -13, 3 }
targets.german = { "german-hat.png", 2400 / 26, 1478 / 26, 4, -40, 5 }
targets.runescape = {"rs-hat.png", 400 / 9, 400 / 9, 4, -45, 5}
                  
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

function newTarget(  )
	local t = display.newGroup() -- new display group for the target
	e = targets.runescape

	t.x, t.y = xCenter,yCenter

	addImage( "putin.png", 320 / 5, 396 / 5, 0, 0, 0, t)
	addImage(e[1], e[2], e[3], e[4], e[5], e[6], t)

	return t
end

-- function addTarget(  )
-- 	if math.random( 0, 300 ) <= 10 then
-- 		--addImage( targets.russian[1], 320 / 5, 396 / 5, xCenter, yCenter, 0, targets)
-- 		newTarget()
-- 	end
-- end

-- checks for collisions
function testForHits(  )
	print(bullets.numChildren)
end

-- -- runs whenever a new frame is drawn
function enterFrame( event )
	testForHits()
	--addTarget()
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