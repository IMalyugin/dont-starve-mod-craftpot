require "class"

local Widget = require "widgets/widget"

local Image = require "widgets/image"
local FoodRecipePopup = require "widgets/foodrecipepopup"

-- GetInventoryItemAtlas is the new way of getting item atlas in porkland
local GetInventoryItemAtlas = function(item)
  if TheSim:GetGameID() == "DS" and IsDLCEnabled(PORKLAND_DLC) then
    return GetInventoryItemAtlas(item)
  end
  return resolvefilepath("images/inventoryimages.xml")
end


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
  self.atlas = GetInventoryItemAtlas(self.item_tex)
  if PREFABDEFINITIONS[self.prefab] and not (
      TheSim.AtlasContains and
      TheSim:AtlasContains(self.atlas, self.item_tex)
  ) then
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
  local unlocked = recipe.unlocked
  local reqsmatch = recipe.reqsmatch
  local readytocook = recipe.readytocook

  if (readytocook or reqsmatch ) and unlocked then
    self.tile:SetTint(1,1,1,1)
  else
    self.tile:SetTint(0,0,0,1)
  end
end


return FoodItem
