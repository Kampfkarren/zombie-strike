local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local RealDelay = require(ReplicatedStorage.Core.RealDelay)

local BossLaserBig = ReplicatedStorage.Assets.Campaign.Campaign3.Boss.BossLaserBig
local ChargeBigLaser = ReplicatedStorage.Remotes.FirelandsBoss.ChargeBigLaser
local LocalPlayer = Players.LocalPlayer

local LASER_LIFETIME = 0.5

if Dungeon.GetDungeonData("Campaign") ~= 3 then return end

local boss = CollectionService:GetInstanceAddedSignal("Boss"):wait()

local active = false

ChargeBigLaser.OnClientEvent:connect(function(newActive)
	active = newActive
	if not active then return end

	local bigLaser = BossLaserBig:Clone()
	bigLaser.Parent = Workspace

	repeat
		local primaryCFrame = boss.Body.PrimaryPart.CFrame
		bigLaser:SetPrimaryPartCFrame(
			(
				primaryCFrame
				+ (primaryCFrame.LookVector
					* bigLaser.PrimaryPart.Size.X / 2
				)
			) * CFrame.Angles(0, math.pi / 2, 0)
		)
		RunService.Heartbeat:wait()
	until not active

	bigLaser.Warning:Destroy()
	bigLaser.BossLaserBig.Color = Color3.fromRGB(255, 107, 2)
	bigLaser.BossLaserBig.Material = Enum.Material.Neon

	local character = LocalPlayer.Character

	if character then
		local touched = false

		bigLaser.BossLaserBig.CanCollide = true

		for _, part in pairs(bigLaser.BossLaserBig:GetTouchingParts()) do
			if part:IsDescendantOf(character) then
				touched = true
				break
			end
		end

		bigLaser.BossLaserBig.CanCollide = false

		if touched then
			ChargeBigLaser:FireServer()
		end
	end

	RealDelay(LASER_LIFETIME, function()
		bigLaser:Destroy()
	end)
end)
