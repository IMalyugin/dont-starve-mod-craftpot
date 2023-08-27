global("RegisterFoodAtlas")
global("GetFoodAtlas")
local FoodAtlasLookup = {}
function RegisterFoodAtlas(prefab, imagename, atlasname)
  if prefab ~= nil and atlasname ~= nil and imagename ~= nil then
    if FoodAtlasLookup[prefab] ~= nil then
      print("RegisterFoodAtlas: Image '" .. imagename .. "' is already registered to atlas '"
              .. FoodAtlasLookup[imagename] .. "'")
      return
    end
    FoodAtlasLookup[prefab] = {imagename, atlasname}
  end
end
function GetFoodAtlas(prefab)
  local lookup = FoodAtlasLookup[prefab]
  if lookup then return unpack(lookup) end
  return nil, nil
end
