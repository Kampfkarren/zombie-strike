local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local Maid = require(ReplicatedStorage.Core.Maid)
local RealDelay = require(ReplicatedStorage.Core.RealDelay)

local LocalPlayer = Players.LocalPlayer
local Spin = ReplicatedStorage.Remotes.FrostlandsBoss.Spin

if Dungeon.GetDungeonData("Campaign") ~= 4 then return end

local boss = CollectionService:GetInstanceAddedSignal("Boss"):wait()

local DAMAGE_DELAY = 1
local ROTATE_RATE = 0.3
local SPIN_TIME = 7

local laserTubes = boss:WaitForChild("Lasers")

local maid = Maid.new()

Spin.OnClientEvent:connect(function()
	local animation = boss.Humanoid:LoadAnimation(
		ReplicatedStorage
			.Assets
			.Campaign
			.Campaign4
			.Boss
			.SpinAnimation
	)

	animation:Play()
	maid:GiveTask(function()
		animation:Stop()

		for _, tube in pairs(laserTubes:GetChildren()) do
			tube.Color = Color3.fromRGB(0, 255, 255)
			tube.Transparency = 1
		end
	end)

	for _, tube in pairs(laserTubes:GetChildren()) do
		tube.Transparency = 0
	end

	maid:GiveTask(RunService.Heartbeat:connect(function(delta)
		laserTubes:SetPrimaryPartCFrame(
			laserTubes.PrimaryPart.CFrame * CFrame.Angles(0, delta * ROTATE_RATE, 0)
		)
	end))

	RealDelay(DAMAGE_DELAY, function()
		for _, tube in pairs(laserTubes:GetChildren()) do
			tube.Color = Color3.new(0, 0, 1)

			maid:GiveTask(tube.Touched:connect(function(part)
				if part:IsDescendantOf(LocalPlayer.Character) then
					Spin:FireServer()
				end
			end))
		end
	end)

	RealDelay(DAMAGE_DELAY + SPIN_TIME, function()
		maid:DoCleaning()
	end)
end)
