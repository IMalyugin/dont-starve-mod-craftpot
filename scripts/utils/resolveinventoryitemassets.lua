local GetInventoryItemAtlas = require "utils/getinventoryitematlas"
local SanitizeAssets = require "utils/sanitizeassets"

-- An ugly, yet partially efficient attempt at getting inventory item assets
return function(prefab)
  local item_tex = prefab..'.tex'
  local atlas = GetInventoryItemAtlas(item_tex)
  local localized_name = STRINGS.NAMES[string.upper(prefab)] or prefab
  local prefabData = Prefabs[prefab]

  if prefabData then
    -- first run we find assets with exact match of prefab name
    if not atlas or not TheSim:AtlasContains(atlas, item_tex) then
      for _, asset in ipairs(prefabData.assets) do
        if asset.type == "INV_IMAGE" then
          item_tex = asset.file..'.tex'
          atlas = GetInventoryItemAtlas(item_tex)
        elseif asset.type == "ATLAS" then
          atlas = asset.file
        end
      end
    end

    -- second run, a special case for migrated items, they are prefixed via `quagmire_`
    if not atlas or not TheSim:AtlasContains(atlas, item_tex) then
      for _, asset in ipairs(Prefabs[prefab].assets) do
        if asset.type == "INV_IMAGE" then
          item_tex = 'quagmire_'..asset.file..'.tex'
          atlas = GetInventoryItemAtlas(item_tex)
        end
      end
    end
  end

  return SanitizeAssets(item_tex, atlas, localized_name)
end
