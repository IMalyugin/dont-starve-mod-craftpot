require "class"

local Widget = require "widgets/widget"

local TileBG = require "widgets/tilebg"
local InventorySlot = require "widgets/invslot"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"

local TabGroup = require "widgets/tabgroup"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local FoodTile = require "widgets/foodtile"
local FoodRecipePopup = require "widgets/foodrecipepopup"

local FoodCraftSlot = Class(Widget, function(self, atlas, bgim, owner)
    Widget._ctor(self, "FoodCraftSlot")
    self.owner = owner

    self.atlas = atlas
    self.bgimage = self:AddChild(Image(atlas, bgim))
    self.reqsmatch = false

    self.tile = self:AddChild(FoodTile(nil))
    self.fgimage = self:AddChild(Image("images/hud.xml", "craft_slot_locked.tex"))
    self.fgimage:Hide()

end)

function FoodCraftSlot:SetOrientation(horizontal)
    self.horizontal = horizontal
    self.bg.horizontal = horizontal
    if horizontal then
        self.bg.sepim = "craft_sep_h.tex"
    else
        self.bg.sepim = "craft_sep.tex"
    end

    self.bg:SetNumTiles(self.num_slots)
    local slot_w, slot_h = self.bg:GetSlotSize()
    local w, h = self.bg:GetSize()

    for k = 1, #self.craftslots.slots do
        local slotpos = self.bg:GetSlotPos(k)
        self.craftslots.slots[k]:SetPosition( slotpos.x,slotpos.y,slotpos.z )
    end

    local but_w, but_h = self.downbutton:GetSize()

    if horizontal then
        self.downbutton:SetRotation(90)
        self.downbutton:SetPosition(-self.bg.length/2 - but_w/2 + slot_w/2,0,0)
        self.upbutton:SetRotation(-90)
        self.upbutton:SetPosition(self.bg.length/2 + but_w/2 - slot_w/2,0,0)
    else
        self.upbutton:SetPosition(0, - self.bg.length/2 - but_h/2 + slot_h/2,0)
        self.downbutton:SetScale(Vector3(1, -1, 1))
        self.downbutton:SetPosition(0, self.bg.length/2 + but_h/2 - slot_h/2,0)
    end


end

function FoodCraftSlot:EnablePopup()
    if not self.recipepopup then
        self.recipepopup = self:AddChild(FoodRecipePopup())
        self.recipepopup:SetPosition(0,-20,0)
        self.recipepopup:Hide()
        local s = 1.25
        self.recipepopup:SetScale(s,s,s)
    end
end

function FoodCraftSlot:OnGainFocus()
    FoodCraftSlot._base.OnGainFocus(self)
    self:Open()
end


function FoodCraftSlot:OnControl(control, down)
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
end


function FoodCraftSlot:OnLoseFocus()
    FoodCraftSlot._base.OnLoseFocus(self)
    self:Close()
end


function FoodCraftSlot:Clear()
    self.foodname = nil
    self.recipe = nil
    self.reqsmatch = false

    if self.tile then
        self.tile:Hide()
    end

    self.fgimage:Hide()
    self.bgimage:SetTexture(self.atlas, "craft_slot.tex")
    self:HideRecipe()
end

function FoodCraftSlot:LockOpen()
	self:Open()
	self.locked = true
    if self.recipepopup then
	   self.recipepopup:SetPosition(-300,-300,0)
    end
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

function FoodCraftSlot:Refresh(recipe)
  local foodname = recipe.name
  local unlocked = recipe.unlocked
  local reqsmatch = recipe.reqsmatch
  local readytocook = recipe.readytocook
  local correctcooker = recipe.correctcooker


  local do_pulse = self.foodname == foodname and not self.reqsmatch and reqsmatch

  if do_pulse then
    self.owner.SoundEmitter:PlaySound("dontstarve/HUD/research_available")
  end
  self.foodname = foodname
  self.recipe = recipe

  if self.foodname then
    self.reqsmatch = reqsmatch
    self.tile:SetRecipe(foodname)
    self.tile:Show()

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

        self.fgimage:Show()
        if not readytocook then self.bgimage:SetTexture(self.atlas, "craft_slot.tex") end -- Make sure we clear out the place bg if it's a new tab
      end
    end

    self.tile:SetCanCook((readytocook or reqsmatch ) and unlocked)

    if self.recipepopup then
      self.recipepopup:SetRecipe(self.recipe, self.owner)
    end

    --self:HideRecipe()
  end
end


return FoodCraftSlot
