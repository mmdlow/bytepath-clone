Player = GameObject:extend()

function Player:new(area, x, y, opts)
  Player.super.new(self, area, x, y, opts)

  self.w, self.h = 12, 12
  self.base_w, self.base_h = self.w, self.h
  self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
  self.collider:setObject(self)
  self.collider:setCollisionClass('Player')

  self.r = -math.pi / 2         -- angle player is moving toward (initially, up)
  self.rv = 1.66 * math.pi      -- velocity of angle change
  self.v = 0                    -- player velocity
  self.base_max_v = 100         -- base max velocity
  self.max_v = self.base_max_v  -- current max velocity
  self.a = 100                  -- player acceleration
  self.ship = 'Fighter'

  -- boost stats
  self.trail_color = skill_point_color
  self.max_boost = 100
  self.boost = self.max_boost
  self.can_boost = true
  self.boost_cooldown = 2
  self.boost_timer = 0

  -- energy shield
  self.energy_shield_recharge_cooldown = 2
  self.energy_shield_recharge_amount = 1

  -- trail particles
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

  -- cycle stats
  self.cycle_timer = 0
  self.cycle_cooldown = 5

  -- multipliers
  self.hp_multiplier = 1
  self.ammo_multiplier = 1
  self.boost_multiplier = 1
  self.luck_multiplier = 1
  self.spawn_hp_chance_multiplier = 1
  self.spawn_boost_chance_multiplier = 1
  self.spawn_sp_chance_multiplier = 1
  self.enemy_spawn_rate_multiplier = 1
  self.resource_spawn_rate_multiplier = 1
  self.attack_spawn_rate_multiplier = 1
  self.turn_rate_multiplier = 1
  self.boost_effectiveness_multiplier = 1
  self.projectile_size_multiplier = 1
  self.boost_recharge_rate_multiplier = 1
  self.invulnerability_time_multiplier = 1
  self.ammo_consumption_multiplier = 1
  self.size_multiplier = 1
  self.stat_boost_duration_multiplier = 1
  self.angle_change_frequency_multiplier = 1
  self.projectile_waviness_multiplier = 1
  self.projectile_acceleration_multiplier = 1
  self.projectile_deceleration_multiplier = 1
  self.projectile_duration_multiplier = 1
  self.area_multiplier = 1
  self.laser_width_multiplier = 1
  self.energy_shield_recharge_amount_multiplier = 1
  self.energy_shield_recharge_cooldown_multiplier = 1

  self.aspd_multiplier = Stat(1)
  self.mvspd_multiplier = Stat(1)
  self.pspd_multiplier = Stat(1)
  self.cycle_speed_multiplier = Stat(1)

  -- flats
  self.flat_hp = 0
  self.flat_boost = 0
  self.ammo_gain = 0
  self.additional_bounce_projectiles = 0
  self.additional_homing_projectiles = 0
  self.additional_barrage_projectiles = 0
  self.added_chance_to_all_on_kill_events = 0

  -- chances
  self.on_ammo_pickup_launch_homing_projectile_chance = 0
  self.on_ammo_pickup_regain_hp_chance = 0

  self.on_sp_pickup_regain_hp_chance = 0
  self.on_sp_pickup_spawn_haste_area_chance = 0

  self.on_hp_pickup_spawn_haste_area_chance = 0

  self.on_cycle_regain_hp_chance = 0
  self.on_cycle_regain_full_ammo_chance = 0
  self.on_cycle_spawn_haste_area_chance = 0
  self.on_cycle_spawn_sp_chance = 0
  self.on_cycle_spawn_hp_chance = 0
  self.on_cycle_change_attack_chance = 0
  self.on_cycle_barrage_chance = 0
  self.on_cycle_launch_homing_projectile_chance = 0
  self.on_cycle_mvspd_boost_chance = 0
  self.on_cycle_pspd_boost_chance = 0
  self.on_cycle_pspd_inhibit_chance = 0
  self.on_cycle_explode_chance = 0

  self.on_kill_barrage_chance = 0
  self.on_kill_regain_ammo_chance = 0
  self.on_kill_launch_homing_projectile_chance = 0
  self.on_kill_regain_boost_chance = 0
  self.on_kill_spawn_boost_chance = 0
  self.on_kill_gain_aspd_boost_chance = 0

  self.while_boosting_launch_homing_projectile_chance = 0

  self.drop_double_ammo_chance = 0
  self.attack_twice_chance = 0
  self.spawn_double_hp_chance = 0
  self.spawn_double_sp_chance = 0
  self.gain_double_sp_chance = 0
  self.shield_projectile_chance = 0
  self.split_projectiles_split_chance = 0
  self.drop_mines_chance = 0

  self.double_spawn_chance = 0
  self.triple_spawn_chance = 0
  self.rapid_spawn_chance = 0
  self.spread_spawn_chance = 0
  self.back_spawn_chance = 0
  self.side_spawn_chance = 0
  self.homing_spawn_chance = 0
  self.blast_spawn_chance = 0
  self.spin_spawn_chance = 0
  self.flame_spawn_chance = 0
  self.bounce_spawn_chance = 0
  self.twosplit_spawn_chance = 0
  self.foursplit_spawn_chance = 0
  self.lightning_spawn_chance = 0
  self.explode_spawn_chance = 0
  self.laser_spawn_chance = 0

  -- conversions
  self.ammo_to_aspd = 0
  self.mvspd_to_aspd = 0
  self.mvspd_to_hp = 0
  self.mvspd_to_pspd = 0

  -- booleans
  self.only_spawn_boost = false
  self.only_spawn_attack = false
  self.no_boost = false
  self.no_ammo_drop = false
  self.infinite_ammo = false
  self.half_ammo = false
  self.half_hp = false
  self.energy_shield = false
  self.deals_damage_while_invulnerable = false
  self.change_attack_periodically = false
  self.gain_sp_on_death = false
  self.convert_hp_to_sp_if_hp_full = false
  self.refill_ammo_if_hp_full = false
  self.refill_boost_if_hp_full = false
  self.while_boosting_increased_cycle_speed = false
  self.while_boosting_increased_luck = false
  self.while_boosting_invulnerability = false
  self.projectile_ninety_degree_change = false
  self.projectile_random_degree_change = false
  self.projectiles_explode_on_expiration = false
  self.projectiles_explosions = false
  self.wavy_projectiles = false
  self.barrage_nova = false
  self.fast_slow = false
  self.slow_fast = false
  self.additional_lightning_bolt = false
  self.increased_lightning_angle = false
  self.fixed_spin_attack_direction = false
  if self.fixed_spin_attack_direction then self.spin_direction = table.random({1, -1}) end

  self.start_with_double = false
  self.start_with_triple = false
  self.start_with_rapid = false
  self.start_with_spread = false
  self.start_with_back = false
  self.start_with_side = false
  self.start_with_homing = false
  self.start_with_blast = false
  self.start_with_spin = false
  self.start_with_flame = false
  self.start_with_bounce = false
  self.start_with_twosplit = false
  self.start_with_foursplit = false
  self.start_with_lightning = false
  self.start_with_explode = false
  self.start_with_laser = false

  -- set attack
  self:setAttack('Neutral')
  self.shoot_timer = 0
  self.shoot_cooldown = attacks[self.attack].cooldown

  -- ship design polygon points
  self.w = self.base_w * self.size_multiplier
  self.h = self.base_h * self.size_multiplier

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

  self:setShip()
  
  -- generate chances and stats
  self:setStats()
  self:setChances()

  -- drop mines
  self.timer:every('drop_mines', 0.5, function()
    if self.drop_mines_chance > 0 and self.chances.drop_mines_chance:next() then
      local d = 1.2 * self.w
      self.area:addGameObject('Projectile',
        self.x - d * math.cos(self.r), self.y - d * math.sin(self.r),
        {r = self.r, mine = true, attack = self.attack})
    end
  end)

  -- change attack periodically
  self.timer:every('change_attack_periodically', 10, function()
    if self.change_attack_periodically then
      self:setAttack(table.random(attack_names))
      self.area:addGameObject('InfoText',
        self.x + table.random({-1, 1}) * self.w, self.y + table.random({-1, 1}) * self.h,
        {color = attacks[self.attack].color, text = self.attack .. '!'})
    end
  end)
