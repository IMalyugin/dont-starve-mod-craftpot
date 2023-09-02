-- clean up to prevent assertion failure
return function(item_tex, atlas, localized_name)
  if atlas and TheSim:AtlasContains(atlas, item_tex) then
    return item_tex, resolvefilepath(atlas), localized_name
  else
    return nil, nil, localized_name
  end
end
