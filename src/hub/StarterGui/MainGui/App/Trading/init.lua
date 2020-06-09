local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Close = require(script.Parent.Close)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local Scale = require(ReplicatedStorage.Core.UI.Components.Scale)
local SelectScreen = require(script.SelectScreen)
local TradeScreenWrapper = require(script.TradeScreenWrapper)

local e = Roact.createElement

local Trading = Roact.PureComponent:extend("Trading")

local AcceptTrade = ReplicatedStorage.Remotes.AcceptTrade
local CancelTrade = ReplicatedStorage.Remotes.CancelTrade
local UpdateTrade = ReplicatedStorage.Remotes.UpdateTrade

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
		page = e(TradeScreenWrapper, {
			ping = function(item)
				return function()
					print("ping", item.UUID)
				end
			end,

			removeItem = function(item)
				return function()
					print("remove item", item.UUID)
					UpdateTrade:FireServer(item.UUID, true)
				end
			end,

			offerItem = function(item)
				return function()
					print("we offer", item.UUID)
					UpdateTrade:FireServer(item.UUID)
				end
			end,

			weAccept = function()
				print("we accept!")
				AcceptTrade:FireServer()
			end,
		})
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
		Size = UDim2.fromOffset(1920, 800),
		Visible = self.props.open,
	}, {
		Scale = e(Scale, {
			Scale = 0.8,
			Size = Vector2.new(1920, 800),
		}),

		Close = e(Close, {
			onClose = self.close,
			ZIndex = 2,
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
