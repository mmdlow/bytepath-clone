Area = Object:extend()

function Area:new(room)
  self.room = room
  self.game_objects = {}
end

function Area:update(dt)
  --[[
    TODO:
    1.  It's not a good idea to alter the size of a array while
        iterating through it
    2. table.remove() is slow:
    https://stackoverflow.com/questions/12394841/safely-remove-items-from-an-array-table-while-iterating
  --]]
  for i = #self.game_objects, 1, -1 do
    local game_object = self.game_objects[i]
    game_object:update(dt)
    if game_object.dead then table.remove(self.game_objects, i) end
  end
end

function Area:draw()
  for _, game_object in ipairs(self.game_objects) do game_object:draw() end
end

function Area:addGameObject(game_object_type, x, y, opts)
  local opts = opts or {}
  local game_object = _G[game_object_type](self, x or 0, y or 0, opts)
  table.insert(self.game_objects, game_object)
  return game_object
end

function Area:getGameObjects(filter)
  local out = {}
  for _, game_object in ipairs(self.game_objects) do
    if filter(game_object) then
      table.insert(game_object)
    end
  end
  return out
end