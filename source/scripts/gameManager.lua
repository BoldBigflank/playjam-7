class('GameManager').extends()
local pd <const> = playdate
local gfx <const> = pd.graphics

function GameManager:init()
    if not self.initialized then
        self.initialized = true
        self:reset()
    end
end

function GameManager:reset()
    -- Clean up existing sprites
    gfx.sprite.removeAll()
    self.level = nil
end

function GameManager:newGame()
    self:reset()

    self.health = 100
    self.lives = 3
    self.levelIndex = 1
    self.level = Level(20, 12, 40, 5)
end

function GameManager:playerDied()
    -- Find a random blank tile to respawn the player
    self.lives = self.lives - 1
    if self.lives == 0 then
        self:reset()
        SceneManager:enter(IntroScene, "You Lose!")
        return
    end
    local playerPlaced = false
    while not playerPlaced do
        local x, y = self.level:getRandomPosition()
        if self.level:isBlank(x, y) then
            -- Get current player position
            local playerX, playerY = self.level:getPlayerPosition()
            -- Clear old player position
            self.level:setPositionType(playerX, playerY, Level.POSITION_TYPES.BLANK)
            -- Place player at new position
            self.level:setPositionType(x, y, Level.POSITION_TYPES.PLAYER)
            playerPlaced = true
        end
    end
end

function GameManager:allEnemiesDead()
    self:reset()
    SceneManager:enter(IntroScene, "You Win!")
end

function GameManager:tick()
    self.level:moveEnemies()
end

GameManager = GameManager()
