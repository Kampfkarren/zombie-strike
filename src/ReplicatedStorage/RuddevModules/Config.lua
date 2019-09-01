local Config = {}

function Config:GetConfig(item)
	return {
		Icon = "rbxassetid://2524106240";
		Type = "Gun";
		Size = "Light";

		Magazine = 16;
		FireRate = 7;
		Recoil = 30;
		Range = 500;
		ShotSize = 1;
		Spread = 2;
		Damage = 14;
		Zoom = 20;
		ReloadTime = 1;
		FireMode = "Semi";
		Dropoff = 3;
	}
end

return Config
