local ReplicatedStorage = game:GetService("ReplicatedStorage")

local t = require(ReplicatedStorage.Vendor.t)

local Items = ReplicatedStorage.Items

local cosmeticType = t.array(t.union(
	t.strictInterface({
		Name = t.string,
		Type = t.literal("Face"),
		Instance = t.instanceIsA("Decal"),
	}),

	t.strictInterface({
		Name = t.string,
		Type = t.union(
			t.literal("LowTier"),
			t.literal("HighTier")
		),
		Instance = t.instanceIsA("Folder"),
	})
))

local Cosmetics = {}

Cosmetics.Cosmetics = {
	{
		Name = "Chill",
		Type = "Face",
		Instance = Items.Face_Chill.Face,
	},

	{
		Name = "Doge",
		Type = "LowTier",
		Instance = Items.Bundle_Doge,
	},

	{
		Name = "Ud'zal",
		Type = "HighTier",
		Instance = Items.Bundle_Udzal,
	},
}

Cosmetics.Distribution = {
	-- Face = 2,
	-- Particle = 2,
	-- LowTier = 2,
	HighTier = 1,
	LowTier = 1,
	Face = 1,
}

function Cosmetics.GetStoreItems()
	local date = os.date("!*t")
	local rng = Random.new(date.year + date.yday)

	local collated = {}

	for _, cosmetic in ipairs(Cosmetics.Cosmetics) do
		if collated[cosmetic.Type] then
			table.insert(collated[cosmetic.Type], cosmetic)
		else
			collated[cosmetic.Type] = { cosmetic }
		end
	end

	local contents = {}

	for key, amount in pairs(Cosmetics.Distribution) do
		local products = {}

		for _ = 1, amount do
			table.insert(products, table.remove(collated[key], rng:NextInteger(1, #collated[key])))
		end

		contents[key] = products
	end

	return contents
end

assert(cosmeticType(Cosmetics.Cosmetics))

return Cosmetics
