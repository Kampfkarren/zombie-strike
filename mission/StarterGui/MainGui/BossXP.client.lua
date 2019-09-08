local CollectionService = game:GetService("CollectionService")

local Boss = script.Parent.Main.Boss

local function updateHealth(humanoid)
	local health, maxHealth = humanoid.Health, humanoid.MaxHealth

	Boss.Inner.Size = UDim2.new(health / maxHealth, 0, 1, 0)
	Boss.Health.Text = math.floor(health) .. "/" .. maxHealth
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
