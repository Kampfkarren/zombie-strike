local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local Explosion = require(ReplicatedStorage.RuddevModules.Effects.Explosion)

local BOSS_DEATH_TIME = 2.7
local EXPLOSION_RADIUS = 20


local boss = CollectionService:GetInstanceAddedSignal("Boss"):wait()

if Dungeon.GetDungeonData("Campaign") ~= 3 and boss.Name ~= "Egg Mech Zombie" then
	return
end

boss.Humanoid.Died:connect(function()
	CollectionService:RemoveTag(boss, "Boss")

	local fogEnd = Lighting.FogEnd

	TweenService:Create(
		Lighting,
		TweenInfo.new(
			BOSS_DEATH_TIME,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{ FogEnd = 0 }
	):Play()

	local time = 0
	local explosionSounds = SoundService.SFX.Explosion:GetChildren()

	repeat
		time = time + wait(0.1)

		Explosion(boss.PrimaryPart.Position, EXPLOSION_RADIUS)

		local explosionSound = explosionSounds[math.random(#explosionSounds)]:Clone()
		explosionSound.Parent = boss.PrimaryPart
		explosionSound:Play()
	until time > BOSS_DEATH_TIME

	Lighting.FogEnd = fogEnd

	boss.Body.Eye:Destroy()

	for _, part in pairs(boss.Body:GetChildren()) do
		part.Color = Color3.fromRGB(177, 177, 177)
		part.Material = Enum.Material.Pebble
	end

	boss:SetPrimaryPartCFrame(
		(boss.PrimaryPart.CFrame - Vector3.new(0, 30, 0))
		* CFrame.Angles(
			math.random() * math.pi,
			math.random() * math.pi,
			math.random() * math.pi
		)
	)
end)
