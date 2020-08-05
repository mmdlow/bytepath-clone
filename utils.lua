function UUID()
  local fn = function(x)
    local r = love.math.random(16) - 1
    r = (x == "x") and (r + 1) or (r % 4) + 9
    return ("0123456789abcdef"):sub(r, r)
end
  return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end

function random(min, max)
  local min, max = min or 0, max or 1
  return (min > max and (love.math.random() * (min - max) + max)) or
    (love.math.random() * (max - min) + min)
end

function table.random(t)
  return t[love.math.random(1, #t)]
end

function table.merge(t1, t2)
  local new_table = {}
  for k, v in pairs(t2) do new_table[k] = v end
  for k, v in pairs(t1) do new_table[k] = v end
  return new_table
end

function pushRotate(x, y, r)
  love.graphics.push()
  love.graphics.translate(x, y)
  love.graphics.rotate(r or 0)
  love.graphics.translate(-x, -y)
end

function pushRotateScale(x, y, r, sx, sy)
  love.graphics.push()
  love.graphics.translate(x, y)
  love.graphics.rotate(r or 0)
  love.graphics.scale(sx or 1, sy or sx or 1)
  love.graphics.translate(-x, -y)
end

function getNegativeColors(colors)
  local negative_colors = {}
  for _, color in ipairs(colors) do
    local nc = {}
    for i = 1, #color do nc[i] = 255 - color[i] end
    negative_colors[#negative_colors + 1] = nc
  end
  return negative_colors
end

function createIrregularPolygon(size, point_amount)
  local point_amount = point_amount or 8
  local points = {}
  for i = 1, point_amount do
    local angle_interval = 2 * math.pi / point_amount
    local distance = size + random(-size / 4, size / 4)
    local angle = (i - 1) * angle_interval + random(-angle_interval / 4, angle_interval / 4)
    table.insert(points, distance * math.cos(angle))
    table.insert(points, distance * math.sin(angle))
  end
  return points
end

function distance(x1, y1, x2, y2)
  return math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
end

function chanceList(...)
  return {
    chance_list = {},
    chance_definitions = {...},
    next = function(self)
      if #self.chance_list == 0 then
        for _, chance_definition in ipairs(self.chance_definitions) do
          for i = 1, chance_definition[2] do
            table.insert(self.chance_list, chance_definition[1])
          end
        end
      end
      return table.remove(self.chance_list, love.math.random(1, #self.chance_list))
    end
  }
end