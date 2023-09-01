local resolvefilepath_soft = rawget(_G,"resolvefilepath_soft") or softresolvefilepath
return function(atlas, tex)
  if atlas and tex then
    local absolute_path = resolvefilepath_soft(atlas)
    if absolute_path and TheSim:AtlasContains(absolute_path, tex) then return absolute_path end
  end
  return nil
end