require "class"

local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Text = require "widgets/text"

local FoodIngredientUI = require "widgets/foodingredientui"

local SIZES = {
  icon = 64,
  space = 8,
  alter = 10,
  bracket = 15,
--  contw = 286,
  contw = 210,
  conth = 105
}
local EPSILON = 0.01

local FoodRecipePopup = Class(Widget, function(self, owner, recipe)
    Widget._ctor(self, "Recipe Popup")

    self.owner = owner
    self.recipe = recipe
    self.ingredients = {}

    local hud_atlas = resolvefilepath( "images/recipe_hud.xml" )
    --self.atlas = resolvefilepath("images/inventoryimages.xml")

    self.bg = self:AddChild(Image())
    self.bg:SetPosition(210,16,0)
    self.bg:SetTexture(hud_atlas, 'recipe_hud.tex')


    self.contents = self:AddChild(Widget(""))
    self.contents:SetPosition(229,130,0)

    if JapaneseOnPS4() then
      self.name = self.contents:AddChild(Text(UIFONT, 42 * 0.8))
    else
      self.name = self.contents:AddChild(Text(UIFONT, 42))
    end

    self.name:SetPosition(3, 0, 0)
    if JapaneseOnPS4() then
      self.name:SetRegionSize(64*3+20,90)
      self.name:EnableWordWrap(true)
    end

    local localized_foodname = STRINGS.NAMES[string.upper(self.recipe.name)] or recipe.name
    self.name:SetString(localized_foodname)

    if JapaneseOnPS4() then
      self.excludes_title = self.contents:AddChild(Text(UIFONT, 32 * 0.8))
    else
      self.excludes_title = self.contents:AddChild(Text(UIFONT, 32))
    end

    self.hunger = self.contents:AddChild(Text(BODYTEXTFONT, 28))
    self.sanity = self.contents:AddChild(Text(BODYTEXTFONT, 28))
    self.health = self.contents:AddChild(Text(BODYTEXTFONT, 28))

    self.excludes_title:SetString('Limit')

    self.excludes_title:SetPosition(0, -164, 0)
    if JapaneseOnPS4() then
      self.excludes_title:SetRegionSize(64*3+20,90)
      --self.excludes_title:EnableWordWrap(true)
    end

    self._minwrap = self.contents:AddChild(Widget(""))
    self._minwrap:SetPosition(0,-27,0)

    self._maxwrap = self.contents:AddChild(Widget(""))
    self._maxwrap:SetPosition(0,-186,0)

    self:_CreateLayout(self._minwrap, self.recipe.minmix, true)
    self:_CreateLayout(self._maxwrap, self.recipe.maxmix, false)
end)

function FoodRecipePopup:Update(cookerIngs)
  for _, ui in ipairs(self.ingredients) do
    local alias,type = ui:GetIngredient()
    ui:Update(cookerIngs[type..'s'][alias] and cookerIngs[type..'s'][alias] or 0)
  end

  local recipe = self.recipe

  self.hunger:SetPosition(5,82,0)
  self.hunger:SetString((not recipe.unlocked) and '?' or type(recipe.hunger) == 'number' and recipe.hunger~=0 and string.format("%g",(math.floor(recipe.hunger*10+0.5)/10)) or '-')
  if recipe.unlocked and type(recipe.hunger) == 'number' and recipe.hunger < 0 then
    self.hunger:SetColour(1,0,0,1)
    self.hunger:SetPosition(2,82,0)
  end

  self.sanity:SetPosition(-73,54,0)
  self.sanity:SetString(not recipe.unlocked and '?' or type(recipe.sanity) == 'number' and recipe.sanity~=0 and string.format("%g",(math.floor(recipe.sanity*10+0.5)/10)) or '-')
  if recipe.unlocked and type(recipe.sanity) == 'number' and recipe.sanity < 0 then
    self.sanity:SetColour(1,0,0,1)
    self.sanity:SetPosition(-76,53,0)
  end

  self.health:SetPosition(84,54,0)
  self.health:SetString(not recipe.unlocked and '?' or type(recipe.health) == 'number' and recipe.health~=0 and string.format("%g",(math.floor(recipe.health*10+0.5)/10)) or '-')
  if recipe.unlocked and type(recipe.health) == 'number' and recipe.health < 0 then
    self.health:SetPosition(81,53,0)
    self.health:SetColour(1,0,0,1)
  end
