local Cooking = require "cooking"

local KnownFoods = Class(function(self, owner)
  self.owner = owner
  self._dtag = 0.5
  self._basiccooker = 'cookpot'
  self._cooker = {} -- openned cooker inst
  self._cookername = self._basiccooker
  self._config = {} -- mod config goes in here onafterload
  self._knownfoods = {} -- enchanced format recipes
  self._cookerRecipes = {} -- raw format recipes
  self._ingredients = {} -- all known ingredients
  self._alltags = {} -- all known tags
  self._allnames ={} -- all known names
  self._oftenExcludedTags = {'meat','monster','veggie','frozen','inedible','eggs','fruit','sweetener','diary',''}

  self._aliases = {
  	cookedsmallmeat = "smallmeat_cooked",
  	cookedmonstermeat = "monstermeat_cooked",
  	cookedmeat = "meat_cooked"
  }

end)

function KnownFoods:OnSave()
	local data = {
    knownfoods = self._knownfoods
  }
	return data
end

function KnownFoods:OnLoad(data)
	if data then
    self._loadedRecipes = data.knownfoods
    local cnt = 0
    for key, val in pairs(self._loadedRecipes) do
      cnt = cnt + 1
    end
    print('Craft Pot ~~~ component loaded '..cnt..' known food recipes')
	else
    print('Craft Pot ~~~ component loaded with no data')
	end
end

function KnownFoods:SetCooker(inst)
  self._cooker = inst
  self._cookername = inst.prefab
end

function KnownFoods:OnAfterLoad(config)
  self._config = config

  self._ingredients = Cooking.ingredients
  self:_FillIngredients()
  for cookername,recipes in pairs(Cooking.recipes) do
    for foodname,recipe in pairs(recipes) do
      self._cookerRecipes[foodname] = recipe
      self._cookerRecipes[foodname].cookername = cookername

    end
  end

  -- first add all the loaded recipes
  if self._loadedRecipes then
    for foodname, recipe in pairs(self._loadedRecipes) do
      if self:MinimizeRecipe(foodname, recipe) then
        self._knownfoods[foodname] = recipe
      end
    end
  end

  -- then add all the simple recipes
  local simplePreparedFoods = require "simplepreparedfoods"
  for foodname, recipe in pairs(simplePreparedFoods) do
    if not self._knownfoods[foodname] and self:MinimizeRecipe(foodname, recipe) then
      self._knownfoods[foodname] = recipe
    end
  end

  -- finally attempt to extract missing recipes from the raw cookbook
  local unknownFoodnames = self:_GetUnknownFoodnames()
  if #unknownFoodnames > 0 then
    local rawRecipes = self:_BruteSearch(unknownFoodnames)
    for foodname, recipe in pairs(rawRecipes) do
      if self:MinimizeRecipe(foodname, recipe) then
        self._knownfoods[foodname] = recipe
      end
    end
  end

end

