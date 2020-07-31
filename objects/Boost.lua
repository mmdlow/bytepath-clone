Boost = RhombusCollectable:extend()

function Boost:new(area, x, y, opts)
  Boost.super.new(self, area, x, y, opts)
  self.main_color = boost_color
  self.die_text = '+BOOST'
end