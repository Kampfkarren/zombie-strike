local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assign = require(ReplicatedStorage.Core.assign)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local function AutoFixedScrollingFrame(props)
	local count = 0

	for _ in pairs(props[Roact.Children]) do
		count = count + 1
	end

	local rows = math.ceil(count / props.CellsPerRow)

	return e("ScrollingFrame", assign(props.ScrollingFrame, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		-- TODO: Optionally allow horizontal scrolling
		CanvasSize = UDim2.fromOffset(0, (rows * props.CellSize.Y.Offset)
			+ (rows * props.CellPadding.Y.Offset)),
	}), assign(props[Roact.Children], {
		UIGridLayout = e("UIGridLayout", assign(props.GridLayout or {}, {
			CellPadding = props.CellPadding,
			CellSize = props.CellSize,
			FillDirectionMaxCells = props.CellsPerRow,
			SortOrder = Enum.SortOrder.LayoutOrder,
		})),
	}))
end

return AutoFixedScrollingFrame
