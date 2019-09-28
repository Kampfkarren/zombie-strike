local ServerStorage = game:GetService("ServerStorage")

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
	nametag.Health.HealthNumber.Text = ("%d/%d"):format(
		math.ceil(humanoid.Health),
		math.ceil(humanoid.MaxHealth)
	)
	nametag.Health.Fill.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)

	nametag.EnemyName.Text = instance.Name
	nametag.Level.Text = "LV. " .. level

	return nametag
end
