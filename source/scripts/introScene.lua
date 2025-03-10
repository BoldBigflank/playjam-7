import "./gameScene"
class('IntroScene').extends(Room)

function IntroScene:enter(prev, text)
    print("IntroScene:enter", text)
    self.text = text
    local titleSprite = Utils:textSprite(self.text)
    titleSprite:setCenter(0, 0)
    titleSprite:moveTo(128, 64)
    titleSprite:add()
end

function IntroScene:AButtonDown()
    self.canAdvance = true
end

function IntroScene:AButtonUp()
    if not self.canAdvance then return end
    SceneManager:enter(GameScene)
end