end

function FoodRecipePopup:_CreateLayout(wrapper, mix, is_min)
  local sequence = self:_BuildSequence(mix, {})
  local groups = self:_BuildGroups(sequence)
  local zoom,linewidth = self:_FindZoom(groups)

  local gwidth  = SIZES.contw / zoom
  local left, top = 0, 0

  for idx,group in ipairs(groups) do
    -- insert element
    local offset = 0
    local component_size = 0

    if left + group.size > gwidth + EPSILON then -- overflow x
      left = 0
      top = top - SIZES.icon - SIZES.space
    end

    for _,component in ipairs(group.sequence) do
      if component == '(' or component == ')' then
        component_size = SIZES.bracket
      elseif component == ',' then
        component_size = SIZES.alter
      elseif component == '_' then
        component_size = SIZES.space
      else
        component_size = SIZES.icon
      end
      offset = offset + component_size
      if component ~= '_' then
        self:_InsertComponent(wrapper,component,left+offset-(type(component) == 'table' and component_size/2 or 0),top-SIZES.icon/2,is_min)
      end
    end

    left = left + group.size + SIZES.space

  end -- groups
  wrapper:SetPosition(wrapper:GetPosition() - Vector3(linewidth/2,0,0))
  wrapper:SetScale(zoom,zoom,zoom)
end

