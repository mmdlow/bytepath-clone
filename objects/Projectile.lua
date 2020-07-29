Projectile = GameObject:extend()

function Projectile:new(area, x, y, opts)
  Projectile.super.new(self, area, x, y, opts)

  self.s = opts.s or 2.5 -- collider radius
  self.v = opts.v or 200 -- collider velocity

  self.collider = self.area.world:newCircleCollider(self.x, self.y, self.s)
  self.collider:setObject(self)
end

function Projectile:update(dt)
  Projectile.super.update(self, dt)
  self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
end

function Projectile:draw()
  love.graphics.setColor(default_color)
  love.graphics.circle('line', self.x, self.y, self.s)
end

function Projectile:destroy()
  Projectile.super.destroy(self)
end