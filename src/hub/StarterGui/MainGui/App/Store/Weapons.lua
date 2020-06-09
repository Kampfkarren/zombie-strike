local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Cosmetics = require(ReplicatedStorage.Core.Cosmetics)
local DayTimer = require(ReplicatedStorage.Core.UI.Components.DayTimer)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local StoreCard = require(script.Parent.StoreCard)

local e = Roact.createElement

local function Weapons(props)
	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Size = UDim2.fromScale(1, 1),

		[Roact.Ref] = props[Roact.Ref],
	}, {
		Contents = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.985, 0),
			Size = UDim2.new(0.95, 0, 0.9, 0),
		}, {
			UIListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0.01, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			Mythic = e(StoreCard, {
				ItemIndex = 1,
				ItemType = "GunHighTier",
				Size = UDim2.new(0.48, 0, 1, 0),

				Prices = Cosmetics.Distribution.GunHighTier,
				Window = props[Roact.Ref],
			}),

			Legendary = e("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 2,
				Size = UDim2.new(0.48, 0, 1, 0),
			}, {
				e("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0.01, 0),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				Legendary1 = e(StoreCard, {
					ItemIndex = 1,
					ItemType = "GunLowTier",
					Size = UDim2.new(1, 0, 0.5, 0),

					LayoutOrder = 1,
					Prices = Cosmetics.Distribution.GunLowTier,
					Window = props[Roact.Ref],
				}),

				Legendary2 = e(StoreCard, {
					ItemIndex = 2,
					ItemType = "GunLowTier",
					Size = UDim2.new(1, 0, 0.5, 0),

					LayoutOrder = 2,
					Prices = Cosmetics.Distribution.GunLowTier,
					Window = props[Roact.Ref],
				}),
			}),
		}),

		TimerFrame = e("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0.025, 0, 0.01, 0),
			Size = UDim2.new(0.4, 0, 0.07, 0),
		}, {
			Timer = e(DayTimer, {
				Native = {
					Font = Enum.Font.GothamBlack,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextStrokeTransparency = 0,
				},
			}),
		}),
	})
end

return Weapons