end

function Player:setShip()
  if self.ship == 'Crusader' then
    self.max_boost = 80
    self.boost_effectiveness_multiplier = 2
    self.mvspd_multiplier = Stat(0.6)
    self.turn_rate_multiplier = 0.5
    self.aspd_multiplier = Stat(0.66)
    self.pspd_multiplier = Stat(1.5)
    self.max_hp = 150
    self.size_multiplier = 1.5

  elseif self.ship == 'Rogue' then
    self.max_boost = 120
    self.boost_recharge_rate_multiplier = 1.5
    self.mvspd_multiplier = Stat(1.3)
    self.max_ammo = 120
    self.aspd_multiplier = Stat(1.25)
    self.max_hp = 80
    self.invulnerability_time_multiplier = 0.5
    self.size_multiplier = 0.9

  elseif self.ship == 'Bit Hunter' then
    self.mvspd_multiplier = Stat(0.9)
    self.turn_rate_multiplier = 0.9
    self.max_ammo = 80
    self.aspd_multiplier = Stat(0.8)
    self.pspd_multiplier = Stat(0.9)
    self.invulnerability_time_multiplier = 1.5
    self.size_multiplier = 1.1
    self.luck_multiplier = 1.5
    self.resource_spawn_rate_multiplier = 1.5
    self.enemy_spawn_rate_multiplier = 1.5
    self.cycle_speed_multiplier = Stat(1.25)

  elseif self.ship == 'Sentinel' then
    self.energy_shield = true

  elseif self.ship == 'Striker' then
    self.max_ammo = 120
    self.aspd_multiplier = Stat(2)
    self.pspd_multiplier = Stat(1.25)
    self.max_hp = 50
    self.additional_barrage_projectiles = 8
    self.on_kill_barrage_chance = 10
    self.on_cycle_barrage_chance = 10
    self.barrage_nova = true

  elseif self.ship == 'Nuclear' then
    self.max_boost = 80
    self.turn_rate_multiplier = 0.8
    self.max_ammo = 80
    self.aspd_multiplier = Stat(0.85)
    self.max_hp = 80
    self.invulnerability_time_multiplier = 2
    self.luck_multiplier = 1.5
    self.resource_spawn_rate_multiplier = 1.5
    self.enemy_spawn_rate_multiplier = 1.5
    self.cycle_speed_multiplier = Stat(1.5)
    self.on_cycle_explode_chance = 10

  elseif self.ship == 'Cycler' then
    self.cycle_speed_multiplier = Stat(2)

  elseif self.ship == 'Wisp' then
    self.max_boost = 50
    self.mvspd_multiplier = Stat(0.5)
    self.turn_rate_multiplier = 0.5
    self.aspd_multiplier = Stat(0.66)
    self.pspd_multiplier = Stat(0.5)
    self.max_hp = 50
    self.size_multiplier = 0.75
    self.resource_spawn_rate_multiplier = 1.5
    self.enemy_spawn_rate_multiplier = 1.5
    self.shield_projectile_chance = 100
    self.projectile_duration_multiplier = 1.5
  end
