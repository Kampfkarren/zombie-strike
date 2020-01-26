local Chat = game:GetService("Chat")

local function setUpChatWindow()
    return { BubbleChatEnabled = true }
end

Chat:RegisterChatCallback(Enum.ChatCallbackType.OnCreatingChatWindow, setUpChatWindow)
