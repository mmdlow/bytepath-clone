RectRoom = Object:extend()

function RectRoom:new()
  self.x = 400
  self.y = 300
  self.w = 300
  self.h = 100
end

function RectRoom:update(dt)

end

function RectRoom:draw()
  love.graphics.rectangle('fill', self.x - self.w/2, self.y - self.h/2, self.w, self.h)
end