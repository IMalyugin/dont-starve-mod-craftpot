require "class"

local Widget = require "widgets/widget"
local TileBG = require "widgets/tilebg"
--local InventorySlot = require "widgets/invslot"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
--local Widget = require "widgets/widget"
--local TabGroup = require "widgets/tabgroup"
--local UIAnim = require "widgets/uianim"
--local Text = require "widgets/text"
local FoodSlot = require "widgets/foodslot"--mod
local FoodItem = require "widgets/fooditem"--mod
local FoodCrafting = Class(Widget, function(self, num_slots, owner)
  Widget._ctor(self, "FoodCrafting")

	self.owner = owner

  self.bg = self:AddChild(TileBG(HUD_ATLAS, "craft_slotbg.tex"))

  --slots
  self.num_slots = num_slots
  self.foodslots = {} -- numeric array holding num_slot foodslots
	self.allfoods = {} -- sorted numeric array of all cooking recipes as fooditems
	self.selfoods = {} -- filtered and sorted numeric array of recipes
	self.shownfoods = {} -- assoc array of foods currently shown in foodslots
	self.focusitem = nil
	self.invIngs = nil -- ingredient values of all the items stored in player inventory
	self.cookerIngs = nil -- ingredient values of items put into the cooker

	self.idx = -1

  self.open = false

	for slot_idx=1,num_slots do
		local foodslot = FoodSlot(self.owner, self, slot_idx)
		table.insert(self.foodslots, foodslot)
		self:AddChild(foodslot)
	end
end)

function FoodCrafting:OnAfterLoad()
  --- create all the recipes
  local recipes = self.owner.components.knownfoods:GetKnownFoods()
  for foodname, recipe in pairs(recipes) do
    local fooditem = FoodItem(self.owner, self, recipe)
    table.insert(self.allfoods, fooditem)
    self:AddChild(fooditem)
		fooditem:Hide()
  end

	--buttons
  self.downbutton = self:AddChild(ImageButton(HUD_ATLAS, "craft_end_normal.tex", "craft_end_normal_mouseover.tex", "craft_end_normal_disabled.tex"))
  self.upbutton = self:AddChild(ImageButton(HUD_ATLAS, "craft_end_normal.tex", "craft_end_normal_mouseover.tex", "craft_end_normal_disabled.tex"))
  self.downbutton:SetOnClick(function() self:ScrollDown() end)
  self.upbutton:SetOnClick(function() self:ScrollUp() end)

	self:SetOrientation(false) -- only vertical for now
end

function FoodCrafting:SetOrientation(horizontal)
    self.horizontal = horizontal
    self.bg.horizontal = horizontal
    if horizontal then
        self.bg.sepim = "craft_sep_h.tex"
    else
        self.bg.sepim = "craft_sep.tex"
    end

		if not self.horizontal then
	    self:SetPosition(305,0,0)
	  end

    self.bg:SetNumTiles(self.num_slots)
    local slot_w, slot_h = self.bg:GetSlotSize()
    local w, h = self.bg:GetSize()

    for k,foodslot in ipairs(self.foodslots) do
      local slotpos = self.bg:GetSlotPos(k)
      foodslot:SetPosition( slotpos.x,slotpos.y,slotpos.z )
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

function FoodCrafting:FoodFocus(slot_idx)
	print(slot_idx..' - '..self.idx)
	local focusIdx = slot_idx+self.idx
	if focusIdx > #self.selfoods then
		print("out of range")
		return false
	end
	local focusItem = self.selfoods[slot_idx+self.idx]
	if focusItem == self.focusItem then
		return
	end

	if self.focusItem then
		self.focusItem:HidePopup()
	end
	self.focusItem = focusItem

	self.focusItem:ShowPopup(self.cookerIngs, self.invIngs)
	self.focusIdx = slot_idx
end

function FoodCrafting:Open(cooker_inst)
	self._cooker = cooker_inst

  self._open = true
	self:Enable()
  self:Show()

	--if cooker_inst ~= self.last_cooker or self.sortneeded or self.filterneeded then
  	self:SortFoods()
	--end
end

function FoodCrafting:Close(cooker_inst)
  self._open = false
  self:Disable()
  self:Hide()
end

-- only this function can be called from the outside
function FoodCrafting:SortFoods()
	if not self._open then return end
	print ("---sortfoods")

	--self:_RefreshFoodStats()

	-- do nothing for now
	--[[table.sort(self.allfoods, function(a,b)
    if a.recipe.correctcooker ~= b.recipe.correctcooker then return a.recipe.correctcooker end
    if a.recipe.readytocook ~= b.recipe.readytocook then return a.recipe.readytocook end
    if b.recipe.name == "wetgoop" then return true elseif a.recipe.name == "wetgoop" then return false end

    if a.recipe.reqsmatch ~= b.recipe.reqsmatch then return a.recipe.reqsmatch end
    if a.recipe.unlocked ~= b.recipe.unlocked then return a.recipe.unlocked end
    if a.recipe.reqsmismatch ~= b.recipe.reqsmismatch then return a.recipe.reqsmismatch end
    return a.recipe.priority > b.recipe.priority
  end)]]
	self:FilterFoods()
end

