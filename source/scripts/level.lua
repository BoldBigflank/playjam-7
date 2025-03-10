class('Level').extends()

-- Position types
Level.POSITION_TYPES = {
    BLANK = 0,
    WALL = 1,
    BLOCK = 2,
    PLAYER = 3,
    ENEMY = 4
}

-- Direction constants
Level.DIRECTIONS = {
    UP = { x = 0, y = -1 },
    DOWN = { x = 0, y = 1 },
    LEFT = { x = -1, y = 0 },
    RIGHT = { x = 1, y = 0 },
    UP_LEFT = { x = -1, y = -1 },
    UP_RIGHT = { x = 1, y = -1 },
    DOWN_LEFT = { x = -1, y = 1 },
    DOWN_RIGHT = { x = 1, y = 1 }
}

-- Sprite indices for each position type
Level.SPRITE_INDICES = {
    [Level.POSITION_TYPES.BLANK] = SPRITES.Empty,
    [Level.POSITION_TYPES.WALL] = SPRITES.DestructibleWall,
    [Level.POSITION_TYPES.BLOCK] = SPRITES.Barrel,
    [Level.POSITION_TYPES.PLAYER] = SPRITES.Player,
    [Level.POSITION_TYPES.ENEMY] = SPRITES.Bug
}

function Level:init(width, height, wallPercent, blockPercent)
    self.x = 16
    self.y = 16
    self.width = width or 10   -- Default width if not specified
    self.height = height or 10 -- Default height if not specified
    self.grid = {}
    self.sprites = {}
    self.spritesheet = Utils:getSpritesheet()
    self.playerX = nil
    self.playerY = nil

    -- Ensure percentages are valid
    wallPercent = wallPercent or 0
    blockPercent = blockPercent or 0
    wallPercent = math.max(0, math.min(100, wallPercent))
    blockPercent = math.max(0, math.min(100, blockPercent))

    -- Convert percentages to decimals
    local wallChance = wallPercent / 100
    local blockChance = blockPercent / 100

    -- Initialize the grid with random positions based on percentages
    for y = 1, self.height do
        self.grid[y] = {}
        self.sprites[y] = {}
        for x = 1, self.width do
            local rand = math.random()
            if rand < wallChance then
                self.grid[y][x] = Level.POSITION_TYPES.WALL
            elseif rand < (wallChance + blockChance) then
                self.grid[y][x] = Level.POSITION_TYPES.BLOCK
            else
                self.grid[y][x] = Level.POSITION_TYPES.BLANK
            end

            -- Create sprite for this position
            self:createSprite(x, y)
        end
    end
    -- Place three enemies randomly on the grid
    local enemiesPlaced = 0
    while enemiesPlaced < 3 do
        local randX = math.random(1, self.width)
        local randY = math.random(1, self.height)

        -- Only place enemy on blank spaces
        if self.grid[randY][randX] == Level.POSITION_TYPES.BLANK then
            self.grid[randY][randX] = Level.POSITION_TYPES.ENEMY
            enemiesPlaced = enemiesPlaced + 1
        end
    end
    -- Place player on a random blank tile
    local playerPlaced = false
    while not playerPlaced do
        local randX = math.random(1, self.width)
        local randY = math.random(1, self.height)

        -- Only place player on blank spaces
        if self.grid[randY][randX] == Level.POSITION_TYPES.BLANK then
            self.grid[randY][randX] = Level.POSITION_TYPES.PLAYER
            self.playerX = randX
            self.playerY = randY
            playerPlaced = true
        end
    end
    self:updateSprites()
end

function Level:createSprite(x, y)
    local sprite = AnimatedSprite(self.spritesheet)

    -- Add states for each position type
    sprite:addState("blank", Level.SPRITE_INDICES[Level.POSITION_TYPES.BLANK],
        Level.SPRITE_INDICES[Level.POSITION_TYPES.BLANK], { tickStep = 1 })
    sprite:addState("wall", Level.SPRITE_INDICES[Level.POSITION_TYPES.WALL],
        Level.SPRITE_INDICES[Level.POSITION_TYPES.WALL], { tickStep = 1 })
    sprite:addState("block", Level.SPRITE_INDICES[Level.POSITION_TYPES.BLOCK],
        Level.SPRITE_INDICES[Level.POSITION_TYPES.BLOCK], { tickStep = 1 })
    sprite:addState("player", Level.SPRITE_INDICES[Level.POSITION_TYPES.PLAYER],
        Level.SPRITE_INDICES[Level.POSITION_TYPES.PLAYER], { tickStep = 1 })
    sprite:addState("enemy", Level.SPRITE_INDICES[Level.POSITION_TYPES.ENEMY],
        Level.SPRITE_INDICES[Level.POSITION_TYPES.ENEMY] + 1, { tickStep = 5 })

    sprite:setCenter(0.5, 0.5)
    sprite:moveTo(self.x + (x - 1) * 16 + 8, self.y + (y - 1) * 16 + 8)
    sprite:add()

    -- Change to the appropriate state based on grid type
    local stateName = "blank"
    if self.grid[y][x] == Level.POSITION_TYPES.WALL then
        stateName = "wall"
    elseif self.grid[y][x] == Level.POSITION_TYPES.BLOCK then
        stateName = "block"
    elseif self.grid[y][x] == Level.POSITION_TYPES.PLAYER then
        stateName = "player"
    elseif self.grid[y][x] == Level.POSITION_TYPES.ENEMY then
        stateName = "enemy"
    end
    sprite:changeState(stateName, true)

    self.sprites[y][x] = sprite
