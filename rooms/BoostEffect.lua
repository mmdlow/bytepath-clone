BoostEffect = GameObject:extend()

function BoostEffect:new(area, x, y, opts)
  BoostEffect.super.new(self, area, x, y, opts)

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

  -- expand outer rhombus
  self.sx, self.sy = 1, 1
  self.timer:tween(0.35, self, {sx = 2, sy = 2}, 'in-out-cubic')
end

function BoostEffect:update(dt)
  BoostEffect.super.update(self, dt)
end

function BoostEffect:draw()
  if not self.visible then return end

  love.graphics.setColor(self.current_color)
  -- rotate effect at boost's last captured angle pre-death
  pushRotate(self.x, self.y, self.r)
  draft:rhombus(self.x, self.y, 1.34 * self.w, 1.34 * self.h, 'fill')
  draft:rhombus(self.x, self.y, self.sx * 2 * self.w, self.sy * 2 * self.h, 'line')
  love.graphics.pop()
  love.graphics.setColor(default_color)
end

function BoostEffect:destroy()
  BoostEffect.super.destroy(self)
end