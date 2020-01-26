local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AutomatedScrollingFrameComponent = require(script.Parent.AutomatedScrollingFrameComponent)
local EquipmentInfo = require(ReplicatedStorage.Core.UI.Components.EquipmentInfo)
local EquipmentUtil = require(ReplicatedStorage.Core.EquipmentUtil)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local SilhouetteModel = require(ReplicatedStorage.Core.SilhouetteModel)
local StyledButton = require(ReplicatedStorage.Core.UI.Components.StyledButton)
local ViewportFramePreviewComponent = require(ReplicatedStorage.Core.UI.Components.ViewportFramePreviewComponent)

local Equipment = Roact.Component:extend("Equipment")
local EquipmentButton = Roact.Component:extend("EquipmentButton")

local EquipmentModules = ReplicatedStorage.Equipment

local e = Roact.createElement

local function copy(list)
	local copy = {}
	for index, value in pairs(list) do
		copy[index] = value
	end
	return copy
end

local function Title(props)
	return e("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		LayoutOrder = 0,
		Size = UDim2.fromScale(0.9, 0.1),
		Text = props.Text,
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
	})
end

function EquipmentButton:init()
	self.model = EquipmentUtil.GetModel(self.props.Type, self.props.Index)
	self.silhouetteModel = SilhouetteModel(self.model:Clone())

	self.activated = function()
		if self.props.Owned then
			ReplicatedStorage.Remotes.UpdateEquipmentInventory:FireServer(
				self.props.Type == "HealthPack" and 1 or 2,
				self.props.Index
			)
		end
	end

	self.onHover = function()
		local props = self.props
		props.OnHover(props.Type, props.Index, not props.Owned)
		self:setState({
			hovered = true,
		})
	end

	self.onUnhover = function()
		local props = self.props
		props.OnUnhover(props.Type, props.Index)
		self:setState({
			hovered = false,
		})
	end
end

function EquipmentButton:render()
	local props = self.props

	local color = EquipmentUtil.GetColor(props.Type)
	if props.Owned and self.state.hovered then
		local h, s, v = Color3.toHSV(color)
		color = Color3.fromHSV(h, s, v * 0.7)
	end

	return e(StyledButton, {
		BackgroundColor3 = props.Owned and color or Color3.new(0.3, 0.3, 0.3),
		LayoutOrder = props.Owned and props.Index or 1000 + props.Index,
		Square = true,
		[Roact.Event.Activated] = self.activated,
		[Roact.Event.MouseEnter] = self.onHover,
		[Roact.Event.MouseLeave] = self.onUnhover,
	}, {
		Preview = e(ViewportFramePreviewComponent, {
			Model = props.Owned and self.model or self.silhouetteModel,

			Native = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.95, 0.95),
			},
		}),
	})
end

local function EquipmentContents(props)
	local children = {}

	children.UIGridLayout = e("UIGridLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	for index = 1, #EquipmentModules[props.Type]:GetChildren() do
		children["Button" .. index] = e(EquipmentButton, {
			Equipped = false, -- TODO
			Index = index,
			Owned = table.find(props.Inventory, index) ~= nil,
			Type = props.Type,
			OnHover = props.OnHover,
			OnUnhover = props.OnUnhover,
		})
	end

	return e(AutomatedScrollingFrameComponent, {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0.9, 0.8),
	}, children)
end

function Equipment:init()
	self:setState({
		lootStack = {},
	})

	self.onHover = function(type, index, silhouette)
		local lootStack = copy(self.state.lootStack)
		table.insert(lootStack, {
			Loot = {
				Type = type,
				Index = index,
			},
			Silhouette = silhouette,
		})

		self:setState({
			lootStack = lootStack,
		})
	end

	self.onUnhover = function(type, index)
		local lootStack = copy(self.state.lootStack)

		for lootIndex, value in pairs(lootStack) do
			if value.Loot.Type == type and value.Loot.Index == index then
				table.remove(lootStack, lootIndex)
				break
			end
		end

		self:setState({
			lootStack = lootStack,
		})
	end
end

function Equipment:didUpdate(previousProps)
	if previousProps.inventory ~= self.props.inventory and next(self.state.lootStack) ~= nil then
		self:setState({
			lootStack = {},
		})
	end
end

function Equipment:render()
	local inventory = self.props.inventory
	if inventory == nil then
		return Roact.createFragment()
	end

	local listLayout = e("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0.01, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	})

	local grenadeInfo, healthPackInfo
	local _, loot = next(self.state.lootStack)

	if loot then
		if loot.Loot.Type == "Grenade" then
			grenadeInfo = e(EquipmentInfo, {
				Loot = loot.Loot,
				Silhouette = loot.Silhouette,
			})
		else
			healthPackInfo = e(EquipmentInfo, {
				Loot = loot.Loot,
				Silhouette = loot.Silhouette,
			})
		end
	end

	return e("ImageButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(18, 18, 18),
		BackgroundTransparency = 1,
		Image = "",
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.6, 0.7),
		Visible = self.props.open,
	}, {
		e("UIAspectRatioConstraint", {
			AspectRatio = 2,
			AspectType = Enum.AspectType.ScaleWithParentSize,
			DominantAxis = Enum.DominantAxis.Height,
		}),

		HealthPacks = e("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 121, 121),
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.5, 1),
		}, {
			Inner = e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}, {
				UIListLayout = listLayout,

				Title = e(Title, {
					Text = "HEALTH PACKS",
				}),

				Equipment = e(EquipmentContents, {
					Inventory = inventory.HealthPack,
					Type = "HealthPack",
					OnHover = self.onHover,
					OnUnhover = self.onUnhover,
				}),
			}),

			GrenadeInfo = e("Frame", {
				BackgroundColor3 = Color3.new(0, 0, 0),
				BackgroundTransparency = grenadeInfo and 0.5 or 1,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 1),
			}, {
				Inner = grenadeInfo,
			}),
		}),

		Grenades = e("Frame", {
			BackgroundColor3 = Color3.fromRGB(186, 220, 88),
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(0.5, 1),
		}, {
			Inner = e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}, {
				UIListLayout = listLayout,

				Title = e(Title, {
					Text = "TACTICAL",
				}),

				Equipment = e(EquipmentContents, {
					Inventory = inventory.Grenade,
					Type = "Grenade",
					OnHover = self.onHover,
					OnUnhover = self.onUnhover,
				}),
			}),

			HealthPackInfo = e("Frame", {
				BackgroundColor3 = Color3.new(0, 0, 0),
				BackgroundTransparency = healthPackInfo and 0.5 or 1,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 1),
			}, {
				Inner = healthPackInfo,
			}),
		}),
	})
end

return RoactRodux.connect(function(state)
	return {
		inventory = state.inventoryEquipment,
		open = state.page.current == "Equipment",
	}
end)(Equipment)
