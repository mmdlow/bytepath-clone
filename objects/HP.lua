HP = GameObject:extend()

function HP:new(area, x, y, opts)
  HP.super.new(self, area, x, y, opts)

  local direction = table.random({-1, 1})
  self.x = gw / 2 + direction * (gw / 2 + 48)
  self.y = random(48, gh - 48)

  self.w, self.h = 6, 6
  self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
  self.collider:setObject(self)
  self.collider:setCollisionClass('Collectable')
  self.collider:setFixedRotation(false)
  self.v = -direction * random(20, 40)
  self.collider:setLinearVelocity(self.v, 0)
  self.collider:applyAngularImpulse(random(-24, 24))

  self.cross = {
    5 * self.w / 6, -self.w / 3,
    self.w / 3, -self.w / 3,
    self.w / 3, -5 * self.w / 6, 
    -self.w / 3, -5 * self.w / 6,
    -self.w / 3, -self.w / 3,
    -5 * self.w / 6, -self.w / 3,
    -5 * self.w / 6, self.w / 3,
    -self.w / 3, self.w / 3,
    -self.w / 3, 5 * self.w / 6,
    self.w / 3, 5 * self.w / 6,
    self.w / 3, self.w / 3,
    5 * self.w / 6, self.w / 3
  }
end

function HP:update(dt)
  HP.super.update(self, dt)

  self.collider:setLinearVelocity(self.v, 0)
end

function HP:draw()
  love.graphics.setColor(default_color)
  love.graphics.circle('line', self.x, self.y, 1.5 * self.w)
  love.graphics.setColor(hp_color)
  -- draw cross
  local points = fn.map(self.cross, function(v, k)
    if k % 2 == 1 then
      return self.x + v
    else
      return self.y + v
    end
  end)
  draft:polygon(points, 'fill')
  love.graphics.setColor(default_color)
end

function HP:die()
  self.dead = true
  self.area:addGameObject('HPEffect',
    self.x + table.random({-1, 1}) * self.w, self.y + table.random({-1, 1}) * self.h,
    {color = hp_color, w = self.w, h = self.h, cross = self.cross})
  self.area:addGameObject('InfoText', self.x, self.y,
    {text = '+HP', color = hp_color})
end

function HP:destroy()
  HP.super.destroy(self)
end