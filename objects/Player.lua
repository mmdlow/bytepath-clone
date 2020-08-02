Player = GameObject:extend()

function Player:new(area, x, y, opts)
  Player.super.new(self, area, x, y, opts)

  self.w, self.h = 12, 12
  self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
  self.collider:setObject(self)
  self.collider:setCollisionClass('Player')

  self.r = -math.pi / 2         -- angle player is moving toward (initially, up)
  self.rv = 1.66 * math.pi      -- velocity of angle change
  self.v = 0                    -- player velocity
  self.base_max_v = 100         -- base max velocity
  self.max_v = self.base_max_v  -- current max velocity
  self.a = 100                  -- player acceleration
  self.ship = 'Striker'

  self.timer:every(5, function() self:tick() end)

  -- boost stats
  self.trail_color = skill_point_color
  self.max_boost = 100
  self.boost = self.max_boost
  self.can_boost = true
  self.boost_cooldown = 2
  self.boost_timer = 0

  self.timer:every(0.01, function()
    if self.ship == 'Fighter' then
      self.area:addGameObject('TrailParticle',
      self.x - 0.9 * self.w * math.cos(self.r) + 0.2 * self.w * math.cos(self.r - math.pi / 2), 
      self.y - 0.9 * self.w * math.sin(self.r) + 0.2 * self.w * math.sin(self.r - math.pi / 2), 
      {parent = self, r = random(2, 4), d = random(0.15, 0.25), color = self.trail_color})
      self.area:addGameObject('TrailParticle',
      self.x - 0.9 * self.w * math.cos(self.r) + 0.2 * self.w * math.cos(self.r + math.pi / 2), 
      self.y - 0.9 * self.w * math.sin(self.r) + 0.2 * self.w * math.sin(self.r + math.pi / 2), 
      {parent = self, r = random(2, 4), d = random(0.15, 0.25), color = self.trail_color})
    
    elseif self.ship == 'Striker' then
      self.area:addGameObject('TrailParticle',
      self.x - 1.0 * self.w * math.cos(self.r) + 0.2 * self.w * math.cos(self.r - math.pi / 2), 
      self.y - 1.0 * self.w * math.sin(self.r) + 0.2 * self.w * math.sin(self.r - math.pi / 2), 
      {parent = self, r = random(2, 4), d = random(0.15, 0.25), color = self.trail_color})
      self.area:addGameObject('TrailParticle',
      self.x - 1.0 * self.w * math.cos(self.r) + 0.2 * self.w * math.cos(self.r + math.pi / 2), 
      self.y - 1.0 * self.w * math.sin(self.r) + 0.2 * self.w * math.sin(self.r + math.pi / 2), 
      {parent = self, r = random(2, 4), d = random(0.15, 0.25), color = self.trail_color})
    
    elseif self.ship == 'Rogue' then
      self.area:addGameObject('TrailParticle',
      self.x - self.w * math.cos(self.r),
      self.y - self.w * math.sin(self.r),
      {parent = self, r = random(2, 4), d = random(0.15, 0.25), color = self.trail_color})
    end
  end)

  -- hp stats
  self.max_hp = 100
  self.hp = self.max_hp

  -- ammo stats
  self.max_ammo = 100
  self.ammo = self.max_ammo

  -- ship design polygon points
  self.polygons = {}
  if self.ship == 'Fighter' then
    self.polygons[1] = {
      self.w, 0,
      self.w / 2, -self.h / 2,
      -self.w / 2, -self.h / 2,
      -self.w, 0,
      -self.w / 2, self.h / 2,
      self.w / 2, self.h / 2
    }
    self.polygons[2] = {
      self.w / 2, -self.h / 2,
      0, -self.h,
      -self.w * 1.5, -self.h,
      -self.w * 0.75, -self.h / 4,
      -self.w / 2, -self.h / 2
    }
    self.polygons[3] = {
      self.w / 2, self.h / 2,
      0, self.h,
      -self.w * 1.5, self.h,
      -self.w * 0.75, self.h / 4,
      -self.w / 2, self.h / 2
    }

  elseif self.ship == 'Striker' then
    self.polygons[1] = {
      self.w, 0,
      self.w/2, -self.h/2,
      -self.w/2, -self.h/2,
      -self.w, 0,
      -self.w/2, self.h/2,
      self.w/2, self.h/2,
    }
    self.polygons[2] = {
      0, self.w/2,
      -self.w/4, self.h,
      0, self.w + self.h/2,
      self.w, self.h,
      0, 2*self.h,
      -self.w/2, self.h + self.h/2,
      -self.w, 0,
      -self.w/2, self.h/2,
    }
    self.polygons[3] = {
      0, -self.h/2,
      -self.w/4, -self.h,
      0, -self.h - self.h/2,
      self.w, -self.h,
      0, -2*self.h,
      -self.w/2, -self.h - self.h/2,
      -self.w, 0,
      -self.w/2, -self.h/2,
    }

  elseif self.ship == 'Rogue' then
    self.polygons[1] = {
      self.w, 0,
      self.w / 4, -self.h * 0.75,
      -self.w * 1.25, -self.h / 4,
      -self.w, 0,
      -self.w * 1.25, self.h / 4,
      self.w / 4, self.h * 0.75
    }
  end

  -- set attack
  self:setAttack('Neutral')
  self.shoot_timer = 0
  self.shoot_cooldown = attacks[self.attack].cooldown
