require "class"

local Widget = require "widgets/widget"

local TileBG = require "widgets/tilebg"
local InventorySlot = require "widgets/invslot"ß
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"

local TabGroup = require "widgets/tabgroup"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local FoodTile = require "widgets/foodtile"
local FoodRecipePopup = require "widgets/foodrecipepopup"

local FoodItem = Class(Widget, function(self, owner, recipe)
    Widget._ctor(self, "FoodItem")
    self.owner = owner

		self.atlas = resolvefilepath("images/inventoryimages.xml")
    self.tile = self:AddChild(Image(self.atlas, recipe.foodname..".tex"))

		self.recipepopup = self:AddChild(FoodRecipePopup(self.owner, self.recipe))
		self.recipepopup:SetPosition(0,-20,0)
		self.recipepopup:Hide()
		local s = 1.25
		self.recipepopup:SetScale(s,s,s)

end)

function FoodItem:ShowRecipe()
    if self.recipepopup then
        self.recipepopup:Show()
    end
end

function FoodItem:HideRecipe()
    if self.recipepopup then
        self.recipepopup:Hide()
    end
end

function FoodItem:Refresh(recipe)
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
