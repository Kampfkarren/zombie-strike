local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Roact = require(ReplicatedStorage.Vendor.Roact)

local ImageTooltip = require(ReplicatedStorage.Assets.Tarmac.UI.tooltip)

local e = Roact.createElement

local Tooltip = Roact.Component:extend("Tooltip")
Tooltip.defaultProps = {
	HoverInSpeed = 3,
	HoverOutSpeed = 6,
	Size = UDim2.fromScale(1, 1),
}

function Tooltip:init()
	self.transparency, self.updateTransparency = Roact.createBinding(0)

	self.heartbeat = function(delta)
		if self.props.Open and self.transparency:getValue() < 1 then
			delta = delta * self.props.HoverInSpeed
			self.updateTransparency(math.min(1, self.transparency:getValue() + delta))
		elseif not self.props.Open and self.transparency:getValue() > 0 then
			delta = delta * self.props.HoverOutSpeed
			self.updateTransparency(math.max(0, self.transparency:getValue() - delta))
		end
	end
end

function Tooltip:didMount()
	self.heartbeatConnection = RunService.Heartbeat:connect(self.heartbeat)
end

function Tooltip:willUnmount()
	self.heartbeatConnection:disconnect()
end

function Tooltip:render()
	local transparency = self.transparency:map(function(transparency)
		return TweenService:GetValue(1 - transparency, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	end)

	return e("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Image = ImageTooltip,
		ImageColor3 = Color3.fromRGB(59, 59, 59),
		ImageTransparency = transparency,
		Position = UDim2.new(0.5, 0, 1, 5),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(24, 14, 45, 41),
		Size = self.props.Size,
	}, self.props.Render(transparency))
end

return Tooltip
