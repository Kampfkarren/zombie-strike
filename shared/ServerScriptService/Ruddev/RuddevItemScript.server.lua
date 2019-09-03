-- Services

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- Constants

local ITEMS = ReplicatedStorage.Items
local REMOTES = ReplicatedStorage.RuddevRemotes

local Data = require(ReplicatedStorage.Core.Data)

-- Variables

-- Functions

local function PrepareItem(item) -- weld, unanchor, and remove mass from an item
	local handle = item.PrimaryPart
	handle.Name = "Handle"

	for _, v in pairs(item:GetDescendants()) do
		if v:IsA("BasePart") and v ~= handle then
			local offset = handle.CFrame:toObjectSpace(v.CFrame)

			local weld = Instance.new("Weld")
				weld.Part0 = handle
				weld.Part1 = v
				weld.C0 = offset
				weld.Parent = v

			--v.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 1, 1)
			v.Massless = true
			v.Anchored = false
			v.CanCollide = false
		end
	end
	--handle.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 1, 1)
	handle.Massless = true
	handle.Anchored = false
	handle.CanCollide = false

	local config = require(item.Config)

	if config.Type == "Gun" or config.Type == "RocketLauncher" then
		local ammo = Instance.new("IntValue")
			ammo.Name = "Ammo"
			ammo.Value = config.Magazine
			ammo.Parent = item

		local attachments = Instance.new("Folder")
			attachments.Name = "Attachments"
			attachments.Parent = item
	elseif config.Type == "Booster" or config.Type == "Throwable" then
		local stack = Instance.new("IntValue")
			stack.Name = "Stack"
			stack.Value = config.Stack
			stack.Parent = item
	end
end

local function Equip(item) -- move an item from the back to the hand
	spawn(function()
		local character = item.Parent
		local handle = item.PrimaryPart

		-- remove unequipped stuff
		if handle:FindFirstChild("UnequippedWeld") then
			handle.UnequippedWeld:Destroy()
		end

		-- add equipped stuff
		local gripMotor = Instance.new("Motor6D")
			gripMotor.Name = "GripMotor"
			gripMotor.Part0 = character.RightHand
			gripMotor.Part1 = handle
			gripMotor.C0 = CFrame.Angles(-math.pi / 2, 0, 0)
			gripMotor.C1 = handle.Grip.CFrame
			gripMotor.Parent = handle
	end)
end

-- Initiate

for _, item in pairs(ITEMS:GetChildren()) do
	if not item:IsA("PackageLink") then
		PrepareItem(item)
	end
end

game.Players.PlayerAdded:connect(function(player)
	local data = Data.GetPlayerData(player, "Weapon")

	local gun = Data.GetModel(data)
	gun.Name = "Gun"

	local weaponData = Instance.new("Folder")
	weaponData.Name = "WeaponData"

	for statName, stat in pairs(data) do
		local statValue = Instance.new((type(stat) == "number" and "Number" or "String") .. "Value")
		statValue.Name = statName
		statValue.Value = stat
		statValue.Parent = weaponData
	end

	gun.Ammo.Value = data.Magazine
	weaponData.Parent = gun

	player.CharacterAdded:connect(function(character)
		local gun = gun:Clone()
		gun.Parent = character
		Equip(gun)
	end)
end)
