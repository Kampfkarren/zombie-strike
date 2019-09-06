local TradeConstants = {}

TradeConstants.Codes = {
	SuccessfulTrade = -1,
	RejectLeave = 0,
	RejectDeny = 1,
	RejectTimeout = 2,
	RejectAnother = 3,
	RejectBusy = 4,
	RejectCloseYou = 5,
	RejectCloseThem = 6,
	RejectEquipYou = 7,
	RejectEquipThem = 8,
}

TradeConstants.Messages = {
	[TradeConstants.Codes.RejectLeave] = "%s has left.",
	[TradeConstants.Codes.RejectDeny] = "%s denied your trade request.",
	[TradeConstants.Codes.RejectTimeout] = "%s didn't accept in time.",
	[TradeConstants.Codes.RejectAnother] = "%s accepted a different trade.",
	[TradeConstants.Codes.RejectBusy] = "%s is busy with a different trade.",
	[TradeConstants.Codes.RejectCloseYou] = "You closed the trade.",
	[TradeConstants.Codes.RejectCloseThem] = "%s closed the trade.",
	[TradeConstants.Codes.SuccessfulTrade] = "Trade successful!",
	[TradeConstants.Codes.RejectEquipYou] = "You changed your inventory, so the trade was cancelled.",
	[TradeConstants.Codes.RejectEquipThem] = "%s changed their inventory, so the trade was cancelled.",
}

return TradeConstants
