
local composer = require( "composer" )
local scene = composer.newScene()


local json = require( "json" )
local scoresTable = {}
local filePath = system.pathForFile( "scores.json", system.DocumentsDirectory )

local musicTrack


local function loadScores()

	local file = io.open( filePath, "r" )

	if file then
		local contents = file:read( "*a" )
		io.close( file )
		scoresTable = json.decode( contents )
	end

	if ( scoresTable == nil or #scoresTable == 0 ) then
		scoresTable = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	end
end


local function saveScores()

	for i = #scoresTable, 11, -1 do
		table.remove( scoresTable, i )
	end

	local file = io.open( filePath, "w" )

	if file then
		file:write( json.encode( scoresTable ) )
		io.close( file )
	end
end

local function gotoMenu()
	composer.gotoScene( "menu", { time=800, effect="crossFade" } )
end


--Composer Events

function scene:create( event )

	local sceneGroup = self.view
	loadScores()

	table.insert( scoresTable, composer.getVariable( "finalScore" ) )
	composer.setVariable( "finalScore", 0 )

	local function compare( a, b )
		return a > b
	end
	table.sort( scoresTable, compare )

	saveScores()

	local background = display.newImageRect( sceneGroup, "images/sunset.png", 568, 1024 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	local highScoresHeader = display.newText( sceneGroup, "High Scores", display.contentCenterX, 100, native.systemFont, 44 )

	for i = 1, 10 do
		if ( scoresTable[i] ) then
			local yPos = 150 + ( i * 56 )

			local rankNum = display.newText( sceneGroup, i .. ")", display.contentCenterX-50, yPos, native.systemFont, 36 )
			rankNum:setFillColor( 1, 1, 1 )
			rankNum.anchorX = 1

			local thisScore = display.newText( sceneGroup, scoresTable[i], display.contentCenterX-30, yPos, native.systemFont, 36 )
			thisScore.anchorX = 0
			thisScore:setFillColor( 1, 1, 1 )
		end
	end

	local menuButton = display.newText( sceneGroup, "Menu", display.contentCenterX, 810, native.systemFont, 44 )
	menuButton:setFillColor( 1, 1, 1 )
	menuButton:addEventListener( "tap", gotoMenu )

	musicTrack = audio.loadStream( "audio/faded.wav" )
end



function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then


	elseif ( phase == "did" ) then

		audio.play( musicTrack, { channel=1, loops=-1 } )
	end
end



function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then


	elseif ( phase == "did" ) then

		audio.stop( 1 )
		composer.removeScene( "highscores" )
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
