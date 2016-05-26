require "class"

local TileBG = require "widgets/tilebg"
local InventorySlot = require "widgets/invslot"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local TabGroup = require "widgets/tabgroup"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"

local FoodIngredientUI = require "widgets/foodingredientui"

local SIZES = {
	icon = 64,
	space = 10,
	alter = 30,
	bracket = 15,
	contw = 286,
	conth = 100
}
local EPSILON = 0.01

local FoodRecipePopup = Class(Widget, function(self, owner, recipe)
    Widget._ctor(self, "Recipe Popup")

		self.owner = owner
		self.recipe = recipe

    local hud_atlas = resolvefilepath( "images/recipe_hud.xml" )
    --self.atlas = resolvefilepath("images/inventoryimages.xml")

    self.bg = self:AddChild(Image())
		self.bg:SetPosition(210,16,0)
    self.bg:SetTexture(hud_atlas, 'recipe_hud.tex')


    self.contents = self:AddChild(Widget(""))
    self.contents:SetPosition(-75,0,0)

    if JapaneseOnPS4() then
      self.name = self.contents:AddChild(Text(UIFONT, 42 * 0.8))
    else
      self.name = self.contents:AddChild(Text(UIFONT, 42))
	  end

    self.name:SetPosition(320, 142, 0)
    if JapaneseOnPS4() then
      self.name:SetRegionSize(64*3+20,90)
      self.name:EnableWordWrap(true)
    end


    if JapaneseOnPS4() then
      self.excludes_title = self.contents:AddChild(Text(UIFONT, 32 * 0.8))
    else
      self.excludes_title = self.contents:AddChild(Text(UIFONT, 32))
	  end

    self.excludes_title:SetString('Limit')

    self.excludes_title:SetPosition(320, -13, 0)
    if JapaneseOnPS4() then
      self.excludes_title:SetRegionSize(64*3+20,90)
      --self.excludes_title:EnableWordWrap(true)
    end

		local center = 317
		self._minwrap = self.contents:AddChild(Widget(""))
		self._minwrap:SetPosition(center,115,0)

		self._maxwrap = self.contents:AddChild(Widget(""))
		self._maxwrap:SetPosition(center,-35,0)

    --self.maxing = {min={},max={}}

		self:_CreateLayout(self._minwrap, self.recipe.minmix)
		self:_CreateLayout(self._maxwrap, self.recipe.maxmix)
end)

function FoodRecipePopup:_CreateLayout(wrapper, mix)
	local sequence = self:_BuildSequence(mix, {})
	local groups = self:_BuildGroups(sequence)
	local zoom = self:_FindZoom(groups)

	local gwidth  = (SIZES.contw + SIZES.space) / zoom
	local left, top = 0, 0

	for idx,group in ipairs(groups) do
		-- insert element
		local offset = 0
		for _,component in ipairs(group.sequence) do
			if component == '(' or component == ')' then
				offset = offset + SIZES.bracket
			elseif component == '/' then
				offset = offset + SIZES.alter
			else
				offset = offset + SIZES.icon
			end
			self:_InsertComponent(wrapper,component,left+offset,top)
		end

		left = left + group.size

		if left > gwidth + EPSILON then -- overflow x
			left = 0
			top = top + SIZES.icon + SIZES.space
		end
	end -- groups
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
					table.insert(arr, '/') -- or
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
		-- insert space before symbol unless near a bracket
		if prev ~= '^' and (symbol ~= ')' and prev ~= '(') then
			table.insert(group.sequence, '_')
			group.size = group.size + SIZES.space
			-- if space was inserted and not after 'or' symbol, the group is finished
			if prev ~= '/' then
				table.insert(groups, group)
				group = {sequence={}, size=0}
			end
		end

		table.insert(group.sequence, symbol)
		if symbol == '(' or symbol == ')' then
			group.size = group.size + SIZES.bracket
		elseif symbol == '/' then
			group.size = group.size + SIZES.alter
		else
			group.size = group.size + SIZES.icon
		end

		prev = symbol
	end

	-- append last group
	table.insert(group.sequence, '_')
	group.size = group.size + SIZES.space
	table.insert(groups, group)

	return groups
end

function FoodRecipePopup:_FindZoom(groups)
	local zoom, newzoom = 1, 1

	while true do
		local gwidth  = (SIZES.contw + SIZES.space) / zoom
		local gheight = (SIZES.conth - SIZES.icon) / zoom -- add&sub space
		local width, height = 0, 0
		newzoom = 0

		local found = true
		local idx = 1

		while idx < #groups do
			local group = groups[idx]
			width = width + group.size

			if width - gwidth > EPSILON then -- overflow x
				newzoom = math.max(newzoom, zoom * gwidth / width)

				width = 0
				height = height + SIZES.icon + SIZES.space

				if height - gheight > EPSILON then -- overflow y
					newzoom = math.max(newzoom, zoom * gheight / height)
					found = false
					break
				end
			else
				idx = idx + 1
			end
		end-- while idx < #groups
		if found then
			return zoom
		end
		-- otherwise take newzoom and try again
		zoom = newzoom
	end -- while true
end

function FoodRecipePopup:_InsertComponent(wrapper, component, left, top)
	local element
	if type(component) == 'table' then
		local is_min = true
		element = FoodIngredientUI(component, is_min, self.owner)
	else
		element = self.contents:AddChild(Text(UIFONT, 42))
		element:SetString(component)
	end
	element:SetPosition(left,top,0)
	wrapper:AddChild(element)
end

function FoodRecipePopup:Refresh()
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
end


function FoodRecipePopup:SetRecipe(recipe, owner)
    self.recipe = recipe
    self.owner = owner
    self:Refresh()
end

return FoodRecipePopup