end

function Player:update(dt)
  Player.super.update(self, dt)

  if input:down('left') then self.r = self.r - self.rv * dt end
  if input:down('right') then self.r = self.r + self.rv * dt end

  -- attack management
  self.shoot_timer = self.shoot_timer + dt
  if self.shoot_timer > self.shoot_cooldown then
    self.shoot_timer = 0
    self:shoot()
  end

  -- collectable behavior
  if self.collider:enter('Collectable') then
    local collision_data = self.collider:getEnterCollisionData('Collectable')
    local object = collision_data.collider:getObject()
    if object:is(Ammo) then
      object:die()
      self:addAmmo(5)
    elseif object:is(HP) then
      object:die()
      self:changeHP(25)
    elseif object:is(SP) then
      object:die()
      current_room.score = current_room.score + 250
    elseif object:is(Boost) then
      current_room.score = current_room.score + 150
      object:die()
    elseif object:is(Attack) then
      object:die()
      self:setAttack(object.attack)
    end
  elseif self.collider:enter('Enemy') then
    self:hit(30)
  end
  
  -- boost management
  self.max_v = self.base_max_v
  self.boost = math.min(self.boost + 10 * dt, self.max_boost)
  self.boost_timer = self.boost_timer + dt
  if self.boost_timer > self.boost_cooldown then self.can_boost = true end
  self.boosting = false

  if input:down('up') and self.boost > 1 and self.can_boost then
    self.boosting = true
    self.max_v = 1.5 * self.base_max_v
    self.boost = self.boost - 50 * dt
    if self.boost <= 1 then
      self.boosting = false
      self.can_boost = false
      self.boost_timer = 0
    end
  end
  if input:down('down') and self.boost > 1 and self.can_boost then
    self.boosting = true
    self.max_v = 0.5 * self.base_max_v
    self.boost = self.boost - 50 * dt
    if self.boost <= 1 then
      self.boosting = false
      self.can_boost = false
      self.boost_timer = 0
    end
  end

  self.trail_color = skill_point_color
  if self.boosting then self.trail_color = boost_color end

  -- velocity management
  self.v = math.min(self.v + self.a * dt, self.max_v)
  self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))

  -- death if player hits the edges
  if self.x < 0 or self.y < 0 or self.x > gw or self.y > gh then self:die() end

  input:bind('f4', function() self:die() end) -- to see death effect
end

function Player:draw()
  if self.invisible then return end
  pushRotate(self.x, self.y, self.r)
  love.graphics.setColor(default_color)
  
  -- draw polygons
  for _, polygon in ipairs(self.polygons) do
    local points = fn.map(polygon, function(v, k) 
      if k % 2 == 1 then
        return self.x + v + random(-1, 1)
      else
        return self.y + v + random(-1, 1)
      end
    end)
    love.graphics.polygon('line', points)
  end

  love.graphics.pop()
end

