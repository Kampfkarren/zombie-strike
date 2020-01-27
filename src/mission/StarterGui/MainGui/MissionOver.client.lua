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
local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local EnglishNumbers = require(ReplicatedStorage.Core.EnglishNumbers)
local GunScaling = require(ReplicatedStorage.Core.GunScaling)
local Loot = require(ReplicatedStorage.Core.Loot)
local LootInfoButton = require(ReplicatedStorage.Core.UI.LootInfoButton)
local PlaceIds = require(ReplicatedStorage.Core.PlaceIds)
local OnDied = require(ReplicatedStorage.Core.OnDied)
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
local REVEAL_ANIMATE_INTERVAL = 1

local GAMEMODE_LOOT_STYLES = {
	Brains = {
		BackgroundColor = Color3.fromRGB(253, 121, 168),
		Type = "Brains",
	},
}

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

local musicTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

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
	TeleportService:Teleport(PlaceIds.GetHubPlace())
end

LootResults.Minor.Leave.MouseButton1Click:connect(leave)

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

	-- Change music
	for _, music in pairs(SoundService.Music:GetDescendants()) do
		if music.Name == "MissionEnd" then
			music:Play()
		end
	end

	-- Loot contents
	local loot = Loot.DeserializeTable(loot)

	local itemTemplate = LootContents.ItemTemplate:Clone()
	LootContents.ItemTemplate:Destroy()

	local revealTemplate = LootContents.RevealTemplate:Clone()
	LootContents.RevealTemplate:Destroy()

	if #loot == 0 and not gamemodeLoot then
		LootContents.InventoryFull.Visible = true
	end

	wait(5.3)
	animate(LootResults.Info.XP.Count, xp, FULL_TIME_XP)
	wait(0.5)
	animate(LootResults.Info.Gold.Count, gold, FULL_TIME_GOLD)

	local revealButtons = {}
	local revealed = 0

	local amountOfLoot = #loot + #(gamemodeLoot or {})

	local function lootRevealed()
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
	end

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

			if Loot.IsWeapon(loot) then
				for key, value in pairs(GunScaling.BaseStats(loot.Type, loot.Level, loot.Rarity)) do
					if loot[key] == nil then
						loot[key] = value
					end
				end
			end

			local model = Data.GetModel(loot)
			if Loot.IsAurora(loot) then
				model.PrimaryPart.Material = Enum.Material.Ice
				model.PrimaryPart.TextureID = ""
			end

			ViewportFramePreview(lootButton.ViewportFrame, model)
			local _, hover = LootInfoButton(lootButton, LootInfo, loot)

			if index == 1 and UserInputService.GamepadEnabled then
				GuiService.SelectedObject = LootContents:FindFirstChild("Template")
			end

			revealButton:Destroy()
			lootButton.Parent = LootContents
			hover()

			lootRevealed()
		end)

		revealButton.Parent = LootContents
		table.insert(revealButtons, revealButton)
	end

	for index, item in pairs(gamemodeLoot or {}) do
		local revealButton = revealTemplate:Clone()
		revealButton.LayoutOrder = #loot + index

		-- if only there was some gui framework that made it easy
		-- to make components. oh well. guess it doesnt exist.
		-- time to do this the stupid baby goo goo way.
		revealButton.MouseButton1Click:connect(function()
			local style = GAMEMODE_LOOT_STYLES[item.Type]

			local lootButton = itemTemplate:Clone()
			lootButton.LayoutOrder = index

			lootButton.BackgroundColor3 = style.BackgroundColor
			lootButton.Rarity.Text = style.Type

			local lootName

			if item.Type == "Brains" then
				lootName = item.Brains .. " 🧠"

				local textLabel = Instance.new("TextLabel")
				textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				textLabel.BackgroundTransparency = 1
				textLabel.Position = UDim2.fromScale(0.5, 0.5)
				textLabel.Size = UDim2.fromScale(0.95, 0.95)
				textLabel.Text = "🧠"
				textLabel.TextScaled = true
				textLabel.Parent = lootButton.ViewportFrame
			end

			lootButton.GunName.Text = lootName

			revealButton:Destroy()
			lootButton.Parent = LootContents
			lootRevealed()
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
