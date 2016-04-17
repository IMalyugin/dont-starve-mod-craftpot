local foods=
{
	butterflymuffin = {
    minnames = {butterflywings=1},
    maxnames = {},
    mintags = {veggie=0},
    maxtags = {meat=0}
	},
  frogglebunwich = {
    --TODO minfoods = {{froglegs=1},{froglegs_cooked=1}},
    minnames = {froglegs=1},
    maxnames = {},
    mintags = {veggie=0},
    maxtags = {},
		minmix = { {name={"froglegs","froglegs_cooked"},amt=1},{tag='veggie',amt=1} }
  }
}


for foodname, recipe in pairs(foods) do
	if not recipe.cooker then
		foods[foodname].cooker = 'cookpot'
	end
end

return foods
