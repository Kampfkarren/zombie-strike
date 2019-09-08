local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Abilities = script.Parent.Main.Abilities
local LocalPlayer = Players.LocalPlayer

local COOLDOWN = 10
local COOLDOWN_TEXT = "%.1fs"

local function abilityButton(keyboardCode, keyboardName, gamepadCode, gamepadName, remote, frame, precondition)
	local cooldown = frame.Cooldown
	local label = frame.Label

	local using = false

	local function updateLabel()
		if UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1 then
			label.Text = gamepadName
		else
			label.Text = keyboardName
		end
	end

	local function use()
		local character = LocalPlayer.Character

		if not character or character.Humanoid.Health <= 0 then return end

		if precondition then
			if not precondition() then return end
		end

		using = true
		remote:FireServer()
	end

	remote.OnClientEvent:connect(function()
		local dt = COOLDOWN

		while dt > 0 do
			cooldown.Text = COOLDOWN_TEXT:format(dt)
			dt = dt - RunService.Heartbeat:wait()
		end

		cooldown.Text = ""
		using = false
	end)

	frame.MouseButton1Click:connect(use)

	UserInputService.InputBegan:connect(function(inputObject, processed)
		if processed then return end

		if inputObject.KeyCode == keyboardCode or inputObject.KeyCode == gamepadCode then
			use()
		end
	end)

	UserInputService.LastInputTypeChanged:connect(updateLabel)

	updateLabel()
end

abilityButton(
	Enum.KeyCode.Q,
	"Q",
	Enum.KeyCode.ButtonL1,
	"L1",
	ReplicatedStorage.Remotes.HealthPack,
	Abilities.Q,
	function()
		if not ReplicatedStorage.HubWorld.Value then
			local humanoid = LocalPlayer.Character.Humanoid
			return humanoid.Health ~= humanoid.MaxHealth
		end

		return true
	end
)
