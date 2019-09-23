local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CoreData = {}

function CoreData.GetModel(data)
	local itemType = data.Type

	local uuid = Instance.new("StringValue")
	uuid.Name = "UUID"
	uuid.Value = data.UUID

	if itemType == "Armor" then
		local armorItem = ReplicatedStorage.Items["Armor" .. data.Model]
		local shirt = armorItem:FindFirstChildOfClass("Shirt")

		if shirt then
			local pants = armorItem:FindFirstChildOfClass("Pants")

			local armorDummy = ReplicatedStorage.ArmorDummy:Clone()
			armorDummy.Shirt.ShirtTemplate = shirt.ShirtTemplate
			armorDummy.Pants.PantsTemplate = pants.PantsTemplate

			uuid.Parent = armorDummy

			return armorDummy
		else
			error("don't know how to handle " .. data.Model)
		end
	elseif itemType == "Helmet" then
		local helmetItem = ReplicatedStorage.Items["Helmet" .. data.Model]
		local hat = helmetItem:FindFirstChildOfClass("Accessory")

		if hat then
			local hat = hat:Clone()
			local model = Instance.new("Model")
			hat.Parent = model
			model.PrimaryPart = hat.Handle
			uuid.Parent = model
			return model
		else
			error("don't know how to handle " .. data.Model)
		end
	else
		local model = ReplicatedStorage.Items[data.Type .. data.Model]:Clone()
		uuid.Parent = model
		return model
	end
end

return CoreData
