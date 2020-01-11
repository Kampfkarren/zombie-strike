local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assign = require(ReplicatedStorage.Core.assign)
local Memoize = require(ReplicatedStorage.Core.Memoize)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local StyledButton = require(ReplicatedStorage.Core.UI.Components.StyledButton)

local e = Roact.createElement

local InventoryFilter = Roact.Component:extend("InventoryFilter")

local function BreakLine(props)
	return e("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromScale(0.98, 0.005),
	})
end

local function Label(props)
	return e("TextLabel", {
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		LayoutOrder = props.LayoutOrder,
		Size = props.Size,
		Text = props.Text,
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
end

local function Checkbox(props)
	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		Size = props.Size,
	}, {
		UIListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0.02, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Button = e(StyledButton, {
			BackgroundColor3 = Color3.new(0.5, 0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			Square = true,
			[Roact.Event.Activated] = props.OnClick,
		}, {
			UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
			Label = e("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.75, 0.75),
				Text = props.Checked and "X" or "",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
			}),
		}),

		Label = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			LayoutOrder = 2,
			Size = UDim2.fromScale(0.7, 1),
			Text = props.Text,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
	})
end

function InventoryFilter:init()
	self.toggleFilter = Memoize(function(filterName)
		return function()
			local filters = self.props.Filters:getValue()

			self.props.UpdateFilters(assign({
				[filterName] = not filters[filterName],
			}, filters))

			self:setState(self.state)
		end
	end)
end

function InventoryFilter:render()
	local props = self.props
	local filters = props.Filters:getValue()

	local layoutOrder = 0

	local function nextLayoutOrder()
		layoutOrder = layoutOrder + 1
		return layoutOrder
	end

	local function makeCheckbox(name)
		return e(Checkbox, {
			Checked = filters[name],
			LayoutOrder = nextLayoutOrder(),
			OnClick = self.toggleFilter(name),
			Size = UDim2.fromScale(0.8, 0.07),
			Text = name:upper(),
		})
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		Contents = e("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.01, 0),
			Size = UDim2.fromScale(0.99, 1),
		}, {
			UIListLayout = e("UIListLayout", {
				Padding = UDim.new(0.01, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			LabelFilter = e(Label, {
				LayoutOrder = nextLayoutOrder(),
				Size = UDim2.fromScale(1, 0.1),
				Text = "FILTERS",
			}),

			ShowHelmets = makeCheckbox("Helmets"),
			ShowArmor = makeCheckbox("Armor"),
			ShowWeapons = makeCheckbox("Weapons"),
			ShowAttachments = makeCheckbox("Attachments"),
			ShowCosmetics = makeCheckbox("Cosmetics"),

			BreakLine = e(BreakLine, {
				LayoutOrder = nextLayoutOrder(),
			}),

			ShowCommon = makeCheckbox("Common"),
			ShowUncommon = makeCheckbox("Uncommon"),
			ShowRare = makeCheckbox("Rare"),
			ShowEpic = makeCheckbox("Epic"),
			ShowLegendary = makeCheckbox("Legendary"),
		}),
	})
end

local function createStateBinding()
	return Roact.createBinding({
		Helmets = true,
		Armor = true,
		Weapons = true,
		Attachments = true,
		Cosmetics = true,

		Common = true,
		Uncommon = true,
		Rare = true,
		Epic = true,
		Legendary = true,
	})
end

return {
	CreateStateBinding = createStateBinding,
	Component = InventoryFilter,
}
