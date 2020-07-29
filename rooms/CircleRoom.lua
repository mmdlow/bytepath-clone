CircleRoom = Object:extend()

function CircleRoom:new()
  self.x = 400
  self.y = 300
  self.radius = 100
end

function CircleRoom:update(dt)

end

function CircleRoom:draw()
  love.graphics.circle('fill', self.x, self.y, self.radius)
end