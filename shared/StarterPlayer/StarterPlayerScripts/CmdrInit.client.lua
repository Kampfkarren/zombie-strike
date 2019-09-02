local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AdminsDictionary = require(ReplicatedStorage.Core.AdminsDictionary)
local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))

if AdminsDictionary[Players.LocalPlayer.UserId] then
	Cmdr:SetActivationKeys({ Enum.KeyCode.Semicolon })
else
	Cmdr:SetActivationKeys({})
end
