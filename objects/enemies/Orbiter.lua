Orbiter = GameObject:extend()

function Orbiter:new(area, x, y, opts)
  Orbiter.super.new(self, area, x, y, opts)

  local direction = table.random({-1, 1})
  self.x = gw / 2 + direction * (gw / 2 + 48)
  self.y = random(16, gh - 16)
  self.w, self.h = 12, 12
  self.collider = self.area.world:newPolygonCollider(createIrregularPolygon(self.w))
  self.collider:setPosition(self.x, self.y)
  self.collider:setObject(self)
  self.collider:setCollisionClass('Enemy')
  self.collider:setFixedRotation(false)
  self.v = -direction * random(20, 40)
  self.collider:setLinearVelocity(self.v, 0)
  self.collider:applyAngularImpulse(random(-100, 100))
  self.hp = 450

  self.projectiles = {}
  for i = 1, love.math.random(4, 8) do
    table.insert(self.projectiles, self.area:addGameObject('EnemyProjectile',
      self.x - direction * 40, self.y, {orbiter = self, shield = true, r = random(0, 2 * math.pi)}
    ))
  end
end

function Orbiter:update(dt)
  Orbiter.super.update(self, dt)
  self.collider:setLinearVelocity(self.v, 0)
end

function Orbiter:draw()
  if self.hit_flash then love.graphics.setColor(default_color)
  else love.graphics.setColor(hp_color) end
  local points = {self.collider:getWorldPoints(self.collider.shapes.main:getPoints())}
  love.graphics.polygon('line', points)
  love.graphics.setColor(default_color)
end

function Orbiter:hit(damage)
  local damage = damage or 100
  self.hp = self.hp - damage
  if self.hp <= 0 then
    self:die()
  else
    self.hit_flash = true
    self.timer:after('hit_flash', 0.2, function() self.hit_flash = false end)
  end
end

function Orbiter:die()
  self.dead = true
  self.area:addGameObject('EnemyDeathEffect', self.x, self.y,
    {color = hp_color, w = 2.5 * self.w, h = 2.5 * self.h})
end

function Orbiter:destroy()
  Orbiter.super.destroy(self)
end