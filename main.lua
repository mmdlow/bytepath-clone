Object = require 'libraries/classic/classic'
Input = require 'libraries/boipushy/Input'
Timer = require 'libraries/enhanced_timer/EnhancedTimer'
Camera = require 'libraries/hump/camera'
Physics = require 'libraries/windfield'
fn = require 'libraries/Moses/moses'

require 'GameObject'
require 'utils'

function love.load()
  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.graphics.setLineStyle('rough')

  local object_files = {}
  recursiveEnumerate('objects', object_files)
  requireFiles(object_files)

  local room_files = {}
  recursiveEnumerate('rooms', room_files)
  requireFiles(room_files)

  camera = Camera()
  timer = Timer()
  input = Input()

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
  
  input:bind('f3', function() camera:shake(4, 60, 1) end)
  input:bind('left', 'left')
  input:bind('right', 'right')

  current_room = nil
  gotoRoom('Stage')

  resize(3)

end

function love.update(dt)
  camera:update(dt)
  timer:update(dt)
  if current_room then current_room:update(dt) end
end

function love.draw()
  if current_room then current_room:draw() end
end

function resize(s)
  love.window.setMode(s*gw, s*gh)
  sx, sy = s, s
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