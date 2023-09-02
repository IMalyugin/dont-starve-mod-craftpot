local GetInventoryItemAtlas = require "utils/getinventoryitematlas"
local CheckAtlas = require "utils/checkinventoryitematlas"
-- An ugly, yet partially efficient attempt at getting inventory item assets

local QUAGMIRE_PORTS =
{
    tomato = true,
    tomato_cooked = true,
    onion = true,
    onion_cooked = true,
}
local inventoryItemAtlasLookup = {} -- Cache the results
return function(prefab)
<<<<<<< Updated upstream
  local item_tex = prefab .. '.tex'
=======
  local item_tex = QUAGMIRE_PORTS[prefab] and "quagmire_"..prefab..'.tex' or prefab..'.tex'
>>>>>>> Stashed changes
  local atlas = GetInventoryItemAtlas(item_tex)
  local localized_name = STRINGS.NAMES[string.upper(prefab)] or prefab
  local prefabData = Prefabs[prefab]

<<<<<<< Updated upstream
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
=======
  if inventoryItemAtlasLookup[prefab] then -- Use cached result if available
    return item_tex,inventoryItemAtlasLookup[prefab],localized_name
  end

  --Original and Mod with registered 
  if atlas and TheSim:AtlasContains(resolvefilepath(atlas), item_tex) then
    inventoryItemAtlasLookup[prefab] = atlas
    return item_tex,atlas,localized_name
  end 

  --prefabData.assets
  if prefabData then
    for _, asset in ipairs(prefabData.assets) do
      if asset.type == "ATLAS" and asset.file then
        if TheSim:AtlasContains(resolvefilepath(asset.file), item_tex) then
          inventoryItemAtlasLookup[prefab] = asset.file
          return item_tex,asset.file,localized_name
        end
>>>>>>> Stashed changes
      end
    end
    atlas = CheckAtlas(atlas, item_tex)
    if atlas then return item_tex, atlas, localized_name end
  end

  --Maybe we can use this to find mod food atlas
  local mod_atlas = "images/inventoryimages/"..prefab..'.xml'
  if softresolvefilepath(mod_atlas) and TheSim:AtlasContains(resolvefilepath(mod_atlas), item_tex) then
    inventoryItemAtlasLookup[prefab] = mod_atlas
    return item_tex,mod_atlas,localized_name
  end

  --Maybe we can use this to find mod food atlas
  mod_atlas = "images/"..prefab..'.xml'
  if softresolvefilepath(mod_atlas) and TheSim:AtlasContains(resolvefilepath(mod_atlas), item_tex) then
    inventoryItemAtlasLookup[prefab] = mod_atlas
    return item_tex,mod_atlas,localized_name
  end

  -- manually added via mod api
  local registered_image, registered_altas = GetFoodAtlas(prefab)
  item_tex = registered_image or item_tex
  atlas = CheckAtlas(registered_altas, item_tex)
  if atlas then return item_tex, atlas, localized_name end

<<<<<<< Updated upstream
  return nil, nil, localized_name
end
=======
  if atlas and TheSim:AtlasContains(resolvefilepath(atlas), item_tex) then
    inventoryItemAtlasLookup[prefab] = atlas
    return item_tex, atlas, localized_name
  end
  return nil, nil, localized_name
end
>>>>>>> Stashed changes
