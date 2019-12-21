local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CosmeticsDictionary = require(ReplicatedStorage.Core.CosmeticsDictionary)
local t = require(ReplicatedStorage.Vendor.t)

local dateStamp

if RunService:IsClient() then
	dateStamp = ReplicatedStorage.Remotes.GetServerDateStamp:InvokeServer()
end

local cosmeticType = t.array(t.union(
	t.strictInterface({
		Index = t.number,
		Name = t.string,
		Type = t.literal("Face"),
		Instance = t.instanceIsA("Decal"),
	}),

	t.strictInterface({
		Index = t.number,
		Name = t.string,
		Type = t.literal("Particle"),
		Instance = t.instanceIsA("Folder"),
		Image = t.instanceIsA("Decal"),
	}),

	t.strictInterface({
		Index = t.number,
		Name = t.string,
		Type = t.union(
			t.literal("LowTier"),
			t.literal("HighTier")
		),
		Instance = t.instanceIsA("Folder"),
	}),

	t.strictInterface({
		Index = t.number,
		Name = t.string,
		Type = t.literal("Armor"),
		Instance = t.union(t.instanceIsA("Folder")),
		ParentType = t.union(
			t.literal("LowTier"),
			t.literal("HighTier")
		),
	}),

	t.strictInterface({
		Index = t.number,
		Name = t.string,
		Type = t.literal("Helmet"),
		Instance = t.union(
			t.instanceIsA("Accessory"),
			t.instanceIsA("Folder"),
			t.instanceIsA("BasePart")
		),
		ParentType = t.union(
			t.literal("LowTier"),
			t.literal("HighTier")
		),
	})
))

local Cosmetics = {}

Cosmetics.Cosmetics = CosmeticsDictionary

for index, item in ipairs(Cosmetics.Cosmetics) do
	local itemType = item.Instance:FindFirstChild("ItemType")
	item.Index = index

	if itemType
		and (itemType.Value == "BundleSimple"
		or itemType.Value == "BundleComplex")
	then
		table.insert(Cosmetics.Cosmetics, index + 1, {
			Name = item.Name,
			Type = "Armor",
			Instance = item.Instance.Contents.Armor,
			ParentType = item.Type,
		})

		table.insert(Cosmetics.Cosmetics, index + 1, {
			Name = item.Name,
			Type = "Helmet",
			Instance = item.Instance.Contents.Helmet,
			ParentType = item.Type,
		})
	end
end

Cosmetics.Distribution = {
	HighTier = {
		Count = 1,
		Cost = 3199,
		UsualCost = 4400,
	},

	LowTier = {
		Count = 2,
		Cost = 1399,
		UsualCost = 1800,
	},

	Face = {
		Count = 2,
		Cost = 199,
		UsualCost = 250,
	},

	Particle = {
		Count = 2,
		Cost = 499,
		UsualCost = 900,
	},
}

function Cosmetics.GetStoreItems()
	local rng

	if RunService:IsServer() then
		local date = os.date("!*t")
		rng = Random.new(date.year + date.yday)
	else
		rng = Random.new(dateStamp)
	end

	local collated = {}

	for _, cosmetic in ipairs(Cosmetics.Cosmetics) do
		if Cosmetics.Distribution[cosmetic.Type] then
			if collated[cosmetic.Type] then
				table.insert(collated[cosmetic.Type], cosmetic)
			else
				collated[cosmetic.Type] = { cosmetic }
			end
		end
	end

	local contents = {}

	for key, passes in pairs(Cosmetics.Distribution) do
		local products = {}

		for _ = 1, passes.Count do
			table.insert(products, table.remove(collated[key], rng:NextInteger(1, #collated[key])))
		end

		contents[key] = products
	end

	return contents
end

assert(cosmeticType(Cosmetics.Cosmetics))

return Cosmetics
