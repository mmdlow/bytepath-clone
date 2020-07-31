SP = RhombusCollectable:extend()

function SP:new(area, x, y, opts)
  SP.super.new(self, area, x, y, opts)
  self.main_color = skill_point_color
  self.die_text = '+1 SP'
end