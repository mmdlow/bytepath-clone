Object = require 'libraries/classic/classic'
Input = require 'libraries/boipushy/Input'
Timer = require 'libraries/enhanced_timer/EnhancedTimer'
Camera = require 'libraries/hump/camera'
Vector = require 'libraries/hump/vector'
Physics = require 'libraries/windfield'
Draft = require 'libraries/draft/draft'
fn = require 'libraries/Moses/moses'

require 'GameObject'
require 'Director'
require 'utils'
require 'globals'
require 'libraries/utf8'

function love.load()
  time = 0

  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.graphics.setLineStyle('rough')

  loadFonts('resources/fonts')

  local parent_object_files = {}
  recursiveEnumerate('parent_objects', parent_object_files)
  requireFiles(parent_object_files)

  local object_files = {}
  recursiveEnumerate('objects', object_files)
  requireFiles(object_files)

  local room_files = {}
  recursiveEnumerate('rooms', room_files)
  requireFiles(room_files)

  camera = Camera()
  timer = Timer()
  input = Input()
  draft = Draft()

  local default_colors = {default_color, hp_color, ammo_color, boost_color, skill_point_color}
  local negative_colors = getNegativeColors(default_colors)
  all_colors = fn.append(default_colors, negative_colors)

  slow_amount = 1
  flash_frames = nil

  -- Garbage collection
  input:bind('f1', function()
    print('Before collection: ' .. collectgarbage("count") / 1024)
    collectgarbage()
    print('After collection: ' .. collectgarbage("count") / 1024)
    print('Object count: ')
    local counts = type_count()
    for k, v in pairs(counts) do print(k, v) end
    print('-----------------------------------')
  end)
  
  input:bind('left', 'left')
  input:bind('right', 'right')
  input:bind('up', 'up')
  input:bind('down', 'down')
  input:bind('1', '1')
  input:bind('2', '2')
  input:bind('3', '3')
  input:bind('4', '4')
  input:bind('5', '5')
  input:bind('6', '6')
  input:bind('7', '7')

  current_room = nil
  skill_points = 0
  gotoRoom('Stage')

  resize(3)

end

function love.update(dt)
  time = time + dt
  camera:update(dt * slow_amount)
  timer:update(dt * slow_amount)
  if current_room then current_room:update(dt * slow_amount) end
end

function love.draw()
  if current_room then current_room:draw() end

  if flash_frames then
    flash_frames = flash_frames - 1
    if flash_frames == -1 then flash_frames = nil end

    love.graphics.setColor(background_color)
    love.graphics.rectangle('fill', 0, 0, sx * gw, sy * gh)
    love.graphics.setColor(255, 255, 255)
  end
end

function resize(s)
  love.window.setMode(s*gw, s*gh)
  sx, sy = s, s
end

function slow(amount, duration)
  slow_amount = amount
  timer:tween('slow', duration, _G, {slow_amount = 1}, 'in-out-cubic')
end

function flash(frames)
  flash_frames = frames
end

--- Room utils ---

function gotoRoom(room_type, ...)
  if current_room and current_room.destroy then current_room:destroy() end
  current_room = _G[room_type](...)
end

--- Load utils ---

function recursiveEnumerate(folder, file_list)
  local items = love.filesystem.getDirectoryItems(folder)
  for _, item in ipairs(items) do
    local file = folder .. '/' .. item
    if love.filesystem.isFile(file) then
      table.insert(file_list, file)
    elseif love.filesystem.isDirectory(file) then
      recursiveEnumerate(file, file_list)
    end
  end
end

function requireFiles(files)
  for _, file in ipairs(files) do
    local file = file:sub(1, -5) -- Remove '.lua' from end of string
    require(file)
  end
end

function loadFonts(path)
  fonts = {}
  local font_paths = {}
  recursiveEnumerate(path, font_paths)
  for i = 8, 16, 1 do
    for _, font_path in pairs(font_paths) do
      local last_forward_slash_index = font_path:find('/[^/]*$')
      local font_name = font_path:sub(last_forward_slash_index + 1, -5)
      local font = love.graphics.newFont(font_path, i)
      font:setFilter('nearest', 'nearest')
      font_name = font_name .. '_' .. i
      fonts[font_name] = font
    end
  end
end

--- Garbage Collection utils ---

-- Enumerate all Lua objects --
function count_all(f)
  local seen = {}
  local count_table
  count_table = function(t)
    if seen[t] then return end
      f(t)
    seen[t] = true
    for k,v in pairs(t) do
        if type(v) == "table" then
          count_table(v)
        elseif type(v) == "userdata" then
          f(v)
        end
    end
  end
  count_table(_G)
end

-- Count num of objects of each type --
function type_count()
	local counts = {}
	local enumerate = function (o)
		local t = type_name(o)
		counts[t] = (counts[t] or 0) + 1
	end
	count_all(enumerate)
	return counts
end

-- Return name of object's type --
global_type_table = nil
function type_name(o)
	if global_type_table == nil then
		global_type_table = {}
		for k,v in pairs(_G) do
			global_type_table[v] = k
		end
		global_type_table[0] = "table"
	end
	return global_type_table[getmetatable(o) or 0] or "Unknown"
end