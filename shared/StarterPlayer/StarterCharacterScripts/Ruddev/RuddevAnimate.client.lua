-- services

local RunService		= game:GetService("RunService")
local Players			= game:GetService("Players")

-- constants

local PLAYER		= Players.LocalPlayer

local CHARACTER		= PLAYER.Character
local HUMANOID		= CHARACTER:WaitForChild("Humanoid")

local STANCE = Instance.new("StringValue")
STANCE.Name = "Stance"
STANCE.Value = "Walk"
STANCE.Parent = HUMANOID

local ROOT_PART		= CHARACTER:WaitForChild("HumanoidRootPart")
local ANIMATIONS	= script:WaitForChild("Animations")

-- variables

local speeds	= {
	Walk	= 1.8;
	Crouch	= 1.7;
	Sprint	= 1.3;
	Down	= 2.5;
}

local animations	= {
	Movement	= {};
	Actions		= {};
	Emotes		= {};
}

local stance	= ""
local grinding	= false
local flying	= false

local lastHealth	= HUMANOID.Health

-- functions

local function Dash(direction)
	local localDirection	= ROOT_PART.CFrame:vectorToObjectSpace(direction)

	if localDirection.Z < 0 then
		animations.Actions.DashForward:Play(0.05, localDirection.Z^2, 2)
	elseif localDirection.Z > 0 then
		animations.Actions.DashBackward:Play(0.05, localDirection.Z^2, 2)
	end

	if localDirection.X > 0 then
		animations.Actions.DashRight:Play(0.05, localDirection.X^2, 2)
	elseif localDirection.X < 0 then
		animations.Actions.DashLeft:Play(0.05, localDirection.X^2, 2)
	end
end

local function UpdateMovement(localVelocity)
	if flying then
		localVelocity	= ROOT_PART.CFrame:vectorToObjectSpace(ROOT_PART.Velocity)
	end
	local speed	= localVelocity.Magnitude

	if speed > 1 then
		for _, emote in pairs(animations.Emotes) do
			if emote.IsPlaying then
				emote:Stop()
			end
		end

		local unit	= localVelocity.Unit
		for name, animation in pairs(animations.Movement) do
			local state	= string.match(name, "^" .. stance .. "_(.+)")
			if state then
				if state == "Idle" then
					if animation.IsPlaying then
						animation:Stop(0.4)
					end
				else
					if speeds[stance] then
						animation:AdjustSpeed(math.max(speeds[stance] * (speed / 20), 0.1))
					end
					if not animation.IsPlaying then
						animation:Play()
					end
				end
				if state == "Forward" then
					animation:AdjustWeight(math.abs(math.clamp(unit.Z, -1, 0.1))^2)
				elseif state == "Backward" then
					animation:AdjustWeight(math.abs(math.clamp(unit.Z, 0.1, 1))^2)
				elseif state == "Right" then
					animation:AdjustWeight(math.abs(math.clamp(unit.X, 0.1, 1))^2)
				elseif state == "Left" then
					animation:AdjustWeight(math.abs(math.clamp(unit.X, -1, 0.1))^2)
				end
			else
				if animation.IsPlaying then
					animation:Stop()
				end
			end
		end
	else
		for name, animation in pairs(animations.Movement) do
			local state	= string.match(name, "^" .. stance .. "_(.+)")
			if state then
				if state == "Idle" then
					if not animation.IsPlaying then
						animation:Play()
					end
				else
					if animation.IsPlaying then
						animation:Stop()
					end
				end
			else
				if animation.IsPlaying then
					animation:Stop()
				end
			end
		end
	end
end

local function SetStance(newStance)
	if stance ~= newStance then
		stance	= newStance

		for _, animation in pairs(animations.Movement) do
			animation:Stop()
		end
	end
end

local function Damage(amount)
	animations.Actions["Damage" .. tostring(math.random(1, 3))]:Play(0.05, amount / (HUMANOID.MaxHealth / 2), 1.5)
end

local function Grind(g)
	grinding	= g
end

local function Fly(f)
	flying	= f

	if not f then
		animations.Actions.SuperLand:Play(0.05, 1, 1)
	end
end

-- initiate

ANIMATIONS:WaitForChild("Movement").ChildAdded:connect(function(animation)
	animations.Movement[animation.Name]	= HUMANOID:LoadAnimation(animation)
end)

ANIMATIONS:WaitForChild("Actions").ChildAdded:connect(function(animation)
	animations.Actions[animation.Name]	= HUMANOID:LoadAnimation(animation)
end)

ANIMATIONS:WaitForChild("Emotes").ChildAdded:connect(function(animation)
	animations.Emotes[animation.Name]	= HUMANOID:LoadAnimation(animation)
end)

for _, animation in pairs(ANIMATIONS.Movement:GetChildren()) do
	animations.Movement[animation.Name]	= HUMANOID:LoadAnimation(animation)
end

for _, animation in pairs(ANIMATIONS.Actions:GetChildren()) do
	animations.Actions[animation.Name]	= HUMANOID:LoadAnimation(animation)
end

for _, animation in pairs(ANIMATIONS.Emotes:GetChildren()) do
	animations.Emotes[animation.Name]	= HUMANOID:LoadAnimation(animation)
end

SetStance(STANCE.Value)

RunService:BindToRenderStep("Animate", 5, function()
	local velocity		= Vector3.new(ROOT_PART.Velocity.X, 0, ROOT_PART.Velocity.Z)
	local localVelocity	= ROOT_PART.CFrame:vectorToObjectSpace(velocity)

	if flying then
		SetStance("Fly")
		UpdateMovement(localVelocity)
	elseif grinding then
		SetStance("Grinding")

		if not animations.Movement.Grind.IsPlaying then
			animations.Movement.Grind:Play()
		end
	else
		if HUMANOID.FloorMaterial == Enum.Material.Air then
			local speed	= ROOT_PART.Velocity.Magnitude

			if speed <= 200 then
				SetStance("Falling")
				if not animations.Movement.Fall.IsPlaying then
					animations.Movement.Fall:Play()
				end
			end
		else
			SetStance(STANCE.Value)
			UpdateMovement(localVelocity)
		end
	end
end)

-- events

script:WaitForChild("Dash").Event:connect(Dash)
script:WaitForChild("Fly").Event:connect(Fly)
script:WaitForChild("Grind").Event:connect(Grind)
script:WaitForChild("Vault").Event:connect(function(v, t)
	if v then
		animations.Actions.Vault:Play(0.05, 1, 1/t)
	else
		animations.Actions.Vault:Stop(0)
	end
end)

script:WaitForChild("Pickup").Event:connect(function()
	animations.Actions.Pickup:Play()
end)

script:WaitForChild("Heal").Event:connect(function(healing, t)
	if healing then
		animations.Actions.Heal:Play(0.1, 1, 1/t)
	else
		animations.Actions.Heal:Stop()
	end
end)

HUMANOID.HealthChanged:connect(function(health)
	local change	= health - lastHealth

	if change < 0 then
		Damage(-change)
	end

	if health <= 0 then
		RunService:UnbindFromRenderStep("Animate")
	end

	lastHealth	= health
end)

HUMANOID.StateChanged:connect(function(_, newState)
	if newState == Enum.HumanoidStateType.Jumping then
		if HUMANOID.FloorMaterial ~= Enum.Material.Air then
			animations.Actions.Jump:Play(0.05, 1, 2)
		end
	elseif newState == Enum.HumanoidStateType.Landed then
		animations.Actions.Land:Play(0.05, 1, 1)
	end
end)