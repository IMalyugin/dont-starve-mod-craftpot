require "class"

local TileBG = require "widgets/tilebg"
local InventorySlot = require "widgets/invslot"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local TabGroup = require "widgets/tabgroup"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"

local mainfunctions = require "mainfunctions"
require "widgets/widgetutil"

local DELTA_TAG = 0.5
local TEX_TAGS = {meat="Meats",monster="Monster Foods",veggie="Vegetables",fruit="Fruits",egg="Eggs",sweetener="Sweets",inedible="Inedibles",dairy="Dairies",fat="Fat",frozen="Ice",magic="Magic",decoration="Decoration",seeds="Seeds"}

local FoodIngredientUI = Class(Widget, function(self, element, is_min, owner) -- atlas, image, quantity, name, is_name,
  Widget._ctor(self, "FoodIngredientUI")

	self.owner = owner

	if element.name then
		self.alias = element.name
		self.is_name = true
	else
		self.alias = element.tag
		self.is_name = false
	end
	self.quantity = element.amt

	self.is_min = is_min

	-- initialize localized_name, atlas and item_tex
	self:DefineAssetData()

	-- initialize Icon Background
  local hud_atlas = resolvefilepath( "images/hud.xml" )
  self.valid_bg = self:AddChild(Image(hud_atlas, "inv_slot.tex"))
  self.invalid_bg = self:AddChild(Image(hud_atlas, "resource_needed.tex"))

	-- initialize Icon Image
	--print(self.atlas.." : "..self.item_tex)
	self.img = self:AddChild(Image(self.atlas, self.item_tex))

	-- initialize current quantity output
	if self.is_min then
		if self.is_name and self.quantity == 1 or not self.is_name and self.quantity <= DELTA_TAG then
			self.mask = ""
		else
			self.mask = "%g/%g"
		end
	else
		if self.quantity == 0 then
			self.mask = ""
		else
			self.mask = "%g/%g"
		end
	end
  if JapaneseOnPS4() then
    self.quant = self:AddChild(Text(SMALLNUMBERFONT, 30))
  else
    self.quant = self:AddChild(Text(SMALLNUMBERFONT, 24))
  end
  self.quant:SetPosition(7,-32, 0)

	-- initialize name
  self:SetTooltip(self.localized_name)
  --self:SetClickable(false)
end)

function FoodIngredientUI:DefineAssetData()
	self.item_tex = self.alias..'.tex'
	self.atlas = resolvefilepath("images/inventoryimages.xml")
	self.localized_name = STRINGS.NAMES[string.upper(self.alias)] or self.alias

	if self.is_name then
		if PREFABDEFINITIONS[self.alias] then
			for idx,asset in ipairs(PREFABDEFINITIONS[self.alias].assets) do
				if asset.type == "INV_IMAGE" then
					self.item_tex = asset.file..'.tex'
				elseif asset.type == "ATLAS" then
					self.atlas = asset.file
				end
			end
		end
	else
		if TEX_TAGS[self.alias] then
			self.atlas = resolvefilepath("images/food_tags.xml")
			self.localized_name = TEX_TAGS[self.alias]
		else
			if PREFABDEFINITIONS[self.alias] then
				for idx,asset in ipairs(PREFABDEFINITIONS[self.alias].assets) do
					if asset.type == "INV_IMAGE" then
						self.item_tex = asset.file..'.tex'
					elseif asset.type == "ATLAS" then
						self.atlas = asset.file
					end
				end
			end
		end
	end
end

function FoodIngredientUI:Update(on_hand)
  local valid = (self.is_min and (on_hand >= self.quantity)) or (not self.is_min and (on_hand <= self.quantity))
	self:_SetValid(valid)
	self.quant:SetString(string.format(self.mask, on_hand, self.quantity))
end

function FoodIngredientUI:_SetValid(valid)
	if valid then
		self.valid_bg:Show()
		self.invalid_bg:Hide()
		self.quant:SetColour(255/255,255/255,255/255,1)
	else
		self.invalid_bg:Show()
		self.valid_bg:Hide()
		self.quant:SetColour(255/255,155/255,155/255,1)
	end
end

return FoodIngredientUI
