local Config = {}

local Bases = {}

Bases.Pistol = {
	Type = "Gun",
	Size = "Light",

	Recoil = 30,
	Range = 500,
	ShotSize = 1,
	Spread = 2,
	Zoom = 20,
	ReloadTime = 1,
	FireMode = "Auto",
	Dropoff = 3,
}

function Config:GetConfig(item)
	local config = {}
	local weaponData = item:WaitForChild("WeaponData")

	for baseKey, baseValue in pairs(Bases[weaponData.Type.Value]) do
		config[baseKey] = baseValue
	end

	for _, dataValue in pairs(weaponData:GetChildren()) do
		local name = dataValue.Name
		if name ~= "Type" then
			config[name] = dataValue.Value
		end
	end

	return config

	-- return {
	-- 	Icon = "rbxassetid://2524106240";
	-- 	Type = "Gun";
	-- 	Size = "Light";

	-- 	Magazine = 16;
	-- 	FireRate = 7;
	-- 	Recoil = 30;
	-- 	Range = 500;
	-- 	ShotSize = 1;
	-- 	Spread = 2;
	-- 	Damage = 14;
	-- 	Zoom = 20;
	-- 	ReloadTime = 1;
	-- 	FireMode = "Semi";
	-- 	Dropoff = 3;
	-- }
end

return Config
