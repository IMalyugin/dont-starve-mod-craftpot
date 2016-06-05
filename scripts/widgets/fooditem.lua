require "class"

local Widget = require "widgets/widget"

local TileBG = require "widgets/tilebg"
local InventorySlot = require "widgets/invslot"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"

local TabGroup = require "widgets/tabgroup"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
--local FoodTile = require "widgets/foodtile"
local FoodRecipePopup = require "widgets/foodrecipepopup"

local FoodItem = Class(Widget, function(self, owner, foodcrafting, recipe)
  Widget._ctor(self, "FoodItem")
  self.owner = owner
	self.foodcrafting = foodcrafting
	self.recipe = recipe
	self.slot = nil

	self.atlas = resolvefilepath("images/inventoryimages.xml")
  self.tile = self:AddChild(Image(self.atlas, recipe.name..".tex"))

	self.recipepopup = self:AddChild(FoodRecipePopup(self.owner, self.recipe))
	self.recipepopup:SetPosition(0,-20,0)
	self.recipepopup:Hide()
	local s = 1.25
	self.recipepopup:SetScale(s,s,s)

end)

function FoodItem:SetSlot(slot)
	self.slot = slot
end

function FoodItem:ShowPopup(cookerIngs)
	self.recipepopup:Update(cookerIngs)
  self.recipepopup:Show()
end

function FoodItem:HidePopup()
  self.recipepopup:Hide()
end

function FoodItem:OnGainFocus()
  FoodItem._base.OnGainFocus(self)
	if self.slot and self.slot.slot_idx then
  	self.foodcrafting:FoodFocus(self.slot.slot_idx)
	end
end

function FoodItem:Refresh()
	local recipe = self.recipe
  local foodname = recipe.name
  local unlocked = recipe.unlocked
  local reqsmatch = recipe.reqsmatch
  local readytocook = recipe.readytocook
  local correctcooker = recipe.correctcooker

	if (readytocook or reqsmatch ) and unlocked then
		self.tile:SetTint(1,1,1,1)
	else
		self.tile:SetTint(0,0,0,1)
	end
end


return FoodItem
