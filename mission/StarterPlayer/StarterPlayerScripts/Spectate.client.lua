local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Spectate = ReplicatedStorage.LocalEvents.Spectate
local StartSpectate = ReplicatedStorage.LocalEvents.StartSpectate
local SpectateGui = Players.LocalPlayer
	:WaitForChild("PlayerGui")
	:WaitForChild("MainGui")
	:WaitForChild("Main")
	:WaitForChild("Spectate")

local alivePlayers

local function getAlivePlayers()
	local players = {}
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character and player.Character.Humanoid.Health > 0 then
			table.insert(players, player)
		end
	end
	return players
end

local function filterOutPlayers()
	local players = {}
	for _, player in ipairs(alivePlayers) do
		if player.Character and player.Character.Humanoid.Health > 0 then
			table.insert(players, player)
		end
	end
	if #players == #alivePlayers then
		return alivePlayers
	else
		return players
	end
end

local currentPlayer

local function spectate(player)
	currentPlayer = player
	Spectate:Fire(player)
	SpectateGui.Username.Text = player.Name
end

StartSpectate.Event:connect(function()
	alivePlayers = getAlivePlayers()
	if #alivePlayers > 0 then
		Lighting.DeathFade:Destroy()
		SpectateGui.Visible = true
		spectate(alivePlayers[math.random(#alivePlayers)])

		UserInputService.InputBegan:connect(function(inputObject, processed)
			if processed then return end

			alivePlayers = filterOutPlayers()
			local currentIndex

			for index, player in pairs(alivePlayers) do
				if player == currentPlayer then
					currentIndex = index
				end
			end

			if currentIndex == nil then
				currentIndex = 0
			end

			if inputObject.KeyCode == Enum.KeyCode.Q then
				if currentIndex == 1 then
					currentIndex = #alivePlayers
				else
					currentIndex = currentIndex - 1
				end
			elseif inputObject.KeyCode == Enum.KeyCode.E then
				if currentIndex == #alivePlayers then
					currentIndex = 1
				else
					currentIndex = currentIndex + 1
				end
			end

			spectate(alivePlayers[currentIndex])
		end)
	end
end)