end

function Player:setStats()

  if self.no_boost then self.max_boost = 0 end
  if self.half_ammo then self.max_ammo = self.max_ammo / 2 end
  if self.half_hp then self.max_hp = self.max_hp / 2 end

  -- Conversions
  if self.mvspd_to_hp > 0 then
    if self.mvspd_multiplier.value < 1 then
      self.flat_hp = self.flat_hp + self.mvspd_multiplier.value * self.mvspd_to_hp
    end
  end

  -- Basic Stats
  self.max_hp = (self.max_hp + self.flat_hp) * self.hp_multiplier
  self.max_ammo = self.max_ammo * self.ammo_multiplier
  self.max_boost = (self.max_boost + self.flat_boost) * self.boost_multiplier
  self.hp = self.max_hp
  self.ammo = self.max_ammo
  self.boost = self.max_boost

  -- Starting attack
  local starting_attacks = {
    self.start_with_double and 'Double',
    self.start_with_triple and 'Triple',
    self.start_with_rapid and 'Rapid',
    self.start_with_spread and 'Spread',
    self.start_with_back and 'Back',
    self.start_with_side and 'Side',
    self.start_with_homing and 'Homing',
    self.start_with_blast and 'Blast',
    self.start_with_spin and 'Spin',
    self.start_with_lightning and 'Lightning',
    self.start_with_flame and 'Flame',
    self.start_with_twosplit and '2Split',
    self.start_with_foursplit and '4Split',
    self.start_with_explode and 'Explode',
    self.start_with_laser and 'Laser',
  }
  starting_attacks = fn.select(starting_attacks, function(v, k) return v end)
  if #starting_attacks > 0 then self:setAttack(table.random(starting_attacks)) end

  -- Energy shield
  if self.energy_shield then
    self.invulnerability_time_multiplier = self.invulnerability_time_multiplier / 2
  end
end

function Player:setChances()
  self.chances = {}
  for k, v in pairs(self) do
    if k:find('_chance') and type(v) == 'number' then
      if k:find('_on_kill') and v > 0 then
        self.chances[k] = chanceList(
          {true, math.ceil((v + self.added_chance_to_all_on_kill_events) * self.luck_multiplier)},
          {false, 100 - math.ceil((v + self.added_chance_to_all_on_kill_events) * self.luck_multiplier)})
      else
        self.chances[k] = chanceList(
          {true, math.ceil(v * self.luck_multiplier)},
          {false, 100 - math.ceil(v * self.luck_multiplier)})
      end
    end
  end
end

