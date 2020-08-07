Projectile = GameObject:extend()

function Projectile:new(area, x, y, opts)
  Projectile.super.new(self, area, x, y, opts)

  self.s = (opts.s or 2.5) * current_room.player.projectile_size_multiplier -- collider radius
  self.v = (opts.v or 200) * current_room.player.pspd_multiplier.value -- collider velocity
  self.base_s = self.s
  self.base_v = self.v
  self.rv = table.random({random(-2 * math.pi, -math.pi), random(math.pi, 2 * math.pi)})

  self.collider = self.area.world:newCircleCollider(self.x, self.y, self.s)
  self.collider:setObject(self)
  self.collider:setCollisionClass('Projectile')
  
  self.color = opts.color or attacks[self.attack].color
  self.color_switch = true

  self.damage = 100

  if self.attack == 'Homing' then
    self.timer:every(0.02, function()
      local r = Vector(self.collider:getLinearVelocity()):angleTo()
      self.area:addGameObject('TrailParticle', self.x - self.s * math.cos(r), self.y - self.s * math.sin(r),
        {parent = self, r = random(1, 3), d = random(0.1, 0.2), color = skill_point_color})
    end)

  elseif self.attack == '2Split' or self.attack == '4Split' then
    self.timer:every(0.02, function()
      local r = Vector(self.collider:getLinearVelocity()):angleTo()
      self.area:addGameObject('TrailParticle', self.x - self.s * math.cos(r), self.y - self.s * math.sin(r),
        {parent = self, r = random(1, 3), d = random(0.1, 0.2), color = self.color})
    end)

  elseif self.attack == 'Blast' then
    self.damage = 75
    self.color = table.random(negative_colors)
    if not self.shield then
      self.timer:tween(random(0.4, 0.6) * current_room.player.projectile_duration_multiplier, self, {v = 0}, 'linear', function() self:die() end)
    end

  elseif self.attack == 'Spin' then
    if not self.shield then
      self.timer:after(random(2.4, 3.2) * current_room.player.projectile_duration_multiplier, function() self:die() end)
      self.timer:every(0.05, function()
        self.area:addGameObject('ProjectileTrail', self.x, self.y,
        {r = Vector(self.collider:getLinearVelocity()):angleTo(), color = self.color, s = self.s})
      end)
    end

  elseif self.attack == 'Flame' then
    self.damage = 50
    if not self.shield then
      self.timer:tween(random(0.6, 1) * current_room.player.projectile_duration_multiplier, self, {v = 0}, 'linear', function() self:die() end)
      self.timer:every(0.05, function()
        self.area:addGameObject('ProjectileTrail', self.x, self.y,
        {r = Vector(self.collider:getLinearVelocity()):angleTo(), color = self.color, s = self.s})
      end)
    end
  end

  if current_room.player.projectile_ninety_degree_change then
    self.timer:after(0.2 / current_room.player.angle_change_frequency_multiplier, function()
      self.ninety_degree_direction = table.random({-1, 1})
      self.r = self.r + self.ninety_degree_direction * math.pi / 2
      self.timer:every('ninety_degree_first', 0.25 / current_room.player.angle_change_frequency_multiplier, function()
        self.r = self.r - self.ninety_degree_direction * math.pi / 2
        self.timer:after('ninety_degree_second', 0.1 / current_room.player.angle_change_frequency_multiplier, function()
          self.r = self.r - self.ninety_degree_direction * math.pi / 2
          self.ninety_degree_direction = -self.ninety_degree_direction
        end)
      end)
    end)
  end

  if current_room.player.projectile_random_degree_change then
    self.timer:after(0.2 / current_room.player.angle_change_frequency_multiplier, function()
      self.r = self.r + table.random({-1, 1}) * math.pi / 6
      self.timer:every('thirty_degree', 0.25 / current_room.player.angle_change_frequency_multiplier, function()
        self.r = self.r + table.random({-1, 1}) * math.pi / 6
      end)
    end)
  end

  if current_room.player.wavy_projectiles then
    local direction = table.random({-1, 1}) * current_room.player.projectile_waviness_multiplier
    self.timer:tween(0.25 / current_room.player.angle_change_frequency_multiplier,
      self, {r = self.r + direction * math.pi / 8}, 'linear',
      function()
        self.timer:tween(0.25, self, {r = self.r - direction * math.pi / 4}, 'linear')
      end)
    self.timer:every(0.75 / current_room.player.angle_change_frequency_multiplier, function()
      self.timer:tween(0.25 / current_room.player.angle_change_frequency_multiplier,
        self, {r = self.r + direction * math.pi / 4}, 'linear',
        function()
          self.timer:tween(0.25, self, {r = self.r - direction * math.pi / 4}, 'linear')
        end)
    end)
  end

  if current_room.player.fast_slow then
    local initial_v = self.v
    self.timer:tween('fast_slow_first', 0.2, self, {v = 2 * initial_v * current_room.player.projectile_acceleration_multiplier}, 'in-out-cubic', function()
      self.timer:tween('fast_slow_second', 0.3, self, {v = initial_v * current_room.player.projectile_acceleration_multiplier/ 2}, 'linear')
    end)
  end

  if current_room.player.slow_fast then
    local initial_v = self.v
    self.timer:tween('slow_fast_first', 0.2, self, {v = initial_v * current_room.player.projectile_deceleration_multiplier / 2}, 'in-out-cubic', function()
      self.timer:tween('slow_fast_second', 0.3, self, {v = initial_v * current_room.player.projectile_deceleration_multiplier * 2}, 'linear')
    end)
  end

  if self.shield then
    self.orbit_distance = random(32, 64)
    self.orbit_speed = random(-6, 6)
    self.orbit_offset = random(0, 2 * math.pi)
    self.invisible = true
    self.timer:after(0.05, function() self.invisible = false end)
    self.timer:after(6 * current_room.player.projectile_duration_multiplier, function() self:die() end)
  end

  self.previous_x, self.previous_y = self.collider:getPosition()

