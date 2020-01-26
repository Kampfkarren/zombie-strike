local ContentProvider = game:GetService("ContentProvider")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local MainGui = PlayerGui:WaitForChild("MainGui")
local RuddevGui = PlayerGui:WaitForChild("RuddevGui")

local sequenceName
if Dungeon.GetDungeonData("Gamemode") == "Boss" then
	sequenceName = Dungeon.GetDungeonData("BossInfo").RoomName
else
	sequenceName = Dungeon.GetDungeonData("Campaign")
end

local Sequence = require(ReplicatedStorage.BossSequences[sequenceName])

local assets = {}

for _, asset in pairs(Sequence.Assets) do
	table.insert(assets, asset)
end

coroutine.wrap(function()
	ContentProvider:PreloadAsync(assets)
end)()

local boss = CollectionService:GetInstanceAddedSignal("Boss"):wait()
boss:WaitForChild("Humanoid")

MainGui.Enabled = false
RuddevGui.Enabled = false

Sequence.Start(boss):andThen(function()
	MainGui.Enabled = true
	RuddevGui.Enabled = true
end)
