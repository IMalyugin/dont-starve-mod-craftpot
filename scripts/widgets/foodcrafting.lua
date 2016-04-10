require "class"

local PreparedFoods = require "preparedfoods"

local Crafting = require "widgets/crafting"
local TileBG = require "widgets/tilebg"
--local InventorySlot = require "widgets/invslot"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
--local Widget = require "widgets/widget"
--local TabGroup = require "widgets/tabgroup"
--local UIAnim = require "widgets/uianim"
--local Text = require "widgets/text"
local FoodCraftSlots = require "widgets/foodcraftslots"--mod

local FoodCrafting = Class(Crafting, function(self, num_slots)
  Crafting._base._ctor(self, "FoodCrafting")

	self.owner = GetPlayer()

  self.bg = self:AddChild(TileBG(HUD_ATLAS, "craft_slotbg.tex"))

  --slots
  self.num_slots = num_slots
  self.craftslots = FoodCraftSlots(num_slots, self.owner)
  self:AddChild(self.craftslots)

  --buttons
  self.downbutton = self:AddChild(ImageButton(HUD_ATLAS, "craft_end_normal.tex", "craft_end_normal_mouseover.tex", "craft_end_normal_disabled.tex"))
  self.upbutton = self:AddChild(ImageButton(HUD_ATLAS, "craft_end_normal.tex", "craft_end_normal_mouseover.tex", "craft_end_normal_disabled.tex"))
  self.downbutton:SetOnClick(function() self:ScrollDown() end)
  self.upbutton:SetOnClick(function() self:ScrollUp() end)

-- start slightly scrolled down
  self.idx = -1
  self.scrolldir = true

  self.open = false
end)

function FoodCrafting:Open(cooker_inst)
  self.owner.components.knownfoods:SetCooker(cooker_inst)

  if not self.horizontal then
    self:SetPosition(cooker_inst.components.container.widgetpos +  Vector3(85,0,0))
  end

  self.open = true
	self:Enable()
  self:Show()
  self:UpdateRecipes()
end

function FoodCrafting:Close(cooker_inst)
  self.open = false
  self:Disable()
  self:Hide()
  self.craftslots:CloseAll()
end

function FoodCrafting:UpdateRecipes()
  if not self.open then return end

  self.craftslots:Clear()

  local recipes = self.owner.components.knownfoods:GetCookBook()
  --local recipes = self.owner.components.builder.recipes
  self.valid_recipes = {}

  for foodname,recipe in pairs(recipes) do
      local show = (not self.filter) or self.filter(recipe.name)
      if show and not recipe.hide then
        table.insert(self.valid_recipes, recipe)
      end
  end

  table.sort(self.valid_recipes, function(a,b)
    if a.correctcooker ~= b.correctcooker then return a.correctcooker end
    if a.readytocook ~= b.readytocook then return a.readytocook end
    if b.name == "wetgoop" then return true elseif a.name == "wetgoop" then return false end

    if a.reqsmatch ~= b.reqsmatch then return a.reqsmatch end
    if a.unlocked ~= b.unlocked then return a.unlocked end
    if a.reqsmismatch ~= b.reqsmismatch then return a.reqsmismatch end
    return a.priority > b.priority
  end)


  local shown_num = 0

  local num = math.min(self.num_slots, #self.valid_recipes)

	if self.idx > #self.valid_recipes - (self.num_slots - 1)  then
		self.idx = #self.valid_recipes - (self.num_slots - 1)
	end

  if self.idx < -1 then
      self.idx = -1
  end


  for k = 0, num do
      local recipe_idx = (self.idx + k )
      local recipe = self.valid_recipes[recipe_idx+1]

      if recipe then
        local slot = self.craftslots.slots[k + 1]
        if slot then
            slot:SetRecipe( recipe )
            shown_num = shown_num + 1
        end
      end
  end

  if self.idx >= 0 then
		self.downbutton:Enable()
	else
		self.downbutton:Disable()
	end

	if #self.valid_recipes < self.idx + self.num_slots then
		self.upbutton:Disable()
    else
		self.upbutton:Enable()
	end
end

function FoodCrafting:ScrollUp()
  Crafting.ScrollUp(self)
  self:UpdateRecipes()
end

function FoodCrafting:ScrollDown()
  Crafting.ScrollDown(self)
  self:UpdateRecipes()
end

return FoodCrafting
