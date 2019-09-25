local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Ammo = script.Parent.Main.Ammo

local function characterAdded(character)
	local function updateGun(gun)
		local magazine = gun:WaitForChild("WeaponData"):WaitForChild("Magazine")
		local ammo = gun:WaitForChild("Ammo")

		local function updateAmmo()
			Ammo.Text = ammo.Value .. " / " .. magazine.Value
		end

		magazine.Changed:connect(updateAmmo)
		ammo.Changed:connect(updateAmmo)
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
