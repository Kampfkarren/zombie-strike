local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assign = require(ReplicatedStorage.Core.assign)
local CircleBackground = require(ReplicatedStorage.Core.UI.Components.CircleBackground)
local Data = require(ReplicatedStorage.Core.Data)
local Loot = require(ReplicatedStorage.Core.Loot)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local ViewportFramePreviewComponent = require(ReplicatedStorage.Core.UI.Components.ViewportFramePreviewComponent)

local e = Roact.createElement

local ItemButton = Roact.PureComponent:extend("ItemButton")

local ICON_FAVORITED = "rbxassetid://4462267516"
local ICON_UNFAVORITED = "rbxassetid://4462267332"

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

	self.favorite = function()
		ReplicatedStorage.Remotes.FavoriteLoot:FireServer(self.props.Loot.UUID)
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
		FavoriteFrame = e("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.88, 0.09),
			Size = UDim2.fromScale(0.2, 0.2),
		}, {
			e(CircleBackground, {}, {
				FavoriteButton = e("ImageButton", {
					BackgroundTransparency = 1,
					Image = props.Loot.Favorited and ICON_FAVORITED or ICON_UNFAVORITED,
					Size = UDim2.fromScale(1, 1),
					[Roact.Event.Activated] = self.favorite,
				}),
			}),
		}),

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
