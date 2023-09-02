local GetInventoryItemAtlas = require "utils/getinventoryitematlas"
local SanitizeAssets = require "utils/sanitizeassets"

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
  local item_tex = QUAGMIRE_PORTS[prefab] and "quagmire_"..prefab..'.tex' or prefab..'.tex'
  local atlas = GetInventoryItemAtlas(item_tex)
  local localized_name = STRINGS.NAMES[string.upper(prefab)] or prefab
  local prefabData = Prefabs[prefab]

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
      end
    end
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
  atlas = registered_altas or atlas

  if atlas and TheSim:AtlasContains(resolvefilepath(atlas), item_tex) then
    inventoryItemAtlasLookup[prefab] = atlas
    return item_tex, atlas, localized_name
  end
  return nil, nil, localized_name
end