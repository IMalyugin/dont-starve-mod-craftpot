local GetInventoryItemAtlas = require "utils/getinventoryitematlas"
local CheckAtlas = require "utils/checkinventoryitematlas"
-- An ugly, yet partially efficient attempt at getting inventory item assets
return function(prefab)
  local item_tex = prefab .. '.tex'
  local atlas = GetInventoryItemAtlas(item_tex)
  local localized_name = STRINGS.NAMES[string.upper(prefab)] or prefab
  local prefabData = Prefabs[prefab]

  -- If registered
  atlas = CheckAtlas(atlas, item_tex)
  if atlas then return item_tex, atlas, localized_name end

  -- find in images/inventoryimages/prefab.xml
  atlas = CheckAtlas("images/inventoryimages/" .. prefab .. '.xml', item_tex)
  if atlas then return item_tex, atlas, localized_name end

  -- find in prefabData
  if prefabData then
    -- first run we find assets with exact match of prefab name
    for _, asset in ipairs(prefabData.assets) do
      if asset.type == "INV_IMAGE" then
        item_tex = asset.file .. '.tex'
        atlas = GetInventoryItemAtlas(item_tex)
        if atlas then break end
      elseif asset.type == "ATLAS" then
        atlas = asset.file
        break
      end
    end
    atlas = CheckAtlas(atlas, item_tex)
    if atlas then return item_tex, atlas, localized_name end

    -- second run, a special case for migrated items, they are prefixed via `quagmire_`
    for _, asset in ipairs(Prefabs[prefab].assets) do
      if asset.type == "INV_IMAGE" then
        item_tex = 'quagmire_' .. asset.file .. '.tex'
        atlas = GetInventoryItemAtlas(item_tex)
        if atlas then break end
      end
    end
    atlas = CheckAtlas(atlas, item_tex)
    if atlas then return item_tex, atlas, localized_name end
  end

  -- manually added via mod api
  local registered_image, registered_altas = GetFoodAtlas(prefab)
  item_tex = registered_image or item_tex
  atlas = CheckAtlas(registered_altas, item_tex)
  if atlas then return item_tex, atlas, localized_name end

  return nil, nil, localized_name
end
