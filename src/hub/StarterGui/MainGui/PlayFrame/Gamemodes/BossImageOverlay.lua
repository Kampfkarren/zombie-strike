local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DayTimer = require(ReplicatedStorage.Core.UI.Components.DayTimer)
local EventConnection = require(ReplicatedStorage.Core.UI.Components.EventConnection)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local BossImageOverlay = Roact.Component:extend("BossImageOverlay")

-- This is a dumb way of doing it, but I'm under crunch :(
local cachedTimeBossDefeated

function BossImageOverlay:init()
	self:setState({
		timeBossDefeated = cachedTimeBossDefeated,
	})

	self.setTimeBossDefeated = function(time)
		cachedTimeBossDefeated = time
		self:setState({
			timeBossDefeated = time,
		})
	end
end

function BossImageOverlay:render()
	local information

	if self.state.timeBossDefeated ~= nil
		and os.time() - self.state.timeBossDefeated <= 24 * 60 * 60
	then
		information = {
			Label = e("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.49, 1),
				Font = Enum.Font.GothamSemibold,
				Position = UDim2.fromScale(0.01, 0),
				Text = "100🧠 IN",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
			}),

			Timer = e("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.49, 1),
				Position = UDim2.fromScale(1, 0),
			}, {
				e(DayTimer, {
					TimeSince = self.state.timeBossDefeated,
					Native = {
						Font = Enum.Font.GothamBlack,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextStrokeTransparency = 0,
					},
				}),
			}),
		}
	elseif self.state.timeBossDefeated ~= nil then
		information = {
			Label = e("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.95, 1),
				Font = Enum.Font.GothamSemibold,
				Position = UDim2.fromScale(0.5, 0),
				Text = "DEFEAT FOR 100🧠!",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				TextStrokeTransparency = 0.6,
			}),
		}
	else
		information = {
			SetTimeBossDefeated = e(EventConnection, {
				callback = self.setTimeBossDefeated,
				event = ReplicatedStorage.Remotes.NewBoss.OnClientEvent,
			}),
		}
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		Information = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.99),
			Size = UDim2.fromScale(0.98, 0.15),
		}, information),
	})
end

return BossImageOverlay
