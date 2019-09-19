local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Rooms = Workspace:WaitForChild("Rooms")

local LOOP_ZONE = 0.03

local ambienceList = {}
local currentAmbience

ambienceList.RainIndoors = {
	Sound = SoundService.Ambience.RainIndoors,
}

ambienceList.RainOutdoors = {
	Sound = SoundService.Ambience.RainOutdoors,
}

local function checkNewAmbience(room)
	local ambience = assert(ambienceList[room:WaitForChild("Ambience").Value], "unknown ambience in " .. room.Name)

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

	ambience.Sound.Volume = 0
	ambience.Sound:Play()
end

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

for _, room in pairs(Rooms:GetChildren()) do
	checkNewAmbience(room)
end

Rooms.ChildAdded:connect(checkNewAmbience)

local descendants = Rooms:GetDescendants()
Rooms.DescendantAdded:connect(function(descendant)
	table.insert(descendants, descendant)
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
			end
		end
	end

	wait(0.1)
end
