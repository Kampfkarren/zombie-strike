local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CoreData = {}

function CoreData.GetModel(data)
	local itemType = data.Type

	if itemType == "Armor" then
		local armorItem = ReplicatedStorage.Items["Armor" .. data.Model]
		local shirt = armorItem:FindFirstChildOfClass("Shirt")

		if shirt then
			local pants = armorItem.Pants

			local armorDummy = ReplicatedStorage.ArmorDummy:Clone()
			armorDummy.Shirt.ShirtTemplate = shirt.ShirtTemplate
			armorDummy.Pants.PantsTemplate = pants.PantsTemplate
			return armorDummy
		else
			error("don't know how to handle " .. data.Model)
		end
	elseif itemType == "Helmet" then
		local helmetItem = ReplicatedStorage.Items["Helmet" .. data.Model]
		local hat = helmetItem:FindFirstChild("Hat")

		if hat then
			local model = Instance.new("Model")
			hat:Clone().Parent = model
			model.PrimaryPart = model.Hat.Handle
			return model
		else
			error("don't know how to handle " .. data.Model)
		end
	else
		return ReplicatedStorage.Items[data.Type .. data.Model]:Clone()
	end
end

return CoreData
