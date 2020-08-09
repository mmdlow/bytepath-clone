Stage = Object:extend()

function Stage:new()
  self.area = Area(self)
  self.area:addPhysicsWorld()
  self.area.world:addCollisionClass('Player')
  self.area.world:addCollisionClass('Enemy', {ignores = {'Player'}})
  self.area.world:addCollisionClass('Projectile', {ignores = {'Projectile'}})
  self.area.world:addCollisionClass('EnemyProjectile',
    {ignores = {'EnemyProjectile', 'Projectile', 'Enemy'}})
  self.area.world:addCollisionClass('Collectable', {ignores= {'Projectile', 'Collectable', 'Enemy'}})
  
  self.main_canvas = love.graphics.newCanvas(gw, gh)
  self.player = self.area:addGameObject('Player', gw/2, gh/2)
  self.director = Director(self)
  self.score = 0
  self.font = fonts.m5x7_16

  input:bind('1', function()
    self.area:addGameObject('Ammo', random(0, gw), random(0, gh))
  end) -- generate ammo resource object
  input:bind('2', function()
    self.area:addGameObject('Boost', 0, 0)
  end) -- generate boost resource object
  input:bind('3', function()
    self.area:addGameObject('HP', 0, 0)
  end) -- generate HP resource object
  input:bind('4', function()
    self.area:addGameObject('SP', 0, 0)
  end) -- generate HP resource object
  input:bind('5', function()
    self.area:addGameObject('Attack', 0, 0)
  end) -- generate Attack resource object
  input:bind('6', function()
    self.area:addGameObject('Rock', 0, 0)
  end) -- generate Rock enemy
  input:bind('7', function()
    self.area:addGameObject('Shooter', 0, 0)
  end) -- generate Shooter enemy
end

function Stage:update(dt)
  self.director:update(dt)
  camera.smoother = Camera.smooth.damped(5)
  camera:lockPosition(dt, gw/2, gh/2)

  self.area:update(dt)
end

function Stage:draw()
  love.graphics.setCanvas(self.main_canvas)
  love.graphics.clear()
    camera:attach(0, 0, gw, gh)
    self.area:draw()
    camera:detach()
      
    love.graphics.setFont(self.font)

    -- Score
    love.graphics.setColor(default_color)
    love.graphics.print(self.score, gw - 20, 10, 0, 1, 1,
      math.floor(self.font:getWidth(self.score) / 2), self.font:getHeight() / 2)
    love.graphics.setColor(255, 255, 255)

    -- SP
    love.graphics.setColor(skill_point_color)
    love.graphics.print(skill_points .. 'SP', 20, 10, 0, 1, 1,
      math.floor(self.font:getWidth(skill_points) / 2), self.font:getHeight() / 2)
    love.graphics.setColor(255, 255, 255)

    -- HP
    local hp_ui_color = self.player.energy_shield and default_color or hp_color
    local hp_text = self.player.energy_shield and 'ES' or 'HP'
    local r, g, b = unpack(hp_ui_color)
    local hp, max_hp = self.player.hp, self.player.max_hp
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle('fill', gw / 2 - 52, gh - 16, 48 * (hp / max_hp), 4)
    love.graphics.setColor(r - 32, g - 32, b - 32)
    love.graphics.rectangle('line', gw / 2 - 52, gh - 16, 48, 4)
    love.graphics.print(hp_text, gw / 2 - 52 + 24, gh - 24, 0, 1, 1,
      math.floor(self.font:getWidth(hp_text) / 2), math.floor(self.font:getHeight() / 2))
    love.graphics.print(hp .. '/' .. max_hp, gw / 2 - 52 + 24, gh - 6, 0, 1, 1,
      math.floor(self.font:getWidth(hp .. '/' .. max_hp) / 2), math.floor(self.font:getHeight() / 2))
    
    -- Ammo
    local r, g, b = unpack(ammo_color)
    local ammo, max_ammo = math.max(0, math.ceil(self.player.ammo)), self.player.max_ammo
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle('fill', gw / 2 - 52, 16, 48 * (ammo / max_ammo), 4)
    love.graphics.setColor(r - 32, g - 32, b - 32)
    love.graphics.rectangle('line', gw / 2 - 52, 16, 48, 4)
    love.graphics.print('AMMO', gw / 2 - 52 + 24, 24, 0, 1, 1,
      math.floor(self.font:getWidth('AMMO') / 2), math.floor(self.font:getHeight() / 2))
    if self.player.infinite_ammo then
      love.graphics.print('unlimited', gw / 2 - 52 + 24, 6, 0, 1, 1,
        math.floor(self.font:getWidth('unlimited') / 2), math.floor(self.font:getHeight() / 2))
    else
      love.graphics.print(ammo .. '/' .. max_ammo, gw / 2 - 52 + 24, 6, 0, 1, 1,
        math.floor(self.font:getWidth(ammo .. '/' .. max_ammo) / 2), math.floor(self.font:getHeight() / 2))
    end

    -- Boost
    if not self.player.no_boost then
      local r, g, b = unpack(boost_color)
      local boost, max_boost = math.ceil(self.player.boost), self.player.max_boost
      love.graphics.setColor(r, g, b)
      love.graphics.rectangle('fill', gw / 2 + 4, 16, 48 * (boost / max_boost), 4)
      love.graphics.setColor(r - 32, g - 32, b - 32)
      love.graphics.rectangle('line', gw / 2 + 4, 16, 48, 4)
      love.graphics.print('BOOST', gw / 2 + 4 + 24, 24, 0, 1, 1,
        math.floor(self.font:getWidth('BOOST') / 2), math.floor(self.font:getHeight() / 2))
      love.graphics.print(boost .. '/' .. max_boost, gw / 2 + 4 + 24, 6, 0, 1, 1,
        math.floor(self.font:getWidth(boost .. '/' .. max_boost) / 2), math.floor(self.font:getHeight() / 2))
    end

    -- Cycle
    local r, g, b = unpack(default_color)
    local cycle, max_cycle = self.player.cycle_timer, self.player.cycle_cooldown
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle('fill', gw / 2 + 4, gh - 16, 48 * (cycle / max_cycle), 4)
    love.graphics.setColor(r - 32, g - 32, b - 32)
    love.graphics.rectangle('line', gw / 2 + 4, gh - 16, 48, 4)
    love.graphics.print('CYCLE', gw / 2 + 4 + 24, gh - 24, 0, 1, 1,
      math.floor(self.font:getWidth('CYCLE') / 2), math.floor(self.font:getHeight() / 2))

  love.graphics.setCanvas()

  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setBlendMode('alpha', 'premultiplied')
  love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
  love.graphics.setBlendMode('alpha')
end

function Stage:finish()
  timer:after(1, function()
    gotoRoom('Stage')
  end)
end

function Stage:destroy()
  self.area:destroy()
  self.area = nil
  self.player = nil
end