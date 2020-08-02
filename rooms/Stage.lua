Stage = Object:extend()

function Stage:new()
  self.area = Area(self)
  self.area:addPhysicsWorld()
  self.area.world:addCollisionClass('Player')
  self.area.world:addCollisionClass('Enemy', {ignores = {'Player'}})
  self.area.world:addCollisionClass('Projectile', {ignores = {'Projectile'}})
  self.area.world:addCollisionClass('EnemyProjectile',
    {ignores = {'EnemyProjectile', 'Projectile', 'Enemy'}})
  self.area.world:addCollisionClass('Collectable', {ignores= {'Projectile', 'Collectable'}})
  
  self.main_canvas = love.graphics.newCanvas(gw, gh)

  self.player = self.area:addGameObject('Player', gw/2, gh/2)

  self.director = Director(self)

  self.score = 0

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
      -- love.graphics.circle('line', gw/2, gh/2, 50)
      self.area:draw()
    camera:detach()
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