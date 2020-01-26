local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EquipmentUtil = require(ReplicatedStorage.Core.EquipmentUtil)
local Loot = require(ReplicatedStorage.Core.Loot)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local SilhouetteModel = require(ReplicatedStorage.Core.SilhouetteModel)
local ViewportFramePreviewComponent = require(ReplicatedStorage.Core.UI.Components.ViewportFramePreviewComponent)

local e = Roact.createElement

local EquipmentInfo = Roact.PureComponent:extend("EquipmentInfo")

function EquipmentInfo:init()
	self:UpdateModelState()
end

function EquipmentInfo:render()
	local lootInfo = self.props.Loot
	local loot = EquipmentUtil.FromIndex(lootInfo.Type, lootInfo.Index)

	local lootColor = EquipmentUtil.GetColor(lootInfo.Type)
	local lootType

	if lootInfo.Type == "Grenade" then
		lootType = "Tactical"
	elseif lootInfo.Type == "HealthPack" then
		lootType = "Health Pack"
	else
		error("unreachable code! loot.Type == " .. lootInfo.Type)
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		e("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.01, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Type = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			LayoutOrder = 1,
			Size = UDim2.new(0.9, 0, 0.06, 0),
			Text = self.props.Silhouette and "Play the Arena to unlock!" or lootType,
			TextColor3 = Color3.fromRGB(227, 227, 227),
			TextScaled = true,
		}),

		LootName = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			LayoutOrder = 2,
			Size = UDim2.new(0.9, 0, 0.15, 0),
			Text = self.props.Silhouette and "???" or loot.Name,
			TextColor3 = Color3.fromRGB(227, 227, 227),
			TextScaled = true,
		}),

		Preview = e(ViewportFramePreviewComponent, {
			Model = self.state.Model,

			Native = {
				BackgroundColor3 = lootColor,
				BackgroundTransparency = 0.6,
				BorderSizePixel = 0,
				LayoutOrder = 3,
				Size = UDim2.new(0.5, 0, 0.7, 0),
			},
		}),
	})
end

function EquipmentInfo:didUpdate(oldProps)
	if self.props.Loot ~= oldProps.Loot then
		self:UpdateModelState()
	end
end

function EquipmentInfo:UpdateModelState()
	local loot = self.props.Loot
	assert(Loot.IsEquipment(loot))

	local model = EquipmentUtil.GetModel(loot.Type, loot.Index)
	if self.props.Silhouette then
		model = SilhouetteModel(model:Clone())
	end

	self:setState({
		Model = model,
	})
end

return EquipmentInfo
