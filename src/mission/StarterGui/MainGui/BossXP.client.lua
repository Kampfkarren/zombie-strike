local CollectionService = game:GetService("CollectionService")

local Boss = script.Parent.Main.Boss

local function updateHealth(humanoid)
	local health, maxHealth = humanoid.Health, humanoid.MaxHealth

	Boss.Inner.Size = UDim2.new(1, 0, health / maxHealth, 0)
	Boss.Health.Text = math.ceil((health / maxHealth) * 100) .. "%"
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
