local CollectionService = game:GetService("CollectionService")
local ContentProvider = game:GetService("ContentProvider")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Data = require(ReplicatedStorage.Core.Data)
local EnglishNumbers = require(ReplicatedStorage.Core.EnglishNumbers)
local GunScaling = require(ReplicatedStorage.Core.GunScaling)
local Loot = require(ReplicatedStorage.Core.Loot)
local LootInfoButton = require(ReplicatedStorage.Core.UI.LootInfoButton)
local ViewportFramePreview = require(ReplicatedStorage.Core.UI.ViewportFramePreview)

local Blur = Lighting.Blur
local Finish = SoundService.SFX.Finish
local GoingUp = SoundService.SFX.GoingUp
local LocalPlayer = Players.LocalPlayer
local LootResults = script.Parent.Main.LootResults
local YouWin = script.Parent.Main.YouWin

local LootContents = LootResults.Loot.Contents
local LootInfo = LootResults.LootInfo.Inner

local FULL_TIME_ANIMATION = 1.5
local FULL_TIME_GOLD = 250
local FULL_TIME_XP = 2000
local HUB_PLACE = 3759927663
local REVEAL_ANIMATE_INTERVAL = 1

local wordTweenIn = {
	TweenInfo.new(2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
	{ Position = UDim2.new(0.5, 0, 0.5, 0) },
}

local wordTweenOut = {
	TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
	{ Position = UDim2.new(-0.5, 0, 0.5, 0) },
}

local questionMarkTween = {
	TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0, true),
	{ Rotation = -35 }
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
	LootResults,
	TweenInfo.new(1.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	{ Position = UDim2.new(0, 0, 0, 0) }
)

-- local tweenBlurOut = TweenService:Create(
-- 	Blur,
-- 	TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
-- 	{ Size = 0 }
-- )

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function animate(label, amount, full)
	local timeNeeded = math.min(FULL_TIME_ANIMATION, lerp(0, FULL_TIME_ANIMATION, amount / full))
	local timeSpent = 0

	GoingUp:Play()

	repeat
		timeSpent = timeSpent + RunService.RenderStepped:wait()
		label.Text = EnglishNumbers(math.min(amount, lerp(0, amount, timeSpent / timeNeeded)))
	until timeSpent >= timeNeeded

	label.Text = EnglishNumbers(amount)

	Finish:Play()
	GoingUp:Stop()
end

local function leave()
	TeleportService:Teleport(HUB_PLACE)
end

LootResults.Minor.Leave.MouseButton1Click:connect(leave)

ReplicatedStorage.Remotes.MissionOver.OnClientEvent:connect(function(loot, xp, gold)
	local clearTime = time()
	LootResults.Minor.ClearTime.Text = ("%d:%02d"):format(math.floor(clearTime / 60), clearTime % 60)

	LocalPlayer.PlayerGui.RuddevGui.Enabled = false

	for _, frame in pairs(script.Parent.Main:GetChildren()) do
		if not CollectionService:HasTag(frame, "KeepUIAfterWin") then
			frame.Visible = false
		end
	end

	tweenWord1In:Play()
	tweenWord2In:Play()
	tweenBlurIn:Play()

	delay(4, function()
		ReplicatedStorage.RuddevEvents.Modal:Fire("Push")
		tweenWord1Out:Play()
		tweenWord2Out:Play()
		tweenLoot:Play()
	end)

	-- Loot contents
	local loot = Loot.DeserializeTable(loot)

	local itemTemplate = LootContents.ItemTemplate:Clone()
	LootContents.ItemTemplate:Destroy()

	local revealTemplate = LootContents.RevealTemplate:Clone()
	LootContents.RevealTemplate:Destroy()

	if #loot == 0 then
		LootContents.InventoryFull.Visible = true
	end

	wait(5.3)
	animate(LootResults.Info.XP.Count, xp, FULL_TIME_XP)
	wait(0.5)
	animate(LootResults.Info.Gold.Count, gold, FULL_TIME_GOLD)

	local revealButtons = {}
	local revealed = 0

	local amountOfLoot = #loot

	for index, loot in pairs(loot) do
		local revealButton = revealTemplate:Clone()
		revealButton.LayoutOrder = index

		revealButton.MouseButton1Click:connect(function()
			local lootButton = itemTemplate:Clone()
			lootButton.LayoutOrder = index

			local rarity = Loot.Rarities[loot.Rarity]

			if rarity.Color then
				lootButton.BackgroundColor3 = rarity.Color
			end

			lootButton.GunName.Text = Loot.GetLootName(loot)
			lootButton.Rarity.Text = rarity.Name

			if loot.Type ~= "Helmet" and loot.Type ~= "Armor" then
				for key, value in pairs(GunScaling.BaseStats(loot.Type, loot.Level, loot.Rarity)) do
					if loot[key] == nil then
						loot[key] = value
					end
				end
			end

			ViewportFramePreview(lootButton.ViewportFrame, Data.GetModel(loot))
			local _, hover = LootInfoButton(lootButton, LootInfo, loot)

			if index == 1 and UserInputService.GamepadEnabled then
				GuiService.SelectedObject = LootContents:FindFirstChild("Template")
			end

			revealButton:Destroy()
			lootButton.Parent = LootContents
			hover()

			local sound = SoundService.SFX.Reveal:Clone()
			sound.PlayOnRemove = true
			sound.Parent = SoundService
			sound:Destroy()

			revealed = revealed + 1

			if revealed == amountOfLoot then
				for timer = 10, 1, -1 do
					LootResults.Minor.Leave.Label.Text = "LEAVE (" .. timer .. ")"
					wait(1)
				end

				LootResults.Minor.Leave.Label.Text = "LEAVING..."
				leave()
			end
		end)

		revealButton.Parent = LootContents
		table.insert(revealButtons, revealButton)
	end

	spawn(function()
		while true do
			for _, revealButton in pairs(revealButtons) do
				if revealButton:IsDescendantOf(game) then
					TweenService:Create(revealButton.QuestionMark, unpack(questionMarkTween)):Play()
				end
			end

			wait(REVEAL_ANIMATE_INTERVAL)
		end
	end)
end)

ContentProvider:PreloadAsync({ SoundService.SFX.Reveal })
