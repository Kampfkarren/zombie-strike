local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AdminsDictionary = require(ReplicatedStorage.Core.AdminsDictionary)

if AdminsDictionary[Players.LocalPlayer.UserId] then
	local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))
	Cmdr:SetActivationKeys({ Enum.KeyCode.Semicolon })
else
	local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	PlayerGui:WaitForChild("Cmdr"):Destroy()
	PlayerGui.ChildAdded:connect(function(child)
		if child.Name == "Cmdr" then
			child:Destroy()
		end
	end)
end
