-- services

local ReplicatedStorage	= game:GetService("ReplicatedStorage")
local TweenService		= game:GetService("TweenService")
local Workspace			= game:GetService("Workspace")
local Debris			= game:GetService("Debris")

-- constants

local assign = require(ReplicatedStorage.Core.assign)

local EFFECTS	= Workspace:WaitForChild("Effects")
local CAMERA	= Workspace.CurrentCamera
local EVENTS	= ReplicatedStorage:WaitForChild("RuddevEvents")

-- functions

local DEFAULT_VISUAL_INFO = {
	FireEmission = 30,
	Meteors = 10,
	SmokeEmission = 15,
	Shake = true,
}

return function(position, radius, better, visualInfo)
	visualInfo = assign(visualInfo or {}, DEFAULT_VISUAL_INFO)

	local explosion		= script.Explosion:Clone()
		explosion.CFrame	= CFrame.new(position)
		explosion.Parent	= EFFECTS

	explosion.FlashEmitter.Size	= NumberSequence.new(radius * 2, 0)
	explosion.FlashEmitter:Emit(3)

	explosion.PointLight.Range	= radius

	if better then
		explosion.PointLight.Brightness = 5
		explosion.PointLight.Color = Color3.new(0, 0, 1)
	end

	local lightInfo		= TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local lightTween	= TweenService:Create(explosion.PointLight, lightInfo, {Range = 0})
	lightTween:Play()

	for _ = 1, visualInfo.Meteors do
		local meteor	= script.Meteor:Clone()
			meteor.CFrame	= CFrame.new(position)
			meteor.Parent	= EFFECTS
			meteor.Velocity	= Vector3.new(math.random(-50, 50), math.random(40, 80), math.random(-50, 50)) * math.random(10, 20) / 10

		Debris:AddItem(meteor, 6)
	end

	explosion["ExplosionSound" .. tostring(math.random(10))]:Play()
	explosion.SmokeEmitter:Emit(visualInfo.SmokeEmission)
	explosion.FireEmitter:Emit(visualInfo.FireEmission)

	local range		= radius * 5
	local distance	= (CAMERA.CFrame.p - position).Magnitude

	if distance < range and visualInfo.Shake then
		local amount	= 1 - (distance / range)
		local direction	= CAMERA.CFrame:vectorToObjectSpace((CAMERA.CFrame.p - position).Unit)
		EVENTS.Shake:Fire(direction * 100 * amount)
	end

	Debris:AddItem(explosion, 10)
end