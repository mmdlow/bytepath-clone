RhombusCollectable = GameObject:extend()

function RhombusCollectable:new(area, x, y, opts)
  RhombusCollectable.super.new(self, area, x, y, opts)

  local direction = table.random({-1, 1})
  self.x = gw / 2 + direction * (gw / 2 + 48)
  self.y = random(48, gh - 48)

  self.w, self.h = 12, 12
  self.collider = self.area.world:newRectangleCollider(self.x, self.y, self.w, self.h)
  self.collider:setObject(self)
  self.collider:setCollisionClass('Collectable')
  self.collider:setFixedRotation(false)
  self.v = -direction * random(20, 40)
  self.collider:setLinearVelocity(self.v, 0)
  self.collider:applyAngularImpulse(random(-24, 24))
end

function RhombusCollectable:update(dt)
  RhombusCollectable.super.update(self, dt)

  self.collider:setLinearVelocity(self.v, 0)
end

function RhombusCollectable:draw()
  if not self.main_color then self.main_color = default_color end
  love.graphics.setColor(self.main_color)
  pushRotate(self.x, self.y, self.collider:getAngle())
  draft:rhombus(self.x, self.y, 1.5 * self.w, 1.5 * self.h, 'line')
  draft:rhombus(self.x, self.y, 0.5 * self.w, 0.5 * self.h, 'fill')
  love.graphics.pop()
  love.graphics.setColor(default_color)
end

function RhombusCollectable:die()
  self.dead = true
  self.area:addGameObject('RhombusCollectableEffect', self.x, self.y,
    {color = self.main_color, w = self.w, h = self.h, r = self.collider:getAngle()})
  if self.die_text then
    self.area:addGameObject('InfoText', self.x, self.y,
    {text = self.die_text, color = self.main_color})
  end
end

function RhombusCollectable:destroy()
  RhombusCollectable.super.destroy(self)
end