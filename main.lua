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
local targets = display.newGroup()
local bullets = display.newGroup()
                  
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
	if group ~= nil then
		local img = display.newImageRect( group, file, width, height )
	end

	local img = display.newImageRect( file, width, height )

	img.x, img.y, img.rotation = x, y, r

	return img
end

-- creates all image objects
function drawImages( ... )
	bg = addImage( "bg.jpg", 1920, 1080, xCenter, yCenter, 0, nil)
	canon = addImage("elefun.png", 70, 145, xCenter, yMax, 0, nil)
	canon.anchorY = 0.75
end

-- whenever the bullet goes off the screen, delete itself and update the score.
function bulletMiss( obj )
	obj:removeSelf( )
	score.update(-1)
end

-- runs whenever screen is tapped, it moves the elefant and fires a bullet from it's trunk
function fire( event )
	-- check if touch bean otherwise do nothing
	if event.phase ~= "began" then
		return nil
	end

	-- move canon
	transition.to(canon, { x = event.x, time = 300})

	-- fire bullet
	local b = addImage ( "butterfly.png", 100 / 3, 89 / 3, -- adds bullet
			canon.x, canon.y - canon.height + 40, canon.rotation, bullets )
	transition.to(b, {x = canon.x, y = canon.y - HEIGHT - 50, time = 2000, onComplete = bulletMiss}) -- moves bullet

	-- put canon on top
	canon:toFront( )
end

-- runs whenever a new frame is drawn
function enterFrame( event )
	testForHits()
end

-- checks for collisions
function testForHits(  )
	print(bullets.numChildren)
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