function Player:update(dt)
  Player.super.update(self, dt)

  self.w = self.base_w * self.size_multiplier
  self.h = self.base_h * self.size_multiplier

  -- conversion management
  if self.ammo_to_aspd > 0 then
    self.aspd_multiplier:increase((self.ammo_to_aspd / 100) * (self.max_ammo - 100))
  end

  if self.mvspd_to_aspd > 0 then
    self.aspd_multiplier:increase((self.mvspd_to_aspd / 100) * (self.mvspd_multiplier.value * 100 - 100))
  end

  if self.mvspd_to_pspd > 0 then
    self.aspd_multiplier:increase((self.mvspd_to_pspd / 100) * (self.mvspd_multiplier.value * 100 - 100))
  end

  -- stat multiplier management
  if self.inside_haste_area then self.aspd_multiplier:increase(100) end
  if self.aspd_boosting then self.aspd_multiplier:increase(100) end

  if self.mvspd_boosting then self.mvspd_multiplier:increase(50) end

  if self.pspd_boosting then self.pspd_multiplier:increase(100) end
  if self.pspd_inhibiting then self.pspd_multiplier:decrease(50) end
  ---- assume these 2 will never ocur simultaneously

  if self.cycle_boosting then self.cycle_speed_multiplier:increase(200) end

  self.aspd_multiplier:update(dt)
  self.mvspd_multiplier:update(dt)
  self.pspd_multiplier:update(dt)
  self.cycle_speed_multiplier:update(dt)

  -- movement
  if input:down('left') then self.r = self.r - self.rv * dt * self.turn_rate_multiplier end
  if input:down('right') then self.r = self.r + self.rv * dt * self.turn_rate_multiplier end

  -- velocity management
  self.v = math.min(self.v + self.a * dt, self.max_v)
  self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))

  -- collectable behavior
  if self.collider:enter('Collectable') then
    local collision_data = self.collider:getEnterCollisionData('Collectable')
    local object = collision_data.collider:getObject()
    if object:is(Ammo) then
      object:die()
      self:addAmmo(5)
      self:onAmmoPickup()

    elseif object:is(HP) then
      object:die()
      self:setHP(25)
      self:onHPPickup()

    elseif object:is(SP) then
      object:die()
      local increment = self.chances.gain_double_sp_chance:next() and 2 or 1
      skill_points = skill_points + increment
      current_room.score = current_room.score + 250
      self:onSPPickup()

    elseif object:is(Boost) then
      self:addBoost(25)
      object:die()

    elseif object:is(Attack) then
      object:die()
      self:setAttack(object.attack)
      current_room.score  = current_room.score + 500
    end
  elseif self.collider:enter('Enemy') then
    if self.invincible and self.deals_damage_while_invulnerable then
      local collision_data = self.collider:getEnterCollisionData('Enemy')
      local object = collision_data.collider:getObject()
      if object then object:hit(100) end
    else
      self:hit(30)
    end
  end

  -- cycle management
  self.cycle_timer = self.cycle_timer + dt * self.cycle_speed_multiplier.value
  if self.cycle_timer > self.cycle_cooldown then
    self.cycle_timer = 0
    self:cycle()
  end
  
  -- boost management
  self.max_v = self.base_max_v * self.mvspd_multiplier.value

  ---- prevent boost depletion rate from being affected by boost_recharge_rate_multiplier
  if self.boosting then
    self.boost = math.min(self.boost + 10 * dt, self.max_boost)
  else
    self.boost = math.min(self.boost + 10 * dt * self.boost_recharge_rate_multiplier, self.max_boost)
  end

  self.boost_timer = self.boost_timer + dt
  if self.boost_timer > self.boost_cooldown then self.can_boost = true end
  self.boosting = false

  if input:pressed('up') and self.boost > 1 and self.can_boost then self:onBoostStart() end
  if input:released('up') then self:onBoostEnd() end
  if input:down('up') and self.boost > 1 and self.can_boost then
    self.boosting = true
    self.max_v = 1.5 * self.base_max_v * self.mvspd_multiplier.value * self.boost_effectiveness_multiplier
    self.boost = self.boost - 50 * dt
    if self.boost <= 1 then
      self.boosting = false
      self.can_boost = false
      self.boost_timer = 0
      self:onBoostEnd()
    end
  end
  if input:pressed('down') and self.boost > 1 and self.can_boost then self:onBoostStart() end
  if input:released('down') then self:onBoostEnd() end
  if input:down('down') and self.boost > 1 and self.can_boost then
    self.boosting = true
    self.max_v = 0.5 * self.base_max_v / self.boost_effectiveness_multiplier
    self.boost = self.boost - 50 * dt
    if self.boost <= 1 then
      self.boosting = false
      self.can_boost = false
      self.boost_timer = 0
      self:onBoostEnd()
    end
  end

  self.trail_color = skill_point_color
  if self.boosting then self.trail_color = boost_color end

  -- death if player hits the edges
  if self.x < 0 or self.y < 0 or self.x > gw or self.y > gh then
    self.hp = 0
    self:die()
  end

  -- shooting management
  self.shoot_timer = self.shoot_timer + dt
  if self.shoot_timer > self.shoot_cooldown / self.aspd_multiplier.value then
    self.shoot_timer = 0
    self:shoot()
  end
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

  local mods = {
    shield = self.chances.shield_projectile_chance:next()
  }

  local attack_ammo = self.infinite_ammo and 0 or attacks[self.attack].ammo

  -- TODO: integrate merging of mods table with opts table for all attacks
  if self.attack == 'Neutral' then
    self.ammo = self.ammo - attack_ammo * self.ammo_consumption_multiplier
    self.area:addGameObject('Projectile',
      self.x + 1.5 * d * math.cos(self.r),
      self.y + 1.5 * d * math.sin(self.r),
      table.merge({r = self.r, attack = self.attack}, mods))

  elseif self.attack == 'Double' then
    self.ammo = self.ammo - attack_ammo * self.ammo_consumption_multiplier
    self.area:addGameObject('Projectile',
      self.x + 1.5 * d * math.cos(self.r + math.pi / 12),
      self.y + 1.5 * d * math.sin(self.r + math.pi / 12),
      table.merge({r = self.r + math.pi/12, attack = self.attack}, mods))
    self.area:addGameObject('Projectile',
      self.x + 1.5 * d * math.cos(self.r - math.pi / 12),
      self.y + 1.5 * d * math.sin(self.r - math.pi / 12),
      table.merge({r = self.r - math.pi/12, attack = self.attack}, mods))

  elseif self.attack == 'Triple' then
    self.ammo = self.ammo - attack_ammo * self.ammo_consumption_multiplier
    self.area:addGameObject('Projectile',
      self.x + 1.5 * d * math.cos(self.r + math.pi / 12),
      self.y + 1.5 * d * math.sin(self.r + math.pi / 12),
      table.merge({r = self.r + math.pi/12, attack = self.attack}, mods))
    self.area:addGameObject('Projectile',
      self.x + 1.5 * d * math.cos(self.r),
      self.y + 1.5 * d * math.sin(self.r),
      table.merge({r = self.r, attack = self.attack}, mods))
    self.area:addGameObject('Projectile',
      self.x + 1.5 * d * math.cos(self.r - math.pi / 12),
      self.y + 1.5 * d * math.sin(self.r - math.pi / 12),
      table.merge({r = self.r - math.pi/12, attack = self.attack}, mods))

  elseif self.attack == 'Rapid' then
    self.ammo = self.ammo - attack_ammo * self.ammo_consumption_multiplier
    self.area:addGameObject('Projectile',
      self.x + 1.5 * d * math.cos(self.r), self.y + 1.5 * d * math.sin(self.r),
      table.merge({r = self.r, attack = self.attack}, mods))

  elseif self.attack == 'Spread' then
    self.ammo = self.ammo - attack_ammo * self.ammo_consumption_multiplier
    self.area:addGameObject('Projectile',
      self.x + 1.5 * d * math.cos(self.r), self.y + 1.5 * d * math.sin(self.r),
      table.merge({r = self.r + random(-math.pi / 8, math.pi / 8), attack = self.attack}, mods))

  elseif self.attack == 'Back' then
    self.ammo = self.ammo - attack_ammo * self.ammo_consumption_multiplier
    self.area:addGameObject('Projectile',
      self.x + 1.5 * d * math.cos(self.r), self.y + 1.5 * d * math.sin(self.r),
      table.merge({r = self.r, attack = self.attack}, mods))
    self.area:addGameObject('Projectile',
      self.x - 1.5 * d * math.cos(self.r), self.y - 1.5 * d * math.sin(self.r),
      table.merge({r = self.r + math.pi, attack = self.attack}, mods))

  elseif self.attack == 'Side' then
    self.ammo = self.ammo - attack_ammo * self.ammo_consumption_multiplier
    self.area:addGameObject('Projectile',
      self.x + 1.5 * d * math.cos(self.r + math.pi / 2),
      self.y + 1.5 * d * math.sin(self.r + math.pi / 2),
      table.merge({r = self.r + math.pi / 2, attack = self.attack}, mods))
    self.area:addGameObject('Projectile',
      self.x + 1.5 * d * math.cos(self.r), self.y + 1.5 * d * math.sin(self.r),
      table.merge({r = self.r, attack = self.attack}, mods))
    self.area:addGameObject('Projectile',
      self.x + 1.5 * d * math.cos(self.r - math.pi / 2),
      self.y + 1.5 * d * math.sin(self.r - math.pi / 2),
      table.merge({r = self.r - math.pi / 2, attack = self.attack}, mods))

  elseif self.attack == 'Homing' then
    self.ammo = self.ammo - attack_ammo * self.ammo_consumption_multiplier
    self.area:addGameObject('Projectile',
      self.x + 1.5 * d * math.cos(self.r), self.y + 1.5 * d * math.sin(self.r),
      table.merge({r = self.r, attack = self.attack}, mods))
  
  elseif self.attack == 'Blast' then
    self.ammo = self.ammo - attack_ammo * self.ammo_consumption_multiplier
    for i = 1, 12 do
      local random_angle = random(-math.pi / 6, math.pi / 6)
      self.area:addGameObject('Projectile',
        self.x + 1.5 * d * math.cos(self.r + random_angle),
        self.y + 1.5 * d * math.sin(self.r + random_angle),
        table.merge({r = self.r + random_angle, attack = self.attack, v = random(500, 600)}, mods))
    end
    camera:shake(4, 60, 0.4)

  elseif self.attack == 'Spin' then
    local opts = {r = self.r, attack = self.attack}
    if self.fixed_spin_attack_direction then
      opts = table.merge(opts, {spin_direction = self.spin_direction})
    end
    self.ammo = self.ammo - attack_ammo * self.ammo_consumption_multiplier
    self.area:addGameObject('Projectile',
      self.x + 1.5 * d * math.cos(self.r), self.y + 1.5 * d * math.sin(self.r),
      table.merge(opts, mods))

  elseif self.attack == 'Flame' then
    self.ammo = self.ammo - attack_ammo * self.ammo_consumption_multiplier
    local random_angle = random(-math.pi / 16, math.pi / 16)
    self.area:addGameObject('Projectile',
      self.x + 1.5 * d * math.cos(self.r + random_angle),
      self.y + 1.5 * d * math.sin(self.r + random_angle),
      table.merge({r = self.r + random_angle, attack = self.attack}, mods))

  elseif self.attack == 'Bounce' then
    self.ammo = self.ammo - attack_ammo * self.ammo_consumption_multiplier
    self.area:addGameObject('Projectile',
      self.x + 1.5 * d * math.cos(self.r), self.y + 1.5 * d * math.sin(self.r),
      table.merge({r = self.r, attack = self.attack, bounce = 4 + self.additional_bounce_projectiles}, mods))

  elseif self.attack == '2Split' then
    self.ammo = self.ammo - attack_ammo * self.ammo_consumption_multiplier
    self.area:addGameObject('Projectile',
      self.x + 1.5 * d * math.cos(self.r), self.y + 1.5 * d * math.sin(self.r),
      table.merge({r = self.r, attack = self.attack}, mods))

  elseif self.attack == '4Split' then
    self.ammo = self.ammo - attack_ammo * self.ammo_consumption_multiplier
    self.area:addGameObject('Projectile',
      self.x + 1.5 * d * math.cos(self.r), self.y + 1.5 * d * math.sin(self.r),
      table.merge({r = self.r, attack = self.attack}, mods))

  elseif self.attack == 'Explode' then
    self.ammo = self.ammo - attack_ammo * self.ammo_consumption_multiplier
    self.area:addGameObject('Projectile',
      self.x + 1.5 * d * math.cos(self.r), self.y + 1.5 * d * math.sin(self.r),
      table.merge({r = self.r, attack = self.attack}, mods))

  elseif self.attack == 'Laser' then
    local duration = 0.2
    self.ammo = self.ammo - attack_ammo * self.ammo_consumption_multiplier
    self.area:addGameObject('LaserShootEffect', self.x + d * math.cos(self.r),
      self.y + d * math.sin(self.r),
      {player = self, d = d, w = 18, duration = duration})
    self.area:addGameObject('LaserLine',
      self.x + 1.5 * d * math.cos(self.r), self.y + 1.5 * d * math.sin(self.r),
      table.merge({mw = 8 * self.laser_width_multiplier, player = self, d = d, attack = self.attack, duration = duration}, mods))

  elseif self.attack == 'Lightning' then
    local aoe_offset_x = self.increased_lightning_angle and 24 * math.cos(self.r) or 0
    local aoe_offset_y = self.increased_lightning_angle and 24 * math.sin(self.r) or 0
    local aoe_radius = self.area_multiplier * 64
    local x1, y1 = self.x + d * math.cos(self.r), self.y + d * math.sin(self.r)
    local cx, cy = x1 + aoe_offset_x, y1 + aoe_offset_y

    -- Find closest enemy
    local nearby_enemies = self.area:getGameObjects(function(e)
      for _, enemy in ipairs(enemies) do
        if (e:is(EnemyProjectile) or e:is(_G[enemy])) and (distance(e.x, e.y, cx, cy) < aoe_radius) then
          return true
        end
      end
    end)

    table.sort(nearby_enemies, function(a, b)
      return distance(a.x, a.y, cx, cy) < distance(b.x, b.y, cx, cy)
    end)

    local num_enemies_to_attack = self.additional_lightning_bolt and 2 or 1
    local closest_enemies = fn.first(nearby_enemies, num_enemies_to_attack)

    for i, closest_enemy in ipairs(closest_enemies) do
      -- Attack closest enemy(ies)
      self.timer:after((i - 1) * 0.05, function()
        if closest_enemy then
          self.ammo = self.ammo - attack_ammo * self.ammo_consumption_multiplier
          
          if closest_enemy.hit then closest_enemy:hit()
          else closest_enemy:die() end

          local x2, y2 = closest_enemy.x, closest_enemy.y
          self.area:addGameObject('LightningLine', 0, 0, {x1 = x1, y1 = y1, x2 = x2, y2 = y2})
          for i = 1, love.math.random(4, 8) do
            self.area:addGameObject('ExplodeParticle', x1, y1, {color = table.random({default_color, boost_color})})
          end
          for i = 1, love.math.random(4, 8) do
            self.area:addGameObject('ExplodeParticle', x2, y2, {color = table.random({default_color, boost_color})})
          end
        end
      end)
    end
  end

  if self.chances.attack_twice_chance:next() then
    self.timer:after(self.shoot_cooldown / 2, function() 
      self:shoot()
    end)
  end

  -- revert to Neutral attack if out of ammo
  if self.ammo <= 0 then
    self:setAttack('Neutral')
    self.ammo = self.max_ammo
  end
