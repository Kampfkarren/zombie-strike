local CollectionService = game:GetService("CollectionService")

return function(context)
	local executor = context.Executor

	executor.Character:SetPrimaryPartCFrame(
		CollectionService:GetTagged("ShopkeeperRange")[1].CFrame
	)
end
