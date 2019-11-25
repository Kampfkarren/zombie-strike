local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assign = require(ReplicatedStorage.Core.assign)
local Data = require(ReplicatedStorage.Core.Data)
local Loot = require(ReplicatedStorage.Core.Loot)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local ViewportFramePreviewComponent = require(ReplicatedStorage.Core.UI.Components.ViewportFramePreviewComponent)

local e = Roact.createElement
local LocalPlayer = Players.LocalPlayer

local ItemButton = Roact.PureComponent:extend("ItemButton")

function ItemButton:init()
	self:setState({
		hovered = false,
		model = Data.GetModel(self.props.Loot),
	})

	self.mouseEnter = function()
		self:setState({
			hovered = true,
		})

		self.props.onHover(self.props.Loot)
	end

	self.mouseLeave = function()
		self:setState({
			hovered = false,
		})

		self.props.onUnhover(self.props.Loot)
	end

	self.activated = function()
		local props = self.props
		if props.equipped then
			props.onClickEquipped()
		else
			props.onClickUnequipped()
		end
	end
end

function ItemButton:render()
	local props = self.props

	local color = Loot.Rarities[props.Loot.Rarity].Color
	local h, s, v = Color3.toHSV(color)

	if props.equipped then
		color = Color3.fromHSV(h, s, v * 0.6)
	elseif self.state.hovered then
		color = Color3.fromHSV(h, s, v * 0.7)
	end

	return e("ImageButton", {
		BackgroundTransparency = 1,
		Image = "http://www.roblox.com/asset/?id=3973353646",
		ImageColor3 = color,
		LayoutOrder = props.LayoutOrder,

		[Roact.Event.Activated] = self.activated,
		[Roact.Event.MouseEnter] = self.mouseEnter,
		[Roact.Event.MouseLeave] = self.mouseLeave,
	}, assign({
		ViewportFrame = e(ViewportFramePreviewComponent, {
			Model = self.state.model,

			Native = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.9, 0.9),
			},
		}),
	}, props[Roact.Children] or {}))
end

return RoactRodux.connect(function(state, props)
	local lootType = props.Loot.Type

	if lootType ~= "Helmet" and lootType ~= "Armor" then
		lootType = "Weapon"
	end

	if state.equipment then
		return {
			equipped = state.equipment["equipped" .. lootType].UUID == props.Loot.UUID,
		}
	else
		return {}
	end
end)(ItemButton)
