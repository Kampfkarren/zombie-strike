local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Data = require(ReplicatedStorage.Libraries.Data)
local Loot = require(ReplicatedStorage.Core.Loot)
local LootInfoButton = require(ReplicatedStorage.Core.UI.LootInfoButton)
local ViewportFramePreview = require(ReplicatedStorage.Core.UI.ViewportFramePreview)

local Blur = Lighting.Blur
local LootResults = script.Parent.Main.LootResults
local YouWin = script.Parent.Main.YouWin

local LootContents = LootResults.Loot.Contents
local LootInfo = LootResults.LootInfo.Inner

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
	LootResults,
	TweenInfo.new(1.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	{ Position = UDim2.new(0, 0, 0, 0) }
)

-- local tweenBlurOut = TweenService:Create(
-- 	Blur,
-- 	TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
-- 	{ Size = 0 }
-- )

ReplicatedStorage.Remotes.MissionOver.OnClientEvent:connect(function(loot, xp, gold)
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

	local template = LootContents.Template:Clone()
	LootContents.Template:Destroy()

	-- TODO: Animate it
	for _, loot in pairs(loot) do
		local lootButton = template:Clone()
		local rarity = Loot.Rarities[loot.Rarity]

		if rarity.Color then
			lootButton.BackgroundColor3 = rarity.Color
		end

		lootButton.GunName.Text = loot.Name
		lootButton.Rarity.Text = rarity.Name

		ViewportFramePreview(lootButton.ViewportFrame, Data.GetModel(loot))
		LootInfoButton(lootButton, LootInfo, loot)

		lootButton.Parent = LootContents
	end

	wait(5.3)

	if UserInputService.GamepadEnabled then
		GuiService.SelectedObject = LootContents:FindFirstChild("Template")
	end
end)
