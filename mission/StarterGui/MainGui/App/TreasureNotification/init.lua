local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Alert = require(ReplicatedStorage.Core.UI.Components.Alert)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)

local e = Roact.createElement

local TreasureNotification = Roact.Component:extend("TreasureNotification")

local ALERT_TIME = 7.5
local HALLELUJAH_DELAY = 3.5
local HALLELUJAH_FADE = 0.6

function TreasureNotification:shouldUpdate(nextProps)
	return nextProps.bought and not self.state.boughtSeen
end

function TreasureNotification:didUpdate()
	self:setState({
		boughtSeen = true,
	})

	SoundService.SFX.ChestBought:Play()

	delay(HALLELUJAH_DELAY, function()
		TweenService:Create(
			SoundService.SFX.ChestBought,
			TweenInfo.new(
				HALLELUJAH_FADE,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.Out
			),
			{ Volume = 0 }
		):Play()
	end)
end

function TreasureNotification:render()
	if self.state.boughtSeen then
		return e(Alert, {
			AlertTime = ALERT_TIME,
			Color = Color3.fromRGB(255, 255, 57),
			Open = true,
			Text = ("%s BOUGHT THE CHEST FOR THE WHOLE TEAM! ENJOY THE LOOT!")
				:format(self.props.donor.Name),
		})
	else
		return Roact.createFragment()
	end
end

return RoactRodux.connect(function(state)
	return {
		bought = state.treasureLoot.bought,
		donor = state.treasureLoot.donor,
	}
end)(TreasureNotification)
