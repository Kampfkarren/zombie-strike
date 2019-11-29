local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local Alert = Roact.Component:extend("Alert")

Alert.defaultProps = {
	AlertTime = 2,
	Open = false,
	Window = Players.LocalPlayer.PlayerGui.MainGui.Main,
}

function Alert:init()
	self.fadeBinding, self.updateFadeBinding = Roact.createBinding(1)
end

function Alert:didUpdate(previousProps)
	if self.props.Open ~= previousProps.Open then
		self.updateFadeBinding(self.props.Open and 0 or 1)

		if self.props.Open then
			local total = 0
			self.animateConnection = RunService.Heartbeat:connect(function(delta)
				total = total + delta
				self.updateFadeBinding(TweenService:GetValue(
					total / self.props.AlertTime,
					Enum.EasingStyle.Cubic,
					Enum.EasingDirection.In
				))

				if total >= self.props.AlertTime then
					self:setState({
						finished = true,
					})

					self.props.OnClose()

					self.animateConnection:Disconnect()
				end
			end)
		else
			self.animateConnection:Disconnect()
		end
	end
end

function Alert:willUnmount()
	if self.animateConnection then
		self.animateConnection:Disconnect()
	end
end

function Alert:render()
	local props = self.props

	return e(Roact.Portal, {
		target = props.Window,
	}, {
		Notification = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromScale(0.5, 0.01),
			Size = UDim2.fromScale(0.8, 0.1),
			Text = props.Text,
			TextColor3 = Color3.fromRGB(255, 78, 78),
			TextScaled = true,
			TextStrokeColor3 = Color3.new(0, 0, 0),
			TextStrokeTransparency = self.fadeBinding,
			TextTransparency = self.fadeBinding,
		}),
	})
end

return Alert
