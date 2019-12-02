local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ConfirmPrompt = require(ReplicatedStorage.Core.UI.Components.ConfirmPrompt)
local Memoize = require(ReplicatedStorage.Core.Memoize)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)

local e = Roact.createElement

local buy = Memoize(function(callback, close)
	return function()
		callback()
		close()
	end
end)

local function BrainsPurchase(props)
	if props.Brains >= props.Cost then
		return e(ConfirmPrompt, {
			Window = props.Window,
			Text = string.format("Are you sure you want to buy '%s' for %d brains?", props.Name, props.Cost),
			Yes = buy(props.OnBuy, props.OnClose),
			No = props.OnClose,
		})
	else
		props.gotoBrains()
		props.OnClose()

		return Roact.createFragment()
	end
end

return RoactRodux.connect(function(state)
	return {
		Brains = state.brains,
	}
end, function(dispatch)
	return {
		gotoBrains = function()
			dispatch({
				type = "OpenStore",
			})

			dispatch({
				type = "SetStorePage",
				page = "BuyBrains",
			})
		end,
	}
end)(BrainsPurchase)
