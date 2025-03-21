-- Below is a small example program where you can move a circle
-- around with the crank. You can delete everything in this file,
-- but make sure to add back in a playdate.update function since
-- one is required for every Playdate game!
-- =============================================================

-- Importing libraries used for drawCircleAtPoint and crankIndicator
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/ui"

import "libraries/RoomyPlaydate"
import "libraries/AnimatedSprite"
import "libraries/PDOptions"

import "scripts/constants"
import "scripts/utils"
import "scripts/level"
import "scripts/introScene"

-- Localizing commonly used globals
local pd <const> = playdate
local gfx <const> = playdate.graphics

SceneManager = Manager()

function pd.update()
    pd.timer.updateTimers()
    gfx.sprite.update()
    SceneManager:emit("update")
end

local function loadGame()
    -- Set font
    gfx.setFont(gfx.font.new('font/topaz_11'))
    math.randomseed(playdate.getSecondsSinceEpoch())

    SceneManager:enter(IntroScene, "Welcome to the game!")
    SceneManager:hook({})
end

loadGame()
