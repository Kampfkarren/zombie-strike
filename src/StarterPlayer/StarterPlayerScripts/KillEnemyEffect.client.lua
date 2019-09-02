local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local fadeTween = {
	TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	{ Transparency = 1 }
}

ReplicatedStorage.Remotes.KillEnemy.OnClientEvent:connect(function(enemy)
	enemy.Head:ClearAllChildren()

	for _, thing in pairs(enemy:GetDescendants()) do
		if thing:IsA("BasePart") or thing:IsA("Decal") then
			TweenService:Create(thing, unpack(fadeTween)):Play()
		end
	end

	Debris:AddItem(enemy)
end)
