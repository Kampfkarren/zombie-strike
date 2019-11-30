local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local PlaySound = require(ReplicatedStorage.Core.PlaySound)

local FloorLaser = ReplicatedStorage.Remotes.FactoryBoss.FloorLaser
local LocalPlayer = Players.LocalPlayer
local WarningRange = ReplicatedStorage.WarningRange

local DELAY = 2
local HEIGHT = 0.25
local HEIGHT_BIG = 100
local LIFETIME = 0.9
local OFFSET = Vector3.new(0, 2, 0)
local RADIUS = 10

if Dungeon.GetDungeonData("Campaign") ~= 2 then return end

FloorLaser.OnClientEvent:connect(function()
	local warnings = {}

	for _, player in pairs(Players:GetPlayers()) do
		local character = player.Character

		local warning = WarningRange:Clone()
		warning.Position = character.PrimaryPart.Position - OFFSET
		warning.Size = Vector3.new(HEIGHT, RADIUS, RADIUS)
		warning.Parent = Workspace

		table.insert(warnings, warning)
	end

	wait(DELAY)

	local touched = false

	for _, warning in pairs(warnings) do
		TweenService:Create(
			warning,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ Size = Vector3.new(HEIGHT_BIG, RADIUS, RADIUS) }
		):Play()

		PlaySound(SoundService.SFX.Laser.Small, warning)

		local function touch(part)
			if touched then return end
			if part:IsDescendantOf(LocalPlayer.Character) then
				touched = true
				FloorLaser:FireServer()
			end
		end

		warning.Touched:connect(touch)

		if not touched then
			warning.CanCollide = true
			for _, part in pairs(warning:GetTouchingParts()) do
				touch(part)
			end
			warning.CanCollide = false
		end

		Debris:AddItem(warning, LIFETIME)
	end
end)
