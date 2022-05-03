-- define or redefine global variable to store cooking pots
global("COOKINGPOTS")
COOKINGPOTS = COOKINGPOTS or {}

--
-- A public API to register cookpots for mod compatibility
--
global("AddCookingPot")
AddCookingPot = function(cookpotname)
  -- the format is extensible, might support other props in the future, such as name or even slots count
  COOKINGPOTS[cookpotname] = COOKINGPOTS[cookpotname] or {}
end

-- vanilla cooking pots
AddCookingPot('cookpot')
AddCookingPot('portablecookpot')

-- known modded cooking pots
AddCookingPot('deluxpot')
AddCookingPot('medal_cookpot')

