InfoText = GameObject:extend()

function InfoText:new(area, x, y, opts)
  InfoText.super.new(self, area, x, y, opts)

  self.depth = 80
  self.visible = true
  self.font = fonts.m5x7_16
  self.background_colors = {}
  self.foreground_colors = {}
  self.characters = {}
  for i = 1, #self.text do table.insert(self.characters, self.text:utf8sub(i, i)) end

  local default_colors = {default_color, hp_color, ammo_color, boost_color, skill_point_color}
  local negative_colors = getNegativeColors(default_colors)
  self.all_colors = fn.append(default_colors, negative_colors)

  self.timer:after(0.70, function()
    self.timer:every(0.05, function() self.visible = not self.visible end)
    self.timer:after(0.35, function() self.visible = true end)
    self.timer:every(0.035, function()
      -- Every 0.035s, 5% chance for each char to change to another char
      local random_characters = '0123456789!@#$%¨&*()-=+[]^~/;?><.,|abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWYXZ'
      for i, character in ipairs(self.characters) do
        if love.math.random(1, 20) <= 1 then
          local r = love.math.random(1, #random_characters)
          self.characters[i] = random_characters:utf8sub(r, r)
        end

        if love.math.random(1, 10) <= 1 then
          self.background_colors[i] = table.random(self.all_colors)
        else
          self.background_colors[i] = nil
        end

        if love.math.random(1, 10) <= 2 then
          self.foreground_colors[i] = table.random(self.all_colors)
        else
          self.background_colors[i] = nil
        end
      end
    end)
  end)
  self.timer:after(1.10, function() self.dead = true end)
end

function InfoText:update(dt)
  InfoText.super.update(self, dt)
end

function InfoText:draw()
  if not self.visible then return end

  love.graphics.setFont(self.font)
  local width = 0
  for i = 1, #self.characters do
    if i > 1 then
      width = width + self.font:getWidth(self.characters[i - 1])
    end

    if self.background_colors[i] then
      love.graphics.setColor(self.background_colors[i])
      love.graphics.rectangle('fill', self.x + width, self.y - self.font:getHeight() / 2,
        self.font:getWidth(self.characters[i]), self.font:getHeight())
    end

    love.graphics.setColor(self.foreground_colors[i] or self.color or default_color)
    love.graphics.print(self.characters[i], self.x + width, self.y,
      0, 1, 1, 0, self.font:getHeight() / 2)
  end
  love.graphics.setColor(default_color)
end

function InfoText:destroy()
  InfoText.super.destroy(self)
end