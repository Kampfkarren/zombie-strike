local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AutomatedScrollingFrameComponent = require(script.Parent.Parent.AutomatedScrollingFrameComponent)
local Cosmetics = require(ReplicatedStorage.Core.Cosmetics)
local CosmeticButton = require(script.Parent.CosmeticButton)
local CosmeticPreview = require(script.Parent.CosmeticPreview)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)

local e = Roact.createElement
local Inventory = Roact.PureComponent:extend("Inventory")

local function EquipButton(props)
	local children = {}

	if props.Item then
		children.Preview = e(CosmeticPreview, {
			item = props.Item,
			size = UDim2.new(1, 0, 0.9, 0),
		})
	end

	children.Name = e("TextLabel", {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		LayoutOrder = props.LayoutOrder,
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0.25, 0),
		Text = props.Type,
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
	})

	return e("ImageButton", {
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
	}, children)
end

function Inventory:render()
	local contents = {
		e("UIGridLayout", {
			CellPadding = UDim2.new(0.01, 0, 0.02, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	}

	for _, itemIndex in pairs(self.props.contents) do
		local item = Cosmetics.Cosmetics[itemIndex]

		contents["Item" .. itemIndex] = e(CosmeticButton, {
			Native = {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = "http://www.roblox.com/asset/?id=3973353646",
				ImageTransparency = 0.5,
				LayoutOrder = itemIndex,
			},

			Item = item,
			PreviewSize = UDim2.new(1, 0, 1, 0),
		})
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
	}, {
		Equipped = e("Frame", {
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.7,
			BorderSizePixel = 0,
			Size = UDim2.new(0.3, 0, 1, 0),
		}, {
			e("UIGridLayout", {
				CellPadding = UDim2.new(0.01, 0, 0.01, 0),
				CellSize = UDim2.new(0.49, 0, 0.49, 0),

				FillDirection = Enum.FillDirection.Horizontal,
				FillDirectionMaxCells = 2,
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}, {
				e("UIAspectRatioConstraint"),
			}),

			e(EquipButton, {
				LayoutOrder = 1,
				Type = "Helmet",
				Item = self.props.equipped.Helmet,
			}),

			e(EquipButton, {
				LayoutOrder = 2,
				Type = "Armor",
				Item = self.props.equipped.Armor,
			}),

			e(EquipButton, {
				LayoutOrder = 3,
				Type = "Particle",
				Item = self.props.equipped.Particle,
			}),

			e(EquipButton, {
				LayoutOrder = 4,
				Type = "Face",
				Item = self.props.equipped.Face,
			}),
		}),

		Contents = e(AutomatedScrollingFrameComponent, {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.31, 0, 0.5, 0),
			Size = UDim2.new(0.68, 0, 0.95, 0),
			VerticalScrollBarInset = Enum.ScrollBarInset.Always,
		}, contents),
	})
end

return RoactRodux.connect(function(state)
	return {
		contents = state.store.contents,
		equipped = state.store.equipped,
	}
end)(Inventory)
