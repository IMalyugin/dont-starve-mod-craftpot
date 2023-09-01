-- clean up to prevent assertion failure
local resolvefilepath_soft = rawget(_G,"resolvefilepath_soft") or softresolvefilepath
return function(item_tex, atlas, localized_name)
  if atlas and TheSim:AtlasContains(resolvefilepath_soft(atlas), item_tex) then
    return item_tex, resolvefilepath(atlas), localized_name
  else
    return nil, nil, localized_name
  end
end
