LaserShootEffect = GameObject:extend()

function LaserShootEffect:new(area, x, y, opts)
  LaserShootEffect.super.new(self, area, x, y, opts)
  
  self.w = opts.w or 8
  self.d = opts.d or 14.4
  self.depth = 75
  self.duration = opts.duration or 0.1
  self.color = opts.color or hp_color
  self.current_color = default_color
  self.alpha = 255
  self.timer:after(self.duration / 3, function()
    self.current_color = self.color
    self.timer:tween(2 * self.duration / 3, self, {alpha = 0}, 'in-out-cubic', function()
      self.dead = true
    end)
  end)
end

function LaserShootEffect:update(dt)
  LaserShootEffect.super.update(self, dt)
  if self.player then
    self.x = self.player.x + 1.5 * self.d * math.cos(self.player.r)
    self.y = self.player.y + 1.5 * self.d * math.sin(self.player.r)
  end
end

function LaserShootEffect:draw()
  pushRotate(self.x, self.y, self.player.r + math.pi / 4)
  local r, g, b = unpack(self.current_color)
  love.graphics.setColor(r, g, b, self.alpha)
  love.graphics.rectangle('fill', self.x - self.w / 2, self.y - self.w / 2, self.w, self.w)
  love.graphics.pop()
end

function LaserShootEffect:destroy()
  LaserShootEffect.super.destroy(self)
end