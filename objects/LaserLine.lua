LaserLine = GameObject:extend()

function LaserLine:new(area, x, y, opts)
  LaserLine.super.new(self, area, x, y, opts)

  self.main_width = opts.mw or 8
  self.side_width = self.main_width / 4
  self.side_offset = 6
  self.color = opts.color or default_color
  self.side_color = opts.side_color or hp_color
  self.length = math.sqrt(gw * gw + gh * gh)
  self.d = opts.d or 14.4
  self.duration = opts.duration or 0.2
  self.damage = 500

  camera:shake(3, 60, 0.25)
  self.timer:tween(3 * self.duration / 2, self, {main_width = 0}, 'in-out-cubic', function() self.dead = true end)
  self.timer:after(self.duration / 2, function()
    self.timer:tween(self.duration / 2, self, {side_width = 0}, 'in-out-cubic')
  end)
end

function LaserLine:update(dt)

  LaserLine.super.update(self, dt)
  
  local nearby_enemies = self.area:queryPolygonArea({
    self.x + self.side_offset * math.cos(self.player.r - math.pi / 2),
    self.y + self.side_offset * math.sin(self.player.r - math.pi / 2),
    self.x + self.length * math.cos(self.player.r) - self.side_offset * math.cos(self.player.r + math.pi / 2),
    self.y + self.length * math.sin(self.player.r) - self.side_offset * math.sin(self.player.r + math.pi / 2),
    self.x + self.length * math.cos(self.player.r) + self.side_offset * math.cos(self.player.r + math.pi / 2),
    self.y + self.length * math.sin(self.player.r) + self.side_offset * math.sin(self.player.r + math.pi / 2),
    self.x + self.side_offset * math.cos(self.player.r + math.pi / 2),
    self.y + self.side_offset * math.sin(self.player.r + math.pi / 2)
  }, enemies)
  
  for _, object in ipairs(nearby_enemies) do
    object:hit(self.damage)
    if object.dead and self.player then self.player:onKill(object) end
  end
  
  if self.player then
    self.x = self.player.x + 1.5 * self.d * math.cos(self.player.r)
    self.y = self.player.y + 1.5 * self.d * math.sin(self.player.r)
  end
end

function LaserLine:draw()
  love.graphics.setLineWidth(self.side_width)
  love.graphics.setColor(self.side_color)
  love.graphics.line(self.x + self.side_offset * math.cos(self.player.r - math.pi / 2),
    self.y + self.side_offset * math.sin(self.player.r - math.pi / 2),
    self.x + self.length * math.cos(self.player.r) - self.side_offset * math.cos(self.player.r + math.pi / 2),
    self.y + self.length * math.sin(self.player.r) - self.side_offset * math.sin(self.player.r + math.pi / 2))

  love.graphics.line(self.x + self.side_offset * math.cos(self.player.r + math.pi / 2),
  self.y + self.side_offset * math.sin(self.player.r + math.pi / 2),
  self.x + self.length * math.cos(self.player.r) + self.side_offset * math.cos(self.player.r + math.pi / 2),
  self.y + self.length * math.sin(self.player.r) + self.side_offset * math.sin(self.player.r + math.pi / 2))

  love.graphics.setLineWidth(self.main_width)
  love.graphics.setColor(self.color)
  love.graphics.line(self.x, self.y,
    self.x + self.length * math.cos(self.player.r), self.y + self.length * math.sin(self.player.r))
  love.graphics.setLineWidth(1)
end

function LaserLine:destroy()
  LaserLine.super.destroy(self)
end
