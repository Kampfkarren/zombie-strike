local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GetAssetsFolder = require(ReplicatedStorage.Libraries.GetAssetsFolder)
local RealDelay = require(ReplicatedStorage.Core.RealDelay)

local LocalPlayer = Players.LocalPlayer
local ProjectileZombieEffect = ReplicatedStorage.Remotes.Zombies.ProjectileZombieEffect

local PROJECTILE_COUNT = 3
local PROJECTILE_LIFETIME = 3
local PROJECTILE_SPEED = 65

local function cloneTemplate()
	return GetAssetsFolder().Projectile.Template:Clone()
end

local function throwProjectile(owner, cframe)
	local touched = false

	local projectile = cloneTemplate()
	projectile.CFrame = cframe
	projectile.Touched:connect(function(part)
		if part:IsDescendantOf(LocalPlayer.Character) then
			if touched then return end
			touched = true
			ProjectileZombieEffect:FireServer(owner)
		end
	end)

	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.P = 80
	bodyVelocity.Velocity = cframe.LookVector * PROJECTILE_SPEED
	bodyVelocity.Parent = projectile

	local antiGravity = Instance.new("BodyForce")
	antiGravity.Force = Vector3.new(0, projectile:GetMass() * Workspace.Gravity, 0)
	antiGravity.Parent = projectile

	projectile.Parent = Workspace
	RealDelay(PROJECTILE_LIFETIME, function()
		projectile:Destroy()
	end)
end

ProjectileZombieEffect.OnClientEvent:connect(function(model)
	local character = LocalPlayer.Character
	local characterPosition = character and character.PrimaryPart.Position

	for offset = 1, PROJECTILE_COUNT do
		local cframe

		if characterPosition then
			cframe = CFrame.new(model.PrimaryPart.Position, characterPosition)
		else
			cframe = model.PrimaryPart.CFrame
		end

		cframe = cframe + (cframe.RightVector * (offset - PROJECTILE_COUNT / 2))

		throwProjectile(model, cframe)
	end
end)
