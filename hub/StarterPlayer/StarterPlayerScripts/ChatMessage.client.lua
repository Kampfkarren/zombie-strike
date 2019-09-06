local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local ChatConstants = require(ReplicatedStorage.ChatConstants)

ReplicatedStorage.Remotes.ChatMessage.OnClientEvent:connect(function(code, ...)
	local chat = ChatConstants.Messages[code]

	StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = string.format(chat.Text, ...),
		Color = chat.Color,
		Font = Enum.Font.GothamSemibold,
	})
end)
