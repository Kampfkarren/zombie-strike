local Debris = game:GetService("Debris")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local LevelUpGui = LocalPlayer
	:WaitForChild("PlayerGui")
	:WaitForChild("MainGui")
	:WaitForChild("Main")
	:WaitForChild("LevelUp")

local GUI_ANIMATE_TIME = 0.8
local GUI_HOLD_TIME = 4
local LIFETIME = 3
local RADIUS = 3
local CIRCLE_RATE = 5
local VERTICAL_RATE = 1

local lightTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

local inset = GuiService:GetGuiInset()
local levelUpHighPosition = UDim2.new(0.5, -inset.X, -LevelUpGui.Size.Y.Scale, -inset.Y)
LevelUpGui.Position = levelUpHighPosition

local function moveAttachment(attachment, t, sign)
	attachment.Position = Vector3.new(
		RADIUS * math.sin(t * CIRCLE_RATE) * sign,
		t * VERTICAL_RATE,
		RADIUS * math.cos(t * CIRCLE_RATE)
	)
end

local function circleEmitter(character, sign)
	local attachment = Instance.new("Attachment")

	moveAttachment(attachment, 0, sign)
	attachment.Parent = character.HumanoidRootPart

	local emitter = script.Part.Circle:Clone()
	emitter.Parent = attachment

	coroutine.wrap(function()
		local t = 0

		while t < LIFETIME do
			t = t + RunService.Heartbeat:wait()
			moveAttachment(attachment, t, sign)
		end

		emitter.Enabled = false
		Debris:AddItem(attachment)
	end)()
end

ReplicatedStorage.Remotes.LevelUp.OnClientEvent:connect(function(player)
	StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = ("%s has LEVELED UP!"):format(player.Name),
		Color = Color3.fromRGB(251, 197, 49),
		Font = Enum.Font.GothamSemibold,
	})

	local character = player.Character
	if not character then return end

	if player == LocalPlayer then
		TweenService:Create(
			LevelUpGui,
			TweenInfo.new(GUI_ANIMATE_TIME, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{ Position = UDim2.fromScale(0.5, 0) }
		):Play()

		delay(GUI_HOLD_TIME, function()
			TweenService:Create(
				LevelUpGui,
				TweenInfo.new(GUI_ANIMATE_TIME, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
				{ Position = levelUpHighPosition }
			):Play()
		end)
	end

	local sound = SoundService.LevelUp:Clone()
	sound.Parent = character.PrimaryPart
	sound:Play()

	Debris:AddItem(sound)

	circleEmitter(character, 1)
	circleEmitter(character, -1)

	local torsoEmitter = script.Part.Torso:Clone()
	torsoEmitter.Parent = character.UpperTorso

	local light = script.Light:Clone()

	local tweenIn = TweenService:Create(
		light,
		lightTweenInfo,
		{ Range = light.Range }
	)

	local tweenOut = TweenService:Create(
		light,
		lightTweenInfo,
		{ Range = 0 }
	)

	light.Range = 0
	light.Parent = character.PrimaryPart
	tweenIn:Play()

	delay(LIFETIME, function()
		torsoEmitter.Enabled = false
		Debris:AddItem(torsoEmitter)

		tweenOut:Play()
		Debris:AddItem(light)
	end)
end)