end

function Projectile:update(dt)
  if self.collider:enter('Enemy') then
    local collision_data = self.collider:getEnterCollisionData('Enemy')
    local object = collision_data.collider:getObject()
    if object then
      object:hit(self.damage)
      self:die()
      if object.hp <= 0 then current_room.player:onKill(object) end
    end

    if self.attack == '2Split' then
      self.area:addGameObject('Projectile',
        self.x, self.y, {r = self.r + math.pi / 4, attack = 'Neutral', color = self.color})
      self.area:addGameObject('Projectile',
        self.x, self.y, {r = self.r - math.pi / 4, attack = 'Neutral', color = self.color})

    elseif self.attack == '4Split' then
      self.area:addGameObject('Projectile',
        self.x, self.y, {r = self.r + math.pi / 4, attack = 'Neutral', color = self.color})
      self.area:addGameObject('Projectile',
        self.x, self.y, {r = self.r - math.pi / 4, attack = 'Neutral', color = self.color})
      self.area:addGameObject('Projectile',
        self.x, self.y, {r = self.r + 3 * math.pi / 4, attack = 'Neutral', color = self.color})
      self.area:addGameObject('Projectile',
        self.x, self.y, {r = self.r - 3 * math.pi / 4, attack = 'Neutral', color = self.color})
    end
  end
  
  Projectile.super.update(self, dt)

  -- Bounce Wall Collision
  if self.bounce and self.bounce > 0 then
    if self.x < 0 then
      self.r = math.pi - self.r
      self.bounce = self.bounce - 1
    end
    if self.y < 0 then
      self.r = 2 * math.pi - self.r
      self.bounce = self.bounce - 1
    end
    if self.x > gw then
      self.r = math.pi - self.r
      self.bounce = self.bounce - 1
    end
    if self.y > gh then
      self.r = 2 * math.pi - self.r
      self.bounce = self.bounce - 1
    end

  -- 2Split and 4Split Wall Collision
  elseif self.attack == '2Split' or self.attack == '4Split' then
    if self.x < 0 then
      self.area:addGameObject('Projectile',
        self.x + self.s, self.y,
        {r = 2 * math.pi - math.pi / 4, attack = 'Neutral', color = self.color})
      self.area:addGameObject('Projectile',
        self.x + self.s, self.y,
        {r = math.pi / 4, attack = 'Neutral', color = self.color})
      self:die()
    end
    if self.y < 0 then
      self.area:addGameObject('Projectile',
        self.x, self.y + self.s,
        {r = 3 * math.pi / 4, attack = 'Neutral', color = self.color})
      self.area:addGameObject('Projectile',
        self.x, self.y + self.s,
        {r = math.pi / 4, attack = 'Neutral', color = self.color})
      self:die()
    end
    if self.x > gw then
      self.area:addGameObject('Projectile',
        self.x - self.s, self.y,
        {r = 5 * math.pi / 4, attack = 'Neutral', color = self.color})
      self.area:addGameObject('Projectile',
        self.x - self.s, self.y,
        {r = 3 * math.pi / 4, attack = 'Neutral', color = self.color})
      self:die()
    end
    if self.y > gh then
      self.area:addGameObject('Projectile',
        self.x, self.y - self.s,
        {r = 5 * math.pi / 4, attack = 'Neutral', color = self.color})
      self.area:addGameObject('Projectile',
        self.x, self.y - self.s,
        {r = 2 * math.pi  - math.pi / 4, attack = 'Neutral', color = self.color})
      self:die()
    end

  else
    if self.x < 0 or self.y < 0 or self.x > gw or self.y > gh then self:die() end
  end

  -- Spread attack
  ---- set projectile color to a random color every other frame
  self.color_switch = not self.color_switch
  if (self.attack == 'Spread' and self.color_switch) then
    self.color = table.random(all_colors)
  end

  -- Spin attack
  if self.attack == 'Spin' then
    self.r = self.r + self.rv * dt
  end

  -- Homing attack
  if self.attack == 'Homing' then
    -- Acquire new target
    if not self.target then
      local targets = self.area:getGameObjects(function(e)
        for _, enemy in ipairs(enemies) do
          if e:is(_G[enemy]) and (distance(e.x, e.y, self.x, self.y) < 400) then
            return true
          end
        end
      end)
      self.target = table.remove(targets, love.math.random(1, #targets))
    end
    if self.target and self.target.dead then self.target = nil end

    -- Move toward target
    if self.target then
      local projectile_heading = Vector(self.collider:getLinearVelocity()):normalized()
      local angle = math.atan2(self.target.y - self.y, self.target.x - self.x)
      local to_target_heading = Vector(math.cos(angle), math.sin(angle)):normalized()
      local final_heading = (projectile_heading + 0.1 * to_target_heading):normalized()
      self.collider:setLinearVelocity(self.v * final_heading.x, self.v * final_heading.y)
    else
      self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
    end
  else
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
  end

  -- Shield attack
  if self.shield then
    local player = current_room.player
    self.collider:setPosition(
      player.x + self.orbit_distance * math.cos(self.orbit_speed * time + self.orbit_offset),
      player.y + self.orbit_distance * math.sin(self.orbit_speed * time + self.orbit_offset)
    )
    local x, y = self.collider:getPosition()
    local dx, dy = x - self.previous_x, y - self.previous_y
    self.r = Vector(dx, dy):angleTo()
  end

  self.previous_x, self.previous_y = self.collider:getPosition()
end

function Projectile:draw()
  if self.invisible then return end
  pushRotate(self.x, self.y, Vector(self.collider:getLinearVelocity()):angleTo())

  if self.attack == 'Homing' or self.attack == '2Split' or self.attack == '4Split' then
    love.graphics.setColor(self.color)
    love.graphics.polygon('fill',
      self.x - 2 * self.s, self.y, self.x, self.y - 1.5 * self.s, self.x, self.y + 1.5 * self.s)
    love.graphics.setColor(default_color)
    love.graphics.polygon('fill',
      self.x, self.y - 1.5 * self.s, self.x, self.y + 1.5 * self.s, self.x + 1.5 * self.s, self.y)
  else
    love.graphics.setLineWidth(self.s - self.s / 4)
    love.graphics.setColor(self.color)

    if self.attack == 'Bounce' then
      love.graphics.setColor(table.random(default_colors))
    end

    love.graphics.line(self.x - 2 * self.s, self.y, self.x, self.y) -- 1st half of line
    love.graphics.setColor(default_color)
    love.graphics.line(self.x, self.y, self.x + 2 * self.s, self.y)
    love.graphics.setLineWidth(1)
  end
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