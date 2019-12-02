local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DayTimer = require(ReplicatedStorage.Core.UI.Components.DayTimer)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local StoreCard = require(script.Parent.StoreCard)

local e = Roact.createElement

local function Shop(props)
	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 1, 0),

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

			Little = e("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 3,
				Size = UDim2.new(0.38, 0, 1, 0),
			}, {
				e("UIGridLayout", {
					CellPadding = UDim2.new(0.02, 0, 0.01, 0),
					CellSize = UDim2.new(0.48, 0, 0.495, 0),
					FillDirection = Enum.FillDirection.Horizontal,
					FillDirectionMaxCells = 2,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				Particle1 = e(StoreCard, {
					ItemIndex = 1,
					ItemType = "Particle",

					LayoutOrder = 1,
					Price = 299,
					Window = props[Roact.Ref],
				}),

				Particle2 = e(StoreCard, {
					ItemIndex = 2,
					ItemType = "Particle",

					LayoutOrder = 2,
					Price = 299,
					Window = props[Roact.Ref],
				}),

				Face1 = e(StoreCard, {
					ItemIndex = 1,
					ItemType = "Face",

					LayoutOrder = 3,
					Price = 99,
					Window = props[Roact.Ref],
				}),

				Face2 = e(StoreCard, {
					ItemIndex = 2,
					ItemType = "Face",

					LayoutOrder = 3,
					Price = 99,
					Window = props[Roact.Ref],
				}),
			}),

			Low = e("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 2,
				Size = UDim2.new(0.3, 0, 1, 0),
			}, {
				e("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0.01, 0),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				LowTier1 = e(StoreCard, {
					ItemIndex = 1,
					ItemType = "LowTier",
					Size = UDim2.new(1, 0, 0.5, 0),

					LayoutOrder = 1,
					Price = 599,
					Window = props[Roact.Ref],
				}),

				LowTier2 = e(StoreCard, {
					ItemIndex = 2,
					ItemType = "LowTier",
					Size = UDim2.new(1, 0, 0.5, 0),

					LayoutOrder = 2,
					Price = 599,
					Window = props[Roact.Ref],
				}),
			}),

			High = e(StoreCard, {
				ItemIndex = 1,
				ItemType = "HighTier",
				Size = UDim2.new(0.3, 0, 1, 0),

				Price = 799,
				Window = props[Roact.Ref],
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

return Shop
