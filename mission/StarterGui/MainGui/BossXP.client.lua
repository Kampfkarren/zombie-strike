local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Boss = script.Parent.Main.Boss
local LocalPlayer = Players.LocalPlayer

local function updateHealth(humanoid)
	local health, maxHealth = humanoid.Health, humanoid.MaxHealth

	Boss.Inner.Size = UDim2.new(health / maxHealth, 0, 1, 0)
	Boss.Health.Text = health .. "/" .. maxHealth
end

local function bossAdded(character)
	Boss.Visible = true

	local humanoid = character:WaitForChild("Humanoid")
	lastHealth = humanoid.MaxHealth
	updateHealth(humanoid)

	humanoid.HealthChanged:connect(function()
		updateHealth(humanoid)
	end)
end

CollectionService:GetInstanceAddedSignal("Boss"):connect(bossAdded)
