local ChatConstants = {}

ChatConstants.Codes = {
	TradeEquipped = 1,
	TradeTooMuch = 2,
}

ChatConstants.Messages = {
	[ChatConstants.Codes.TradeEquipped] = {
		Color = Color3.fromRGB(252, 92, 101),
		Text = "You cannot trade equipped items."
	},

	[ChatConstants.Codes.TradeTooMuch] = {
		Color = Color3.fromRGB(252, 92, 101),
		Text = "The other player doesn't have enough inventory space for that."
	},
}

return ChatConstants
