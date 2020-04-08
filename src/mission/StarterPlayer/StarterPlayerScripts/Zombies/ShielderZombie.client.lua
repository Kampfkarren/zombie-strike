local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Color3Lerp = require(ReplicatedStorage.Core.Color3Lerp)
local PlaySound = require(ReplicatedStorage.Core.PlaySound)
local OnDied = require(ReplicatedStorage.Core.OnDied)

local FLASH_TIME = 0.35

local function velocityComponent()
	return math.random(20, 40) * (math.random(-1, 1) > 0 and 1 or -1)
end

local function setColor(thing, color)
	if thing:IsA("BasePart") then
		thing.Color = color
	else
		thing.Color3 = color
	end
end

CollectionService:GetInstanceAddedSignal("ShieldZombie"):connect(function(zombie)
	local shield = zombie:WaitForChild("Shield")

	local flashAnimation

	local colors

	local timeLeft = 0
	local function flash(delta)
		if colors == nil then
			colors = {}
			for _, thing in ipairs(shield:GetDescendants()) do
				local color

				if thing:IsA("BasePart") then
					color = thing.Color
				elseif thing:IsA("Texture") then
					color = thing.Color3
				end

				if color then
					local _, _, value = Color3.toHSV(color)
					colors[thing] = {
						Base = color,
						Red = Color3.fromHSV(0, 1, value),
					}
				end
			end
		end

		timeLeft = math.min(FLASH_TIME, timeLeft + delta)

		local delta = TweenService:GetValue(timeLeft / FLASH_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		for thing, colors in pairs(colors) do
			setColor(thing, Color3Lerp(colors.Red, colors.Base, delta))
		end

		if timeLeft >= FLASH_TIME then
			timeLeft = 0
			flashAnimation:Disconnect()
			flashAnimation = nil
		end
	end

	local shieldHumanoid = shield:WaitForChild("Humanoid")

	shieldHumanoid.HealthChanged:connect(function()
		PlaySound(SoundService.ZombieSounds["1"].Shielder.Impact, shield.PrimaryPart)

		if flashAnimation == nil then
			flashAnimation = RunService.Heartbeat:connect(flash)
		else
			timeLeft = 0
		end
	end)

	OnDied(shieldHumanoid):connect(function()
		PlaySound(SoundService.ZombieSounds["1"].Shielder.Break, zombie.PrimaryPart)

		local newShield = shield:Clone()
		shield:Destroy()
		newShield.Parent = Workspace

		newShield.Humanoid:Destroy()

		for _, part in ipairs(newShield:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = false
				part.Parent = Workspace

				for _, weld in pairs(part:GetDescendants()) do
					if weld:IsA("WeldConstraint") then
						weld:Destroy()
					end
				end

				part.Velocity = Vector3.new(
					velocityComponent(),
					0,
					velocityComponent()
				)
			end
		end

		for _, track in ipairs(zombie.Humanoid:GetPlayingAnimationTracks()) do
			if track.Name == "Pose" then
				track:Stop()
			end
		end

		zombie.Animations.run.RunAnim.AnimationId = zombie.Animations.Enraged.AnimationId
	end)
end)
