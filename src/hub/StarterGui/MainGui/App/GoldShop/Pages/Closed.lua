local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PerfectTextLabel = require(ReplicatedStorage.Core.UI.Components.PerfectTextLabel)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local function Closed()
	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		UIListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Sorry = e(PerfectTextLabel, {
			Font = Enum.Font.GothamBold,
			LayoutOrder = 1,
			Text = "WE'RE CLOSED!!!",
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 80,
		}),

		But = e(PerfectTextLabel, {
			Font = Enum.Font.Gotham,
			LayoutOrder = 1,
			Text = "...but will reopen very shortly.",
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 80,
		}),
	})
end

return Closed
