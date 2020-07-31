Projectile = GameObject:extend()

function Projectile:new(area, x, y, opts)
  Projectile.super.new(self, area, x, y, opts)

  self.s = opts.s or 2.5 -- collider radius
  self.v = opts.v or 200 -- collider velocity

  self.collider = self.area.world:newCircleCollider(self.x, self.y, self.s)
  self.collider:setObject(self)
  self.collider:setCollisionClass('Projectile')

  self.color = attacks[self.attack].color
end

function Projectile:update(dt)
  Projectile.super.update(self, dt)
  self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))

  if self.x < 0 or self.y < 0 or self.x > gw or self.y > gh then self:die() end
end

function Projectile:draw()
  pushRotate(self.x, self.y, Vector(self.collider:getLinearVelocity()):angleTo())
  love.graphics.setLineWidth(self.s, self.x / 4)
  love.graphics.setColor(self.color)
  love.graphics.line(self.x - 2 * self.s, self.y, self.x, self.y) -- 1st half of line
  love.graphics.setColor(default_color)
  love.graphics.line(self.x, self.y, self.x + 2 * self.s, self.y)
  love.graphics.setLineWidth(1)
  love.graphics.pop()
end

function Projectile:die()
  self.dead = true
  self.area:addGameObject('ProjectileDeathEffect', self.x, self.y,
  {color = hp_color, w = 3 * self.s})
end

function Projectile:destroy()
  Projectile.super.destroy(self)
end