-- Services

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Constants

local ITEMS = ReplicatedStorage.Items

local Data = require(ReplicatedStorage.Libraries.Data)
local Equip = require(ServerScriptService.Shared.Ruddev.Equip)

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

-- Initiate

for _, item in pairs(ITEMS:GetChildren()) do
	if item.ItemType.Value == "Gun" then
		PrepareItem(item)
	end
end

game.Players.PlayerAdded:connect(function(player)
	local data = Data.GetPlayerData(player, "Weapon")
	local function characterAdded(character)
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
		gun.Parent = character
		Equip(gun)
	end

	if player.Character then
		characterAdded(player.Character)
	end
	player.CharacterAdded:connect(characterAdded)
end)
