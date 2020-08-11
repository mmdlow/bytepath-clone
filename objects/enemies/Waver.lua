Waver = GameObject:extend()

function Waver:new(area, x, y, opts)
  Waver.super.new(self, area, x, y, otps)
  
  self.direction = table.random({-1, 1})
  self.x = gw / 2 + self.direction * (gw / 2 + 48)
  self.y = random(16, gh - 16)

  self.w, self.h = 12, 6
  self.r = self.direction == 1 and math.pi or 0
  self.collider = self.area.world:newPolygonCollider(
    {self.w, 0, 0, self.h, -self.w, 0, 0, -self.h})
  self.collider:setPosition(self.x, self.y)
  self.collider:setObject(self)
  self.collider:setCollisionClass('Enemy')
  self.collider:setFixedRotation(false)
  self.collider:setAngle(self.r)
  self.collider:setFixedRotation(true)
  self.v = self.direction * random(20, 40)
  self.collider:setLinearVelocity(self.v, 0)
  self.hp = 70
  self.max_shots = 1
  
  self.timer:every(random(2.2, 2.6), function()
    self.timer:after(1, function()
      for i = 1, self.max_shots do
        self.timer:after((i - 1) * 0.075, function()
          self.area:addGameObject('EnemyProjectile',
            self.x + 1.4 * self.w * math.cos(self.r), self.y + 1.4 * self.w * math.sin(self.r),
            {r = self.r, v = random(140, 160)})
          self.area:addGameObject('EnemyProjectile',
            self.x + 1.4 * self.w * math.cos(self.r - math.pi), self.y + 1.4 * self.w * math.sin(self.r - math.pi),
            {r = self.r - math.pi, v = random(140, 160)})
        end)
      end
    end)
  end)

  local d = table.random({-1, 1})
  local m = random(1, 4)
  self.timer:tween(0.25, self, {r = self.r + m * d * math.pi / 8}, 'linear', function()
    self.timer:tween(0.5, self, {r = self.r - m * d * math.pi / 4}, 'linear')
  end)
  self.timer:every(1, function()
    self.timer:tween(0.5, self, {r = self.r + m * d * math.pi / 4}, 'linear', function()
      self.timer:tween(0.5, self, {r = self.r - m * d * math.pi / 4}, 'linear')
    end)
  end)
end

function Waver:update(dt)
  Waver.super.update(self, dt)

  self.collider:setLinearVelocity(self.direction * self.v * math.cos(self.r), self.direction * self.v * math.sin(self.r))
  self.collider:setAngle(self.r)
end

function Waver:draw()
  if self.hit_flash then love.graphics.setColor(default_color)
  else love.graphics.setColor(hp_color) end
  local points = {self.collider:getWorldPoints(self.collider.shapes.main:getPoints())}
  love.graphics.polygon('line', points)
  love.graphics.setColor(default_color)
end

function Waver:hit(damage)
  local damage = damage or 100
  self.hp = self.hp - damage
  if self.hp <= 0 then
    self:die()
  else
    self.hit_flash = true
    timer:after('hit_flash', 0.2, function() self.hit_flash = false end)
  end
end

function Waver:die()
  current_room.score = current_room.score + 300
  self.dead = true
  if not current_room.player.no_ammo_drop then
    self.area:addGameObject('Ammo', self.x, self.y)
  end
  self.area:addGameObject('EnemyDeathEffect', self.x, self.y,
    {color = hp_color, w = 2.5 * self.w, h = 2.5 * self.h})
end

function Waver:destroy()
  Waver.super.destroy(self)
end