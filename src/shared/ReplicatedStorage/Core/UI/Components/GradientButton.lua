local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Color3Lerp = require(ReplicatedStorage.Core.Color3Lerp)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local function copy(list)
	local copy = {}
	for key, value in pairs(list) do
		copy[key] = value
	end
	return copy
end

local GradientButton = Roact.Component:extend("GradientButton")

GradientButton.defaultProps = {
	AnimateSpeed = 8,

	GradientRotation = 90,

	MinGradient = Color3.fromRGB(65, 65, 65),
	MaxGradient = Color3.fromRGB(82, 82, 82),

	HoveredMaxGradient = Color3.fromRGB(110, 110, 110),
}

function GradientButton:init()
	self.total, self.setTotal = Roact.createBinding(0)

	self.hover = function()
		self.direction = 1
		self:Animate()

		if self.props[Roact.Event.MouseEnter] then
			self.props[Roact.Event.MouseEnter]()
		end
	end

	self.unhover = function()
		self.direction = -1
		self:Animate()

		if self.props[Roact.Event.MouseLeave] then
			self.props[Roact.Event.MouseLeave]()
		end
	end
end

function GradientButton:Animate()
	if self.animateLoop == nil then
		self.animateLoop = RunService.Heartbeat:connect(function(delta)
			self.setTotal(math.clamp(
				self.total:getValue()
				+ delta
				* self.direction
				* self.props.AnimateSpeed,
				0,
				1
			))
		end)
	end
end

function GradientButton:willUnmount()
	if self.animateLoop then
		self.animateLoop:Disconnect()
	end
end

function GradientButton:render()
	local props = copy(self.props)

	for defaultProperty in pairs(GradientButton.defaultProps) do
		props[defaultProperty] = nil
	end

	props[Roact.Event.MouseEnter] = self.hover
	props[Roact.Event.MouseLeave] = self.unhover

	table.insert(props[Roact.Children], e("UIGradient", {
		Color = self.total:map(function(total)
			return ColorSequence.new(
				self.props.MinGradient,
				Color3Lerp(self.props.MaxGradient, self.props.HoveredMaxGradient, math.sin(total * (math.pi / 2)))
			)
		end),
		Rotation = self.props.GradientRotation,
	}))

	return e("ImageButton", props)
end

return GradientButton
