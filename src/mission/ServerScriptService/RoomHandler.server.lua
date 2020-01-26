local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)

local JoinTimer = ReplicatedStorage.JoinTimer

DataStore2.Combine("DATA", "Gold", "Inventory", "Level", "XP", "DungeonsPlayed")

local gamemode = Dungeon.GetDungeonData("Gamemode")

local currentGamemode
if gamemode == "Arena" then
	currentGamemode = require(ServerScriptService.Gamemodes.Arena).Init()
else
	currentGamemode = require(ServerScriptService.Gamemodes.Standard).Init()
end

local started = 0
local startedCountdown = false

local function start()
	if started == 2 then return end
	started = 2

	for countdown = -3, -1 do
		JoinTimer.Value = countdown
		currentGamemode.Countdown(-countdown)

		wait(1)
	end

	JoinTimer.Value = -4

	local playMusicFlag = Instance.new("Model")
	playMusicFlag.Name = "PlayMissionMusic"
	playMusicFlag.Parent = ReplicatedStorage

	delay(3, function()
		JoinTimer.Value = 0
	end)
end

local function checkCharacterCount()
	if started ~= 0 then return end

	local characterCount = 0
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character then
			characterCount = characterCount + 1
		end
	end

	if characterCount == #Dungeon.GetDungeonData("Members") then
		print("all players connected")
		started = 1
		JoinTimer.Value = 0
		wait(5)
		start()
		return
	end
end

local function playerAdded(player)
	if started ~= 0 then return end

	checkCharacterCount()
	player.CharacterAdded:connect(checkCharacterCount)

	if not startedCountdown then
		startedCountdown = true

		FastSpawn(function()
			for time = 30, 1, -1 do
				if started ~= 0 then return end
				JoinTimer.Value = time
				wait(1)
			end

			start()
		end)
	end
end

for _, player in pairs(Players:GetPlayers()) do
	playerAdded(player)
end

Players.PlayerAdded:connect(playerAdded)
