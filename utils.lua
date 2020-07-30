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