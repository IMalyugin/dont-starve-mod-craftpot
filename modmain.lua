local require = GLOBAL.require
local Vector3 = GLOBAL.Vector3
local GetPlayer = GLOBAL.GetPlayer

local MouseFoodCrafting = require "widgets/mousefoodcrafting"

Assets = {
	Asset("ATLAS", "images/food_tags.xml"),
	Asset("ATLAS", "images/recipe_hud.xml"),
}
--local require = GLOBAL.require
--local cooking = require "cooking"
--local recipes = cooking.recipes["cookpot"] or {}
--local ingredients = cooking.ingredients or {}

local function OnLoad(player)
    player:AddComponent('knownfoods')
end

local function OnAfterLoad(player)
  if not player.components.knownfoods then
    player:AddComponent('knownfoods')
  end
	local config = {lock_uncooked=GetModConfigData("lock_uncooked")}
  player.components.knownfoods:OnAfterLoad(config)
end

local function ControlsPostInit(self)
  local num_slots = 7
  self.foodcrafting = self.containerroot:AddChild(MouseFoodCrafting(num_slots))
  self.foodcrafting:Hide()
end

local function CookerPostInit(inst)
	if not inst.components.stewer then return end

-- store base metods
  local onopenfn = inst.components.container.onopenfn
  local onclosefn = inst.components.container.onclosefn
	local ondonecookingfn = inst.components.stewer.ondonecooking

-- define modded actions
  local function mod_onopen(inst)
    if onopenfn then onopenfn(inst) end
    GetPlayer().HUD.controls.foodcrafting:Open(inst)
  end

  local function mod_onclose(inst)
    if onclosefn then onclosefn(inst) end
    GetPlayer().HUD.controls.foodcrafting:Close(inst)
  end

	local function mod_ondonecooking(inst)
    if ondonecookingfn then ondonecookingfn(inst) end
		local foodname = inst.components.stewer.product
		GetPlayer().components.knownfoods:IncrementCookCounter(foodname)
  end

	local function cookerchangefn(inst)
		local HUD = GetPlayer().HUD
		if HUD then HUD.controls.foodcrafting:UpdateRecipes() end
	end

-- override methods
  inst.components.container.onopenfn = mod_onopen
  inst.components.container.onclosefn = mod_onclose
	inst.components.stewer.ondonecooking = mod_ondonecooking

	inst:ListenForEvent("itemget", cookerchangefn)
	inst:ListenForEvent("itemlose", cookerchangefn)
end


AddPlayerPostInit(OnLoad)
AddSimPostInit(OnAfterLoad)
AddClassPostConstruct("widgets/controls", ControlsPostInit)

-- AddComponentPostInit("stewer",StewerPostInit)
-- sadly we have to try every prefab ingame, since we just can't bind events onto postinit of stewer.host prefab
AddPrefabPostInitAny(CookerPostInit)
