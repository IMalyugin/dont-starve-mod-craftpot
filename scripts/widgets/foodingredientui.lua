require "class"
require "widgets/widgetutil"

local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ResolveFoodTagAssets = require "utils/resolvefoodtagassets"
local ResolveInventoryItemAssets = require "utils/resolveinventoryitemassets"

local DELTA_TAG = 0.5

local ALIASES = {
  smallmeat_cooked = "cookedsmallmeat",
  monstermeat_cooked = "cookedmonstermeat",
  meat_cooked = "cookedmeat"
}

local FoodIngredientUI = Class(Widget, function(self, element, is_min, owner) -- atlas, image, quantity, name, is_name,
  Widget._ctor(self, "FoodIngredientUI")

  self.owner = owner

  if element.name then
    self.alias = element.name
    self.is_name = true
  else
    self.alias = element.tag
    self.is_name = false
  end
  self.quantity = element.amt

  self.prefab = ALIASES[self.alias] or self.alias
  self.is_min = is_min

  -- initialize localized_name, atlas and item_tex
  self:DefineAssetData()

  -- initialize Icon Background
  local hud_atlas = resolvefilepath( "images/hud.xml" )
  self.valid_bg = self:AddChild(Image(hud_atlas, "inv_slot.tex"))
  self.invalid_bg = self:AddChild(Image(hud_atlas, "resource_needed.tex"))

  -- initialize Icon Image
  --print(self.atlas.." : "..self.item_tex)
  self.img = self:AddChild(Image(self.atlas, self.item_tex))

  -- initialize current quantity output
  if self.is_min then
    if self.is_name and self.quantity == 1 or not self.is_name and self.quantity <= DELTA_TAG then
      self.mask = ""
    else
      self.mask = "%g/%g"
    end
  else
    if self.quantity == 0 then
      self.mask = ""
    else
      self.mask = "%g/%g"
    end
  end
  if JapaneseOnPS4() then
    self.quant = self:AddChild(Text(SMALLNUMBERFONT, 30))
  else
    self.quant = self:AddChild(Text(SMALLNUMBERFONT, 24))
  end
  self.quant:SetPosition(7,-32, 0)

  -- initialize name
  self:SetTooltip(self.localized_name)
  --self:SetClickable(false)
end)

function FoodIngredientUI:GetIngredient()
  return self.alias, self.is_name and 'name' or 'tag'
end

function FoodIngredientUI:DefineAssetData()
  if self.is_name then
    self.item_tex, self.atlas, self.localized_name = ResolveInventoryItemAssets(self.prefab)
  else
    self.item_tex, self.atlas, self.localized_name = ResolveFoodTagAssets(self.prefab)
  end
end

function FoodIngredientUI:Update(on_hand)
  --print(on_hand)
  local valid = (self.is_min and (on_hand >= self.quantity)) or (not self.is_min and (on_hand <= self.quantity))
  self:_SetValid(valid)
  self.quant:SetString(string.format(self.mask, on_hand, self.quantity))
end

function FoodIngredientUI:_SetValid(valid)
  if valid then
    self.valid_bg:Show()
    self.invalid_bg:Hide()
    self.quant:SetColour(255/255,255/255,255/255,1)
  else
    self.invalid_bg:Show()
    self.valid_bg:Hide()
    self.quant:SetColour(255/255,155/255,155/255,1)
  end
end

return FoodIngredientUI
