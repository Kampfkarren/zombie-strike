local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer
	:WaitForChild("PlayerGui")

local MouseGui = PlayerGui
	:WaitForChild("RuddevGui")
	:WaitForChild("Mouse")

local Mouse = LocalPlayer:GetMouse()

local lastX, lastY = Mouse.X, Mouse.Y

local function recheckMouse()
	if not UserInputService.MouseEnabled then
		UserInputService.MouseIconEnabled = false
		MouseGui.Visible = true
	else
		local guis = PlayerGui:GetGuiObjectsAtPosition(lastX, lastY)

		for _, gui in pairs(guis) do
			if gui.Active then
				UserInputService.MouseIconEnabled = true
				MouseGui.Visible = false
				return
			end
		end

		UserInputService.MouseIconEnabled = false
		MouseGui.Visible = true
	end
end

UserInputService:GetPropertyChangedSignal("MouseEnabled"):connect(function()
	recheckMouse()
end)

UserInputService.InputChanged:connect(function(inputObject)
	lastX, lastY = inputObject.Position.X, inputObject.Position.Y
	recheckMouse()
end)
