local pd <const> = playdate
local gfx <const> = playdate.graphics

class("Utils").extends()

local tilemap = nil

function Utils:getSpritesheet()
    if not tilemap then
        tilemap = gfx.imagetable.new("images/sprites-table-16-16.png")
    end
    return tilemap
end

function Utils:textImage(text)
    local textString = '' .. text
    local textImage = gfx.image.new(gfx.getTextSize(textString))
    gfx.pushContext(textImage)
    gfx.drawText(textString, 0, 0)
    gfx.popContext()
    return textImage
end

function Utils:textSprite(text)
    local textImage = Utils:textImage(text)
    local textSprite = gfx.sprite.new(textImage)
    textSprite:add()
    return textSprite
end

Utils = Utils()
