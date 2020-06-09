local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CapBundles = ReplicatedStorage.Assets.Tarmac.UI.cap_bundles

local images = {}

for _, module in ipairs(CapBundles:GetChildren()) do
	images[tonumber(module.Name)] = require(module)
end

return {
	{
		Caps = 740,
		Cost = 425,
		Image = images[1],
	},

	{
		Caps = 6275,
		Cost = 3185,
		Image = images[2],
		Value = 12,
	},

	{
		Caps = 14350,
		Cost = 7320,
		Image = images[3],
		Value = 12,
	},

	{
		Caps = 22000,
		Cost = 10520,
		Image = images[4],
		Value = 25,
	},

	{
		Caps = 56000,
		Cost = 26499,
		Image = images[5],
		Value = 25,
	},

	{
		Caps = 160000,
		Cost = 61240,
		Image = images[6],
		Value = 50,
	},
}
