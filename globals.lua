default_color     = {222, 222, 222}
background_color  = {16, 16, 16}
ammo_color        = {123, 200, 164}
boost_color       = {76, 195, 217}
hp_color          = {241, 103, 69}
skill_point_color = {255, 198, 93}

attacks = {
  ['Neutral']   = {cooldown = 0.24, ammo = 0, abbreviation = 'N', color = default_color},
  ['Double']    = {cooldown = 0.32, ammo = 2, abbreviation = '2', color = ammo_color},
  ['Triple']    = {cooldown = 0.40, ammo = 3, abbreviation = '3', color = boost_color},
  ['Rapid']     = {cooldown = 0.16, ammo = 1, abbreviation = 'R', color = default_color},
  ['Spread']    = {cooldown = 0.16, ammo = 1, abbreviation = 'RS', color = default_color},
  ['Back']      = {cooldown = 0.32, ammo = 2, abbreviation = 'Ba', color = skill_point_color},
  ['Side']      = {cooldown = 0.32, ammo = 2, abbreviation = 'Si', color = boost_color},
  ['Homing']    = {cooldown = 0.56, ammo = 4, abbreviation = 'H', color = skill_point_color},
  ['Blast']     = {cooldown = 0.64, ammo = 6, abbreviation = 'W', color = default_color},
  ['Spin']      = {cooldown = 0.32, ammo = 2, abbreviation = 'Sp', color = hp_color},
  ['Flame']     = {cooldown = 0.048, ammo = 0.4, abbreviation = 'F', color = skill_point_color},
  ['Bounce']    = {cooldown = 0.32, ammo = 4, abbreviation = 'Bn', color = default_color},
  ['2Split']    = {cooldown = 0.32, ammo = 3, abbreviation = '2S', color = ammo_color},
  ['4Split']    = {cooldown = 0.4, ammo = 4, abbreviation = '4S', color = boost_color},
  ['Lightning'] = {cooldown = 0.2, ammo = 8, abbreviation = 'Li', color = default_color},
  ['Explode']   = {cooldown = 0.6, ammo = 4, abbreviation = 'E', color = hp_color},
  ['Laser']     = {cooldown = 0.8, ammo = 6, abbreviation = 'La', color = hp_color}
}

attack_names = {}
for k, v in pairs(attacks) do table.insert(attack_names, k) end

enemies = {'Shooter', 'Rock', 'BigRock'}