end

function Player:cycle()
  self.area:addGameObject('TickEffect', self.x, self.y, {parent = self})
  self:onCycle()
end

function Player:onCycle()
  if self.chances.on_cycle_spawn_sp_chance:next() then
    self.area:addGameObject('SP')
    self.area:addGameObject('InfoText', self.x, self.y, {text = 'SP Spawn!', color = skill_point_color})
  end
  if self.chances.on_cycle_spawn_hp_chance:next() then
    self.area:addGameObject('HP')
    self.area:addGameObject('InfoText', self.x, self.y, {text = 'HP Spawn!', color = hp_color})
  end
  if self.chances.on_cycle_regain_hp_chance:next() then
    self:setHP(25)
    self.area:addGameObject('InfoText', self.x, self.y, {text = 'HP Regain!', color = hp_color})
  end
  if self.chances.on_cycle_regain_full_ammo_chance:next() then
    self.ammo = self.max_ammo
    self.area:addGameObject('InfoText', self.x, self.y, {text = 'Max Ammo!', color = ammo_color})
  end
  if self.chances.on_cycle_change_attack_chance:next() then
    -- self.ammo = self.max_ammo
    self.attack = table.random({'Double', 'Triple', 'Rapid', 'Spread', 'Back', 'Side', 'Homing'})
    self.area:addGameObject('InfoText', self.x, self.y, {text = self.attack .. '!'})
  end
  if self.chances.on_cycle_spawn_haste_area_chance:next() then
    self.area:addGameObject('HasteArea', self.x, self.y)
    self.area:addGameObject('InfoText', self.x, self.y, {text = 'Haste Area!'})
  end
  if self.chances.on_cycle_barrage_chance:next() then
    for i = 1, 8 + self.additional_barrage_projectiles do
      self.timer:after((i - 1) * 0.05, function()
        local random_angle = self.barrage_nova and random(0, 2 * math.pi) or random(-math.pi / 8, math.pi / 8)
        local d = 2.2 * self.w
        self.area:addGameObject('Projectile',
          self.x + d * math.cos(self.r + random_angle),
          self.y + d * math.sin(self.r + random_angle),
          {r = self.r + random_angle, attack = self.attack})
      end)
    end
    self.area:addGameObject('InfoText', self.x, self.y, {text = 'Barrage!'})
  end
  if self.chances.on_cycle_launch_homing_projectile_chance:next() then
    local d = 1.2 * self.w
    for i = 1, 1 + self.additional_homing_projectiles do
      self.area:addGameObject('Projectile',
        self.x + d * math.cos(self.r), self.y + d * math.sin(self.r),
        {r = self.r, attack = 'Homing'})
    end
    self.area:addGameObject('InfoText', self.x, self.y, {text = 'Homing Projectile!'})
  end
  if self.chances.on_cycle_mvspd_boost_chance:next() then
    self.mvspd_boosting = true
    self.timer:after(4, function() self.mvspd_boosting = false end)
    self.area:addGameObject('InfoText', self.x, self.y, {text = 'MVSPD Boost!', color = boost_color})
  end
  if self.chances.on_cycle_pspd_boost_chance:next() then
    self.pspd_boosting = true
    self.timer:after(4, function() self.pspd_boosting = false end)
    self.area:addGameObject('InfoText', self.x, self.y, {text = 'PSPD Boost!'})
  end
   -- assume this will never happen with 'boost pspd' simultaneously
  if self.chances.on_cycle_pspd_inhibit_chance:next() then
    self.pspd_inhibiting = true
    self.timer:after(4, function() self.pspd_inhibiting = false end)
    self.area:addGameObject('InfoText', self.x, self.y, {text = 'PSPD Inhibit!'})
  end
  if self.chances.on_cycle_explode_chance:next() then
    local d = 3.5 * self.w
    local coeffs = {1, 1, 1, -1, -1, -1, -1, 1}
    for i = 1, #coeffs, 2 do
      self.timer:after(table.random({0, 0.01, 0.02}), function()
        self.area:addGameObject('Explosion',
          self.x + coeffs[i] * d, self.y + coeffs[i + 1] * d, {w2 = d * 3})
      end)
    end
  end
