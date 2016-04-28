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

local FoodCraftSlot = Class(Widget, function(self, owner, recipe, orientation)
    Widget._ctor(self, "FoodCraftSlot")
    self.owner = owner

    self.atlas = HUD_ATLAS
    self.bgimage = self:AddChild(Image(self.atlas, "craft_slot.tex"))
    self.reqsmatch = false

    self.fgimage = self:AddChild(Image("images/hud.xml", "craft_slot_locked.tex"))
    self.fgimage:Hide()
end)

--[[function FoodCraftSlot:OnGainFocus()
    FoodCraftSlot._base.OnGainFocus(self)
    self:Open()
end

function FoodCraftSlot:OnLoseFocus()
    FoodCraftSlot._base.OnLoseFocus(self)
    self:Close()
end]]


function FoodCraftSlot:Clear()
    self.foodname = nil
    self.recipe = nil
    self.reqsmatch = false

    if self.tile then
        self.tile:Hide()
    end

    self.fgimage:Hide()
    self.bgimage:SetTexture(HUD_ATLAS, "craft_slot.tex")
    self:HideRecipe()
end

function FoodCraftSlot:Open()
    if self.recipepopup then
        self.recipepopup:SetPosition(0,-20,0)
    end
    self.open = true
    self:ShowRecipe()
    self.owner.SoundEmitter:PlaySound("dontstarve/HUD/click_mouseover")
end

function FoodCraftSlot:Close()
    self.open = false
    self.locked = false
    self:HideRecipe()
end

function FoodCraftSlot:ShowRecipe()
    if self.recipe and self.recipepopup then
        self.recipepopup:Show()
        self.recipepopup:SetRecipe(self.recipe, self.owner)
    end
end

function FoodCraftSlot:HideRecipe()
    if self.recipepopup then
        self.recipepopup:Hide()
    end
end

function FoodCraftSlot:SetRecipe(recipe)
  self:Show()
	self:Refresh(recipe)
end

function FoodCraftSlot:Refresh()
  local foodname = self.recipe.name
  local unlocked = self.recipe.unlocked
  local reqsmatch = self.recipe.reqsmatch
  local readytocook = self.recipe.readytocook
  local correctcooker = self.recipe.correctcooker

  if self.foodname then
    self.reqsmatch = reqsmatch

    if self.fgimage then
      if unlocked and correctcooker then
        if readytocook then
          self.bgimage:SetTexture(self.atlas, "craft_slot_place.tex")
        else
          self.bgimage:SetTexture(self.atlas, "craft_slot.tex")
        end

        self.fgimage:Hide()
      else


        local hud_atlas = resolvefilepath( "images/hud.xml" )

        if not correctcooker then
            self.fgimage:SetTexture(hud_atlas, "craft_slot_locked_nextlevel.tex")
        elseif reqsmatch then
            self.fgimage:SetTexture(hud_atlas, "craft_slot_locked_highlight.tex")
        else
            self.fgimage:SetTexture(hud_atlas, "craft_slot_locked.tex")
        end

				self.bgimage:SetTexture(self.atlas, "craft_slot.tex")
        self.fgimage:Show()
        --if not readytocook then self.bgimage:SetTexture(self.atlas, "craft_slot.tex") end -- Make sure we clear out the place bg if it's a new tab
      end
    end
  end
end


--[[function FoodCraftSlot:OnControl(control, down)
  if FoodCraftSlot._base.OnControl(self, control, down) then return true end

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


return FoodCraftSlot
