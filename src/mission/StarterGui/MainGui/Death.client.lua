local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)
local LivesText = require(ReplicatedStorage.Libraries.LivesText)
local OnDied = require(ReplicatedStorage.Core.OnDied)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local PerfectTextLabel = require(ReplicatedStorage.Core.UI.Components.PerfectTextLabel)

local ImageCap = require(ReplicatedStorage.Assets.Tarmac.UI.cap)

local e = Roact.createElement

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

local function CapsLoss(props)
	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		UIListLayout = e("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Label = e(PerfectTextLabel, {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			LayoutOrder = 1,
			Text = props.amount .. "% ",
			TextColor3 = Color3.fromRGB(214, 48, 48),
			TextSize = props.textSize,

			ForceY = UDim.new(1, 0),
		}),

		Caps = e("ImageLabel", {
			BackgroundTransparency = 1,
			Image = ImageCap,
			LayoutOrder = 2,
			Size = UDim2.fromOffset(props.textSize, props.textSize),
		}),
	})
end

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

		GoldLoss.Text = ""

		local tree = Roact.mount(e(CapsLoss, {
			amount = 100,
			textSize = 60,
		}), GoldLoss)

		GoldLoss:GetPropertyChangedSignal("TextSize"):connect(function()
			Roact.update(tree, e(CapsLoss, {
				amount = amount,
				textSize = GoldLoss.TextSize,
			}))
		end)

		characterAdded = function(character)
			OnDied(character:WaitForChild("Humanoid")):connect(function()
				respawningDeath(function()
					if amount > MIN_COINS then
						amount = amount - 10
						Roact.update(tree, e(CapsLoss, {
							amount = amount,
							textSize = GoldLoss.TextSize,
						}))
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
