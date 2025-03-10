-- shorthand variables
local pd <const> = playdate
local gfx <const> = pd.graphics


class('GameScene').extends(Room)

local text = {
    'You are humanity\'s last hope\nof stopping an alien invasion.\nYou are given two weapons.',
    'The Reflect Gun shoots disks\nthat bounce off walls. Hit\nenemies around corners.',
    'The Float Gun lobs explosive\ncharges over walls. Very\neffective, but be careful',
    'You will always have another\nsoldier to take over, but the\nweapons will not refill.',
    'Press Menu to view your controls.'
}

function GameScene:enter()
    print("GameScene:enter")
    -- local titleSprite = Utils:textSprite(text[2])
    -- titleSprite:setCenter(0, 0)
    -- titleSprite:moveTo(128, 64)
    -- titleSprite:add()

    -- local titleSprite = Utils:textSprite(text[3])
    -- titleSprite:setCenter(0, 0)
    -- titleSprite:moveTo(80, 112)
    -- titleSprite:add()

    -- local titleSprite = Utils:textSprite(text[4])
    -- titleSprite:setCenter(0, 0)
    -- titleSprite:moveTo(128, 160)
    -- titleSprite:add()

    -- local titleSprite = Utils:textSprite(text[5])
    -- titleSprite:setCenter(0.5, 0)
    -- titleSprite:moveTo(200, 208)
    -- titleSprite:add()

    -- local aButtonSprite = AnimatedSprite(Utils:getSpritesheet())
    -- aButtonSprite:addState("idle", 1, 1,
    --     { xScale = 2, yScale = 2, frames = { SPRITES.AButton, SPRITES.Empty }, tickStep = 6 })
    -- aButtonSprite:changeState('idle', true)
    -- aButtonSprite:moveTo(400 - 32, 240 - 32)
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

    -- GameManager:tick()
end

function GameScene:AButtonDown()
    self.canAdvance = true
end

function GameScene:AButtonUp()
    print("GameScene:AButtonUp")
    if not self.canAdvance then return end
    -- SoundPlayer:playSound(SOUNDS.Shoot)
    -- SceneManager:enter(MissionBriefingScene)
end
