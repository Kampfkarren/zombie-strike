local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ConfirmPrompt2 = require(ReplicatedStorage.Core.UI.Components.ConfirmPrompt2)
local FormatNumber = require(ReplicatedStorage.Core.FormatNumber)
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
		return e(Roact.Portal, {
			target = props.Window:getValue(),
		}, {
			ConfirmPrompt2 = e(ConfirmPrompt2, {
				Text = ("Are you sure you want to buy '%s' for %s brains?"):format(props.Name, FormatNumber(props.Cost)),
				Scale = props.Scale,
				Buttons = {
					Yes = {
						LayoutOrder = 1,
						Style = "Yes",
						Text = "Yes",
						Activated = buy(props.OnBuy, props.OnClose),
					},

					No = {
						LayoutOrder = 2,
						Style = "No",
						Text = "No",
						Activated = props.OnClose,
					},
				},
			}),
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
