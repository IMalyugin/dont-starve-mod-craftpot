require "class"

local TileBG = require "widgets/tilebg"
local InventorySlot = require "widgets/invslot"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local TabGroup = require "widgets/tabgroup"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"

local DELTA_TAG = 0.5
local FoodIngredientUI = Class(Widget, function(self, atlas, image, quantity, on_hand, name, is_name, is_min, owner)
  Widget._ctor(self, "FoodIngredientUI")

  --self:SetClickable(false)

  local hud_atlas = resolvefilepath( "images/hud.xml" )
  local valid = (is_min and (on_hand >= quantity)) or (not is_min and (on_hand <= quantity))

  if valid then
      self.bg = self:AddChild(Image(hud_atlas, "inv_slot.tex"))
  else
      self.bg = self:AddChild(Image(hud_atlas, "resource_needed.tex"))
  end

  self:SetTooltip(name)

  self.ing = self:AddChild(Image(atlas, image))

  if JapaneseOnPS4() then
    self.quant = self:AddChild(Text(SMALLNUMBERFONT, 30))
  else
    self.quant = self:AddChild(Text(SMALLNUMBERFONT, 24))
  end

  self.quant:SetPosition(7,-32, 0)

  local mask
  if is_min then
    if is_name and quantity == 1 or not is_name and quantity <= DELTA_TAG then
      mask = ""
    else
      mask = "%g/%g"
    end
  else
    if quantity == 0 then
      mask = ""
    else
      mask = "%g/%g"
    end
  end
  self.quant:SetString(string.format(mask, on_hand,quantity))
  if not valid then
      self.quant:SetColour(255/255,155/255,155/255,1)
  end
end)

return FoodIngredientUI
