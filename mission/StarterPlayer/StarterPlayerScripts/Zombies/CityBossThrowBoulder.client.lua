local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local WarningRange = require(ReplicatedStorage.Libraries.WarningRange)

local LocalPlayer = Players.LocalPlayer

local HitByBoulder = ReplicatedStorage.Remotes.CityBoss.HitByBoulder
local ThrowBoulder = ReplicatedStorage.Remotes.CityBoss.ThrowBoulder

local RANGE = 15

local function randomAngle()
	return math.random(-math.pi * 100, math.pi * 100) / 100
end

local function playSound(soundFolder)
	local children = soundFolder:GetChildren()
	local sound = children[math.random(#children)]
	sound:Play()
end

ThrowBoulder.OnClientEvent:connect(function(boulderModel, position)
	playSound(SoundService.ZombieSounds["1"].Boss.RockThrow)

	local boulder = boulderModel.PrimaryPart:Clone()
	boulder.GripMotor:Destroy()
	boulder.Anchored = true
	boulder.Parent = Workspace

	boulderModel:Destroy()

	local tween = TweenService:Create(
		boulder,
		TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{
			CFrame = CFrame.new(position) * CFrame.Angles(
				randomAngle(),
				randomAngle(),
				randomAngle()
			)
		}
	)

	local warning = WarningRange(position, RANGE)

	tween.Completed:connect(function()
		local impact = boulder.Impact:Clone()

		local attachment = Instance.new("Attachment")
		attachment.Position = boulder.Position

		impact.Parent = attachment

		attachment.Parent = Workspace.Terrain
		impact:Emit(30)
		Debris:AddItem(attachment)

		boulder:Destroy()
		warning:Destroy()

		local character = LocalPlayer.Character
		if character then
			if (character.PrimaryPart.Position - position).Magnitude <= RANGE then
				HitByBoulder:FireServer()
			end
		end
	end)

	tween:Play()
end)
