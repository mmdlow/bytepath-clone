AttackEffect = RhombusCollectableEffect:extend()

function AttackEffect:new(area, x, y, opts)
  AttackEffect.super.new(self, area, x, y, opts)
end

function AttackEffect:draw()
  if not self.visible then return end
  love.graphics.setColor(self.current_color)
  draft:rhombus(self.x, self.y, self.sx * 2 * self.w, self.sy * 2 * self.h, 'line')
  love.graphics.setColor(default_color)
end