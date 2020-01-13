local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RealDelay = require(ReplicatedStorage.Core.RealDelay)

local function Interval(interval, callback)
	local cancelled = false

	local function modifiedCallback()
		if cancelled then return end
		if callback() == false then return end
		RealDelay(interval, modifiedCallback)
	end

	RealDelay(interval, modifiedCallback)

	return function()
		cancelled = true
	end
end

return Interval
