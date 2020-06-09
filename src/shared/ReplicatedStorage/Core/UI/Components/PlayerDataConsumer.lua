local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local MockPlayer = require(ReplicatedStorage.Core.MockData.MockPlayer)
local Promise = require(ReplicatedStorage.Core.Promise)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local LocalPlayer = Players.LocalPlayer

local PlayerDataConsumer = Roact.Component:extend("PlayerDataConsumer")

function PlayerDataConsumer:init()
	self.waitForIt = Promise.async(function(resolve)
		if RunService:IsRunning() then
			self.instance = LocalPlayer
				:WaitForChild("PlayerData")
				:WaitForChild(self.props.Name)
		else
			local value = Instance.new("NumberValue")
			value.Value = MockPlayer()[self.props.Name]
			self.instance = value
		end

		resolve()
	end):andThen(function()
		self.changedConnection = self.instance.Changed:connect(function(newValue)
			self:setState({
				data = newValue,
			})
		end)

		self:setState({
			data = self.instance.Value,
		})
	end)
end

function PlayerDataConsumer:willUnmount()
	if self.instance then
		self.changedConnection:Disconnect()
	else
		self.waitForIt:cancel()
	end
end

function PlayerDataConsumer:render()
	local data = self.state.data

	return data and self.props.Render(data)
end

return PlayerDataConsumer