-- perform iterative search over preparedfood list and attempt to find their real recipes
function KnownFoods:_BruteSearch(remaining)
  local matches = {}
  local tags, tags1, tags2, tags3
  local backup

  print('Craft Pot ~~~ Brute Search initiated')
  print('Total unknown recipes: '..#remaining)

  -- step 1 all names and tags included
  self:_GroupTestTags(self._alltags, remaining, matches)
  print('Unknown recipes after step 1: '..#remaining)



  for num_names=3,1,-1 do -- try with all different amounts
    self:_FillIngredients(num_names)

    -- step 2 exclude all tags
    self:_GroupTestTags({}, remaining, matches)
    print('Unknown recipes after step 2-'..num_names..': '..#remaining)

    -- step 3 add one tag
    for inc1,_v in pairs(self._alltags) do
      tags = {}
      tags[inc1] = 1

      self:_GroupTestTags(tags, remaining, matches)
    end
    print('Unknown recipes after step 3-'..num_names..': '..#remaining)

    if num_names <= 2 then
      -- step 4 add two tags
      for inc1,_v in pairs(self._alltags) do
        tags = {}
        tags[inc1] = 1
        for inc2,_v in pairs(self._alltags) do
          tags2 = self:_CopyTable(tags)
          tags2[inc2] = tags2[inc2] and tags2[inc2] + 1 or 1

          self:_GroupTestTags(tags2, remaining, matches)
        end
      end
      print('Unknown recipes after step 4-'..num_names..': '..#remaining)
    end

    if num_names == 1 then
      -- step 5 add three tags
      for inc1,_v in pairs(self._alltags) do
        tags = {}
        tags[inc1] = 1
        for inc2,_v in pairs(self._alltags) do
          tags2 = self:_CopyTable(tags)
          tags2[inc2] = tags2[inc2] and tags2[inc2] + 1 or 1
          for inc3,_v in pairs(self._alltags) do
            tags3 = self:_CopyTable(tags2)
            tags3[inc3] = tags3[inc3] and tags3[inc3] + 1 or 1

            self:_GroupTestTags(tags3, remaining, matches)
          end
        end
      end
      print('Unknown recipes after step 5: '..#remaining)
    end

  end

  --- test all 4 names no tags
  self:_FillIngredients(4)
  self:_GroupTestTags({}, remaining, matches)
  print('Unknown recipes after step 6: '..#remaining)

  -- test all 3 names, exclude 1-2 tag --TODO change to include 3 tags full
  self:_FillIngredients(3)
  for exclude1,_v in pairs(self._alltags) do
    self._alltags[exclude1] = nil
    for exclude2,_v in pairs(self._alltags) do
      self._alltags[exclude2] = nil
      self:_GroupTestTags(self._alltags, remaining, matches)
      self._alltags[exclude2] = 3
    end
    self._alltags[exclude1] = 3
  end
  print('Unknown recipes after step 7: '..#remaining)

  self:_FillIngredients() -- back to default

  for idx,name in ipairs(remaining) do
    print("Craft Pot ~~~ Could not find recipe for "..name)
  end

  return matches
end

function KnownFoods:_CopyTable(table)
  local t = {}
  for k,v in pairs(table) do
    t[k] = v
  end
  return t
end

function KnownFoods:_GroupTestTags(in_tags, inout_remaining, out_matches)
  for idx=#inout_remaining,1,-1 do
    local foodname = inout_remaining[idx]
    if self._knownfoods[foodname] or self:_Test(foodname, self._allnames, in_tags) then
      out_matches[foodname] = self:_RawToSimple(self._allnames, in_tags)
      table.remove(inout_remaining,idx)
    end
  end
end

function KnownFoods:_RawToSimple(names, tags)
  local recipe = {
    minnames = {},
    mintags = {},
    maxnames = {},
    maxtags = {}
  }

  for name, amount in pairs(names) do
    if amount < 1000 then
      recipe.maxnames[name] = amount
    end
    if amount > 0 then
      recipe.minnames[name] = amount
    end
  end

  for tag, amount in pairs(tags) do
    if amount < 1000 then
      recipe.maxtags[tag] = amount
    end
    if amount > 0 then
      recipe.mintags[tag] = amount
    end
  end

  return recipe
end

function KnownFoods:MinimizeRecipe(foodname,recipe)
  -- save foodname inside of the recipe

  -- validate recipe existence
  if not self._cookerRecipes[foodname] then
    self._exknownfoods[foodname] = recipe
    print("Craft Pot ~~~ Could not find global recipe for "..foodname)
    return false
  end

  recipe.name = foodname
  recipe.cookername = self._cookerRecipes[foodname].cookername
  recipe.priority = self._cookerRecipes[foodname].priority

  -- validate used names and tags
  local names = {}
  local tags = {}

  for name, amount in pairs(recipe.minnames) do
    names[name] = amount
  end

  for tag, amount in pairs(recipe.mintags) do
    tags[tag] = amount
  end

  if not self:_Test(foodname, names, tags) then
    print("Craft Pot ~~~ Invalid recipe for "..foodname)
    return false
  end

  local buffer = nil

  -- *************
  -- find minnames
  -- *************
  for name,amount in pairs(names) do
    names[name] = nil
    if self:_Test(foodname, names, tags) then -- _Test[nil] == true, not a required name
      recipe.minnames[name] = nil
    else -- _Test[nil] == false, minname is required
      names[name] = amount - 1

      if not self:_Test(foodname, names, tags) then -- _Test[amount-1] == false, valid minname
        names[name] = amount
      else -- _Test[amount-1] == true, invalid restriction
        names[name] = 1
        while not self:_Test(foodname, names, tags) and names[name] <= 4 do
          names[name] = names[name] + 1
        end
        recipe.minnames[name] = names[name]
      end
    end
  end

  -- ************
  -- find mintags
  -- ************
  for tag,amount in pairs(tags) do
    tags[tag] = nil
    if self:_Test(foodname, names, tags) then -- _Test[nil] == true, not a required tag
      recipe.mintags[tag] = nil
    else -- _Test[nil] == false, mintag is required
      tags[tag] = amount - self._dtag

      if not self:_Test(foodname, names, tags) then -- _Test[amount-1] == false, valid mintag
        tags[tag] = amount
      else -- _Test[amount-1] == true, invalid restriction
        tags[tag] = self._dtag
        while not self:_Test(foodname, names, tags) and tags[tag] < 1001 do
          tags[tag] = tags[tag] + self._dtag
        end
        recipe.mintags[tag] = tags[tag]
      end
    end
  end

  -- *************
  -- find maxnames
  -- *************
  local maxtest

  for name,_ in pairs(self._allnames) do
    buffer = names[name] or nil

     maxtest = math.max(recipe.minnames[name] and recipe.minnames[name] + 1 or 0, recipe.maxnames[name] and recipe.maxnames[name] + 1 or 0, 1)
     names[name] = maxtest
    if self:_Test(foodname, names, tags) then -- _Test[amount+1] == true, invalid restriction
      names[name] = 4
      if self:_Test(foodname, names, tags) then -- _Test[amount+1] == true and _Test[1000] == true, no restriction needed
        recipe.maxnames[name] = nil
      else -- _Test[amount+1] == true and _Test[1000] == false, restriction is somwhere above
        names[name] = maxtest + 1
        while self:_Test(foodname, names, tags) and names[name] <= 4 do
          names[name] = names[name] + 1
        end
        recipe.maxnames[name] = names[name] - 1
      end
    else -- _Test[amount+1] == false, valid restriction, but maybe we could reduce it
      repeat
        names[name] = names[name] - 1
      until names[name] <= 0 or self:_Test(foodname,names,tags)
      recipe.maxnames[name] = names[name]
    end

    names[name] = buffer
  end

  -- ************
  -- find maxtags
  -- ************
  for tag,_ in pairs(self._alltags) do
    buffer = tags[tag] or nil

    maxtest = math.max(recipe.mintags[tag] and recipe.mintags[tag] + self._dtag or 0, recipe.maxtags[tag] and recipe.maxtags[tag] + self._dtag or 0, self._dtag)
    tags[tag] = maxtest
    if self:_Test(foodname, names, tags) then -- _Test[amount+1] == true, invalid restriction
      tags[tag] = 1000
      if self:_Test(foodname, names, tags) then -- _Test[amount+1] == true and _Test[1000] == true, no restriction needed
        recipe.maxtags[tag] = nil
      else -- _Test[amount+1] == true and _Test[1000] == false, restriction is somwhere above
        tags[tag] = maxtest + self._dtag
        while self:_Test(foodname, names, tags) and tags[tag] < 1001 do
          tags[tag] = tags[tag] + self._dtag
        end
        recipe.maxtags[tag] = tags[tag] - self._dtag
      end
    else -- _Test[amount+1] == false, valid restriction, but maybe we could reduce it
      repeat
        tags[tag] = tags[tag] - self._dtag
      until tags[tag] <= 0 or self:_Test(foodname,names,tags)
      recipe.maxtags[tag] = tags[tag]
    end

    tags[tag] = buffer
  end

  return true
end

function KnownFoods:_Test(foodname, names, tags)
  if self._cookerRecipes[foodname].test(self._basiccooker, names, tags) then -- cooker here has no meaning
    return true
  end
  return false
end

function KnownFoods:_TestMax(foodname, names, tags)
  local recipe = self._knownfoods[foodname]
  if not recipe then
    print('Error in KnownFoods:_TestMax - attempting to test non existant recipe')
    return false
  end

  for name, amt in pairs(names) do

    if recipe.maxnames[name] and amt > recipe.maxnames[name] then
      return false
    end
  end

  for tag, amt in pairs(tags) do
    if recipe.maxtags[tag] and amt > recipe.maxtags[tag] then
      return false
    end
  end

  return true
end

function KnownFoods:_FillIngredients(num_names)
  for name, data in pairs(self._ingredients) do
    self._allnames[name] = num_names and num_names or 4
    for tag, amount in pairs(data.tags) do
      if not self._alltags[tag] then
        self._alltags[tag] = 1000
      end
    end
  end
end

function KnownFoods:_GetUnknownFoodnames()
  local unknown = {}

  for foodname,recipe in pairs(self._cookerRecipes) do
    if not self._knownfoods[foodname] then
      table.insert(unknown, foodname)
    end
  end

  return unknown
end

function KnownFoods:IncrementCookCounter(foodname)
  local times_cooked = self._knownfoods[foodname].times_cooked or 0
  if self._knownfoods[foodname] then
    self._knownfoods[foodname].times_cooked = times_cooked + 1
  end
  self.owner.HUD.controls.foodcrafting:UpdateRecipes()
end

function KnownFoods:GetIngredientValues(prefablist)
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

function KnownFoods:GetCookerIngredientValues()
  local ings = {}
  for k,v in pairs(self._cooker.components.container.slots) do
    table.insert(ings, v.prefab)
  end
  return self:GetIngredientValues(ings), #ings
end

function KnownFoods:GetCookBook()
  local recipes = self._knownfoods

  local ingdata,num_ing = self:GetCookerIngredientValues()
  local cook_priority = -9999
  for foodname, recipe in pairs(recipes) do
    recipes[foodname].reqsmatch = false -- all the min requirements are met
    recipes[foodname].reqsmismatch = false -- all the max requirements are met
    recipes[foodname].readytocook = false -- all ingredients match recipe and cookpot is loaded
    recipes[foodname].specialcooker = recipe.cookername ~= self._basiccooker -- does the recipe require special cooker
    recipes[foodname].correctcooker = not recipe.specialcooker or recipe.cookername == self._cookername
    recipes[foodname].unlocked = not self._config.lock_uncooked or recipe.times_cooked and recipe.times_cooked > 0

    --recipes[foodname].unlocked = false

    if not self:_TestMax(foodname, ingdata.names, ingdata.tags) then
      recipes[foodname].reqsmismatch = true
    end

    if self:_Test(foodname, ingdata.names, ingdata.tags) then
      recipes[foodname].reqsmatch = true
      if num_ing == 4 and recipe.correctcooker then
        recipes[foodname].readytocook = true
        if recipe.priority > cook_priority then
          cook_priority = recipe.priority
        end
      end
    end

    recipes[foodname].hide = num_ing > 0 and (not recipe.correctcooker or recipe.reqsmismatch)
  end

  if num_ing == 4 then -- show only dishes that have chance of cooking
    for foodname, recipe in pairs(recipes) do
      if recipe.readytocook then
         if recipe.priority < cook_priority then
           recipes[foodname].readytocook = false
           recipes[foodname].hide = true
         end
      else
        recipes[foodname].hide = true
      end
    end
  end

  return recipes
end

return KnownFoods
