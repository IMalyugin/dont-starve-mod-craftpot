require "class"

local FoodCrafting = require "widgets/foodcrafting"--mod

local MouseFoodCrafting = Class(FoodCrafting, function(self, numtabs)
    FoodCrafting._ctor(self,numtabs)
    self:SetOrientation(false)
    local scale = 0.5
    self.in_pos = Vector3(145,0,0)
    self.out_pos = Vector3(0,0,0)    
    self:SetScale(scale,scale,scale)
    self.craftslots:EnablePopups()
end)


return MouseFoodCrafting
