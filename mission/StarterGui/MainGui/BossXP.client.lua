local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EnglishNumbers = require(ReplicatedStorage.Core.EnglishNumbers)

local Boss = script.Parent.Main.Boss

local function updateHealth(humanoid)
	local health, maxHealth = humanoid.Health, humanoid.MaxHealth

	Boss.Inner.Size = UDim2.new(health / maxHealth, 0, 1, 0)
	Boss.Health.Text = EnglishNumbers(health) .. "/" .. EnglishNumbers(maxHealth)
end

local function bossAdded(character)
	Boss.Visible = true

	local humanoid = character:WaitForChild("Humanoid")
	updateHealth(humanoid)

	humanoid.HealthChanged:connect(function()
		updateHealth(humanoid)
	end)
end

CollectionService:GetInstanceAddedSignal("Boss"):connect(bossAdded)
