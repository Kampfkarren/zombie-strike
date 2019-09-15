local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)

local DeathFade = Lighting.DeathFade
local GoldLoss = script.Parent.Main.GoldLoss
local LocalPlayer = Players.LocalPlayer
local RespawnMe = ReplicatedStorage.Remotes.RespawnMe

local HARDCORE_TIME = 1.5
local MIN_COINS = 50

local characterAdded

if Dungeon.GetDungeonData("Hardcore") then
	characterAdded = function(character)
		character:WaitForChild("Humanoid").Died:wait()

		local total = 0

		repeat
			total = math.min(
				HARDCORE_TIME,
				total + RunService.RenderStepped:wait()
			)

			local tint = (HARDCORE_TIME - total) / 1.5

			DeathFade.TintColor = Color3.new(1, tint, tint)
		until total >= HARDCORE_TIME
	end
else
	local amount = 100

	local tweenFadeOut = TweenService:Create(
		DeathFade,
		TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Brightness = -1 }
	)

	local tweenFadeIn = TweenService:Create(
		DeathFade,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Brightness = 0 }
	)

	local tweenGoldLossIn = TweenService:Create(
		GoldLoss,
		TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
		{ Position = UDim2.new(0.5, 0, 0.5, 0) }
	)

	local tweenGoldLossOut = TweenService:Create(
		GoldLoss,
		TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
		{ Position = UDim2.new(1.5, 0, 0.5, 0) }
	)

	local tweenGoldLossBounce = TweenService:Create(
		GoldLoss,
		TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, true),
		{ TextSize = 100 }
	)

	characterAdded = function(character)
		character:WaitForChild("Humanoid").Died:connect(function()
			tweenFadeOut:Play()
			LocalPlayer.PlayerGui.RuddevGui.Enabled = false

			wait(0.2)
			tweenGoldLossIn:Play()
			tweenGoldLossIn.Completed:wait()
			wait(0.2)

			if amount > MIN_COINS then
				amount = amount - 10
				GoldLoss.Text = amount .. "% G"
				tweenGoldLossBounce:Play()
			end

			wait(1.5)

			RespawnMe:InvokeServer()
			tweenGoldLossOut:Play()

			tweenFadeIn:Play()
			tweenFadeIn.Completed:wait()
			RunService.Heartbeat:wait()
			GoldLoss.Position = UDim2.new(-0.5, 0, 0.5, 0)
			LocalPlayer.PlayerGui.RuddevGui.Enabled = true
		end)
	end
end

LocalPlayer.CharacterAdded:connect(characterAdded)
if LocalPlayer.Character then
	characterAdded(LocalPlayer.Character)
end
