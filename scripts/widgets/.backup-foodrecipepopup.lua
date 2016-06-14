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
local mainfunctions = require "mainfunctions"

require "widgets/widgetutil"

local TEX_TAGS = {meat="Meats",monster="Monster Foods",veggie="Vegetables",fruit="Fruits",egg="Eggs",sweetener="Sweets",inedible="Inedibles",dairy="Dairies",fat="Fat",frozen="Ice",magic="Magic",decoration="Decoration",seeds="Seeds"}

local FoodRecipePopup = Class(Widget, function(self, horizontal)
    Widget._ctor(self, "Recipe Popup")

    local hud_atlas = resolvefilepath( "images/recipe_hud.xml" )
    self.atlas = resolvefilepath("images/inventoryimages.xml")
    self.tag_atlas = resolvefilepath("images/food_tags.xml")

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


    self.ing = {min={},max={}}

end)


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

  self._minfoodwrap = self.contents:AddChild(Widget(""))
  self._minfoodwrap:SetPosition(center,115,0)

  self._maxfoodwrap = self.contents:AddChild(Widget(""))
  self._maxfoodwrap:SetPosition(center,-35,0)

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
