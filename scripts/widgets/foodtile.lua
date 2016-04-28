require "class"

--local TileBG = require "widgets/tilebg"
--local InventorySlot = require "widgets/invslot"
local Image = require "widgets/image"
--local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"

--local TabGroup = require "widgets/tabgroup"
--local UIAnim = require "widgets/uianim"
--local Text = require "widgets/text"

local FoodTile = Class(Widget, function(self, recipe)
    Widget._ctor(self, "FoodTile")

		self.foodname = foodname

		self.atlas = resolvefilepath("images/inventoryimages.xml")
    self.img = self:AddChild(Image(self.atlas, foodname..".tex"))

    self:SetClickable(false)
    self.numtiles = 0
end)

function FoodTile:SetCanCook(cancook)
    if cancook then
        self.img:SetTint(1,1,1,1)
    else
        self.img:SetTint(0,0,0,1)
    end
end

return FoodTile
