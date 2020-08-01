EnemyProjectile = GameObject:extend()

function EnemyProjectile:new(area, x, y, opts)
  EnemyProjectile.super.new(self, area, x, y, opts)

  self.s = opts.s or 2.5 -- collider radius
  self.v = opts.v or 200 -- collider velocity

  self.collider = self.area.world:newCircleCollider(self.x, self.y, self.s)
  self.collider:setObject(self)
  self.collider:setCollisionClass('EnemyProjectile')

  self.color = attacks[self.attack].color
  self.color_switch = true

  self.damage = 10
end

function EnemyProjectile:update(dt)
  if self.collider:enter('Player') then
    local collision_data = self.collider:getEnterCollisionData('Player')
    local object = collision_data.collider:getObject()
    object:hit(self.damage)
    self:die()
  end

  EnemyProjectile.super.update(self, dt)
  self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
  if self.x < 0 or self.y < 0 or self.x > gw or self.y > gh then self:die() end
end

function EnemyProjectile:draw()
  love.graphics.setColor(hp_color)
  pushRotate(self.x, self.y, Vector(self.collider:getLinearVelocity()):angleTo())
  love.graphics.setLineWidth(self.s, self.x / 4)
  love.graphics.line(self.x - 2 * self.s, self.y, self.x + 2 * self.s, self.y)
  love.graphics.setLineWidth(1)
  love.graphics.pop()
  love.graphics.setColor(default_color)
end

function EnemyProjectile:destroy()
  EnemyProjectile.super.destroy(self)
end