end

function Level:updateSprites()
    for y = 1, self.height do
        for x = 1, self.width do
            local sprite = self.sprites[y][x]
            if sprite then
                -- Only update state if it's different from current
                local currentState = sprite:getCurrentState()
                local newState = "blank"
                if self.grid[y][x] == Level.POSITION_TYPES.WALL then
                    newState = "wall"
                elseif self.grid[y][x] == Level.POSITION_TYPES.BLOCK then
                    newState = "block"
                elseif self.grid[y][x] == Level.POSITION_TYPES.PLAYER then
                    newState = "player"
                elseif self.grid[y][x] == Level.POSITION_TYPES.ENEMY then
                    newState = "enemy"
                end

                if currentState ~= newState then
                    sprite:changeState(newState, true)
                end

                -- Only update position if it's different from current
                local currentX, currentY = sprite:getPosition()
                local targetX = self.x + (x - 1) * 16 + 8
                local targetY = self.y + (y - 1) * 16 + 8

                if currentX ~= targetX or currentY ~= targetY then
                    sprite:moveTo(targetX, targetY)
                end
            end
        end
    end
end

function Level:getRandomPosition()
    local x = math.random(1, self.width)
    local y = math.random(1, self.height)
    return x, y
end

-- Get the type at a specific position
function Level:getPositionType(x, y)
    if x < 1 or x > self.width or y < 1 or y > self.height then
        return nil
    end
    return self.grid[y][x]
end

-- Set the type at a specific position
function Level:setPositionType(x, y, type)
    if x < 1 or x > self.width or y < 1 or y > self.height then
        return false
    end
    self.grid[y][x] = type
    -- Update the sprite
    if self.sprites[y][x] then
        local stateName = "blank"
        if type == Level.POSITION_TYPES.WALL then
            stateName = "wall"
        elseif type == Level.POSITION_TYPES.BLOCK then
            stateName = "block"
        elseif type == Level.POSITION_TYPES.PLAYER then
            stateName = "player"
            self.playerX = x
            self.playerY = y
        elseif type == Level.POSITION_TYPES.ENEMY then
            stateName = "enemy"
        end
        self.sprites[y][x]:changeState(stateName, true)
    end
    return true
end

-- Check if a position is valid and of a specific type
function Level:isPositionType(x, y, type)
    local posType = self:getPositionType(x, y)
    return posType == type
end

-- Get the dimensions of the level
function Level:getDimensions()
    return self.width, self.height
end

-- Clear the entire level (set all positions to blank)
function Level:clear()
    -- Remove all sprites
    for y = 1, self.height do
        for x = 1, self.width do
            if self.sprites[y][x] then
                self.sprites[y][x]:remove()
                self.sprites[y][x] = nil
            end
        end
    end

    -- Clear the grid
    for y = 1, self.height do
        for x = 1, self.width do
            self.grid[y][x] = Level.POSITION_TYPES.BLANK
        end
    end

    -- Recreate sprites
    for y = 1, self.height do
        for x = 1, self.width do
            self:createSprite(x, y)
        end
    end
end

-- Check if a position is valid and blank
function Level:isBlank(x, y)
    return self:isPositionType(x, y, Level.POSITION_TYPES.BLANK)
end

function Level:getPlayerPosition()
    return self.playerX, self.playerY
end

function Level:movePlayer(direction)
    if not direction or not Level.DIRECTIONS[direction] then
        return false
    end

    local dir = Level.DIRECTIONS[direction]
    local playerX, playerY = self:getPlayerPosition()
    local newX = playerX + dir.x
    local newY = playerY + dir.y

    if self:isPositionType(newX, newY, Level.POSITION_TYPES.WALL) then
        self:moveWalls(direction)
    end

    if self:isBlank(newX, newY) then
        -- Reset rotation of the tile the player is leaving
        local oldSprite = self.sprites[playerY][playerX]
        if oldSprite then
            oldSprite:setRotation(0)
        end

        -- Update player position
        self:setPositionType(playerX, playerY, Level.POSITION_TYPES.BLANK)
        self:setPositionType(newX, newY, Level.POSITION_TYPES.PLAYER)

        -- Update player sprite rotation based on direction
        local playerSprite = self.sprites[newY][newX]
        if playerSprite then
            local rotation = 0
            if direction == "UP" then
                rotation = 0
            elseif direction == "RIGHT" then
                rotation = 90
            elseif direction == "DOWN" then
                rotation = 180
            elseif direction == "LEFT" then
                rotation = 270
            end
            playerSprite:setRotation(rotation)
        end

        return true
    end

    return false
