local ChatConstants = {}

ChatConstants.Codes = {
	TradeEquipped = 1,
}

ChatConstants.Messages = {
	[ChatConstants.Codes.TradeEquipped] = {
		Color = Color3.fromRGB(252, 92, 101),
		Text = "You cannot trade equipped items."
	},
}

return ChatConstants
