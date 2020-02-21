local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

local Color3Lerp = require(ReplicatedStorage.Core.Color3Lerp)
local Maid = require(ReplicatedStorage.Core.Maid)
local PlayQuickSound = require(ReplicatedStorage.Core.PlayQuickSound)

local TowerSounds = SoundService.SFX.Campaigns.Tower
local UsePortal = ReplicatedStorage.Remotes.Tower.UsePortal

local Tower = {}

local MAX_DISTANCE = 25
local MIN_DISTANCE = 5

local PORTAL_BRIGHTNESS = 0.3

local PORTAL_COLOR = Color3.new(1, 0, 1)
local WHITE = Color3.new(1, 1, 1)

local colorCorrection = Instance.new("ColorCorrectionEffect")
colorCorrection.Parent = Lighting

local expecting = {}
local latestPortal

UsePortal.OnClientEvent:connect(function(player)
	if expecting[player] then
		expecting[player] = nil
		local character = player.Character
		if character then
			PlayQuickSound(TowerSounds.OtherTeleport, latestPortal and character.PrimaryPart or latestPortal)
		end
	end
end)

function Tower.Open(gate)
	latestPortal = gate.PrimaryPart

	gate.PrimaryPart.Color = Color3.new(0.5, 0, 0.5)
	gate.PrimaryPart.ParticleEmitter.Enabled = true
	gate.Portal.GateLight.PointLight.Enabled = true

	local maid = Maid.new()

	PlayQuickSound(TowerSounds.PortalOpen, gate.PrimaryPart)

	local loop = TowerSounds.PortalLoop:Clone()
	loop.Parent = gate.PrimaryPart
	loop:Play()
	maid:GiveTask(loop)

	maid:GiveTask(function()
		colorCorrection.Brightness = 0
		colorCorrection.TintColor = Color3.new(1, 1, 1)
		latestPortal = nil
	end)

	maid:GiveTask(RunService.Heartbeat:connect(function()
		local character = Players.LocalPlayer.Character
		local distance = MAX_DISTANCE

		if character then
			distance = math.clamp(
				(gate.PrimaryPart.Position - character.PrimaryPart.Position).Magnitude,
				MIN_DISTANCE,
				MAX_DISTANCE
			)
		end

		local alpha = (distance - MIN_DISTANCE) / (MAX_DISTANCE - MIN_DISTANCE)
		colorCorrection.Brightness = PORTAL_BRIGHTNESS * (1 - alpha)
		colorCorrection.TintColor = Color3Lerp(
			PORTAL_COLOR,
			WHITE,
			alpha
		)
	end))

	maid:GiveTask(gate.PrimaryPart.Touched:connect(function(part)
		local character = Players.LocalPlayer.Character
		if character and part:IsDescendantOf(character) then
			maid:DoCleaning()
			character:SetPrimaryPartCFrame(ReplicatedStorage.CurrentSpawn.Value.WorldCFrame)
			PlayQuickSound(TowerSounds.SelfTeleport)
			UsePortal:FireServer()
		end
	end))

	for _, player in pairs(Players:GetPlayers()) do
		expecting[player] = true
	end

	return gate
end

return Tower
