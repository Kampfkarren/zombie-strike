local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Input = require(ReplicatedStorage.RuddevModules.Input)

local MobileButtons = script.Parent.MobileButtons

local COLOR_DEFAULT = Color3.new(1, 1, 1)
local COLOR_PRESS = Color3.new(0.5, 0.5, 0.5)

MobileButtons.Reload.InputBegan:connect(function(inputObject)
	if inputObject.UserInputType == Enum.UserInputType.Touch then
		Input.FireBegan("Reload")
		MobileButtons.Reload.ImageColor3 = COLOR_PRESS
	end
end)

MobileButtons.Reload.InputEnded:connect(function(inputObject)
	if inputObject.UserInputType == Enum.UserInputType.Touch then
		Input.FireEnded("Reload")
		MobileButtons.Reload.ImageColor3 = COLOR_DEFAULT
	end
end)

MobileButtons.Shoot.InputBegan:connect(function(inputObject)
	if inputObject.UserInputType == Enum.UserInputType.Touch then
		Input.FireBegan("Primary")
		MobileButtons.Shoot.ImageColor3 = COLOR_PRESS
	end
end)

MobileButtons.Shoot.InputEnded:connect(function(inputObject)
	if inputObject.UserInputType == Enum.UserInputType.Touch then
		Input.FireEnded("Primary")
		MobileButtons.Shoot.ImageColor3 = COLOR_DEFAULT
	end
end)

MobileButtons.Visible = UserInputService.TouchEnabled
MobileButtons.Shoot.Visible = ReplicatedStorage.HubWorld.Value
