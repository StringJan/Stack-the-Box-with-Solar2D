
local composer = require( "composer" )

display.setStatusBar( display.HiddenStatusBar )

audio.reserveChannels( 1 )
audio.setVolume( 1, { channel=1 } )

composer.gotoScene( "menu" )
