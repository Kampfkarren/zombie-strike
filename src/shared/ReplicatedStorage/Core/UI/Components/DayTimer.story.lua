local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DayTimer = require(script.Parent.DayTimer)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local function TextLabel(props)
	return e("TextLabel", {
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		Text = props.Text,
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
	})
end

local function TestDayTimer()
	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		UIGridLayout = e("UIGridLayout", {
			CellSize = UDim2.fromScale(0.49, 0.1),
			CellPadding = UDim2.fromScale(0.01, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		DefaultPropsLabel = e(TextLabel, {
			LayoutOrder = 1,
			Text = "Default",
		}),

		DefaultPropsTimer = e(DayTimer, {
			Native = {
				LayoutOrder = 2,
			},
		}),

		TimeSinceLabel = e(TextLabel, {
			LayoutOrder = 3,
			Text = "TimeSince = os.time() - 60",
		}),

		TimeSinceTimer = e(DayTimer, {
			TimeSince = os.time() - 60,

			Native = {
				LayoutOrder = 4,
			},
		}),
	})
end

return function(target)
	local handle = Roact.mount(e(TestDayTimer), target, "DayTimer")

	return function()
		Roact.unmount(handle)
	end
end