end

function Player:onSPPickup()
  if self.chances.on_sp_pickup_regain_hp_chance:next() then
    self:setHP(25)
    self.area:addGameObject('InfoText', self.x, self.y, {text = 'HP Regain!', color = hp_color})
  end
  if self.chances.on_sp_pickup_spawn_haste_area_chance:next() then
    self.area:addGameObject('HasteArea', self.x, self.y)
    self.area:addGameObject('InfoText', self.x, self.y, {text = 'Haste Area!'})
  end
end

function Player:addAmmo(amount)
  self.ammo = math.min(self.ammo + amount + self.ammo_gain, self.max_ammo)
  current_room.score = current_room.score + 50
end

function Player:onAmmoPickup()
  if self.chances.on_ammo_pickup_launch_homing_projectile_chance:next() then
    local d = 1.2 * self.w
    for i = 1, 1 + self.additional_homing_projectiles do
      self.area:addGameObject('Projectile',
        self.x + d * math.cos(self.r), self.y + d * math.sin(self.r),
        {r = self.r, attack = 'Homing'})
    end
    self.area:addGameObject('InfoText', self.x, self.y, {text = 'Homing Projectile!'})
  end

  if self.chances.on_ammo_pickup_regain_hp_chance:next() then
    self:setHP(25)
    self.area:addGameObject('InfoText', self.x, self.y, {text = 'HP Regain!', color = hp_color})
  end
