import "./gameScene"
import "./gameManager"
-- shorthand variables
local pd <const> = playdate
local gfx <const> = pd.graphics

class('GameScene').extends(Room)

function GameScene:enter()
    -- GameManager is already initialized as a singleton
    GameManager:newGame()
end

function GameScene:update()
    -- Handle player movement based on d-pad input
    if pd.buttonJustPressed(pd.kButtonUp) then
        GameManager.level:movePlayer("UP")
    elseif pd.buttonJustPressed(pd.kButtonDown) then
        GameManager.level:movePlayer("DOWN")
    elseif pd.buttonJustPressed(pd.kButtonLeft) then
        GameManager.level:movePlayer("LEFT")
    elseif pd.buttonJustPressed(pd.kButtonRight) then
        GameManager.level:movePlayer("RIGHT")
    end
    -- Track time since last tick
    if not self.lastTickTime then
        self.lastTickTime = pd.getCurrentTimeMilliseconds()
    end

    local currentTime = pd.getCurrentTimeMilliseconds()
    if currentTime - self.lastTickTime >= 1000 then
        GameManager:tick()
        self.lastTickTime = currentTime
    end
end
