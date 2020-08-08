Explosion = GameObject:extend()

function Explosion:new(area, x, y, opts)
  Explosion.super.new(self, area, x, y, opts)

  self.w = opts.w or 16
  self.depth = 75
  self.damage = 200
  local w = random(48, 56)
  
  self.timer:tween(0.10, self, {w = w}, 'in-quart', function()
    camera:shake(w / 48, 60, (w / 48) * 0.4)
    for i = 1, love.math.random(8, 12) do
      self.area:addGameObject('ExplodeParticle', self.x, self.y, {color = self.color})
    end
    self.timer:tween(0.20, self, {w = 0}, 'in-out-cubic', function() self.dead = true end)
  end)
  
  local nearby_enemies = self.area:getGameObjects(function(e)
    for _, enemy in ipairs(enemies) do
      if e:is(_G[enemy]) and (distance(e.x, e.y, self.x, self.y) < self.w) then
        return true
      end
    end
  end)

  for i, enemy in ipairs(nearby_enemies) do
    self.timer:after((i - 1) * 0.025, function()
      if enemy.hit then enemy:hit(self.damage)
      else enemy:die() end
      if enemy.hp <= 0 then current_room.player:onKill(enemy) end
    end)
  end

  self.color = opts.color or hp_color
  self.current_color = default_color
  self.timer:after(0.1, function()
    self.current_color = self.color
    self.timer:after(0.15, function() self.dead = true end)
  end)
end

function Explosion:update(dt)
  Explosion.super.update(self, dt)
end

function Explosion:draw()
  love.graphics.setColor(self.current_color)
  love.graphics.rectangle('fill', self.x - self.w / 2, self.y - self.w / 2, self.w, self.w)
  love.graphics.setColor(default_color)
end

function Explosion:destroy()
  Explosion.super.destroy(self)
end