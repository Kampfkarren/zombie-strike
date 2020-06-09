local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local EquipmentUtil = require(ReplicatedStorage.Core.EquipmentUtil)
local Promise = require(ReplicatedStorage.Core.Promise)

local Abilities = script.Parent.Main.Abilities
local LocalPlayer = Players.LocalPlayer

local COOLDOWN_TEXT = "%.1fs"

local function alwaysTrue()
	return true
end

local function abilityButton(keyboardCode, keyboardName, gamepadCode, gamepadName, frame, remote, getEquipment, equipmentName)
	local cooldown = frame.Cooldown
	local label = frame.Tooltip

	local using = false

	local function updateLabel()
		local inputType = UserInputService:GetLastInputType()
		if inputType == Enum.UserInputType.Gamepad1 then
			label.Text = gamepadName
		elseif inputType == Enum.UserInputType.Touch then
			label.Text = ""
		else
			label.Text = keyboardName
		end
	end

	local function startCooldown(itemCooldown)
		return Promise.async(function(resolve)
			local dt = itemCooldown

			while dt > 0 do
				cooldown.Text = COOLDOWN_TEXT:format(dt)
				dt = dt - RunService.Heartbeat:wait()
			end

			resolve()
		end):finally(function()
			cooldown.Text = ""
			using = false
		end)
	end

	local function updateIcon()
		local equipped = getEquipment()
		frame.Icon.Image = equipped.Icon
	end

	local function use()
		local character = LocalPlayer.Character

		if not character or character.Humanoid.Health <= 0 then return end
		if using then return end

		local equipment = getEquipment()

		using = true
		if (equipment.CanUse or alwaysTrue)(LocalPlayer) then
			local output = remote:InvokeServer()

			if equipment.ClientEffect then
				equipment.ClientEffect(output)
			end

			startCooldown(equipment.Cooldown)
		else
			using = false
		end
	end

	frame.MouseButton1Click:connect(use)

	UserInputService.InputBegan:connect(function(inputObject, processed)
		if processed then return end

		if inputObject.KeyCode == keyboardCode or inputObject.KeyCode == gamepadCode then
			use()
		end
	end)

	UserInputService.LastInputTypeChanged:connect(updateLabel)

	updateLabel()
	updateIcon()

	LocalPlayer
		:WaitForChild("PlayerData")
		:WaitForChild("Equipped" .. equipmentName)
		.Changed:connect(function()
			updateIcon()
		end)
end

abilityButton(
	Enum.KeyCode.Q,
	"Q",
	Enum.KeyCode.ButtonL1,
	"L1",
	Abilities.Q,
	ReplicatedStorage.Remotes.UseHealthPack,
	EquipmentUtil.GetHealthPack,
	"HealthPack"
)

abilityButton(
	Enum.KeyCode.E,
	"E",
	Enum.KeyCode.ButtonR1,
	"R1",
	Abilities.E,
	ReplicatedStorage.Remotes.UseGrenade,
	EquipmentUtil.GetGrenade,
	"Grenade"
)
