local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AutomatedScrollingFrameComponent = require(ReplicatedStorage.Core.UI.Components.AutomatedScrollingFrameComponent)
local Bosses = require(ReplicatedStorage.Core.Bosses)
local Campaigns = require(ReplicatedStorage.Core.Campaigns)
local CollectionLogUtil = require(ReplicatedStorage.Libraries.CollectionLogUtil)
local Context = require(script.Parent.Context)
local Loot = require(ReplicatedStorage.Core.Loot)
local LootStyles = require(ReplicatedStorage.Core.LootStyles)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local function filter(name, callback)
	return {
		Name = name,
		Filter = callback,
	}
end

local filters = {
	filter("All", function()
		return true
	end),

	filter("Guns", Loot.IsWeapon),
	filter("Armor", Loot.IsWearable),
	filter("Perks", function(loot)
		return loot.Type == "Perk"
	end),
	filter("Pets", Loot.IsPet),
	filter("Attachments", Loot.IsAttachment),
}

local function filterLootFrom(location)
	return function(loot)
		if loot.Source.Method == CollectionLogUtil.ItemSourceMethod.MultipleSources then
			return false
		end

		local lootTable = location.Loot[loot.Type]
		if lootTable then
			return table.find(lootTable[LootStyles[loot.Rarity].Name], loot.Model) ~= nil
		end
	end
end

for _, campaign in ipairs(Campaigns) do
	table.insert(filters, filter(campaign.Name, filterLootFrom(campaign)))
end

for _, boss in ipairs(Bosses) do
	if next(boss.Loot) ~= nil then
		table.insert(filters, filter(boss.Name, filterLootFrom(boss)))
	end
end

local function FilterButton(props)
	return e(Context.Consumer, {
		render = function(context)
			return e("TextButton", {
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = context.selectedFilter.Name == props.filter.Name and 0.7 or 0.4,
				BorderSizePixel = 0,
				LayoutOrder = props.index,
				Size = UDim2.new(1, 0, 0, 100),
				Text = "",

				[Roact.Event.Activated] = function()
					context.updateSelectedFilter(props.filter)
				end,
			}, {
				UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
					AspectRatio = 3,
				}),

				UIGradient = e("UIGradient", {
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(0.1, 0.2),
						NumberSequenceKeypoint.new(0.5, 0),
						NumberSequenceKeypoint.new(0.9, 0.2),
						NumberSequenceKeypoint.new(1, 1),
					}),
				}),

				UIPadding = e("UIPadding", {
					PaddingLeft = UDim.new(0.08, 0),
					PaddingRight = UDim.new(0.08, 0),
					PaddingTop = UDim.new(0.1, 0),
					PaddingBottom = UDim.new(0.1, 0),
				}),

				TextLabel = e("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Size = UDim2.fromScale(1, 1),
					Text = props.filter.Name,
					TextColor3 = Color3.new(0.95, 0.95, 0.95),
					TextScaled = true,
					TextStrokeTransparency = 0.2,
				}),
			})
		end,
	})
end

local function CollectionLogFilters()
	local contents = {
		UIListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0.01, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	}

	for index, filter in ipairs(filters) do
		contents["Filter" .. filter.Name] = e(FilterButton, {
			index = index,
			filter = filter,
		})
	end

	return e(AutomatedScrollingFrameComponent, {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, contents)
end

return CollectionLogFilters
