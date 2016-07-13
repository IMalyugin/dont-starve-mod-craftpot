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

local mainfunctions = require "mainfunctions"

local FoodItem = Class(Widget, function(self, owner, foodcrafting, recipe)
  Widget._ctor(self, "FoodItem")
  self.owner = owner
	self.foodcrafting = foodcrafting
	self.recipe = recipe
	self.slot = nil

  self.prefab = self.recipe.name
  self:DefineAssetData()
  self.tile = self:AddChild(Image(self.atlas, self.item_tex))

	self.recipepopup = self:AddChild(FoodRecipePopup(self.owner, self.recipe))
	self.recipepopup:SetPosition(-24,-8,0)
	self.recipepopup:Hide()
	local s = 1.60
	self.recipepopup:SetScale(s,s,s)

end)

function FoodItem:DefineAssetData()
  self.item_tex = self.prefab..'.tex'
  self.atlas = resolvefilepath("images/inventoryimages.xml")
  if PREFABDEFINITIONS[self.prefab] then
    for idx,asset in ipairs(PREFABDEFINITIONS[self.prefab].assets) do
      if asset.type == "INV_IMAGE" then
        self.item_tex = asset.file..'.tex'
      elseif asset.type == "ATLAS" then
        self.atlas = asset.file
      end
    end
  end
end

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