end

function Player:addBoost(amount)
  self.boost = math.min(self.boost + amount, self.max_boost)
  current_room.score = current_room.score + 150
end

function Player:onBoostStart()
  self.timer:every('while_boosting_launch_homing_projectile_chance', 0.2, function()
    if self.chances.while_boosting_launch_homing_projectile_chance:next() then
      local d = 1.2 * self.w
      for i = 1, 1 + self.additional_homing_projectiles do
        self.area:addGameObject('Projectile',
          self.x + d * math.cos(self.r), self.y + d * math.sin(self.r),
          {r = self.r, attack = 'Homing'})
      end
      self.area:addGameObject('InfoText', self.x, self.y, {text = 'Homing Projectile!'})
    end
  end)
  if self.while_boosting_increased_cycle_speed then
    self.cycle_boosting = true
    self.area:addGameObject('InfoText', self.x, self.y, {text = 'Cycle Speed Increased!'})
  end
  if self.while_boosting_invulnerability then
    self.invincible = true
    self.area:addGameObject('InfoText', self.x, self.y, {text = 'Invulnerable!'})
  end
  if self.while_boosting_increased_luck then
    self.luck_boosting = true
    self.luck_multiplier = self.luck_multiplier * 2
    self:setChances()
  end
end

function Player:onBoostEnd()
  self.timer:cancel('while_boosting_launch_homing_projectile_chance')

  if self.while_boosting_increased_cycle_speed and self.cycle_boosting then
    self.cycle_speed_multiplier:decrease(50)
    self.cycle_boosting = false
  end
  if self.while_boosting_invulnerability then
    self.invincible = false
  end
  if self.while_boosting_increased_luck and self.luck_boosting then
    self.luck_boosting = false
    self.luck_multiplier = self.luck_multiplier / 2
    self:setChances()
  end
