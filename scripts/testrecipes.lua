local foods=
{
  frogglebunwich = {
    minmix = { {{name="froglegs",amt=2},{name="froglegs_cooked",amt=2}},{tag='veggie',amt=2} },
		minmix = { {{name="froglegs",amt=1},{name="froglegs_cooked",amt=1}},{tag='veggie',amt=1} },
    --maxmix = { {name={"froglegs","froglegs_cooked"},amt=2},{tag='veggie',amt=2} },
		--minmix = { {name={"froglegs","froglegs_cooked"},amt=1},{tag='veggie',amt=1} },
  }
}


for foodname, recipe in pairs(foods) do
	if not recipe.cooker then
		foods[foodname].cooker = 'cookpot'
	end
end

return foods
