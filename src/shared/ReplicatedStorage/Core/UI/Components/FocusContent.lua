local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)

local e = Roact.createElement
local inset = GuiService:GetGuiInset()

local FocusContent = Roact.Component:extend("FocusContent")

function FocusContent:didMount()
	self.props.hideUi()
end

function FocusContent:willUnmount()
	self.props.showUi()
end

function FocusContent:render()
	return e("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(-inset.X, -inset.Y),
		Size = UDim2.new(1, inset.X, 1, inset.Y),
	}, {
		UIGradient = e("UIGradient", {
			Color = ColorSequence.new(
				self.props.BackgroundColor,
				Color3.new(1, 1, 1)
			),
			Transparency = NumberSequence.new(0, 1),
			Rotation = 90,
		}),

		Blur = RunService:IsRunning() and e(Roact.Portal, {
			target = Lighting,
		}, {
			BlurEffect = e("BlurEffect"),
		}) or nil,

		Page = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.5, inset.Y / 2),
			Size = UDim2.new(1, -inset.X, 0.95, -inset.Y),
		}, self.props[Roact.Children]),
	})
end

return RoactRodux.connect(nil, function(dispatch)
	return {
		hideUi = function()
			dispatch({
				type = "HideUI",
			})
		end,

		showUi = function()
			dispatch({
				type = "ShowUI",
			})
		end,
	}
end)(FocusContent)
