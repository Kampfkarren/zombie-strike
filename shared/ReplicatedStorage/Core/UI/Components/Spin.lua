local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local EventConnection = require(ReplicatedStorage.Core.UI.Components.EventConnection)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local Spin = Roact.Component:extend("Spin")

function Spin:init()
	self.rotation, self.updateRotation = Roact.createBinding(0)

	self.spin = function(delta)
		self.updateRotation(self.rotation:getValue() + delta * self.props.Speed)
	end
end

function Spin:render()
	local children = {}

	for name, element in pairs(self.props[Roact.Children] or {}) do
		children[name] = element
	end

	table.insert(children, e(EventConnection, {
		callback = self.spin,
		event = RunService.Heartbeat,
	}))

	return e("Frame", {
		BackgroundTransparency = 1,
		Rotation = self.rotation,
		Size = UDim2.fromScale(1, 1),
	}, children)
end

return Spin
