local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CompareTo = require(ReplicatedStorage.Core.CompareTo)
local EquipmentInfo = require(ReplicatedStorage.Core.UI.Components.EquipmentInfo)
local GlowAura = require(ReplicatedStorage.Core.UI.Components.GlowAura)
local ItemDetailsComplete = require(ReplicatedStorage.Core.UI.Components.ItemDetailsComplete)
local LootStyles = require(ReplicatedStorage.Core.LootStyles)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local Scale = require(ReplicatedStorage.Core.UI.Components.Scale)
local Spin = require(ReplicatedStorage.Core.UI.Components.Spin)

local e = Roact.createElement

local function ArenaRewards(props)
	return e("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.03, 0.5),
		Size = UDim2.fromOffset(500, 750),
	}, {
		Scale = e(Scale, {
			Size = Vector2.new(500, 750),
		}),

		YouUnlocked = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Size = UDim2.new(1, 0, 0, 35),
			Text = "YOU UNLOCKED...",
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			TextStrokeTransparency = 0.2,
		}, {
			UITextSizeConstraint = e("UITextSizeConstraint", {
				MaxTextSize = 35,
			}),
		}),

		Inner = e("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 1, -35),
		}, {
			ItemDetails = props.ItemLoot and e(ItemDetailsComplete, {
				CompareTo = CompareTo(props.equipment, props.ItemLoot),
				Item = props.ItemLoot,
				ShowGearScore = true,
			}),

			GlowAura = props.ItemLoot and e("Frame", {
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
						Color = LootStyles[props.ItemLoot.Rarity].Color,
					}),
				}),
			}),

			EquipmentInfo = props.EquipmentLoot and e(EquipmentInfo, {
				Loot = props.EquipmentLoot,
			}),
		}),
	})
end

return RoactRodux.connect(function(state)
	return {
		equipment = state.equipment,
	}
end)(ArenaRewards)
