SP = RhombusCollectable:extend()

function SP:new(area, x, y, opts)
  SP.super.new(self, area, x, y, opts)
  self.main_color = skill_point_color
  self.die_text = current_room.player.chances.gain_double_sp_chance:next() and 'Double SP!' or '+1 SP'
end