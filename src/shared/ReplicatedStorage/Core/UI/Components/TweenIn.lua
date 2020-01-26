local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local EventConnection = require(ReplicatedStorage.Core.UI.Components.EventConnection)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local TweenIn = Roact.Component:extend("TweenIn")

function TweenIn:init()
	self.total, self.updateTotal = Roact.createBinding(0)

	self.tick = function(delta)
		local total = self.total:getValue() + delta
		self.updateTotal(total)

		if total >= 1 + self.props.TweenInfo.DelayTime then
			self:setState({
				finished = true,
			})
		end
	end
end

function TweenIn:didMount()
	self.updateTotal(0)
end

function TweenIn:render()
	local children = {}

	for name, element in pairs(self.props[Roact.Children] or {}) do
		children[name] = element
	end

	if not self.state.finished then
		table.insert(children, e("UIScale", {
			Scale = self.total:map(function(total)
				local tweenInfo = self.props.TweenInfo

				if total <= tweenInfo.DelayTime then
					return 0
				else
					return TweenService:GetValue(
						(total - tweenInfo.DelayTime) / tweenInfo.Time,
						tweenInfo.EasingStyle,
						tweenInfo.EasingDirection
					)
				end
			end),
		}))

		table.insert(children, e(EventConnection, {
			event = RunService.Heartbeat,
			callback = self.tick,
		}))
	end

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
	}, children)
end

return TweenIn
