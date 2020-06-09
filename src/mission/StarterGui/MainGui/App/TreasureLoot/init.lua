local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local GlowAura = require(ReplicatedStorage.Core.UI.Components.GlowAura)
local ItemDetails = require(ReplicatedStorage.Core.UI.Components.ItemDetails)
local Loot = require(ReplicatedStorage.Core.Loot)
local LootStyles = require(ReplicatedStorage.Core.LootStyles)
local PerkDetails = require(ReplicatedStorage.Core.UI.Components.PerkDetails)
local PerkUtil = require(ReplicatedStorage.Core.Perks.PerkUtil)
local PlayerDataConsumer = require(ReplicatedStorage.Core.UI.Components.PlayerDataConsumer)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local Scale = require(ReplicatedStorage.Core.UI.Components.Scale)
local Spin = require(ReplicatedStorage.Core.UI.Components.Spin)

local e = Roact.createElement
local LocalPlayer = Players.LocalPlayer

local TreasureLoot = Roact.PureComponent:extend("TreasureLoot")

local PRODUCT_EPIC = 934232605
local PRODUCT_LEGENDARY = 934232697

local function copy(list)
	local copy = {}
	for key, value in pairs(list) do
		copy[key] = value
	end
	return copy
end

local function DashLine(props)
	return e("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0.1, 0.1, 0.1),
		BorderSizePixel = 1,
		Position = props.Right and UDim2.fromScale(1, 0),
		Size = UDim2.fromScale(0.005, 1),
	})
end

function TreasureLoot:init()
	self.buyHotkey = UserInputService.InputBegan:connect(function(inputObject, processed)
		if processed then return end
		if inputObject.KeyCode == Enum.KeyCode.B and self.props.open then
			self.props.buyLoot()
		end
	end)
end

function TreasureLoot:willUnmount()
	self.buyHotkey:Disconnect()
end

function TreasureLoot:render()
	if not self.props.treasure
		or self.props.equippedWeapon == nil
		or not self.props.open
		or self.props.bought
	then
		return nil
	end

	return e(PlayerDataConsumer, {
		Name = "Level",
		Render = function(level)
			local hotkey

			if UserInputService.KeyboardEnabled then
				hotkey = e("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Position = UDim2.fromScale(0.5, 0.6),
					Size = UDim2.fromScale(0.25, 0.1),
					Text = "Press [B] to unlock!",
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					TextStrokeColor3 = Color3.new(0.1, 0.1, 0.1),
					TextStrokeTransparency = 0,
					ZIndex = 10,
				})
			else
				hotkey = e("TextButton", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.fromRGB(76, 209, 55),
					BorderSizePixel = 0,
					Font = Enum.Font.GothamBold,
					Position = UDim2.fromScale(0.5, 0.1),
					Size = UDim2.fromScale(0.25, 0.1),
					Text = "BUY",
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					[Roact.Event.Activated] = self.props.buyLoot,
				})
			end

			local loot = copy(self.props.treasure)
			loot.Level = level
			loot.Perks = PerkUtil.DeserializePerks(loot.Perks)

			local lootStyle = LootStyles[loot.Rarity]

			return e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}, {
				ItemDetails = e("Frame", {
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.02, 0.5),
					Size = UDim2.fromOffset(535, 895),
				}, {
					Scale = e(Scale, {
						Size = Vector2.new(535, 895),
					}),

					ItemPreview = e(ItemDetails, {
						CompareTo = self.props.equippedWeapon,
						Item = loot,
						GetName = Loot.GetLootName,
						ShowGearScore = true,
					}),

					PerkDetails = e(PerkDetails, {
						Perks = loot.Perks,
						Seed = loot.Seed,

						RenderParent = function(element, size)
							return e("Frame", {
								AnchorPoint = Vector2.new(1, 1),
								BackgroundTransparency = 1,
								Position = UDim2.new(0.8, 0, 1, -75),
								Size = UDim2.new(size.X, UDim.new(1, 0)),
							}, {
								Bottom = e("Frame", {
									AnchorPoint = Vector2.new(0, 1),
									BackgroundTransparency = 1,
									Position = UDim2.fromScale(1, 1),
									Size = size,
								}, {
									PerkDetails = element,
								}),
							})
						end,
					}),

					GlowAura = e("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1, 1),
						ZIndex = 0,
					}, {
						UIAspectRatioConstraint = e("UIAspectRatioConstraint"),

						Spin = e(Spin, {
							Speed = 8,
						}, {
							GlowAura = e(GlowAura, {
								Color = lootStyle.Color,
							}),
						}),
					}),
				}),

				Notice = e("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Position = UDim2.fromScale(0.5, 0.2),
					Size = UDim2.fromScale(0.4, 0.15),
					Text = "This chest gives " .. lootStyle.Name:upper() .." loot to your WHOLE TEAM!",
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					TextStrokeColor3 = Color3.new(0.1, 0.1, 0.1),
					TextStrokeTransparency = 0,
				}, {
					Left = e(DashLine),
					Right = e(DashLine, { Right = true }),
				}),

				Hotkey = hotkey,
			})
		end,
	})
end

return RoactRodux.connect(function(state)
	return {
		equippedWeapon = state.equipment and state.equipment.equippedWeapon,

		bought = state.treasureLoot.bought,
		open = state.treasureLoot.open,
		treasure = state.treasureLoot.loot,

		buyLoot = function()
			if not RunService:IsRunning() then
				print("buyLoot")
				return
			end

			local epic = state.treasureLoot.loot.Rarity == 4
			MarketplaceService:PromptProductPurchase(
				LocalPlayer,
				epic and PRODUCT_EPIC or PRODUCT_LEGENDARY
			)
		end,
	}
end)(TreasureLoot)
