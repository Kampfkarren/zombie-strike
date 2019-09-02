local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LIFETIME = 3
local RADIUS = 3
local CIRCLE_RATE = 5
local VERTICAL_RATE = 1

local function moveAttachment(attachment, t)
	attachment.Position = Vector3.new(
		RADIUS * math.sin(t * CIRCLE_RATE),
		t * VERTICAL_RATE,
		RADIUS * math.cos(t * CIRCLE_RATE)
	)
end

ReplicatedStorage.Remotes.LevelUp.OnClientEvent:connect(function(player)
	StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = ("%s has LEVELED UP!"):format(player.Name),
		Color = Color3.fromRGB(251, 197, 49),
		Font = Enum.Font.GothamSemibold,
	})

	local character = player.Character
	if not character then return end

	local attachment = Instance.new("Attachment")
	moveAttachment(attachment, 0)
	attachment.Parent = character.HumanoidRootPart

	local emitter = script.Part.ParticleEmitter:Clone()
	emitter.Parent = attachment

	local t = 0

	while t < LIFETIME do
		t = t + RunService.Heartbeat:wait()
		moveAttachment(attachment, t)
	end

	emitter.Enabled = false
	Debris:AddItem(attachment)
end)
