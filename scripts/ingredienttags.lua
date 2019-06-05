-- define or redefine global variable to store tag data
global("FOODTAGDEFINITIONS")
FOODTAGDEFINITIONS = FOODTAGDEFINITIONS or {}

--
-- A public API for ingredient tag management
-- This function should be used by modders to add info about food tags, specifically atlas
-- Function performs merge, so it is safe to call multiple times or with different data
--
-- So Far TagData only takes following keys: atlas, tex, name
local AddFoodTags = function(tag, data)
  local mergedData = FOODTAGDEFINITIONS[tag] or {}

  for k, v in pairs(data) do
    mergedData[k] = v
  end

  FOODTAGDEFINITIONS[tag] = mergedData
end

-- common tags
AddFoodTags('meat', { name= 'Meats', atlas="images/food_tags.xml" })
AddFoodTags('veggie', { name="Vegetables", atlas="images/food_tags.xml" })
AddFoodTags('fish', { name="Fish", atlas="images/food_tags.xml" })
AddFoodTags('sweetener', { name="Sweets", atlas="images/food_tags.xml" })

AddFoodTags('monster', { name="Monster Foods", atlas="images/food_tags.xml" })
AddFoodTags('fruit', { name="Fruits", atlas="images/food_tags.xml" })
AddFoodTags('egg', { name="Eggs", atlas="images/food_tags.xml" })
AddFoodTags('inedible', { name="Inedibles", atlas="images/food_tags.xml" })

AddFoodTags('frozen', { name="Ice", atlas="images/food_tags.xml" })
AddFoodTags('magic', { name="Magic", atlas="images/food_tags.xml" })
AddFoodTags('decoration', { name="Decoration", atlas="images/food_tags.xml" })
AddFoodTags('seed', { name="Seeds", atlas="images/food_tags.xml" })

AddFoodTags('dairy', { name="Dairies", atlas="images/food_tags.xml" })
AddFoodTags('fat', { name="Fat", atlas="images/food_tags.xml" })

AddFoodTags('alkaline', { name="Alkaline", atlas="images/food_tags.xml" })
AddFoodTags('flora', { name="Flora", atlas="images/food_tags.xml" })
AddFoodTags('fungus', { name="Fungi", atlas="images/food_tags.xml" })
AddFoodTags('leek', { name="Leek", atlas="images/food_tags.xml" })
AddFoodTags('citrus', { name="Citrus", atlas="images/food_tags.xml" })

AddFoodTags('dairy_alt', { name="Dairy", atlas="images/food_tags.xml" })
AddFoodTags('fat_alt', { name="Fat", atlas="images/food_tags.xml" })

AddFoodTags('mushrooms', { name="Mushrooms", atlas="images/food_tags.xml" })
AddFoodTags('nut', { name="Nuts", atlas="images/food_tags.xml" })
AddFoodTags('poultry', { name="Poultries", atlas="images/food_tags.xml" })
AddFoodTags('pungent', { name="Pungents", atlas="images/food_tags.xml" })
AddFoodTags('grapes', { name="Grapes", atlas="images/food_tags.xml" })

AddFoodTags('decoration_alt', { name="Decoration", atlas="images/food_tags.xml" })
AddFoodTags('seed_alt', { name="Seeds", atlas="images/food_tags.xml" })

AddFoodTags('root', { name="Roots", atlas="images/food_tags.xml" })
AddFoodTags('seafood', { name="Seafood", atlas="images/food_tags.xml" })
AddFoodTags('shellfish', { name="Shellfish", atlas="images/food_tags.xml" })
AddFoodTags('spices', { name="Spices", atlas="images/food_tags.xml" })
AddFoodTags('wings', { name="Wings", atlas="images/food_tags.xml" })

AddFoodTags('monster_alt', { name="Monster Foods", atlas="images/food_tags.xml" })
AddFoodTags('sweetener_alt', { name="Sweets", atlas="images/food_tags.xml" })

AddFoodTags('squash', { name="Squash", atlas="images/food_tags.xml" })
AddFoodTags('starch', { name="Starch", atlas="images/food_tags.xml" })
AddFoodTags('tuber', { name="Tuber", atlas="images/food_tags.xml" })
AddFoodTags('precook', { name="Precooked", atlas="images/food_tags.xml" })
AddFoodTags('cactus', { name="Cactus", atlas="images/food_tags.xml" })

global("AddFoodTags")
AddFoodTags = AddFoodTags
