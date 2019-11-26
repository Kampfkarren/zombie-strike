local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local HubWorld = ReplicatedStorage.HubWorld.Value
local LocalPlayer = Players.LocalPlayer

local LOOP_ZONE = 0.03

local currentAmbience

ReplicatedStorage.LocalEvents.Footstep.Event:connect(function(type)
	if currentAmbience then
		local table = currentAmbience[type]
		local footstep = table[math.random(#table)]:Clone()
		footstep.Parent = Workspace
		footstep:Play()
		Debris:AddItem(footstep, footstep.TimeLength + 2)
	end
end)

if HubWorld then
	currentAmbience = {
		Footsteps = SoundService.Footsteps.Concrete:GetChildren(),
		Land = SoundService.Footsteps.ConcreteLand:GetChildren(),
	}
else
	local Rooms = Workspace:WaitForChild("Rooms")

	local ambienceList = {}

	ambienceList.Concrete = {
		Footsteps = SoundService.Footsteps.Concrete:GetChildren(),
		Land = SoundService.Footsteps.ConcreteLand:GetChildren(),
		Sound = Instance.new("Sound"),
	}

	ambienceList.Firelands = {
		Footsteps = SoundService.Footsteps.Concrete:GetChildren(),
		Land = SoundService.Footsteps.ConcreteLand:GetChildren(),
		Sound = SoundService.Ambience.Firelands,
	}

	ambienceList.RainIndoors = {
		Footsteps = SoundService.Footsteps.Concrete:GetChildren(),
		Land = SoundService.Footsteps.ConcreteLand:GetChildren(),
		Sound = SoundService.Ambience.RainIndoors,
	}

	ambienceList.RainOutdoors = {
		Footsteps = SoundService.Footsteps.Water:GetChildren(),
		Land = SoundService.Footsteps.WaterLand:GetChildren(),
		Sound = SoundService.Ambience.RainOutdoors,
	}

	ambienceList.Treasure = {
		Footsteps = SoundService.Footsteps.Concrete:GetChildren(),
		Land = SoundService.Footsteps.ConcreteLand:GetChildren(),
		Sound = SoundService.Treasure,
	}

	local function checkNewAmbience(room)
		local ambienceValue = room:WaitForChild("Ambience")
		local ambience = assert(ambienceList[ambienceValue.Value], "unknown ambience in " .. room.Name)

		if ambience.Used then return end

		ambience.Used = true

		ambience.FadeIn = TweenService:Create(
			ambience.Sound,
			TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ Volume = ambience.Sound.Volume }
		)

		ambience.FadeOut = TweenService:Create(
			ambience.Sound,
			TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ Volume = 0 }
		)

		coroutine.wrap(function()
			ContentProvider:PreloadAsync(ambience.Footsteps)
		end)()

		coroutine.wrap(function()
			ContentProvider:PreloadAsync(ambience.Land)
		end)()

		ambience.Sound.Volume = 0
		ambience.Sound:Play()
	end

	for _, room in pairs(Rooms:GetChildren()) do
		checkNewAmbience(room)
	end

	Rooms.ChildAdded:connect(checkNewAmbience)

	local descendants = Rooms:GetDescendants()
	Rooms.DescendantAdded:connect(function(descendant)
		table.insert(descendants, descendant)
	end)

	RunService.Heartbeat:connect(function()
		if currentAmbience then
			local length = currentAmbience.Sound.TimeLength
			if length > 0 then
				if currentAmbience.Sound.TimePosition >= length - LOOP_ZONE then
					currentAmbience.Sound.TimePosition = 0.1
				end
			end
		end
	end)

	while true do
		local root = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart

		if root then
			local hit = Workspace:FindPartOnRayWithWhitelist(
				Ray.new(root.Position, Vector3.new(0, -1000, 0)),
				descendants
			)

			if hit then
				local room = hit
				while room.Parent ~= Rooms do
					room = room.Parent
				end

				local ambience = ambienceList[room.Ambience.Value]

				if currentAmbience ~= ambience then
					if currentAmbience then
						currentAmbience.FadeOut:Play()
					end

					ambience.FadeIn:Play()
					currentAmbience = ambience
					ReplicatedStorage.LocalEvents.AmbienceChanged:Fire(room.Ambience.Value, currentAmbience)
				end
			end
		end

		wait(0.1)
	end
end
