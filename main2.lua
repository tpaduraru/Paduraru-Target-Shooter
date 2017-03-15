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

-- image objects
local bg
local canon 

-- groups
local bullets = display.newGroup()
local targets = display.newGroup()

-- Definitions for target images
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
		score.hits = score.hits + 1
	elseif value == -1 then
		score.misses = score.misses + 1
	end

	-- updates score text
	score.percent = math.floor(score.hits / (score.hits + score.misses))
	score.text.text = "Hits: " .. score.hits .. ", Misses: " .. score.misses .. ", Percent Hit: " .. math.floor( 100 * score.hits / (score.hits + score.misses)) .. "%"
end

-- utility function to help add objects in one line
function addImage( file, width, height, x, y, r, group )
	local img

	--checks if the user wants to add a group or not.
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
	-- background image
	bg = addImage( "bg.jpg", 1920, 1080, xCenter, yCenter, 0, nil)
	bg:toBack( )

	-- canon
	canon = addImage("elefun.png", 70, 145, xCenter, yMax, 0, nil)
	canon.anchorY = 0.75

	-- score
	score.text = display.newText( "Hits: " .. score.hits .. ", Misses: " .. score.misses .. ", Percent Hit: " .. "100%",
			xCenter, yMin + 30, native.systemFontBold, 15 )
	score.text:toFront( )
end

-- whenever the bullet goes off the screen
function removeObj( obj )
	obj:removeSelf( ) -- deletes image
end

-- once the target transition is done, it deletes the object
function targetDone( t )
	t:removeSelf( )
	score.update(-1) -- adds one miss to sco
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
	transition.to(newBullet(), {x = canon.x, y =  canon.y - HEIGHT - 50, time = 2000, onComplete = removeObj}) -- moves bullet

	-- put canon on top
	canon:toFront()
end

-- positions target off screen randomly
function positionTarget( target, type )

	local t = targets[targets.types[type]]
	print( targets.types[type] )
	target.x = math.random( t.originMinX, t.originMaxX ) 
	target.y = math.random( t.originMinY, t.originMaxY )

	transition.to(target, {
			x = math.random(targets.destMinX, targets.destMaxX), 
			y = math.random(targets.destMinY, targets.destMaxY),
			alpha = t.destAlpha,
			rotation = math.random(targets.rotationMin, targets.rotationMax), 
			time = math.random(targets.timeMin, targets.timeMax), 
			onComplete = targetDone
			})
end

-- definitions for target transitions
function initTargets()
	-- general definitions
	targets.timeMin = 5000
	targets.timeMax = 8000
	targets.rotationMin = 180
	targets.rotationMax = 1800
	targets.destMinX = xMin - 400 
	targets.destMaxX = xMin - 100
	targets.originMinX = 320 / 5 + xMax
	targets.originMaxX = 320 / 5 + xMax + 50
	targets.destMinY = yMin
	targets.destMaxY = yMax - canon.height
	targets.originMinY = yMin
	targets.originMaxY = yMax - canon.height

	-- russian definitions
	targets.russian.destAlpha = 1 
	targets.russian.destMaxX = xMin - 100
	targets.russian.originMinX = 320 / 5 + xMax

	-- german definitions
	targets.german.destAlpha = 1
	targets.german.destMaxX = xMax + 400
	targets.german.originMinX = xMin - 320 / 5 - 50

	-- runescape definitions
	targets.runescape.destAlpha = 0 
	targets.runescape.destMaxX = xMax + 400
	targets.runescape.originMinX = xMin - 320 / 5 - 50
end

-- creates the new target with different hats
function newTarget(  )
	local t = display.newGroup() -- new display group for the target
	local type = math.random(1,3)

	spr = targets[ tostring(targets.types[type]) ] -- creates a target of a random class

	addImage( "putin.png", 320 / 5, 396 / 5, 0, 0, 0, t)
	addImage( spr[1], spr[2], spr[3], spr[4], spr[5], spr[6], t)

	targets:insert( t )

	positionTarget(t, type)
end

-- once bulllet hits target
function hit( t, b )
	-- stops both of the transitions
	transition.cancel(t)
	transition.cancel(b)

	-- shows an explosion that grows and fades out
	e = addImage("explosion.png", 200 / 4, 211 / 4, t.x, t.y, 0, nil)
	transition.to(e, {xScale = 2, yScale = 2, alpha = 0, onComplete = removeObj})

	-- remove those objects
	t:removeSelf( ) 
	b:removeSelf( )
 
	-- adds one hit
	score.update(1)
end

-- checks for collisions
function testForHits(  )
	for i = 1, targets.numChildren do -- for every target
		for j = 1, bullets.numChildren do -- for every bullets

			if math.abs(targets[i].x - bullets[j].x) <= (targets[i].width / 2)  + (bullets[j].width / 2)  and
				math.abs(targets[i].y - bullets[j].y) <= (targets[i].width / 2)  + (bullets[j].height / 2) then
				hit( targets[i], bullets[j] )
				return true
			end

		end
	end
end

-- -- runs whenever a new frame is drawn
function enterFrame( event )

	-- 30 in 1000 chance to create a new target (3%)
	if math.random( 1, 1000 ) <= 30 then
		newTarget()
	end

	-- tests for bullet and target collisions
	testForHits()
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

	-- inits the target variables
	initTargets()

	-- event listeners
	Runtime:addEventListener( "touch", fire )
	Runtime:addEventListener( "enterFrame", enterFrame)
end

-- starts the game
initGame()