local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Maid = require(ReplicatedStorage.Core.Maid)
local RealDelay = require(ReplicatedStorage.Core.RealDelay)

local GunslingerZombieEffect = ReplicatedStorage.Remotes.Zombies.GunslingerZombieEffect
local LocalPlayer = Players.LocalPlayer
local Range = ReplicatedStorage.Assets.Range

local shootingGuns = {}

local function shootRange(zombie, range)
	return function()
		if zombie.Humanoid.Health > 0 then
			range.CanCollide = true
			for _, part in pairs(range:GetTouchingParts()) do
				if part:IsDescendantOf(LocalPlayer.Character) then
					GunslingerZombieEffect:FireServer(zombie)
					break
				end
			end
			range.CanCollide = false

			range.Color = Color3.new(1, 0, 0)
			RealDelay(0.5, function()
				range:Destroy()
			end)
		else
			range:Destroy()
		end
	end
end

GunslingerZombieEffect.OnClientEvent:connect(function(zombie, shoot)
	if shoot then
		local maid = shootingGuns[zombie]
		if maid then
			maid:DoCleaning()
		end
	else
		local maid = Maid.new()
		local muzzle = zombie.Gun.Handle.Muzzle

		for _, child in pairs(zombie.Gun.Handle:GetChildren()) do
			if child.Name:match("^Final") then
				local range = Range:Clone()
				range.Size = Vector3.new(
					(muzzle.Position - child.Position).Magnitude,
					range.Size.Y,
					range.Size.Z
				)

				local cframe = CFrame.new(
					muzzle.WorldPosition,
					child.WorldPosition
				)

				cframe = cframe + (cframe.LookVector * range.Size.X / 2)

				range.CFrame = cframe * CFrame.Angles(0, math.pi / 2, 0)

				local weld = Instance.new("WeldConstraint")
				weld.Part0 = range
				weld.Part1 = zombie.Gun.Handle
				weld.Parent = range
				range.Parent = Workspace

				maid:GiveTask(shootRange(zombie, range))
			end
		end

		shootingGuns[zombie] = maid
	end
end)
