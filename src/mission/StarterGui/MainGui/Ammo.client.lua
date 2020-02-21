local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage.RuddevModules.Config)

local LocalPlayer = Players.LocalPlayer

local Ammo = script.Parent.Main.Ammo
local CurrentPowerup = ReplicatedStorage.CurrentPowerup

local function characterAdded(character)
	local function updateGun(gun)
		local ammo = gun:WaitForChild("Ammo")

		local function updateAmmo()
			if CurrentPowerup.Value:match("Bulletstorm/")
				or gun:WaitForChild("WeaponData"):WaitForChild("Type").Value == "Crystal"
			then
				Ammo.Text = "∞/∞"
			else
				Ammo.Text = ammo.Value .. " / " .. Config:GetConfig(gun).Magazine
			end
		end

		ammo.Changed:connect(updateAmmo)
		CurrentPowerup.Changed:connect(updateAmmo)
		updateAmmo()
	end

	character.ChildAdded:connect(function(thing)
		if thing.Name == "Gun" then
			updateGun(thing)
		end
	end)

	local gun = character:FindFirstChild("Gun")
	if gun then
		updateGun(gun)
	end
end

if LocalPlayer.Character then
	characterAdded(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:connect(characterAdded)
