local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CosmeticsDictionary = require(ReplicatedStorage.Core.CosmeticsDictionary)
local CosmeticsStore = require(ReplicatedStorage.Core.CosmeticsStore)
local t = require(ReplicatedStorage.Vendor.t)

local dateStamp

if RunService:IsClient() and RunService:IsRunning() then
	dateStamp = ReplicatedStorage.Remotes.GetServerDateStamp:InvokeServer()
end

local cosmeticType = t.array(t.union(
	t.strictInterface({
		Index = t.number,
		Name = t.string,
		Type = t.literal("Face"),
		Instance = t.instanceIsA("Decal"),
		DontSellMe = t.optional(t.boolean),
	}),

	t.strictInterface({
		Index = t.number,
		Name = t.string,
		Type = t.literal("Particle"),
		Instance = t.instanceIsA("Folder"),
		Image = t.instanceIsA("Decal"),
		DontSellMe = t.optional(t.boolean),
	}),

	t.strictInterface({
		Index = t.number,
		Name = t.string,
		Type = t.union(
			t.literal("LowTier"),
			t.literal("HighTier")
		),
		Instance = t.instanceIsA("Folder"),
		DontSellMe = t.optional(t.boolean),
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
		DontSellMe = t.optional(t.boolean),
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
		DontSellMe = t.optional(t.boolean),
	}),

	t.strictInterface({
		Index = t.number,
		Name = t.string,
		Type = t.union(
			t.literal("GunLowTier"),
			t.literal("GunHighTier")
		),
		Instance = t.instanceIsA("Folder"),
		DontSellMe = t.optional(t.boolean),
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
		Cost = 4400,
	},

	LowTier = {
		Count = 2,
		Cost = 1800,
	},

	Face = {
		Count = 2,
		Cost = 250,
	},

	Particle = {
		Count = 2,
		Cost = 900,
	},

	GunHighTier = {
		Count = 1,
		Cost = 1499,
	},

	GunLowTier = {
		Count = 2,
		Cost = 1199,
	},
}

function Cosmetics.CostOf(itemType)
	return Cosmetics.Distribution[itemType].Cost
end

function Cosmetics.GetStoreItems()
	local stamp

	if RunService:IsServer() then
		local date = os.date("!*t")
		stamp = date.year + date.yday
	else
		stamp = dateStamp
	end

	local rng = Random.new(stamp)
	local collated = {}

	for _, cosmetic in ipairs(Cosmetics.Cosmetics) do
		if Cosmetics.Distribution[cosmetic.Type] and not cosmetic.DontSellMe then
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

	-- Apply explicit store patch
	local storePatch = CosmeticsStore[stamp]
	if storePatch then
		for key, stuff in pairs(storePatch) do
			local patchedContents = {}
			for _, item in ipairs(CosmeticsDictionary) do
				if item.Type == key then
					local needed = table.find(stuff, item.Name)
					if needed then
						patchedContents[needed] = item
					end
				end
			end
			assert(#patchedContents == #contents[key])
			contents[key] = patchedContents
		end
	end

	return contents
end

assert(cosmeticType(Cosmetics.Cosmetics))

return Cosmetics
