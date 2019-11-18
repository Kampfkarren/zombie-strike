local ReplicatedStorage = game:GetService("ReplicatedStorage")

ReplicatedStorage.Remotes.MobileBaby.OnServerEvent:connect(function(player)
	if not player:FindFirstChild("MobileDamageBuff") then
		local flag = Instance.new("Model")
		flag.Name = "MobileDamageBuff"
		flag.Parent = player
	end
end)