function FoodRecipePopup:_BuildSequence(mix, arr)
  for cid, conj in ipairs(mix) do
    if conj.amt then
      table.insert(arr, conj) -- icon of conjuction
    else
      local brackets = (#arr ~= 0 or #mix == 0)
      if brackets then
        table.insert(arr, '(')
      end
      for aid, alt in ipairs(conj) do
        if aid > 1 then
          table.insert(arr, ',') -- or
        end
        if alt.amt then
          table.insert(arr, alt) -- icon of alternation
        else
          self:_BuildSequence(alt, arr)
        end
      end
      if brackets then
        table.insert(arr, ')')
      end
    end
  end
  return arr
end

function FoodRecipePopup:_BuildGroups(sequence)
  local groups = {}
  local group = {sequence={},size=0}
  local prev = '^'

  for idx, symbol in ipairs(sequence) do
    -- possible group end, unless near a bracket or comma
    if prev ~= '^' and (symbol ~= ')' and prev ~= '(') and symbol ~= ',' then
        table.insert(groups, group)
        group = {sequence={}, size=0}
    end

    table.insert(group.sequence, symbol)
    if symbol == '(' or symbol == ')' then
      group.size = group.size + SIZES.bracket
    elseif symbol == ',' then
      group.size = group.size + SIZES.alter
    else
      group.size = group.size + SIZES.icon
    end

    prev = symbol
  end

  -- append last group
  --table.insert(group.sequence, '_')
  --group.size = group.size + SIZES.space
  table.insert(groups, group)

  return groups
end

-- retuns zoom, maxwidth
function FoodRecipePopup:_FindZoom(groups)
  local zoom, newzoom, maxwidth = 1, 0, 0

  while true do
    local gwidth  = SIZES.contw / zoom
    local gheight = SIZES.conth / zoom -- add&sub space
    local width,height = 0,SIZES.icon

    newzoom, maxwidth = 0, 0

    local found = true
    local idx = 1

    while idx <= #groups do
      local group = groups[idx]
      width = width + group.size

      if width > gwidth + EPSILON then -- overflow x
        newzoom = math.max(newzoom, zoom * gwidth / width)
        width = 0
        height = height + SIZES.icon + SIZES.space
        if height > gheight + EPSILON then -- overflow y
          newzoom = math.max(newzoom, zoom * gheight / height)
          found = false
          break
        end
      else
        maxwidth = math.max(maxwidth, zoom * width)
        width = width + SIZES.space
        idx = idx + 1
      end
    end-- while idx < #groups
    if found then
      return zoom,maxwidth
    end
    -- otherwise take newzoom and try again
    zoom = newzoom
  end -- while true
end

function FoodRecipePopup:_InsertComponent(wrapper, component, left, top, is_min)
  local element, fontsize, fontfamily
  if type(component) == 'table' then
    element = FoodIngredientUI(component, is_min, self.owner)
    element:SetPosition(left,top,0)
    table.insert(self.ingredients, element)
  else
    if component == ',' then
      fontsize = 73
      top = top - 8
      left = left + 2
      fontfamily = DEFAULTFONT
    else
      fontsize = 73
      top = top - 8
      fontfamily = UIFONT
    end
    element = self.contents:AddChild(Text(fontfamily, fontsize))
    element:SetString(component)
    element:SetPosition(left,top,0)
  end
  wrapper:AddChild(element)
end

--[[function FoodRecipePopup:Refresh()
  local recipe = self.recipe
  local owner = self.owner

  if not owner then
    return false
  end

  local localized_foodname = STRINGS.NAMES[string.upper(self.recipe.name)] or recipe.name
  self.name:SetString(localized_foodname)
  --self.desc:SetString("test desc")

  local num = 0
  local center = 317
  local w = 64
  local div = 10

  local foodwrap
  local ind
  local row
  local in_row
  local base_offset
  local offset
  local scale

  local cookervalues, num_ing = owner.components.knownfoods:GetCookerIngredientValues()
  local macrogroups = {min={names="minnames",tags="mintags"},max={names="maxnames",tags="maxtags"}}
  for macrokey, group in pairs(macrogroups) do -- macrokey:min/max
    local is_min = macrokey == 'min'
    for k,v in pairs(self.ing[macrokey]) do
      v:Kill()
    end
    self.ing[macrokey] = {}

    -- count number of name and tag categories
    num = 0
    for groupname,gkey in pairs(group) do
      for k,v in pairs(recipe[gkey]) do
        num = num + 1
      end
    end

    if is_min then foodwrap = self._minfoodwrap else foodwrap = self._maxfoodwrap end

    if num <= 3 then
      in_row = 3
    elseif num <= 8 then
      in_row = 4
    else
      in_row = 6
    end

    ind = 0
    base_offset = - (math.min(in_row, num)-1) * (w + div) /2
    scale = 3/in_row

    foodwrap:SetScale(scale,scale,scale)
    for groupname,gkey in pairs(group) do -- groupname:names/tags, gkey:minnames, mintags, maxnames, maxtags
      local is_name = groupname == 'names'
      for alias,amount in pairs(recipe[gkey]) do
        local num_found = cookervalues[groupname][alias] and cookervalues[groupname][alias] or 0
        --local has, num_found = owner.components.inventory:Has(alias, amount)


        local localized_name = STRINGS.NAMES[string.upper(alias)] or alias
        local item_img = alias

        local atlas
        if is_name then
          atlas = self.atlas
          if PREFABDEFINITIONS[item_img] then
            for idx,asset in ipairs(PREFABDEFINITIONS[item_img].assets) do
              if asset.type == "INV_IMAGE" then
                item_img = asset.file
              elseif asset.type == "ATLAS" then
                atlas = asset.file
              end
            end
          end
        else
          if TEX_TAGS[item_img] then
            atlas = self.tag_atlas
            localized_name = TEX_TAGS[item_img]
          else
            atlas = self.atlas
            if PREFABDEFINITIONS[item_img] then
              for idx,asset in ipairs(PREFABDEFINITIONS[item_img].assets) do
                if asset.type == "INV_IMAGE" then
                  item_img = asset.file
                elseif asset.type == "ATLAS" then
                  atlas = asset.file
                end
              end
            end
          end
        end

        local ing = foodwrap:AddChild(FoodIngredientUI(atlas, item_img..".tex", amount, num_found, localized_name, is_name, is_min, owner))

        ing:SetPosition(Vector3(base_offset + (w + div) * (ind % in_row), -(w+div)*math.floor(ind/in_row) - w/2, 0))
        --offset = offset + (w+ div)
        self.ing[macrokey][ind] = ing
        ind = ind + 1
      end
    end
  end
end]]


--[[function FoodRecipePopup:SetRecipe(recipe, owner)
    self.recipe = recipe
    self.owner = owner
    self:Refresh()
end]]

return FoodRecipePopup
