local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local function isMobile()
	return not UserInputService.MouseEnabled
		and not UserInputService.GamepadEnabled
		and not UserInputService.KeyboardEnabled
end

if isMobile() then
	ReplicatedStorage.Remotes.MobileBaby:FireServer()
end
