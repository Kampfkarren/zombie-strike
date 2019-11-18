local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Data = require(ReplicatedStorage.Core.Data)
local Loot = require(ReplicatedStorage.Core.Loot)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local ViewportFramePreviewComponent = require(ReplicatedStorage.Core.UI.Components.ViewportFramePreviewComponent)

local e = Roact.createElement
local LocalPlayer = Players.LocalPlayer

local ItemButton = Roact.Component:extend("ItemButton")

function ItemButton:init()
	self:setState({
		hovered = false,
		model = Data.GetModel(self.props.Loot),
	})
end

function ItemButton:shouldUpdate(nextProps, nextState)
	for key, value in pairs(nextProps.Loot) do
		if self.props.Loot[key] ~= value then
			return true
		end
	end

	return self.props.state ~= nextState
		and (self.props.LayoutOrder ~= nextProps.LayoutOrder or self.props.equipped ~= nextProps.equipped)
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

		[Roact.Event.MouseEnter] = function()
			self:setState({
				hovered = true,
			})

			props.onHover(props.Loot)
		end,

		[Roact.Event.MouseLeave] = function()
			self:setState({
				hovered = false,
			})

			props.onUnhover(props.Loot)
		end,

		[Roact.Event.Activated] = function()
			if not props.equipped then
				if props.Loot.Level > LocalPlayer.PlayerData.Level.Value then
					StarterGui:SetCore("ChatMakeSystemMessage", {
						Text = "You're not a high enough level to equip that!",
						Color = Color3.fromRGB(252, 92, 101),
						Font = Enum.Font.GothamSemibold,
					})
				else
					props.equip()
				end
			end
		end,
	}, {
		ViewportFrame = e(ViewportFramePreviewComponent, {
			Model = self.state.model,

			Native = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.9, 0.9),
			},
		}),
	})
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
