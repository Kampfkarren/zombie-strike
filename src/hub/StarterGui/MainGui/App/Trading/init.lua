local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Close = require(script.Parent.Close)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local SelectScreen = require(script.SelectScreen)
local TradeScreen = require(script.TradeScreen)

local e = Roact.createElement

local Trading = Roact.PureComponent:extend("Trading")

local CancelTrade = ReplicatedStorage.Remotes.CancelTrade

function Trading:init()
	self.close = function()
		if self.props.trading then
			CancelTrade:FireServer()
		else
			self.props.closeWindow()
		end
	end
end

function Trading:render()
	local page

	if self.props.trading then
		page = e(TradeScreen)
	else
		page = e(SelectScreen)
	end

	return e("ImageButton", {
		Active = true,
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(18, 18, 18),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Image = "",
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.6, 0.7),
		Visible = self.props.open,
	}, {
		Close = e(Close, {
			onClose = self.close,
		}),

		Inner = page,
	})
end

return RoactRodux.connect(function(state)
	return {
		open = state.page.current == "Trading" or state.trading.trading,
		trading = state.trading.trading,
	}
end, function(dispatch)
	return {
		closeWindow = function()
			dispatch({
				type = "CloseTrading",
			})
		end,
	}
end)(Trading)