function Player:shoot()
  local d = 1.2 * self.w

  self.area:addGameObject('ShootEffect', self.x + d * math.cos(self.r),
    self.y + d * math.sin(self.r),
    {player = self, d = d})

  self.ammo = self.ammo - attacks[self.attack].ammo

  if self.attack == 'Neutral' then
    self.area:addGameObject('Projectile', self.x + 1.5 * d * math.cos(self.r),
      self.y + 1.5 * d * math.sin(self.r), {r = self.r, attack = self.attack})

  elseif self.attack == 'Double' then
    self.area:addGameObject('Projectile',
      self.x + 1.5 * d * math.cos(self.r + math.pi / 12),
      self.y + 1.5 * d * math.sin(self.r + math.pi / 12),
      {r = self.r + math.pi/12, attack = self.attack})
    self.area:addGameObject('Projectile',
      self.x + 1.5 * d * math.cos(self.r - math.pi / 12),
      self.y + 1.5 * d * math.sin(self.r - math.pi / 12),
      {r = self.r - math.pi/12, attack = self.attack})

  elseif self.attack == 'Triple' then
    self.area:addGameObject('Projectile',
      self.x + 1.5 * d * math.cos(self.r + math.pi / 12),
      self.y + 1.5 * d * math.sin(self.r + math.pi / 12),
      {r = self.r + math.pi/12, attack = self.attack})
    self.area:addGameObject('Projectile',
      self.x + 1.5 * d * math.cos(self.r),
      self.y + 1.5 * d * math.sin(self.r),
      {r = self.r, attack = self.attack})
    self.area:addGameObject('Projectile',
      self.x + 1.5 * d * math.cos(self.r - math.pi / 12),
      self.y + 1.5 * d * math.sin(self.r - math.pi / 12),
      {r = self.r - math.pi/12, attack = self.attack})

  elseif self.attack == 'Rapid' then
    self.area:addGameObject('Projectile', self.x + 1.5 * d * math.cos(self.r),
      self.y + 1.5 * d * math.sin(self.r), {r = self.r, attack = self.attack})

  elseif self.attack == 'Spread' then
    self.area:addGameObject('Projectile',
      self.x + 1.5 * d * math.cos(self.r),
      self.y + 1.5 * d * math.sin(self.r),
      {r = self.r + random(-math.pi / 8, math.pi / 8), attack = self.attack})

  elseif self.attack == 'Back' then
    self.area:addGameObject('Projectile', self.x + 1.5 * d * math.cos(self.r),
      self.y + 1.5 * d * math.sin(self.r), {r = self.r, attack = self.attack})
    self.area:addGameObject('Projectile', self.x - 1.5 * d * math.cos(self.r),
      self.y - 1.5 * d * math.sin(self.r), {r = self.r + math.pi, attack = self.attack})

  elseif self.attack == 'Side' then
    self.area:addGameObject('Projectile',
      self.x + 1.5 * d * math.cos(self.r + math.pi / 2),
      self.y + 1.5 * d * math.sin(self.r + math.pi / 2),
      {r = self.r + math.pi / 2, attack = self.attack})
    self.area:addGameObject('Projectile', self.x + 1.5 * d * math.cos(self.r),
      self.y + 1.5 * d * math.sin(self.r), {r = self.r, attack = self.attack})
    self.area:addGameObject('Projectile',
      self.x + 1.5 * d * math.cos(self.r - math.pi / 2),
      self.y + 1.5 * d * math.sin(self.r - math.pi / 2),
      {r = self.r - math.pi / 2, attack = self.attack})
  
  end

  -- revert to Neutral attack if out of ammo
  if self.ammo <= 0 then
    self:setAttack('Neutral')
    self.ammo = self.max_ammo
  end
end

function Player:tick()
  self.area:addGameObject('TickEffect', self.x, self.y, {parent = self})
end

function Player:addAmmo(amount)
  self.ammo = math.min(self.ammo + amount, self.max_ammo)
  current_room.score = current_room.score + 50
end

function Player:changeHP(amount)
  self.hp = math.min(self.hp + amount, self.max_hp)
  if self.hp <= 0 then self:die() end
end

function Player:setAttack(attack)
  self.attack = attack
  self.shoot_cooldown = attacks[attack].cooldown
  self.ammo = self.max_ammo
  current_room.score  = current_room.score + 500
end

function Player:hit(damage)
  if self.invincible then return end
  local damage = damage or 10
  self:changeHP(-damage)
  for i = 1, love.math.random(4, 8) do
    self.area:addGameObject('ExplodeParticle', self.x, self.y)
  end

  if damage >= 30 then
    self.invincible = true
    self.invisible = true
    self.timer:every(0.04, function() self.invisible = not self.invisible end, 50)
    self.timer:after(2, function() self.invincible = false end)
    self.timer:after(2.04, function() self.invisible = false end)
    camera:shake(6, 60, 0.2)
    flash(3)
    slow(0.25, 0.5)
  else
    camera:shake(6, 60, 0.1)
    flash(2)
    slow(0.75, 0.25)
  end

end

function Player:die()
  self.dead = true
  flash(4)
  slow(0.15, 1)
  camera:shake(6, 60, 0.4)
  for i = 1, love.math.random(8, 12) do
    self.area:addGameObject('ExplodeParticle', self.x, self.y)
  end
  current_room:finish()
end

function Player:destroy()
  Player.super.destroy(self)
end