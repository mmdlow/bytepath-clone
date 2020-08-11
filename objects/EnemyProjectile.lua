EnemyProjectile = GameObject:extend()

function EnemyProjectile:new(area, x, y, opts)
  EnemyProjectile.super.new(self, area, x, y, opts)

  self.s = opts.s or 2.5 -- collider radius
  self.v = opts.v or 200 -- collider velocity

  self.collider = self.area.world:newCircleCollider(self.x, self.y, self.s)
  self.collider:setObject(self)
  self.collider:setCollisionClass('EnemyProjectile')

  self.damage = 10

  if self.mine then
    self.rv = table.random({random(-12 * math.pi, -10 * math.pi), random(10 * math.pi, 12 * math.pi)})
    self.timer:after(random(8, 12), function() self:die() end)
  end

  if self.shield then
    self.orbit_distance = random(32, 64)
    self.orbit_speed = random(-6, 6)
    self.orbit_offset = random(0, 2 * math.pi)
    self.post_shield_timer = 0
  end

  self.previous_x, self.previous_y = self.collider:getPosition()
end

function EnemyProjectile:update(dt)
  if self.collider:enter('Player') then
    local collision_data = self.collider:getEnterCollisionData('Player')
    local object = collision_data.collider:getObject()
    if object then
      object:hit(self.damage)
      self:die()
    end
  elseif self.collider:enter('Projectile') then
    local collision_data = self.collider:getEnterCollisionData('Projectile')
    local object = collision_data.collider:getObject()
    if object then
      object:die()
      self:die()
    end
  end

  EnemyProjectile.super.update(self, dt)
  
  if not self.shield then
    if self.x < 0 or self.y < 0 or self.x > gw or self.y > gh then self:die() end
  end
  
  if self.mine then self.r = self.r + self.rv * dt end

  if self.shield then
    -- Orbit orbiter if orbiter is not dead
    if self.orbiter and not self.orbiter.dead then
      local orbiter = self.orbiter
      self.collider:setPosition(
        orbiter.x + self.orbit_distance * math.cos(self.orbit_speed * time + self.orbit_offset),
        orbiter.y + self.orbit_distance * math.sin(self.orbit_speed * time + self.orbit_offset)
      )
      local x, y = self.collider:getPosition()
      local dx, dy = x - self.previous_x, y - self.previous_y
      self.r = Vector(dx, dy):angleTo()
      self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))

    -- If orbiter dead, home in on player
    elseif current_room.player and not current_room.player.dead then
      local target = current_room.player
      local projectile_heading = Vector(self.collider:getLinearVelocity()):normalized()
      local angle = math.atan2(target.y - self.y, target.x - self.x)
      local to_target_heading = Vector(math.cos(angle), math.sin(angle)):normalized()
      local final_heading = (projectile_heading + 0.1 * to_target_heading):normalized()
      self.collider:setLinearVelocity(self.v * final_heading.x, self.v * final_heading.y)
      
      self.post_shield_timer = self.post_shield_timer + dt
      if self.post_shield_timer == 2 then self:die() end

    else
      self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
    end
  else
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
  end

  self.previous_x, self.previous_y = self.collider:getPosition()
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

function EnemyProjectile:die()
  self.dead = true
  self.area:addGameObject('ProjectileDeathEffect', self.x, self.y, {color = hp_color, w = 3 * self.s})
end

function EnemyProjectile:destroy()
  EnemyProjectile.super.destroy(self)
end