HPEffect = GameObject:extend()

function HPEffect:new(area, x, y, opts)
  HPEffect.super.new(self, area, x, y, opts)

  self.depth = 75

  -- center white flash
  self.current_color = default_color
  self.timer:after(0.2, function()
    self.current_color = self.color
    self.timer:after(0.35, function() self.dead = true end)
  end)

  -- blinking effect
  self.visible = true
  self.timer:after(0.2, function()
    self.timer:every(0.05, function() self.visible = not self.visible end)
    self.timer:after(0.35, function() self.visible = true end)
  end)

  -- expand outer circle
  self.sx, self.sy = 1, 1
  self.timer:tween(0.35, self, {sx = 2, sy = 2}, 'in-out-cubic')
end

function HPEffect:update(dt)
  HPEffect.super.update(self, dt)
end

function HPEffect:draw()
  if not self.visible then return end
  love.graphics.setColor(self.current_color)
  if self.cross then
    local points = fn.map(self.cross, function(v, k)
      if k % 2 == 1 then
        return self.x + v * 1.5
      else
        return self.y + v * 1.5
      end
    end)
    draft:polygon(points, 'fill')
  end
  love.graphics.setColor(default_color)
  love.graphics.circle('line', self.x, self.y, self.sx * 1.5 * self.w)
end

function HPEffect:destroy()
  HPEffect.super.destroy(self)
end