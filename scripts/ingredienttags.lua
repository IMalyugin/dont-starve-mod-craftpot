-- define or redefine global variable to store tag data
global("FOODTAGDEFINITIONS")
FOODTAGDEFINITIONS = FOODTAGDEFINITIONS or {}

--
-- A public API for ingredient tag management
-- This function should be used by modders to add info about food tags, specifically atlas
-- Function performs merge, so it is safe to call multiple times or with different data
--
-- So Far TagData only takes following keys: atlas, tex, name
global("AddFoodTag")
AddFoodTag = function(tag, data)
  local mergedData = FOODTAGDEFINITIONS[tag] or {}

  for k, v in pairs(data) do
    mergedData[k] = v
  end

  FOODTAGDEFINITIONS[tag] = mergedData
end

-- common tags
AddFoodTag('meat', { name= 'Meats', atlas="images/food_tags.xml" })
AddFoodTag('veggie', { name="Vegetables", atlas="images/food_tags.xml" })
AddFoodTag('fish', { name="Fish", atlas="images/food_tags.xml" })
AddFoodTag('sweetener', { name="Sweets", atlas="images/food_tags.xml" })

AddFoodTag('monster', { name="Monster Foods", atlas="images/food_tags.xml" })
AddFoodTag('fruit', { name="Fruits", atlas="images/food_tags.xml" })
AddFoodTag('egg', { name="Eggs", atlas="images/food_tags.xml" })
AddFoodTag('inedible', { name="Inedibles", atlas="images/food_tags.xml" })

AddFoodTag('frozen', { name="Ice", atlas="images/food_tags.xml" })
AddFoodTag('magic', { name="Magic", atlas="images/food_tags.xml" })
AddFoodTag('decoration', { name="Decoration", atlas="images/food_tags.xml" })
AddFoodTag('seed', { name="Seeds", atlas="images/food_tags.xml" })

AddFoodTag('dairy', { name="Dairies", atlas="images/food_tags.xml" })
AddFoodTag('fat', { name="Fat", atlas="images/food_tags.xml" })

AddFoodTag('alkaline', { name="Alkaline", atlas="images/food_tags.xml" })
AddFoodTag('flora', { name="Flora", atlas="images/food_tags.xml" })
AddFoodTag('fungus', { name="Fungi", atlas="images/food_tags.xml" })
AddFoodTag('leek', { name="Leek", atlas="images/food_tags.xml" })
AddFoodTag('citrus', { name="Citrus", atlas="images/food_tags.xml" })

AddFoodTag('dairy_alt', { name="Dairy", atlas="images/food_tags.xml" })
AddFoodTag('fat_alt', { name="Fat", atlas="images/food_tags.xml" })

AddFoodTag('mushrooms', { name="Mushrooms", atlas="images/food_tags.xml" })
AddFoodTag('nut', { name="Nuts", atlas="images/food_tags.xml" })
AddFoodTag('poultry', { name="Poultries", atlas="images/food_tags.xml" })
AddFoodTag('pungent', { name="Pungents", atlas="images/food_tags.xml" })
AddFoodTag('grapes', { name="Grapes", atlas="images/food_tags.xml" })

AddFoodTag('decoration_alt', { name="Decoration", atlas="images/food_tags.xml" })
AddFoodTag('seed_alt', { name="Seeds", atlas="images/food_tags.xml" })

AddFoodTag('root', { name="Roots", atlas="images/food_tags.xml" })
AddFoodTag('seafood', { name="Seafood", atlas="images/food_tags.xml" })
AddFoodTag('shellfish', { name="Shellfish", atlas="images/food_tags.xml" })
AddFoodTag('spices', { name="Spices", atlas="images/food_tags.xml" })
AddFoodTag('wings', { name="Wings", atlas="images/food_tags.xml" })

AddFoodTag('monster_alt', { name="Monster Foods", atlas="images/food_tags.xml" })
AddFoodTag('sweetener_alt', { name="Sweets", atlas="images/food_tags.xml" })

AddFoodTag('squash', { name="Squash", atlas="images/food_tags.xml" })
AddFoodTag('starch', { name="Starch", atlas="images/food_tags.xml" })
AddFoodTag('tuber', { name="Tuber", atlas="images/food_tags.xml" })
AddFoodTag('precook', { name="Precooked", atlas="images/food_tags.xml" })
AddFoodTag('cactus', { name="Cactus", atlas="images/food_tags.xml" })
