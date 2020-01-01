local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)

local LocalPlayer = Players.LocalPlayer
local ShootFrenzyCircles = ReplicatedStorage.Remotes.WestBoss.ShootFrenzyCircles
local WarningRange = ReplicatedStorage.WarningRange

local CIRCLES_PER_PLAYER = 5
local COLOR_ACTIVE = Color3.new(1, 0, 0)
local COLOR_IDLE = Color3.new(1, 1, 0)
local DELAY = 1
local HEIGHT = 20
local LIFETIME = 0.9
local POSITION_RANGE = 30
local RADIUS = 10
local OFFSET = Vector3.new(0, 2.5, 0)

if Dungeon.GetDungeonData("Campaign") ~= 5 then return end

local function summonCircle(position)
	local warning = WarningRange:Clone()
	warning.Color = COLOR_IDLE
	warning.Position = position
	warning.Size = Vector3.new(HEIGHT, RADIUS, RADIUS)
	warning.Parent = Workspace

	return warning
end

ShootFrenzyCircles.OnClientEvent:connect(function()
	local circles = {}

	for _, player in pairs(Players:GetPlayers()) do
		local position = player.Character.PrimaryPart.Position - OFFSET
		table.insert(circles, summonCircle(position))

		for _ = 1, CIRCLES_PER_PLAYER do
			table.insert(circles, summonCircle(position + Vector3.new(
				math.random(-POSITION_RANGE, POSITION_RANGE),
				0,
				math.random(-POSITION_RANGE, POSITION_RANGE)
			)))
		end
	end

	wait(DELAY)

	local touched = false

	local function touch(part)
		if touched then return end
		if part:IsDescendantOf(LocalPlayer.Character) then
			touched = true
			ShootFrenzyCircles:FireServer()
		end
	end

	for _, circle in pairs(circles) do
		circle.Color = COLOR_ACTIVE
		circle.Touched:connect(touch)
	end

	wait(LIFETIME)

	for _, circle in pairs(circles) do
		circle:Destroy()
	end
end)
