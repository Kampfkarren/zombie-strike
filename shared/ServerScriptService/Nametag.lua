local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local EnglishNumbers = require(ReplicatedStorage.Core.EnglishNumbers)

return function(instance, level)
	local nametag = instance.Head:FindFirstChild("Nametag")

	if not nametag then
		nametag = ServerStorage.Nametag:Clone()
		nametag.Parent = instance.Head
		instance.ChildAdded:connect(function(child)
			if child.Name == "Head" then
				nametag.Parent = child
			end
		end)
	end

	local humanoid = instance.Humanoid
	nametag.Health.HealthNumber.Text = ("%s/%s"):format(
		EnglishNumbers(math.ceil(humanoid.Health)),
		EnglishNumbers(math.ceil(humanoid.MaxHealth))
	)
	nametag.Health.Fill.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)

	nametag.EnemyName.Text = instance.Name
	nametag.Level.Text = "LV. " .. level

	return nametag
end
