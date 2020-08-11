BigRock = GameObject:extend()

function BigRock:new(area, x, y, opts)
  BigRock.super.new(self, area, x, y, opts)

  self.direction = table.random({-1, 1})
  self.x = gw / 2 + self.direction * (gw / 2 + 48)
  self.y = random(16, gh - 16)
  self.w, self.h = 16, 16
  self.collider = self.area.world:newPolygonCollider(createIrregularPolygon(self.w))
  self.collider:setPosition(self.x, self.y)
  self.collider:setObject(self)
  self.collider:setCollisionClass('Enemy')
  self.collider:setFixedRotation(false)
  self.v = -self.direction * random(20, 40)
  self.collider:setLinearVelocity(self.v, 0)
  self.collider:applyAngularImpulse(random(-100, 100))
  self.hp = 300
end

function BigRock:update(dt)
  BigRock.super.update(self, dt)
  self.collider:setLinearVelocity(self.v, 0)
end

function BigRock:draw()
  if self.hit_flash then love.graphics.setColor(default_color)
  else love.graphics.setColor(hp_color) end
  local points = {self.collider:getWorldPoints(self.collider.shapes.main:getPoints())}
  love.graphics.polygon('line', points)
  love.graphics.setColor(default_color)
end

function BigRock:hit(damage)
  local damage = damage or 100
  self.hp = self.hp - damage
  if self.hp <= 0 then
    self:die()
  else
    self.hit_flash = true
    self.timer:after('hit_flash', 0.2, function() self.hit_flash = false end)
  end
end

function BigRock:die()
  self.dead = true
  self.area:addGameObject('EnemyDeathEffect', self.x, self.y,
    {color = hp_color, w = 2.5 * self.w, h = 2.5 * self.h})
  for i = 1, 4 do
    self.timer:after(table.random({0, 0.01, 0.02}), function()
      self.area:addGameObject('Rock', 0, 0,
        {x = self.x + random(-self.w, self.w), y = self.y + random(-self.w, self.w), direction = self.direction})
    end)
  end
end

function BigRock:destroy()
  BigRock.super.destroy(self)
end