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
            playerPlaced = true
            print("Player placed at:", randX, randY)
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

    sprite:setCenter(0, 0)
    sprite:moveTo(self.x + (x - 1) * 16, self.y + (y - 1) * 16)
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
    print("Updating sprites")
    for y = 1, self.height do
        for x = 1, self.width do
            local sprite = self.sprites[y][x]
            if sprite then
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
                sprite:moveTo(self.x + (x - 1) * 16, self.y + (y - 1) * 16)
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
    for y = 1, self.height do
        for x = 1, self.width do
            if self:isPositionType(x, y, Level.POSITION_TYPES.PLAYER) then
                return x, y
            end
        end
    end
    return nil
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
        self:setPositionType(playerX, playerY, Level.POSITION_TYPES.BLANK)
        self:setPositionType(newX, newY, Level.POSITION_TYPES.PLAYER)
        return true
    end

    return false
end

function Level:moveEnemies()
    local enemyPositions = {}
    for y = 1, self.height do
        for x = 1, self.width do
            if self:isPositionType(x, y, Level.POSITION_TYPES.ENEMY) then
                table.insert(enemyPositions, { x = x, y = y })
            end
        end
    end

    if #enemyPositions == 0 then
        GameManager:allEnemiesDead()
        return
    end

    local playerX, playerY = self:getPlayerPosition()

    for _, enemyPos in ipairs(enemyPositions) do
        local x, y = enemyPos.x, enemyPos.y
        -- Calculate Manhattan distance to player
        local distance = math.abs(x - playerX) + math.abs(y - playerY)

        if distance <= 6 then
            -- Check all adjacent tiles
            local bestMove = nil
            local bestDistance = 100 * distance

            for direction, offset in pairs(Level.DIRECTIONS) do
                local newX = x + offset.x
                local newY = y + offset.y

                -- Check if position is valid and blank
                if newX >= 1 and newX <= self.width and
                    newY >= 1 and newY <= self.height and
                    self:isBlank(newX, newY) or self:isPositionType(newX, newY, Level.POSITION_TYPES.PLAYER) then
                    -- Calculate new distance to player
                    local newDistance = math.abs(newX - playerX) + math.abs(newY - playerY)

                    -- Move if this gets us closer to the player
                    if newDistance < bestDistance then
                        bestMove = { x = newX, y = newY }
                        bestDistance = newDistance
                    end
                end
            end

            -- Make the move if we found a better position
            if bestMove then
                -- Check if we would reach the player
                if math.abs(bestMove.x - playerX) + math.abs(bestMove.y - playerY) == 0 then
                    GameManager:playerDied()
                end

                self:setPositionType(x, y, Level.POSITION_TYPES.BLANK)
                self:setPositionType(bestMove.x, bestMove.y, Level.POSITION_TYPES.ENEMY)
            end
        else
            -- Move to a random adjacent blank tile
            local validMoves = {}
            for direction, offset in pairs(Level.DIRECTIONS) do
                local newX = x + offset.x
                local newY = y + offset.y

                if newX >= 1 and newX <= self.width and
                    newY >= 1 and newY <= self.height and
                    self:isBlank(newX, newY) then
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

        -- If we found a blank tile, that's our target
        if self:isBlank(currentX, currentY) or
            (self:isPositionType(currentX, currentY, Level.POSITION_TYPES.ENEMY) and
                (currentX + dir.x < 1 or currentX + dir.x > self.width or
                    currentY + dir.y < 1 or currentY + dir.y > self.height or
                    self:isPositionType(currentX + dir.x, currentY + dir.y, Level.POSITION_TYPES.WALL) or
                    self:isPositionType(currentX + dir.x, currentY + dir.y, Level.POSITION_TYPES.BLOCK))) then
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
