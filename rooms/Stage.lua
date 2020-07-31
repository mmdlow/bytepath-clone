Stage = Object:extend()

function Stage:new()
  self.area = Area(self)
  self.area:addPhysicsWorld()
  self.area.world:addCollisionClass('Player')
  self.area.world:addCollisionClass('Projectile', {ignores = {'Projectile'}})
  self.area.world:addCollisionClass('Collectable', {ignores= {'Projectile', 'Collectable'}})
  
  self.main_canvas = love.graphics.newCanvas(gw, gh)

  self.player = self.area:addGameObject('Player', gw/2, gh/2)

  input:bind('p', function()
    self.area:addGameObject('Ammo', random(0, gw), random(0, gh))
  end) -- generate ammo resource object
  input:bind('o', function()
    self.area:addGameObject('Boost', 0, 0)
  end) -- generate boost resource object
  input:bind('i', function()
    self.area:addGameObject('HP', 0, 0)
  end) -- generate HP resource object
end

function Stage:update(dt)
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

function Stage:destroy()
  self.area:destroy()
  self.area = nil
  self.player = nil
end