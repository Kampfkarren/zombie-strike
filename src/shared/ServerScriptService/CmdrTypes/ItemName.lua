local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Items = ReplicatedStorage.Items

local util
local ItemName = {}

function ItemName.Transform(text)
	local itemNames = {}

	for _, item in ipairs(Items:GetChildren()) do
		local itemType = item.ItemType.Value

		if itemType == "Helmet"
			or itemType == "Armor"
			or itemType == "Gun"
		then
			table.insert(itemNames, {
				Name = item.ItemName.Value .. " (" .. item.Name .. ")",
				Item = item,
			})
		end
	end

	return util.MakeFuzzyFinder(itemNames)(text)
end

function ItemName.Validate(value)
	return #value > 0, "No item with that name."
end

function ItemName.Autocomplete(value)
	local itemNames = {}

	for _, item in ipairs(value) do
		table.insert(itemNames, item.Name)
	end

	return itemNames
end

function ItemName.Parse(value)
	return value[1].Item
end

return function(registry)
	util = registry.Cmdr.Util
	registry:RegisterType("itemName", ItemName)
end
