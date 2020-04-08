local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HoverStack = require(script.Parent.HoverStack)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local function TestButton(props)
	return e("TextButton", {
		BorderColor3 = Color3.new(1, 0, 0),
		BorderSizePixel = props.hovered == props.data and 5 or 0,
		Size = UDim2.fromScale(0.2, 0.2),
		Text = props.data,
		TextScaled = true,

		[Roact.Event.MouseEnter] = props.hover(props.data),
		[Roact.Event.MouseLeave] = props.unhover(props.data),
	})
end

return function(target)
	local handle = Roact.mount(
		e(HoverStack, {
			Render = function(hovered, hover, unhover)
				return e("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
				}, {
					UIListLayout = e("UIListLayout"),

					TextButtonA = e(TestButton, {
						data = "A",
						hover = hover,
						unhover = unhover,
						hovered = hovered,
					}),

					TextButtonB = e(TestButton, {
						data = "B",
						hover = hover,
						unhover = unhover,
						hovered = hovered,
					}),

					TextButtonC = e(TestButton, {
						data = "C",
						hover = hover,
						unhover = unhover,
						hovered = hovered,
					}),
				})
			end,
		}), target, "HoverStack"
	)

	return function()
		Roact.unmount(handle)
	end
end

