local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local Maid = require(ReplicatedStorage.Core.Maid)
local RealDelay = require(ReplicatedStorage.Core.RealDelay)

local LocalPlayer = Players.LocalPlayer
local Icicle = ReplicatedStorage.Assets.Campaign.Campaign4.Boss.Icicle
local IcicleRain = ReplicatedStorage.Remotes.FrostlandsBoss.IcicleRain
local IcicleShard = SoundService.ZombieSounds["4"].Boss.IceShard
local WarningRange = ReplicatedStorage.WarningRange

local HEIGHT = 0.25
local ICICLE_DROP = 0.6
local ICICLE_LIFETIME = 0.5
local ICICLE_OFFSET = Vector3.new(0, 10, 0)
local ICICLE_PER_SECOND = 8
local OFFSET = Vector3.new(0, 2.4, 0)
local RADIUS = 10

if Dungeon.GetDungeonData("Campaign") ~= 4 then return end

local function dropIcicles()
	for _, player in pairs(Players:GetPlayers()) do
		local character = player.Character

		if character then
			local maid = Maid.new()

			local warning = WarningRange:Clone()
			warning.Color = Color3.fromRGB(0, 255, 255)
			warning.Position = character.PrimaryPart.Position - OFFSET
			warning.Size = Vector3.new(HEIGHT, RADIUS, RADIUS)
			warning.Parent = Workspace

			local icicle = Icicle:Clone()
			icicle.Position = character.PrimaryPart.Position + ICICLE_OFFSET
			icicle.Parent = Workspace

			local sound = IcicleShard:Clone()
			sound.Parent = icicle
			sound:Play()

			local hurtByIcicle = false

			maid:GiveTask(icicle.Touched:connect(function(part)
				if hurtByIcicle then return end
				if part:IsDescendantOf(LocalPlayer.Character) then
					hurtByIcicle = true
					IcicleRain:FireServer()
				end
			end))

			TweenService:Create(
				icicle,
				TweenInfo.new(
					ICICLE_DROP,
					Enum.EasingStyle.Sine,
					Enum.EasingDirection.InOut
				),
				{
					Position = warning.Position,
				}
			):Play()

			maid:GiveTask(warning)

			RealDelay(ICICLE_DROP, function()
				maid:DoCleaning()

				TweenService:Create(
					icicle,
					TweenInfo.new(ICICLE_LIFETIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Transparency = 1,
					}
				):Play()

				RealDelay(ICICLE_LIFETIME, function()
					icicle:Destroy()
				end)
			end)
		end
	end
end

IcicleRain.OnClientEvent:connect(function(timer)
	local maid = Maid.new()

	local total = 0

	maid:GiveTask(RunService.Heartbeat:connect(function(delta)
		total = total + delta
		if total >= 1 / ICICLE_PER_SECOND then
			total = 0
			dropIcicles()
		end
	end))

	RealDelay(timer, function()
		maid:DoCleaning()
	end)
end)
