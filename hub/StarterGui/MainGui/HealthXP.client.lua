local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local XP = require(ReplicatedStorage.Core.XP)

local XPAmmoGold = script.Parent.Main.XPAmmoGold
local LocalPlayer = Players.LocalPlayer

local function updateAmmo(ammo)
	XPAmmoGold.Ammo.Text = ammo
end

local function newGun(gun)
	local ammo = gun:WaitForChild("Ammo")
	ammo.Changed:connect(updateAmmo)
	updateAmmo(ammo.Value)
end

local function characterAdded(character)
	local gun = character:FindFirstChild("Gun")
	if gun then
		newGun(gun)
	end

	character.ChildAdded:connect(function(child)
		if child.Name == "Gun" then
			newGun(child)
		end
	end)
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

local gold = playerData:WaitForChild("Gold")

local function updateGold(value)
	XPAmmoGold.Gold.Text = value
end

XPAmmoGold.Gold.Visible = true
updateGold(gold.Value)
gold.Changed:connect(updateGold)

if LocalPlayer.Character then
	characterAdded(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:connect(characterAdded)
