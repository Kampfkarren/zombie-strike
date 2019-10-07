local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")

local LIFETIME = 3
local RADIUS = 3
local CIRCLE_RATE = 5
local VERTICAL_RATE = 1

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

	local emitter = script.Part.ParticleEmitter:Clone()
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

	local sound = SoundService.LevelUp:Clone()
	sound.Parent = character.PrimaryPart
	sound:Play()

	Debris:AddItem(sound)

	circleEmitter(character, 1)
	circleEmitter(character, -1)
end)
