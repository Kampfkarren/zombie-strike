local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)
local LivesText = require(ReplicatedStorage.Libraries.LivesText)
local OnDied = require(ReplicatedStorage.Core.OnDied)

local DeathFade = Lighting.DeathFade
local GoldLoss = script.Parent.Main.GoldLoss
local LocalPlayer = Players.LocalPlayer
local RespawnMe = ReplicatedStorage.Remotes.RespawnMe

local HARDCORE_TIME = 1.5
local START_SPECTATE_TIME = 1
local MIN_COINS = 50

local characterAdded
local gamemodeInfo = Dungeon.GetGamemodeInfo()

local function hardcoreDeath()
	local total = 0

	repeat
		total = math.min(
			HARDCORE_TIME,
			total + RunService.RenderStepped:wait()
		)

		local tint = (HARDCORE_TIME - total) / 1.5

		DeathFade.TintColor = Color3.new(1, tint, tint)
	until total >= HARDCORE_TIME

	wait(START_SPECTATE_TIME)

	LocalPlayer.PlayerGui.MainGui.Main.Abilities.Visible = false
	LocalPlayer.PlayerGui.MainGui.Main.Ammo.Visible = false

	ReplicatedStorage.LocalEvents.StartSpectate:Fire()
end

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

local function respawningDeath(shiftAmount)
	tweenFadeOut:Play()
	LocalPlayer.PlayerGui.RuddevGui.Enabled = false

	wait(0.2)
	tweenGoldLossIn:Play()
	tweenGoldLossIn.Completed:wait()
	wait(0.2)

	if shiftAmount() then
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
end

if gamemodeInfo.Lives == nil then
	if Dungeon.GetDungeonData("Hardcore") then
		characterAdded = function(character)
			OnDied(character:WaitForChild("Humanoid")):wait()
			hardcoreDeath()
		end
	else
		local amount = 100

		characterAdded = function(character)
			OnDied(character:WaitForChild("Humanoid")):connect(function()
				respawningDeath(function()
					if amount > MIN_COINS then
						amount = amount - 10
						GoldLoss.Text = amount .. "% G"
						return true
					end
				end)
			end)
		end
	end
else
	local lives = ReplicatedStorage:WaitForChild("Lives")

	characterAdded = function(character)
		OnDied(character:WaitForChild("Humanoid")):connect(function()
			if lives.Value == 0 then
				hardcoreDeath()
			else
				GoldLoss.TextColor3 = Color3.new(1, 0.6, 1)
				GoldLoss.Text = LivesText(lives.Value)

				respawningDeath(function()
					GoldLoss.Text = LivesText(lives.Value)

					if lives.Value == 0 then
						FastSpawn(hardcoreDeath)
					end

					return true
				end)
			end
		end)
	end
end

LocalPlayer.CharacterAdded:connect(characterAdded)
if LocalPlayer.Character then
	characterAdded(LocalPlayer.Character)
end
