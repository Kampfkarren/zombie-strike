local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modalifier = require(ReplicatedStorage.Core.UI.Components.Modalifier)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local COLOR_NO = Color3.fromRGB(195, 64, 50)
local COLOR_YES = Color3.fromRGB(32, 146, 81)

local function ConfirmPrompt(props)
	return e(Modalifier, {
		OnClosed = props.No,
		Window = props.Window,

		Render = function()
			return e("Frame", {
				BackgroundTransparency = 0.5,
				BackgroundColor3 = Color3.new(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 1),
			}, {
				Label = e("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Position = UDim2.fromScale(0.5, 0.4),
					Size = UDim2.fromScale(0.6, 0.4),
					Text = props.Text,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
				}),

				Yes = e("TextButton", {
					AnchorPoint = Vector2.new(0.5, 1),
					BackgroundColor3 = COLOR_YES,
					BorderSizePixel = 0,
					Font = Enum.Font.GothamBold,
					Position = UDim2.fromScale(0.3, 0.9),
					Size = UDim2.fromScale(0.3, 0.1),
					Text = "YES",
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					[Roact.Event.Activated] = props.Yes,
				}),

				No = e("TextButton", {
					AnchorPoint = Vector2.new(0.5, 1),
					BackgroundColor3 = COLOR_NO,
					BorderSizePixel = 0,
					Font = Enum.Font.GothamBold,
					Position = UDim2.fromScale(0.7, 0.9),
					Size = UDim2.fromScale(0.3, 0.1),
					Text = "NO",
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					[Roact.Event.Activated] = props.No,
				}),
			})
		end
	})
end

return ConfirmPrompt
