
local composer = require( "composer" )

local scene = composer.newScene()

local musicTrack


local function gotoGame()
	composer.gotoScene( "game", { time=800, effect="crossFade" } )
end

local function gotoHighScores()
	composer.gotoScene( "highscores", { time=800, effect="crossFade" } )
end


--Composer Events

function scene:create( event )

	local sceneGroup = self.view

	local background = display.newImageRect( sceneGroup, "images/menuImg.png", 1200, 1024 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	local title = display.newImageRect( sceneGroup, "images/DHWBlocks.png", 400, 70 )
	title.x = display.contentCenterX
	title.y = 200

	local playButton = display.newText( sceneGroup, "Play", display.contentCenterX, 700, native.systemFont, 44 )
	playButton:setFillColor( 0.5, 0.5, 0.5 )

	local highScoresButton = display.newText( sceneGroup, "High Scores", display.contentCenterX, 810, native.systemFont, 44 )
	highScoresButton:setFillColor( 0.5, 0.5, 0.5 )

	playButton:addEventListener( "tap", gotoGame )
	highScoresButton:addEventListener( "tap", gotoHighScores )

	musicTrack = audio.loadStream( "audio/faded.wav" )
end

function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "did" ) then
		audio.play( musicTrack, { channel=1, loops=-1 } )
	end
end

function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "did" ) then
		audio.stop( 1 )
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
