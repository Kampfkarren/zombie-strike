local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Data = require(ReplicatedStorage.Libraries.Data)
local Loot = require(ReplicatedStorage.Libraries.Loot)

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

local function changeStat(statFrame, lootStat, currentStat, format, consizeredZero)
	consizeredZero = consizeredZero or 0
	format = format or "%d"
	statFrame.Current.Text = format:format(lootStat)

	local diff = lootStat - currentStat

	if diff > consizeredZero then
		statFrame.Diff.Text = "+" .. format:format(diff)
		statFrame.Diff.TextColor3 = Color3.fromRGB(85, 255, 127)
	elseif diff < 0 then
		statFrame.Diff.Text = format:format(diff)
		statFrame.Diff.TextColor3 = Color3.fromRGB(232, 65, 24)
	else
		statFrame.Diff.Text = "+0"
		statFrame.Diff.TextColor3 = Color3.new(0.8, 0.8, 0.8)
	end
end

local function viewportFrame(viewportFrame, model)
	local model = model:Clone()

	if viewportFrame.CurrentCamera then
		viewportFrame.CurrentCamera:Destroy()
	end

	local camera = Instance.new("Camera")
	model.Parent = camera
	local bounds = model:GetBoundingBox()
	camera.CFrame = CFrame.new(
		model.PrimaryPart.Position - model.PrimaryPart.CFrame.RightVector * model.PrimaryPart.Size.Z,
		model.PrimaryPart.Position
	)
	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera
end

ReplicatedStorage.Remotes.MissionOver.OnClientEvent:connect(function(loot, xp, gold)
	local currentGun = Data.GetLocalPlayerData("Weapon")

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
		viewportFrame(lootButton.ViewportFrame, Data.GetModel(loot))

		local function lootInfo()
			LootInfo.Level.Text = "Level " .. loot.Level
			LootInfo.LootName.Text = loot.Name
			LootInfo.Rarity.Text = rarity.Name .. " " .. loot.Type

			local stats = LootInfo.Stats

			changeStat(stats.MagSize, loot.Magazine, currentGun.Magazine)
			changeStat(stats.Damage, loot.Damage, currentGun.Damage)

			changeStat(
				stats.CritChance,
				loot.CritChance * 100,
				currentGun.CritChance * 100,
				"%d%%",
				0.99999999
			)

			changeStat(stats.FireRate, loot.FireRate, currentGun.FireRate, "%.1f", 0.00999999)
			viewportFrame(LootInfo.ViewportFrame, Data.GetModel(loot))

			if rarity.Color then
				LootInfo.ViewportFrame.BackgroundColor3 = rarity.Color
			end

			LootInfo.Visible = true
		end

		lootButton.MouseButton1Click:connect(function()
			if UserInputService.TouchEnabled then
				if LootInfo.Visible then
					LootInfo.Visible = false
				else
					lootInfo()
				end
			end
		end)

		lootButton.MouseEnter:connect(function()
			if UserInputService.MouseEnabled then
				LootInfo.Visible = true
			end
		end)

		lootButton.MouseLeave:connect(function()
			if UserInputService.MouseEnabled then
				LootInfo.Visible = false
			end
		end)

		lootButton.SelectionGained:connect(function()
			lootInfo()
		end)

		lootButton.Parent = LootContents
	end

	wait(5.3)

	if UserInputService.GamepadEnabled then
		GuiService.SelectedObject = LootContents:FindFirstChild("Template")
	end
end)