function FoodCrafting:FilterFoods()
	self.selfoods = {}

	for idx, fooditem in ipairs(self.allfoods) do
		if not self.filterFn or self.filterFn(fooditem) then
			if self._cooker.prefab == 'cookpot' or fooditem.recipe.cookername == self._cooker.prefab then
				table.insert(self.selfoods, fooditem)
			end
		end
	end

	self:UpdateFoodSlots()
end

function FoodCrafting:UpdateFoodSlots()
	for idx, foodslot in ipairs(self.foodslots) do
		foodslot:ClearFood()
	end

	if self.idx > #self.selfoods - (self.num_slots )  then
		self.idx = #self.selfoods - (self.num_slots)
	end

  if self.idx < -1 then
    self.idx = -1
  end

	if self.idx > -1 then
		self.downbutton:Enable()
	else
		self.downbutton:Disable()
	end

	if #self.selfoods < self.idx + self.num_slots+1 then
		self.upbutton:Disable()
    else
		self.upbutton:Enable()
	end

	for idx=1, self.num_slots do
		local foodidx = idx + self.idx
		--print("looper")
		if foodidx > 0 and foodidx <= #self.selfoods then
			--print("setfood="..idx..":"..foodidx)
			self.foodslots[idx]:SetFood(self.selfoods[foodidx])
			--print('woot')
			self.selfoods[foodidx]:SetSlot(self.foodslots[idx])
			--print('what')
		end
	end
	--print("afterlooper")

	if self.focusItem then
		self.focusItem:HidePopup()
		self.focusItem = self.selfoods[self.focusIdx+self.idx]
		self.focusItem:ShowPopup()
	end
end

function FoodCrafting:OnControl(control, down)
  if FoodCrafting._base.OnControl(self, control, down) then return true end

  if down and self.focus then
    if control == CONTROL_MAP_ZOOM_IN then
      self:ScrollDown()
      return true
    elseif control == CONTROL_MAP_ZOOM_OUT then
      self:ScrollUp()
      return true
    end
  end
end

function FoodCrafting:ScrollUp()
  if not IsPaused() then
    local oldidx = self.idx
    self.idx = self.idx + 1
    self:UpdateFoodSlots()
    if self.idx ~= oldidx then
      self.owner.SoundEmitter:PlaySound("dontstarve/HUD/craft_up")
    end
  end
  --self:UpdateRecipes()
end

function FoodCrafting:ScrollDown()
  if not IsPaused() then
    local oldidx = self.idx
    self.idx = self.idx - 1
    self:UpdateFoodSlots()
    if self.idx ~= oldidx then
        self.owner.SoundEmitter:PlaySound("dontstarve/HUD/craft_down")
    end
  end
end

function FoodCrafting:OnGainFocus()
  FoodCrafting._base.OnGainFocus(self)
	TheCamera:SetControllable(false)
end

function FoodCrafting:OnLoseFocus()
  FoodCrafting._base.OnLoseFocus(self)
	TheCamera:SetControllable(true)

	if self.focusItem then
		self.focusItem:HidePopup()
		self.focusItem = nil
	end
end

function FoodCrafting:_RefreshFoodStats()
	local ingdata,num_ing = self:_GetContainerIngredientValues(self._cooker.components.container)

	self.cookerIngs = ingdata
	self.invIngs = nil

	local cook_priority = -9999
	for idx, fooditem in ipairs(self.allfoods) do
		local recipe = fooditem.recipe
		recipe.reqsmatch = false -- all the min requirements are met
		recipe.reqsmismatch = false -- all the max requirements are met
		recipe.readytocook = false -- all ingredients match recipe and cookpot is loaded
		recipe.specialcooker = recipe.cookername ~= self._basiccooker -- does the recipe require special cooker
		recipe.correctcooker = not recipe.specialcooker or recipe.cookername == self._cookername
		recipe.unlocked = not self._config.lock_uncooked or recipe.times_cooked and recipe.times_cooked > 0

		if not self:_TestMax(recipe.name, ingdata.names, ingdata.tags) then
			recipe.reqsmismatch = true
		end

		if self:_Test(recipe.name, ingdata.names, ingdata.tags) then
			recipe.reqsmatch = true
			if num_ing == 4 and recipe.correctcooker then
				recipe.readytocook = true
				if recipe.priority > cook_priority then
					cook_priority = recipe.priority
				end
			end
		end

		recipe.hide = num_ing > 0 and (not recipe.correctcooker or recipe.reqsmismatch)
	end

	if num_ing == 4 then -- show only dishes that have chance of cooking
		for idx, fooditem in ipairs(self.allfoods) do
			if recipe.readytocook then
				 if recipe.priority < cook_priority then
					 recipe.readytocook = false
					 recipe.hide = true
				 end
			else
				recipe.hide = true
			end
		end
	end
end

function FoodCrafting:_GetIngredientValues(prefablist)
	local names = {}
	local tags = {}
	for k,v in pairs(prefablist) do
		local name = self._aliases[v] or v
		names[name] = names[name] and names[name] + 1 or 1

		if self._ingredients[name] then
			for kk, vv in pairs(self._ingredients[name].tags) do
				tags[kk] = tags[kk] and tags[kk] + vv or vv
			end
		end
	end

	return {tags = tags, names = names}
end

function FoodCrafting:_GetContainerIngredientValues(container)
  local ings = {}
  for k,v in pairs(container.slots) do
    table.insert(ings, v.prefab)
  end
  return self:_GetIngredientValues(ings), #ings
end

return FoodCrafting
