local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Alert = require(ReplicatedStorage.Core.UI.Components.Alert)
local EventConnection = require(ReplicatedStorage.Core.UI.Components.EventConnection)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement
local GameUpdate = ReplicatedStorage.Remotes.GameUpdate

local SoftShutdownAlert = Roact.PureComponent:extend("SoftShutdownAlert")

function SoftShutdownAlert:init()
	self:setState({
		open = false,
	})

	self.open = function()
		self:setState({
			open = true,
		})
	end

	self.close = function()
		self:setState({
			open = false,
		})
	end
end

function SoftShutdownAlert:render()
	if self.state.open then
		return e(Alert, {
			AlertTime = 5,
			Color = Color3.new(1, 1, 0.5),
			OnClose = self.close,
			Open = true,
			Text = "The servers are currently restarting for updates. Wait a moment...",
		})
	else
		return e(EventConnection, {
			callback = self.open,
			event = GameUpdate.OnClientEvent,
		})
	end
end

return SoftShutdownAlert
