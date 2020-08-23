local SanitizeAssets = require "utils/sanitizeassets"

global("FOODTAGDEFINITIONS")


-- Using FOODTAGDEFINITIONS created as part of Craft Pot api for modders.
return function(foodTag)
  local tagData = FOODTAGDEFINITIONS[foodTag] or {}

  local item_tex = tagData.tex or foodTag..'.tex'
  local atlas = tagData.atlas and resolvefilepath(tagData.atlas) or nil
  local localized_name = STRINGS.NAMES[string.upper(foodTag)] or tagData.name or foodTag

  return SanitizeAssets(item_tex, atlas, localized_name)
  end
