-- services

local ReplicatedStorage	= game:GetService("ReplicatedStorage")
local TweenService		= game:GetService("TweenService")
local Workspace			= game:GetService("Workspace")
local Debris			= game:GetService("Debris")

-- constants

local EFFECTS	= Workspace:WaitForChild("Effects")
local CAMERA	= Workspace.CurrentCamera
local EVENTS	= ReplicatedStorage:WaitForChild("RuddevEvents")

-- functions

return function(position, radius)
	local explosion		= script.Explosion:Clone()
		explosion.CFrame	= CFrame.new(position)
		explosion.Parent	= EFFECTS

	explosion.FlashEmitter.Size	= NumberSequence.new(radius * 2, 0)
	explosion.FlashEmitter:Emit(3)

	explosion.PointLight.Range	= radius
	local lightInfo		= TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local lightTween	= TweenService:Create(explosion.PointLight, lightInfo, {Range = 0})
	lightTween:Play()

	for i = 1, 10 do
		local meteor	= script.Meteor:Clone()
			meteor.CFrame	= CFrame.new(position)
			meteor.Parent	= EFFECTS
			meteor.Velocity	= Vector3.new(math.random(-50, 50), math.random(40, 80), math.random(-50, 50)) * math.random(10, 20) / 10

		Debris:AddItem(meteor, 6)
	end

	explosion["ExplosionSound" .. tostring(math.random(10))]:Play()
	explosion.SmokeEmitter:Emit(15)
	explosion.FireEmitter:Emit(30)

	local range		= radius * 5
	local distance	= (CAMERA.CFrame.p - position).Magnitude

	if distance < range then
		local amount	= 1 - (distance / range)
		local direction	= CAMERA.CFrame:vectorToObjectSpace((CAMERA.CFrame.p - position).Unit)
		EVENTS.Shake:Fire(direction * 100 * amount)
	end

	Debris:AddItem(explosion, 10)
end