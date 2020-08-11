Seeker = GameObject:extend()

function Seeker:new(area, x, y, opts)
  Seeker.super.new(self, area, x, y, opts)

  self.direction = table.random({-1, 1})
  self.x = gw / 2 + self.direction * (gw / 2 + 48)
  self.y = random(16, gh - 16)

  self.w, self.h = 16, 8
  self.r = self.direction == 1 and math.pi or 0
  self.collider = self.area.world:newPolygonCollider({
    self.w, 0, self.w / 2, self.h, -self.w / 2, self.h,
    -self.w, 0, -self.w / 2, -self.h, self.w / 2, -self.h
  })
  self.collider:setPosition(self.x, self.y)
  self.collider:setObject(self)
  self.collider:setCollisionClass('Enemy')
  self.collider:setFixedRotation(false)
  self.collider:setAngle(self.r)
  self.collider:setFixedRotation(true)
  self.v = random(20, 40)
  self.vx, self.vy = self.v * math.cos(self.r), self.v * math.sin(self.r)

  self.timer:every(random(1, 2), function()
    self.area:addGameObject('PreAttackEffect',
      self.x + 1.4 * self.w * math.cos(self.collider:getAngle()),
      self.y + 1.4 * self.h * math.sin(self.collider:getAngle()),
      {shooter = self, color = hp_color, duration = 1})
    self.timer:after(1, function()
      self.area:addGameObject('EnemyProjectile',
        self.x + 1.4 * self.w * math.cos(self.collider:getAngle()),
        self.y + 1.4 * self.h * math.sin(self.collider:getAngle()),
        {r = self.collider:getAngle(), v = random(80, 100), s = 3.5, mine = true})
    end)
  end)

  self.hp = 200
end

function Seeker:update(dt)
  Seeker.super.update(self, dt)

  if not self.target then
    self.target = current_room.player
    if self.target and self.target.dead then self.target = nil end
  end
  
  if self.target then
    local seeker_heading = Vector(self.collider:getLinearVelocity()):normalized()
    local angle = math.atan2(self.target.y - self.y, self.target.x - self.x)
    local to_target_heading = Vector(math.cos(angle), math.sin(angle)):normalized()
    local final_heading = (seeker_heading + 0.1 * to_target_heading):normalized()
    self.vx, self.vy = self.v * final_heading.x, self.v * final_heading.y
  else
    self.vx, self.vy = self.v * math.cos(self.r), self.v * math.sin(self.r)
  end
  
  self.r = Vector(self.vx, self.vy):angleTo()
  self.collider:setAngle(self.r - math.pi)
  self.collider:setLinearVelocity(self.vx, self.vy)
end

function Seeker:draw()
  if self.hit_flash then love.graphics.setColor(default_color)
  else love.graphics.setColor(hp_color) end
  local points = {self.collider:getWorldPoints(self.collider.shapes.main:getPoints())}
  love.graphics.polygon('line', points)
  love.graphics.setColor(default_color)
end

function Seeker:hit(damage)
  local damage = damage or 100
  self.hp = self.hp - damage
  if self.hp <= 0 then
    self:die()
  else
    self.hit_flash = true
    timer:after('hit_flash', 0.2, function() self.hit_flash = false end)
  end
end

function Seeker:die()
  current_room.score = current_room.score + 250
  self.dead = true
  if not current_room.player.no_ammo_drop then
    self.area:addGameObject('Ammo', self.x, self.y)
  end
  self.area:addGameObject('EnemyDeathEffect', self.x, self.y,
    {color = hp_color, w = 2.5 * self.w, h = 2.5 * self.h})
end

function Seeker:destroy()
  Seeker.super.destroy(self)
end