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

Bases.Rifle = {
	Type = "Gun",
	Size = "Medium",

	Recoil = 10,
	Range = 700,
	ShotSize = 1,
	Spread = 2,
	Zoom = 20,
	ReloadTime = 1.8,
	FireMode = "Auto",
	Dropoff = 3,
}

Bases.Shotgun = {
	Type = "Gun",
	Size = "Shotgun",

	Recoil = 50,
	Range = 150,
	Spread = 8,
	Zoom = 10,
	ReloadTime = 1.3,
	FireMode = "Auto",
	Dropoff = 3,
	Reticle = "Shotgun",
}

Bases.SMG = {
	Type = "Gun",
	Size = "Light",

	Recoil = 12,
	Range = 500,
	ShotSize = 1,
	Spread = 3,
	Zoom = 20,
	ReloadTime = 1,
	FireMode = "Auto",
	Dropoff = 3,
}

Bases.Sniper = {
	Type = "Gun",
	Size = "Heavy",

	Recoil = 60,
	Range = 1300,
	ShotSize = 1,
	Spread = 0,
	Zoom = 35,
	ReloadTime = 1.8,
	FireMode = "Auto",
	Dropoff = 5,
}

function Config.GetConfig(_, item)
	local config = {}
	local weaponData = item:WaitForChild("WeaponData")

	for baseKey, baseValue in pairs(Bases[weaponData:WaitForChild("Type").Value]) do
		config[baseKey] = baseValue
	end

	for _, dataValue in pairs(weaponData:GetChildren()) do
		local name = dataValue.Name
		if name ~= "Type" then
			config[name] = dataValue.Value
		end
	end

	if config.Size == "Shotgun" then
		config.ShotSize = math.floor(5 + (1.01 ^ (config.Level - 1)))
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
