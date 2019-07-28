local function IsDST()
  return GLOBAL.TheSim:GetGameID() == "DST"
end

local function IsClientSim()
  return IsDST() and GLOBAL.TheNet:GetIsClient()
end

local function GetPlayer()
  if IsDST() then
    return GLOBAL.ThePlayer
  else
    return GLOBAL.GetPlayer()
  end
end

local function GetWorld()
  if IsDST() then
    return GLOBAL.TheWorld
  else
    return GLOBAL.GetWorld()
  end
end

local function AddPlayerPostInit(fn)
  if IsDST() then
    env.AddPrefabPostInit("world", function(wrld)
      wrld:ListenForEvent("playeractivated", function(wlrd, player)
        if player == GLOBAL.ThePlayer then
          fn(player)
        end
      end)
    end)
  else
    env.AddPlayerPostInit(function(player)
      fn(player)
    end)
  end
end


local require = GLOBAL.require
local TheInput = GLOBAL.TheInput

local MouseFoodCrafting = require "widgets/mousefoodcrafting"
require "ingredienttags"

Assets = {
  Asset("ATLAS", "images/food_tags.xml"),
  Asset("ATLAS", "images/recipe_hud.xml"),
}

local _SimLoaded = false
local _GameLoaded = false
local _ControlsLoaded = false
local _PlayerLoaded = false

local function OnAfterLoad(controls)
  if _GameLoaded ~= true or _SimLoaded ~= true or _PlayerLoaded ~= true or _ControlsLoaded ~= true then
    return false
  end

	--- OnAfterLoad may be executed once more if player gets rebuild,
	--- e.g.: it could happen if player repicked his character via Celestial Portal or such
	--- so we reset PlayerLoaded and ControlsLoaded to prevent double call on OnAfterLoad once that happens
	_PlayerLoaded = false
	_ControlsLoaded = false

	local player = GetPlayer()
	local foodcrafting = controls and controls.foodcrafting or player.HUD.controls.foodcrafting

	if player and player.components and player.components.knownfoods and foodcrafting then
    local config = {
      lock_uncooked=GetModConfigData("lock_uncooked"),
      invert_controller=GetModConfigData("invert_controller"),
      has_popup=GetModConfigData("has_popup"),
    }
    player.components.knownfoods:OnAfterLoad(config)
    foodcrafting:OnAfterLoad(config, player)
  end
end

local function OnPlayerLoad(player)
  _PlayerLoaded = true
  if not IsDST() then
    player:AddComponent('knownfoods')
  end
  OnAfterLoad()
end

local function OnSimLoad()
  _SimLoaded = true
  OnAfterLoad()
end

local function OnGameLoad()
  _GameLoaded = true
  OnAfterLoad()
end


local function ControlsPostInit(self)
  _ControlsLoaded = true
  if IsDST() then
    GetPlayer():AddComponent('knownfoods')
  end
    self.foodcrafting = self.containerroot:AddChild(MouseFoodCrafting())
    self.foodcrafting:Hide()
    OnAfterLoad(self)
end

local function ContainerPostConstruct(inst, prefab)
    -- if inst.type is not defined, it would mean that OnEntityReplicated has not been called yet
    if not inst.type and not inst.__craftPotPatched then
        -- this variable prevents possibility of endless loop for ContainerPostConstruct
        inst.__craftPotPatched = true

        -- thus we need to delay ContainerPostConstruct call until it is fully initialized
        if prefab and prefab.OnEntityReplicated then
            originalEntityReplicatedHandler = prefab.OnEntityReplicated
            prefab.OnEntityReplicated = function(...)
                originalEntityReplicatedHandler(...)
                ContainerPostConstruct(inst, prefab)
            end
        end
  end


  -- only apply mod to components that are cookers and that have no widget
  if not inst.type or inst.type ~= "cooker" or (not inst.widget or not inst.widget.buttoninfo) and IsDST() then
    return false
  end

  -- store base methods
  local onopenfn = inst.Open
  local onclosefn = inst.Close
  local getitemsfn = inst.GetItems
  local onstartcookingfn = inst.widget and inst.widget.buttoninfo.fn
  local ondonecookingfn = inst.inst.components.stewer and inst.inst.components.stewer.ondonecooking

  -- define modded actions
  local function mod_onopen(inst, doer, ...)
      onopenfn(inst, doer, ...)

    if doer == GetPlayer() then
    doer.HUD.controls.foodcrafting:Open(inst.GetItems and inst or inst.inst)
    end
  end

  local function mod_onclose(inst, ...)
      onclosefn(inst, ...)
    local player = GetPlayer()
    if player and player.HUD and player.HUD.controls and player.HUD.controls.foodcrafting and inst then
    player.HUD.controls.foodcrafting:Close(inst.inst)
    end
  end

  local function mod_onstartcooking(inst, ...)
    -- local doer = inst.components.container.opener
    local recipe = GetPlayer().HUD.controls.foodcrafting:GetProduct()
    if recipe ~= nil and recipe.name then
      GetPlayer().components.knownfoods:IncrementCookCounter(recipe.name)
    end
    onstartcookingfn(inst, ...)
    return items
  end

  local function mod_ondonecooking(inst, ...)
    if ondonecookingfn then ondonecookingfn(inst, ...) end
    local foodname = inst.components.stewer.product
    GetPlayer().components.knownfoods:IncrementCookCounter(foodname)
    return items
  end

  local function cookerchangefn(inst)
    local player = GetPlayer()
    if player and player.HUD then player.HUD.controls.foodcrafting:SortFoods() end
  end

  -- override methods
  inst.Open = mod_onopen
  inst.Close = mod_onclose
  if onstartcookingfn then
    inst.widget.buttoninfo.fn = mod_onstartcooking
  else
    inst.inst.components.stewer.ondonecooking = mod_ondonecooking
  end

  inst.inst:ListenForEvent("itemget", cookerchangefn)
  inst.inst:ListenForEvent("itemlose", cookerchangefn)
  --GetPlayer():ListenForEvent( "itemget", cookerchangefn)
  -- TODO: track itemget of additional open inventories