end

function Level:moveEnemies()
    local enemyPositions = {}
    local playerX, playerY = self:getPlayerPosition()
    local enemyCount = 0

    -- Collect enemy positions and count them
    for y = 1, self.height do
        for x = 1, self.width do
            if self:isPositionType(x, y, Level.POSITION_TYPES.ENEMY) then
                enemyCount = enemyCount + 1
                table.insert(enemyPositions, { x = x, y = y })
            end
        end
    end

    if enemyCount == 0 then
        GameManager:allEnemiesDead()
        return
    end

    -- Helper function to calculate Manhattan distance
    local function getDistance(x1, y1, x2, y2)
        return math.abs(x1 - x2) + math.abs(y1 - y2)
    end

    -- Helper function to check if a position is valid and movable
    local function isValidMove(x, y)
        return x >= 1 and x <= self.width and
            y >= 1 and y <= self.height and
            (self:isBlank(x, y) or self:isPositionType(x, y, Level.POSITION_TYPES.PLAYER))
    end

    for _, enemyPos in ipairs(enemyPositions) do
        local x, y = enemyPos.x, enemyPos.y
        local distance = getDistance(x, y, playerX, playerY)

        if distance <= 6 then
            -- Chase player
            local bestMove = nil
            local bestDistance = 100 * distance

            for direction, offset in pairs(Level.DIRECTIONS) do
                local newX = x + offset.x
                local newY = y + offset.y

                if isValidMove(newX, newY) then
                    local newDistance = getDistance(newX, newY, playerX, playerY)
                    if newDistance < bestDistance then
                        bestMove = { x = newX, y = newY }
                        bestDistance = newDistance
                    end
                end
            end

            if bestMove then
                if getDistance(bestMove.x, bestMove.y, playerX, playerY) == 0 then
                    GameManager:playerDied()
                end
                self:setPositionType(x, y, Level.POSITION_TYPES.BLANK)
                self:setPositionType(bestMove.x, bestMove.y, Level.POSITION_TYPES.ENEMY)
            end
        else
            -- Random movement
            local validMoves = {}
            for direction, offset in pairs(Level.DIRECTIONS) do
                local newX = x + offset.x
                local newY = y + offset.y
                if isValidMove(newX, newY) then
                    table.insert(validMoves, { x = newX, y = newY })
                end
            end

            if #validMoves > 0 then
                local move = validMoves[math.random(#validMoves)]
                self:setPositionType(x, y, Level.POSITION_TYPES.BLANK)
                self:setPositionType(move.x, move.y, Level.POSITION_TYPES.ENEMY)
            end
        end
    end
end

-- Move walls in a specified direction from start position until first blank
function Level:moveWalls(direction)
    if not direction or not Level.DIRECTIONS[direction] then
        return false
    end

    local dir = Level.DIRECTIONS[direction]
    local moved = false

    -- Find the first blank tile in the direction
    local currentX, currentY = self:getPlayerPosition()
    local firstBlankX, firstBlankY = nil, nil

    while true do
        currentX = currentX + dir.x
        currentY = currentY + dir.y

        -- Check if we've hit the edge of the level
        if currentX < 1 or currentX > self.width or currentY < 1 or currentY > self.height then
            return false
        end

        -- If we hit a block, we can't move walls through it
        if self:isPositionType(currentX, currentY, Level.POSITION_TYPES.BLOCK) then
            return false
        end

        -- If we hit an enemy, make sure there's a wall or edge of the level one tile after it
        if self:isPositionType(currentX, currentY, Level.POSITION_TYPES.ENEMY) then
            local nextX = currentX + dir.x
            local nextY = currentY + dir.y
            if self:isPositionType(nextX, nextY, Level.POSITION_TYPES.WALL) or
                self:isPositionType(nextX, nextY, Level.POSITION_TYPES.BLOCK) or
                nextX < 1 or nextX > self.width or nextY < 1 or nextY > self.height then
                firstBlankX, firstBlankY = currentX, currentY
                break
            else
                return false
            end
        end

        -- If we hit a blank tile, that's our target
        if self:isBlank(currentX, currentY) then
            firstBlankX, firstBlankY = currentX, currentY
            break
        end
    end

    -- If we didn't find a blank tile, return false
    if not firstBlankX then
        return false
    end

    -- Move walls from the blank tile back towards the start position
    currentX, currentY = firstBlankX, firstBlankY
    local playerX, playerY = self:getPlayerPosition()
    while currentX ~= playerX or currentY ~= playerY do
        local prevX = currentX - dir.x
        local prevY = currentY - dir.y

        -- If previous position is a wall, move it to current position
        if self:isPositionType(prevX, prevY, Level.POSITION_TYPES.WALL) then
            -- Move the wall
            self:setPositionType(currentX, currentY, Level.POSITION_TYPES.WALL)
            self:setPositionType(prevX, prevY, Level.POSITION_TYPES.BLANK)
            moved = true
        end

        currentX = prevX
        currentY = prevY
    end

    return moved
end
