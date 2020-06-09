local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EventConnection = require(ReplicatedStorage.Core.UI.Components.EventConnection)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local TradeScreen2 = require(script.Parent.TradeScreen2)

local e = Roact.createElement

local TradeScreenWrapper = Roact.Component:extend("TradeScreen")

function TradeScreenWrapper:init()
	self.acceptTrade = function(us, accepted)
		if us then
			self:setState({
				weAccepted = accepted,
			})
		else
			self:setState({
				theyAccepted = accepted,
			})
		end
	end
end

-- props might change because we pass unmemoized functions
-- but the function implementations don't change depending on any state
function TradeScreenWrapper:shouldUpdate(_, nextState)
	return nextState ~= self.state
end

function TradeScreenWrapper:render()
	return Roact.createFragment({
		TradeScreen = e(TradeScreen2, {
			offerItem = self.props.offerItem,
			ping = self.props.ping,
			removeItem = self.props.removeItem,
			weAccept = self.props.weAccept,

			theyAccepted = self.state.theyAccepted,
			weAccepted = self.state.weAccepted,
		}),

		AcceptTrade = e(EventConnection, {
			callback = self.acceptTrade,
			event = ReplicatedStorage.Remotes.AcceptTrade.OnClientEvent,
		}),
	})
end

return TradeScreenWrapper
