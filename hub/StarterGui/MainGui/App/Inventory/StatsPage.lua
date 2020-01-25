local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EnglishNumbers = require(ReplicatedStorage.Core.EnglishNumbers)
local PlayerDataConsumer = require(ReplicatedStorage.Core.UI.Components.PlayerDataConsumer)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local function Stat(props)
	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
	}, {
		e("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.04, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Label = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBlack,
			LayoutOrder = 0,
			Size = UDim2.new(1, 0, 0.4, 0),
			Text = props.Name,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
		}),

		Current = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0.3, 0),
			Text = EnglishNumbers(props.Value),
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
		}),
	})
end

local function StatsPage()
	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 0.98),
	}, {
		Contents = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		}, {
			UIGridLayout = e("UIGridLayout", {
				CellPadding = UDim2.fromScale(0.01, 0.01),
				CellSize = UDim2.fromScale(0.23, 0.48),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			MissionsPlayed = e(PlayerDataConsumer, {
				Name = "DungeonsPlayed",
				Render = function(value)
					return e(Stat, {
						LayoutOrder = 1,
						Name = "Missions Played",
						Value = value,
					})
				end,
			}),

			DamageDealt = e(PlayerDataConsumer, {
				Name = "DamageDealt",
				Render = function(value)
					return e(Stat, {
						LayoutOrder = 2,
						Name = "Damage Dealt",
						Value = math.floor(10 ^ value),
					})
				end,
			}),

			LootEarned = e(PlayerDataConsumer, {
				Name = "LootEarned",
				Render = function(value)
					return e(Stat, {
						LayoutOrder = 3,
						Name = "Loot Earned",
						Value = value,
					})
				end,
			}),

			RoomsCleared = e(PlayerDataConsumer, {
				Name = "RoomsCleared",
				Render = function(value)
					return e(Stat, {
						LayoutOrder = 4,
						Name = "Rooms Cleared",
						Value = value,
					})
				end,
			}),

			ZombiesKilled = e(PlayerDataConsumer, {
				Name = "ZombiesKilled",
				Render = function(value)
					return e(Stat, {
						LayoutOrder = 5,
						Name = "Zombies Killed",
						Value = value,
					})
				end,
			}),

			LegendariesObtained = e(PlayerDataConsumer, {
				Name = "LegendariesObtained",
				Render = function(value)
					return e(Stat, {
						LayoutOrder = 6,
						Name = "Legendaries Owned",
						Value = value,
					})
				end,
			}),
		}),

		Notice = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 1,
			Font = Enum.Font.SourceSans,
			Position = UDim2.fromScale(0.5, 0.99),
			Size = UDim2.fromScale(0.5, 0.08),
			Text = "Data before v0.9.0 was not recorded.",
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
		}),
	})
end

return StatsPage