end


local function FollowCameraPostInit(inst)
  local old_can_control = inst.CanControl
  inst.CanControl = function(inst, ...)
    return old_can_control(inst, ...) and not GetPlayer().HUD.controls.foodcrafting:IsFocused()
  end
end

-- follow camera modification is required to cancel the scrolling
AddClassPostConstruct("cameras/followcamera", FollowCameraPostInit)

-- first block is used for DST clients, second - for DS/DST Host
if IsClientSim() then
  AddClassPostConstruct("components/container_replica",  ContainerPostConstruct)
else
  local function PrefabPostInitAny(inst)
    if inst.components.stewer then
      ContainerPostConstruct(inst.components.container)
    end
  end
  -- sadly we have to try every prefab ingame, since we just can't bind events onto postinit of stewer.host prefab
  AddPrefabPostInitAny(PrefabPostInitAny)
end

AddClassPostConstruct("screens/playerhud", function(inst)
  if TheInput:ControllerAttached() then
    --local old_open_controller_inventory = inst.OpenControllerInventory
    --[[inst.OpenControllerInventory = function(self)
      if not inst.controls.foodcrafting:IsOpen() then
        old_open_controller_inventory(self)
      end
    end]]

    local old_on_control = inst.OnControl
    inst.OnControl = function(self, control, down, ...)
      old_on_control(self, control, down, ...)
      if inst.controls.foodcrafting:IsOpen() then
        inst.controls.foodcrafting:OnControl(control, down)
      end
    end
  end

end)

AddClassPostConstruct("widgets/inventorybar", function(inst)
  if TheInput:ControllerAttached() then
    local actions = {
      CursorUp=   {GLOBAL.CONTROL_INVENTORY_UP, GLOBAL.CONTROL_MOVE_UP},
      CursorDown= {GLOBAL.CONTROL_INVENTORY_DOWN, GLOBAL.CONTROL_MOVE_DOWN},
      CursorLeft= {GLOBAL.CONTROL_INVENTORY_LEFT, GLOBAL.CONTROL_MOVE_LEFT},
      CursorRight={GLOBAL.CONTROL_INVENTORY_RIGHT, GLOBAL.CONTROL_MOVE_RIGHT}
    }
    for action, controls in pairs(actions) do
      local old_cursor_action = inst[action]
      inst[action] = function(self, ...)
        if not inst.owner.HUD.controls.foodcrafting:IsFocused()
          or TheInput:IsControlPressed(controls[GetModConfigData("invert_controller") and 2 or 1])
        then
          old_cursor_action(self, ...)
        else
          inst.owner.HUD.controls.foodcrafting
            :DoControl(controls[GetModConfigData("invert_controller") and 1 or 2])
        end
      end
    end
  end
end)

-- these three loads race each other, last one gets to launch OnAfterLoad
AddSimPostInit(OnSimLoad) -- fires before game init
AddGamePostInit(OnGameLoad) -- fires last, unless it is first game launch in DS, then it fires first
AddPlayerPostInit(OnPlayerLoad) -- fire last in DST, but first in DS, i think
AddClassPostConstruct("widgets/controls", ControlsPostInit)
