local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local XP = require(ReplicatedStorage.Core.XP)

local HealthXP = script.Parent.Main.HealthXP
local LocalPlayer = Players.LocalPlayer

local function updateHealth(humanoid)
	local health, maxHealth = humanoid.Health, humanoid.MaxHealth
	HealthXP.Health.TextLabel.Text = health .. "/" .. maxHealth
end

local function updateAmmo(ammo)
	HealthXP.Ammo.Text = ammo
end

local function characterAdded(character)
	local humanoid = character:WaitForChild("Humanoid")
	updateHealth(humanoid)

	humanoid.HealthChanged:connect(function()
		updateHealth(humanoid)
	end)

	local ammo = character:WaitForChild("Gun"):WaitForChild("Ammo")
	ammo.Changed:connect(updateAmmo)
	updateAmmo(ammo.Value)
end

local playerData = LocalPlayer:WaitForChild("PlayerData")

local level = playerData:WaitForChild("Level")
local xp = playerData:WaitForChild("XP")

local function updateXP()
	local maxXp = XP.XPNeededForNextLevel(level.Value)

	HealthXP.XP.TextLabel.Text = ("%d / %d"):format(
		xp.Value,
		maxXp
	)

	HealthXP.XP.Inner.Size = UDim2.new(xp.Value / maxXp, 0, 1, 0)
end

coroutine.wrap(updateXP)()
xp.Changed:connect(updateXP)

local gold = playerData:WaitForChild("Gold")

local function updateGold(value)
	HealthXP.Gold.Text = value
end

HealthXP.Gold.Visible = true
updateGold(gold.Value)
gold.Changed:connect(updateGold)

if LocalPlayer.Character then
	characterAdded(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:connect(characterAdded)
