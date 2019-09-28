local ReplicatedStorage = game:GetService("ReplicatedStorage")

local inspect = require(ReplicatedStorage.Core.inspect)

local CoreData = {}

local function getDataItem(data)
	if data.Model then
		-- Standard item
		return ReplicatedStorage.Items[data.Type .. data.Model]
	else
		return data.Instance
	end
end

function CoreData.GetModel(data)
	local itemType = data.Type

	local uuid = {} -- luacheck: ignore

	assert(data.UUID ~= nil, "UUID is nil! " .. inspect(data))
	uuid = Instance.new("StringValue")
	uuid.Name = "UUID"
	uuid.Value = data.UUID

	if itemType == "Armor" then
		local armorItem = getDataItem(data)
		local shirt = armorItem:FindFirstChildOfClass("Shirt")

		if shirt then
			local pants = armorItem:FindFirstChildOfClass("Pants")

			local armorDummy = ReplicatedStorage.ArmorDummy:Clone()
			armorDummy.Shirt.ShirtTemplate = shirt.ShirtTemplate
			armorDummy.Shirt.Color3 = shirt.Color3
			armorDummy.Pants.PantsTemplate = pants.PantsTemplate
			armorDummy.Pants.Color3 = pants.Color3

			uuid.Parent = armorDummy
			return armorDummy
		elseif armorItem:FindFirstChild("UpperTorso") then
			-- Cosmetic
			local armorDummy = ReplicatedStorage.ArmorDummy:Clone()

			for _, limb in pairs(armorItem:GetChildren()) do
				armorDummy.Humanoid:ReplaceBodyPartR15(limb.Name, limb:Clone())
			end

			uuid.Parent = armorDummy
			return armorDummy
		else
			error("don't know how to handle " .. inspect(data))
		end
	elseif itemType == "Helmet" then
		local helmetItem = getDataItem(data)

		local hat

		if helmetItem:IsA("Accessory") or helmetItem:IsA("BasePart") then
			hat = helmetItem
		else
			hat = helmetItem:FindFirstChildOfClass("Accessory")
		end

		if hat then
			local hat = hat:Clone()
			local model = Instance.new("Model")
			hat.Parent = model

			if hat:IsA("Accessory") then
				model.PrimaryPart = hat.Handle
			else
				assert(hat:IsA("BasePart"), "not an accessory nor a basepart: " .. inspect(helmetItem))
				model.PrimaryPart = hat
			end

			uuid.Parent = model
			return model
		else
			error("don't know how to handle " .. inspect(data))
		end
	else
		local model = ReplicatedStorage.Items[data.Type .. data.Model]:Clone()
		uuid.Parent = model
		return model
	end
end

return CoreData
