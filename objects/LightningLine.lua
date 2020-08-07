LightningLine = GameObject:extend()

function LightningLine:new(area, x, y, opts)
  LightningLine.super.new(self, area, x, y, opts)
  self.lines = {}
  table.insert(self.lines, {x1 = self.x1, y1 = self.y1, x2 = self.x2, y2 = self.y2})
  self.generations = opts.generations or 4
  self.max_offset = opts.max_offset or 8

  self:generate()

  self.duration = opts.duration or 0.15
  self.alpha = 255
  self.timer:tween(self.duration, self, {alpha = 0}, 'in-out-cubic', function() self.dead = true end)
end

function LightningLine:update(dt)
  LightningLine.super.update(self, dt)
end

function LightningLine:generate()
  local lines = self.lines
  local offset = self.max_offset
  for i = 1, self.generations do
    for j = #lines, 1, -1 do
      line = table.remove(lines, j)
      local mid_x, mid_y = (line.x1 + line.x2) / 2, (line.y1 + line.y2) / 2
      local px, py = VectorLight.perpendicular(VectorLight.normalize(line.x2 - line.x1, line.y2 - line.y1))
      mid_x = mid_x + px * random(-offset, offset)
      mid_y = mid_y + py * random(-offset, offset)
      table.insert(lines, {x1 = line.x1, y1 = line.y1, x2 = mid_x, y2 = mid_y})
      table.insert(lines, {x1 = mid_x, y1 = mid_y, x2 = line.x2, y2 = line.y2})
    end
    offset = offset / 2
  end
end

function LightningLine:draw()
  for i, line in ipairs(self.lines) do
    local r, g, b = unpack(boost_color)
    love.graphics.setColor(r, g, b, self.alpha)
    love.graphics.setLineWidth(2.5)
    love.graphics.line(line.x1, line.y1, line.x2, line.y2)

    local r, g, b = unpack(default_color)
    love.graphics.setColor(r, g, b, self.alpha)
    love.graphics.setLineWidth(1.5)
    love.graphics.line(line.x1, line.y1, line.x2, line.y2)
  end

  love.graphics.setLineWidth(1)
  love.graphics.setColor(255, 255, 255, 255)
end

function LightningLine:destroy()
  LightningLine.super.destroy(self)
end