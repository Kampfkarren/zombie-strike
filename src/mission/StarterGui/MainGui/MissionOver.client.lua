local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local App = require(ReplicatedStorage.Core.UI.Components.App)
local Loot = require(ReplicatedStorage.Core.Loot)
local LootResults = require(ReplicatedStorage.Components.LootResults)
local RealDelay = require(ReplicatedStorage.Core.RealDelay)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local State = require(ReplicatedStorage.State)
local OnDied = require(ReplicatedStorage.Core.OnDied)

local e = Roact.createElement

local Blur = Lighting.Blur
local LocalPlayer = Players.LocalPlayer
local LootResultsFrame = script.Parent.Main.LootResults
local YouWin = script.Parent.Main.YouWin

local wordTweenIn = {
	TweenInfo.new(2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
	{ Position = UDim2.new(0.5, 0, 0.5, 0) },
}

local wordTweenOut = {
	TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
	{ Position = UDim2.new(-0.5, 0, 0.5, 0) },
}

local tweenWord1In = TweenService:Create(
	YouWin.Word1,
	unpack(wordTweenIn)
)

local tweenWord1Out = TweenService:Create(
	YouWin.Word1,
	unpack(wordTweenOut)
)

local tweenWord2In = TweenService:Create(
	YouWin.Word2,
	unpack(wordTweenIn)
)

local tweenWord2Out = TweenService:Create(
	YouWin.Word2,
	unpack(wordTweenOut)
)

local tweenBlurIn = TweenService:Create(
	Blur,
	TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
	{ Size = 20 }
)

local tweenLoot = TweenService:Create(
	LootResultsFrame,
	TweenInfo.new(1.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	{ Position = UDim2.new(0, 0, 0, 0) }
)

local musicTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

CollectionService:GetInstanceAddedSignal("Boss"):connect(function(boss)
	OnDied(boss:WaitForChild("Humanoid")):connect(function()
		for _, music in pairs(SoundService.Music:GetDescendants()) do
			if music.Name ~= "MissionEnd" and music:IsA("Sound") then
				TweenService:Create(
					music,
					musicTweenInfo,
					{ Volume = 0 }
				):Play()
			end
		end
	end)
end)

ReplicatedStorage.Remotes.MissionOver.OnClientEvent:connect(function(loot, xp, gold, gamemodeLoot)
	LocalPlayer.PlayerGui.RuddevGui.Enabled = false

	for _, frame in pairs(script.Parent.Main:GetChildren()) do
		if not CollectionService:HasTag(frame, "KeepUIAfterWin") then
			frame.Visible = false
		end
	end

	tweenWord1In:Play()
	tweenWord2In:Play()
	tweenBlurIn:Play()

	-- Change music
	for _, music in pairs(SoundService.Music:GetDescendants()) do
		if music.Name == "MissionEnd" then
			music:Play()
		end
	end

	-- Loot contents
	local loot = Loot.DeserializeTableWithBase(loot)

	local function tree(animateXpNow)
		return e(RoactRodux.StoreProvider, {
			store = State,
		}, {
			App = e(App.AppBase, {}, {
				LootResults = e(LootResults, {
					AnimateXPNow = animateXpNow,
					GamemodeLoot = gamemodeLoot or {},
					Caps = gold,
					Loot = loot,
					XP = xp,
				}),
			}),
		})
	end

	local handle = Roact.mount(tree(), LootResultsFrame)

	RealDelay(4, function()
		ReplicatedStorage.RuddevEvents.Modal:Fire("Push")
		tweenWord1Out:Play()
		tweenWord2Out:Play()
		tweenLoot:Play()

		Roact.update(handle, tree(true))
	end)
end)
