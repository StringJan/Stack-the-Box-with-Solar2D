
local composer = require( "composer" )
local scene = composer.newScene()

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 9.81 )


local score = 1000

local gameLoopTimer

local scoreText

local backGroup
local mainGroup
local uiGroup

local musicTrack

local chests = {}
local lastChest
local highestChest
local checking = false

local function dragBox( event, params )
	local body = event.target
	local phase = event.phase
	local stage = display.getCurrentStage()

	if "began" == phase then
		stage:setFocus( body )
		body.isFocus = true
		body.tempJoint = physics.newJoint( "touch", body, event.x, event.y )
		
	elseif body.isFocus then
		if "moved" == phase then
			body.tempJoint:setTarget( event.x, event.y )

		elseif "ended" == phase or "cancelled" == phase then
			stage:setFocus( nil )
			body.isFocus = false	
			body.tempJoint:removeSelf()
		end
	end

	return true
end

local function spawnChest()
	local chest = display.newImageRect(mainGroup, "images/chest.png", 150, 50)
	chest.x = display.contentCenterX * 1.4
	chest.y = display.actualContentHeight - 200
	physics.addBody( chest, { density=1.0, friction=2, bounce=0 } )
	
	chest:addEventListener( "touch", dragBox )
	table.insert(chests, chest)
end

local function refreshHighestChest()
	for i = 1, #chests do
		local currentChest = chests[i]

		if currentChest.y < highestChest.y then
			highestChest = currentChest
		end
	end
end

local function checkIfStable( obj )
	if obj ~= nil then
		if obj:getLinearVelocity() < 10 and obj:getLinearVelocity() > -10 then
			return true
		end
	end
	return false
end

local function checkHeight(obj)
	if obj.y <= 150 then
		return true
	end
end

local function endGame()
	composer.setVariable( "finalScore", score )
	composer.gotoScene( "highscores", { time=800, effect="crossFade" } )
end

local function updateText(obj)
	scoreText.text = "Chests: " .. #chests .. "   Score: " .. score
end

local function checkEndgame()
	if checkIfStable(highestChest) and checkHeight(highestChest) and not highestChest.isFocus then
		endGame()
	end	
	checking = false
end

local function checkGameOver()
	if score <= 0 then
		composer.setVariable( "finalScore", 0 )
		composer.gotoScene( "highscores", { time=800, effect="crossFade" } )
	end
end

local function gameLoop()

	if chests[1] == null then
		spawnChest()
		score = score - 10
		highestChest = chests[1]
	end
	lastChest = chests[#chests]

	updateText(highestChest)

	if lastChest.x <= display.contentCenterX * 1.2 or lastChest.x >= display.contentCenterX * 1.6 then
		spawnChest()
		score = score - 10
	end

	refreshHighestChest()
	score = score - 1
	checkGameOver()
	
	if checkHeight(highestChest) and not highestChest.isFocus and not checking then
		checking = true
		timer.performWithDelay(3000,checkEndgame);
	end	
	
end


--Composer Events

function scene:create( event )

	local sceneGroup = self.view

	physics.pause()  


	backGroup = display.newGroup() 
	sceneGroup:insert( backGroup ) 

	mainGroup = display.newGroup() 
	sceneGroup:insert( mainGroup )  

	uiGroup = display.newGroup()  
	sceneGroup:insert( uiGroup )  
	

	local background = display.newImageRect( backGroup, "images/sky.png", 1920, 1080 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY


	scoreText = display.newText( uiGroup, "Chests: " .. #chests .. "   Score: " .. score , 400, 80, native.systemFont, 36 )

	for i = 1,30 do
		local floor = display.newImageRect( mainGroup, "images/grass.png", 50, 50)
		floor.x = i * 50 - 100
		floor.y = display.actualContentHeight -25
		physics.addBody( floor, "static", { density=1, friction=0.1, bounce=0 } )
	end 

	local finish = display.newImageRect( mainGroup, "images/finish.png", 1000,  100)
	finish.y = 100
	finish.x = display.contentCenterX
	

	musicTrack = audio.loadStream( "audio/faded.wav" )
end

function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then
		physics.start()
		gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )
		audio.play( musicTrack, { channel=1, loops=-1 } )
	end
end

function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		timer.cancel( gameLoopTimer )

	elseif ( phase == "did" ) then
		
		physics.pause()
		audio.stop( 1 )
		composer.removeScene( "game" )
	end
end

function scene:destroy( event )
	local sceneGroup = self.view
	audio.dispose( musicTrack )
end


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
