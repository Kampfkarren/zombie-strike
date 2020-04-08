local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local Collection = require(ReplicatedStorage.Core.Collection)
local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)
local PlayQuickSound = require(ReplicatedStorage.Core.PlayQuickSound)
local Raycast = require(ReplicatedStorage.Core.Raycast)

if Dungeon.GetDungeonData("Gamemode") ~= "Mission" then return end

local Rooms = Workspace:WaitForChild("Rooms")

local EMERGE_TIME = 1.25

local function checkRoom(room)
	local obbyType = room:WaitForChild("ObbyType")
	if obbyType.Value ~= "wave" then return end

	Collection("WaveDefenseZombie", function(waveDefenseZombie)
		local humanoid = waveDefenseZombie:WaitForChild("Humanoid")
		local root = waveDefenseZombie:WaitForChild("HumanoidRootPart")

		local _, ground = Raycast(
			root.Position,
			Vector3.new(0, -1000, 0),
			{ Workspace.Effects }
		)

		local initial = root.CFrame
			- root.Position
			+ ground
			- Vector3.new(0, waveDefenseZombie:GetExtentsSize().Y / 2, 0)
		local goal = initial
			- Vector3.new(0, initial.Position.Y, 0)
			+ Vector3.new(0, root.Position.Y, 0)

		local total = 0
		local emergeAnimation
		emergeAnimation = RunService.Heartbeat:connect(function(delta)
			total = math.min(total + delta, EMERGE_TIME)

			waveDefenseZombie:SetPrimaryPartCFrame(initial:Lerp(
				goal,
				math.sin((total / EMERGE_TIME) * (math.pi / 2))
			))

			if total >= EMERGE_TIME then
				emergeAnimation:disconnect()
			end
		end)

		local groundAnimation = humanoid:LoadAnimation(script.GroundAnimation)
		groundAnimation:Play()

		PlayQuickSound(SoundService.SFX.EmergeFromGround, root)
	end)

	ContentProvider:PreloadAsync({ script.GroundAnimation })
end

for _, room in ipairs(Rooms:GetChildren()) do
	FastSpawn(function()
		checkRoom(room)
	end)
end

Rooms.ChildAdded:connect(checkRoom)
