local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local HealthVignette = script.Parent.Main.HealthVignette
local LocalPlayer = Players.LocalPlayer

local HEALTH_THRESHOLD = 0.5
local MAX_TRANSPARENCY = 0.05

local tween = TweenService:Create(
	HealthVignette,
	TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	{ ImageTransparency = 1 }
)

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function characterAdded(character)
	local humanoid = character:WaitForChild("Humanoid")

	humanoid.Died:connect(function()
		tween:Play()
	end)

	humanoid.HealthChanged:connect(function(health)
		local percent = health / humanoid.MaxHealth
		HealthVignette.ImageTransparency = lerp(1 + (1 - HEALTH_THRESHOLD), MAX_TRANSPARENCY, 1 - percent)
	end)
end

if LocalPlayer.Character then
	characterAdded(LocalPlayer.Character)
end

characterAdded(LocalPlayer.Character)
