local Debris = game:GetService("Debris")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Explosion = require(ReplicatedStorage.RuddevModules.Effects.Explosion)

local SoundGateCity = SoundService.SFX.Gate.City

local RUBBLE_EXPLOSION_RADIUS = 20
local RUBBLE_FADE_INFO = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local RUBBLE_START_FADE = 0.5

local City = {}

local rng = Random.new()

function City.Open(gate)
	for _, part in pairs(gate:GetChildren()) do
		if part.Name == "InvisiblePart" then
			part.CanCollide = false
			Explosion(part.Position, RUBBLE_EXPLOSION_RADIUS)

			local sound = SoundGateCity:Clone()
			sound.Parent = part
			sound:Play()
			Debris:AddItem(sound)
		else
			part.Anchored = false
			PhysicsService:SetPartCollisionGroup(part, "DeadZombies")
			part.Velocity = Vector3.new(
				rng:NextInteger(-150, 150),
				rng:NextInteger(-150, 150),
				rng:NextInteger(-150, 150)
			)

			delay(RUBBLE_START_FADE, function()
				TweenService:Create(
					part,
					RUBBLE_FADE_INFO,
					{ Size = Vector3.new() }
				):Play()
			end)

			Debris:AddItem(part)
		end
	end

	return gate
end

return City
