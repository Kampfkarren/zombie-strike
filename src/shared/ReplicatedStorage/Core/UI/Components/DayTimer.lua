local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assign = require(ReplicatedStorage.Core.assign)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local DayTimer = Roact.Component:extend("DayTimer")

local e = Roact.createElement

local SECONDS_IN_DAY = 24 * 60 * 60

local function timer()
	local date = os.date("!*t", os.time() + SECONDS_IN_DAY)

	return os.time({
		year = date.year,
		month = date.month,
		day = date.day,
		hour = 0,
		minute = 0,
		sec = 0,
	}) - os.time()
end

function DayTimer:init()
	local timerValue

	if self.props.TimeSince then
		timerValue = SECONDS_IN_DAY - (os.time() - self.props.TimeSince)
	else
		timerValue = timer()
	end

	self:setState({
		timer = timerValue,
	})
end

function DayTimer:didMount()
	self.running = true

	coroutine.wrap(function()
		while self.running do
			wait(1)
			if not self.running then break end
			self:setState(function(state)
				local timer = state.timer - 1

				if timer <= 0 and not self.props.Overflow then
					timer = 0
					self.running = false
				end

				return {
					timer = timer,
				}
			end)
		end
	end)()
end

function DayTimer:willUnmount()
	self.running = false
end

function DayTimer:render()
	return e("TextLabel", assign({
		AutoLocalize = false,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = ("%02d:%02d:%02d"):format(
			math.floor(self.state.timer / 3600),
			math.floor(self.state.timer / 60) % 60,
			self.state.timer % 60
		),
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
	}, self.props.Native or {}))
end

return DayTimer