end

function Player:setHP(amount)
  self.hp = math.min(math.max(self.hp + amount, 0), self.max_hp)
  if self.hp <= 0 then self:die() end
end

function Player:onHPPickup()
  if self.chances.on_hp_pickup_spawn_haste_area_chance:next() then
    self.area:addGameObject('HasteArea', self.x, self.y)
    self.area:addGameObject('InfoText', self.x, self.y, {text = 'Haste Area!'})
  end

  if self.convert_hp_to_sp_if_hp_full and self.hp == self.max_hp then
    skill_points = skill_points + 3
    self.area:addGameObject('InfoText', self.x, self.y, {text = 'HP converted!'})
  end

  if self.refill_ammo_if_hp_full and self.hp == self.max_hp then
    self.ammo = self.max_ammo
  end

  if self.refill_boost_if_hp_full and self.hp == self.max_hp then
    self.boost = self.max_boost
  end
end

function Player:setAttack(attack)
  self.attack = attack
  self.shoot_cooldown = attacks[attack].cooldown
  self.ammo = self.max_ammo
end

function Player:onKill(enemy)
  if self.chances.on_kill_barrage_chance:next() then
    for i = 1, 8 + self.additional_barrage_projectiles do
      self.timer:after((i - 1) * 0.05, function()
        local random_angle = self.barrage_nova and random(0, 2 * math.pi) or random(-math.pi / 8, math.pi / 8)
        local d = 2.2 * self.w
        self.area:addGameObject('Projectile',
          self.x + d * math.cos(self.r + random_angle),
          self.y + d * math.sin(self.r + random_angle),
          {r = self.r + random_angle, attack = self.attack})
      end)
    end
    self.area:addGameObject('InfoText', self.x, self.y, {text = 'Barrage!'})
  end
  if self.chances.on_kill_regain_ammo_chance:next() then
    self:addAmmo(20)
    self.area:addGameObject('InfoText', self.x, self.y, {text = 'Ammo Regain!', color = ammo_color})
  end
  if self.chances.on_kill_launch_homing_projectile_chance:next() then
    local d = 1.2 * self.w
    for i = 1, 1 + self.additional_homing_projectiles do
      self.area:addGameObject('Projectile',
        self.x + d * math.cos(self.r), self.y + d * math.sin(self.r),
        {r = self.r, attack = 'Homing'})
    end
    self.area:addGameObject('InfoText', self.x, self.y, {text = 'Homing Projectile!'})
  end
  if self.chances.on_kill_regain_boost_chance:next() then
    self.boost = math.min(self.boost + 40, self.max_boost)
    self.area:addGameObject('InfoText', self.x, self.y, {text = 'Boost Regain!', color = boost_color})
  end
  if self.chances.on_kill_spawn_boost_chance:next() then
    self.area:addGameObject('Boost')
    self.area:addGameObject('InfoText', self.x, self.y, {text = 'Boost Spawn!', color = boost_color})
  end
  if self.chances.on_kill_gain_aspd_boost_chance:next() then
    self.aspd_boosting = true
    self.timer:after(4, function() self.aspd_boosting = false end)
    self.area:addGameObject('InfoText', self.x, self.y, {text = 'ASPD Boost!', color = ammo_color})
  end
  if self.chances.drop_double_ammo_chance:next() then
    self.area:addGameObject('Ammo', enemy.x, enemy.y)
    self.area:addGameObject('InfoText', self.x, self.y, {text = 'Double Ammo!', color = ammo_color})
  end
end

function Player:hit(damage)
  if self.invincible then return end

  local damage = damage or 10

  if self.energy_shield then
    damage = damage * 2
    self.timer:after('es_cooldown', self.energy_shield_recharge_cooldown * self.energy_shield_recharge_cooldown_multiplier, function()
      self.timer:every('es_amount', 0.25, function()
        self:setHP(self.energy_shield_recharge_amount * self.energy_shield_recharge_amount_multiplier)
      end)
    end)
  end

  self:setHP(-damage)
  for i = 1, love.math.random(4, 8) do
    self.area:addGameObject('ExplodeParticle', self.x, self.y)
  end

  if damage >= 30 then
    self.invincible = true
    self.invisible = true
    self.timer:every(0.04, function() self.invisible = not self.invisible end, 50 * self.invulnerability_time_multiplier)
    self.timer:after(2 * self.invulnerability_time_multiplier, function() self.invincible = false end)
    self.timer:after(2 * self.invulnerability_time_multiplier + 0.04, function() self.invisible = false end)
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

  if self.gain_sp_on_death then skill_points = skill_points + 20 end

  current_room:finish()
end

function Player:destroy()
  Player.super.destroy(self)
end