Projectile = GameObject:extend()

function Projectile:new(area, x, y, opts)
  Projectile.super.new(self, area, x, y, opts)

  self.s = opts.s or 2.5 -- collider radius
  self.v = opts.v or 200 -- collider velocity
  self.base_s = self.s
  self.base_v = self.v

  self.collider = self.area.world:newCircleCollider(self.x, self.y, self.s)
  self.collider:setObject(self)
  self.collider:setCollisionClass('Projectile')

  self.color = attacks[self.attack].color
  self.color_switch = true

  self.damage = 100

  if self.attack == 'Homing' then
    self.timer:every(0.02, function()
      local r = Vector(self.collider:getLinearVelocity()):angleTo()
      self.area:addGameObject('TrailParticle', self.x - self.s * math.cos(r), self.y - self.s * math.sin(r),
        {parent = self, r = random(1, 3), d = random(0.1, 0.2), color = skill_point_color})
    end)
  end
end

function Projectile:update(dt)
  self.v = self.base_v * current_room.player.pspd_multiplier.value
  self.s = self.base_s * current_room.player.projectile_size_multiplier

  if self.collider:enter('Enemy') then
    local collision_data = self.collider:getEnterCollisionData('Enemy')
    local object = collision_data.collider:getObject()
    if object then
      object:hit(self.damage)
      self:die()
      if object.hp <= 0 then current_room.player:onKill(object) end
    end
  end

  -- if Spread attack, set projectile color to a random color every other frame
  self.color_switch = not self.color_switch
  if (self.attack == 'Spread' and self.color_switch) then
    self.color = table.random(all_colors)
  else
    self.color = attacks[self.attack].color
  end
  
  Projectile.super.update(self, dt)

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

  if self.x < 0 or self.y < 0 or self.x > gw or self.y > gh then self:die() end
end

function Projectile:draw()
  pushRotate(self.x, self.y, Vector(self.collider:getLinearVelocity()):angleTo())
  if self.attack == 'Homing' then
    love.graphics.setColor(self.color)
    love.graphics.polygon('fill',
      self.x - 2 * self.s, self.y, self.x, self.y - 1.5 * self.s, self.x, self.y + 1.5 * self.s)
    love.graphics.setColor(default_color)
    love.graphics.polygon('fill',
      self.x, self.y - 1.5 * self.s, self.x, self.y + 1.5 * self.s, self.x + 1.5 * self.s, self.y)
  else
    love.graphics.setLineWidth(self.s - self.s / 4)
    love.graphics.setColor(self.color)
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