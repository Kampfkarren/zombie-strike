local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local EventConnection = require(ReplicatedStorage.Core.UI.Components.EventConnection)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local Counter = Roact.Component:extend("Counter")

function Counter:init()
	self.total, self.updateTotal = Roact.createBinding(0)

	self.heartbeat = function(delta)
		self.updateTotal(self.total:getValue() + delta)
	end
end

function Counter:render()
	return Roact.createFragment({
		Roact.createElement(EventConnection, {
			event = RunService.Heartbeat,
			callback = self.heartbeat,
		}),

		self.props.Render(self.total),
	})
end

return Counter
