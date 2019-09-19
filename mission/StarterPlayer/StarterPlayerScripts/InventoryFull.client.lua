local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

ReplicatedStorage.Remotes.InventoryFull.OnClientEvent:connect(function(amount)
	StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = ("Your inventory is full! You lost %d item%s..."):format(amount, amount == 1 and "" or "s"),
		Color = Color3.fromRGB(252, 92, 101),
		Font = Enum.Font.GothamSemibold,
	})
end)
