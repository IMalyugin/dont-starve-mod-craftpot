require "class"

local Widget = require "widgets/widget"

local Image = require "widgets/image"

-- Overlay ordering:
--  foodcrafting->bgimage
--  fooditem->tile
--  foodslot->fgimage
local FoodSlot = Class(Widget, function(self, owner, foodcrafting, slot_idx, bgimage)
    Widget._ctor(self, "FoodSlot")
    self.owner = owner
    self.foodcrafting = foodcrafting

    self.atlas = HUD_ATLAS

    self.bgimage = bgimage
    self.bgimage:SetTexture(self.atlas, "craft_slot.tex")
    self.fgimage = self:AddChild(Image("images/hud.xml", "craft_slot_locked.tex"))
    self.fgimage:Hide()

    self.reqsmatch = false

    self.slot_idx = slot_idx
    self:ClearFood()
end)

-- foreground is initialized later to overlay the slot icons, also childs are added to root class
function FoodSlot:InitForeground()
end

function FoodSlot:OnGainFocus()
  FoodSlot._base.OnGainFocus(self)
  if self.slot_idx then
    self.foodcrafting:FoodFocus(self.slot_idx)
  end
end

function FoodSlot:ClearFood()
  if self.fooditem then
    self.fooditem:Hide()
  end
  self.bgimage:SetTexture(self.atlas, "craft_slot.tex")
  self.fgimage:Hide()
  self.fooditem = nil
end

function FoodSlot:SetFood(fooditem)
  self.fooditem = fooditem
  self.fooditem:SetPosition(self:GetPosition())
  self.fooditem:Show()
  self.fooditem:Refresh()
  self:Refresh()
end

function FoodSlot:Refresh()
  local recipe = self.fooditem.recipe
  local foodname = recipe.name
  local unlocked = recipe.unlocked
  local reqsmatch = recipe.reqsmatch
  local readytocook = recipe.readytocook
  local correctCooker = recipe.correctCooker
  local hud_atlas = resolvefilepath( "images/hud.xml" )

  if foodname then
    reqsmatch = reqsmatch

    if self.fgimage then
      self.bgimage:SetTexture(self.atlas, "craft_slot.tex")

      if unlocked then
        self.fgimage:Hide()

        if readytocook then
          self.bgimage:SetTexture(self.atlas, "craft_slot_place.tex")
        elseif not correctCooker then
          self.fgimage:SetTexture(hud_atlas, "craft_slot_locked_nextlevel.tex")
          self.fgimage:Show()
        end
      else
        if not correctCooker then
          self.fgimage:SetTexture(hud_atlas, "craft_slot_locked_nextlevel.tex")
        elseif reqsmatch then
          self.fgimage:SetTexture(hud_atlas, "craft_slot_locked_highlight.tex")
        else
          self.fgimage:SetTexture(hud_atlas, "craft_slot_locked.tex")
        end
        self.fgimage:Show()
      end
    end
  end
end


--[[function FoodSlot:OnControl(control, down)
  if FoodSlot._base.OnControl(self, control, down) then return true end

  if not down and control == CONTROL_ACCEPT then
    if self.owner and self.recipe then
      if self.recipepopup and not self.recipepopup.focus then
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        if not DoRecipeClick(self.owner, self.recipe) then self:Close() end
        return true
      end
    end
  end
end]]


return FoodSlot
