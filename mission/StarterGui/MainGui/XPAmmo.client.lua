local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local XP = require(ReplicatedStorage.Core.XP)

local XPAmmoGold = script.Parent.Main.XPAmmoGold
local LocalPlayer = Players.LocalPlayer

local function updateAmmo(ammo)
	XPAmmoGold.Ammo.Text = ammo
end

local function characterAdded(character)
	local ammo = character:WaitForChild("Gun"):WaitForChild("Ammo")
	ammo.Changed:connect(updateAmmo)
	updateAmmo(ammo.Value)
end

local playerData = LocalPlayer:WaitForChild("PlayerData")

local level = playerData:WaitForChild("Level")
local xp = playerData:WaitForChild("XP")

local function updateXP()
	local maxXp = XP.XPNeededForNextLevel(level.Value)

	XPAmmoGold.XP.TextLabel.Text = ("%d / %d"):format(
		xp.Value,
		maxXp
	)

	XPAmmoGold.XP.Inner.Size = UDim2.new(xp.Value / maxXp, 0, 1, 0)
end

coroutine.wrap(updateXP)()
xp.Changed:connect(updateXP)

if LocalPlayer.Character then
	characterAdded(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:connect(characterAdded)
