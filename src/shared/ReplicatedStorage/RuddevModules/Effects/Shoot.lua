-- services

local ReplicatedStorage	= game:GetService("ReplicatedStorage")
local RunService		= game:GetService("RunService")
local SoundService		= game:GetService("SoundService")
local Workspace			= game:GetService("Workspace")
local Debris			= game:GetService("Debris")

-- constants

local CAMERA	= Workspace.CurrentCamera
local EFFECTS	= Workspace:WaitForChild("Effects")
local MODULES	= ReplicatedStorage:WaitForChild("RuddevModules")
	local CONFIG	= require(MODULES:WaitForChild("Config"))

local DAMAGE	= require(script.Parent:WaitForChild("Damage"))

local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)
local GunSpray = require(ReplicatedStorage.Core.GunSpray)
local LootStyles = require(ReplicatedStorage.Core.LootStyles)

-- functions
local HOLE_LIFETIME = 5

local holes = {}

FastSpawn(function()
	while true do
		wait(5)

		debug.profilebegin("Hole cleanup")

		local newHoles = {}

		for _, hole in ipairs(holes) do
			if tick() - hole[2] <= HOLE_LIFETIME then
				table.insert(newHoles, hole)
			else
				hole[1]:Destroy()
			end
		end

		holes = newHoles

		debug.profileend()
	end
end)

local function Raycast(position, direction, ignore)
	local ray		= Ray.new(position, direction)
	local success	= false
	local h, p, n, humanoid

	table.insert(ignore, EFFECTS)

	repeat
		h, p, n	= Workspace:FindPartOnRayWithIgnoreList(ray, ignore)

		if h then
			humanoid = h.Parent:FindFirstChildOfClass("Humanoid")

			if humanoid then
				if humanoid.Health <= 0 then
					table.insert(ignore, h)
				else
					success	= true
				end
			else
				if h.CanCollide and h.Transparency < 1 then
					success	= true
				else
					table.insert(ignore, h)
					success	= false
				end
			end
		else
			success	= true
		end
	until success

	return h, p, n, humanoid
end

return function(item, position, directions, ammo, forceEnd)
	local handle		= item.Handle
	local muzzle		= handle.Muzzle
	local ammo			= ammo and ammo or item.Ammo.Value
	local config		= CONFIG:GetConfig(item)
	local attachments	= item:FindFirstChild("Attachments")

	if handle:FindFirstChild("ReloadSound_Clone") then
		handle.ReloadSound_Clone:Destroy()
	end

	if directions == nil then
		directions = {}

		for _, spray in pairs(GunSpray(handle.CFrame, config)) do
			table.insert(directions, spray.LookVector.Unit)
		end
	end

	local numSounds		= 0
	for _, s in pairs(muzzle:GetChildren()) do
		if string.match(s.Name, "FireSound%d+") then
			numSounds	= numSounds + 1
		end
	end

	local sound		= muzzle["FireSound" .. tostring(math.random(numSounds))]:Clone()
		sound.Name		= "FireSound_Clone"
		sound.Parent	= muzzle

	local min	= math.floor(config.Magazine * 0.45)
	if ammo < min then
		local amount	= (min - ammo) / min
		local equalizer	= script.AmmoEqualizer:Clone()
			equalizer.LowGain	= -7 * amount
			equalizer.HighGain	= 7 * amount
			equalizer.Parent	= sound
	end

	local distance	= (CAMERA.CFrame.p - muzzle.WorldPosition).Magnitude
	local amount	= math.min((distance/500)^3, 2)
	if amount >= 0.1 then
		local equalizer	= script.DistanceEqualizer:Clone()
			equalizer.HighGain	= -10 * amount
			equalizer.MidGain	= -5 * amount
			equalizer.LowGain	= -5 * amount
			equalizer.Parent	= sound
	end

	if config.Silenced then
		sound.PlaybackSpeed	= sound.PlaybackSpeed * 1.5

		local equalizer	= script.SilencedEqualizer:Clone()
			equalizer.Parent	= sound
	else
		if attachments and attachments:FindFirstChild("Extended Barrel") then
			attachments["Extended Barrel"].PrimaryPart.Muzzle.FlashEmitter:Emit(1)
		else
			muzzle.FlashEmitter:Emit(1)
		end
	end

	sound:Play()
	Debris:AddItem(sound, sound.TimeLength / sound.PlaybackSpeed)

	for _, dir in pairs(directions) do
		local hit, pos, normal, humanoid

		if forceEnd then
			hit, pos, normal, humanoid = unpack(forceEnd)
		else
			hit, pos, normal, humanoid = Raycast(position, dir * config.Range, {item, item.Parent})
		end

		local distance	= (position - pos).Magnitude

		if hit then
			if humanoid then
				DAMAGE(humanoid, pos, normal)
			else
				if hit.Anchored then
					local hole	= script.BulletHole:Clone()
						hole.CFrame	= CFrame.new(pos, pos + normal) * CFrame.Angles(0, 0, math.rad(math.random(0, 360)))
						hole.Parent	= EFFECTS

					hole.DirtEmitter:Emit(5)
					hole.DustEmitter:Emit(3)
					hole.HitEmitter:Emit(1)

					table.insert(holes, { hole, tick() })
				end
			end
		end

		local cframe	= CFrame.new(position, pos)
		local offset	= cframe:pointToObjectSpace(CAMERA.CFrame.p)

		if offset.Z < 0 and offset.Z > -config.Range then
			local distance	= Ray.new(position, (pos - position).Unit):Distance(CAMERA.CFrame.p)

			if distance < 20 then
				local loudness	= 1 - (distance / 20)
				local sound		= script.BulletSounds["Bullet" .. tostring(math.random(15))]:Clone()
					sound.Volume	= loudness
					sound.Parent	= SoundService

				sound:Play()
				Debris:AddItem(sound, sound.TimeLength)
			end
		end

		local trail = script.BulletTrail:Clone()
		trail.CFrame = CFrame.new(position, pos)
		trail.EndAttach.Position = Vector3.new(0, 0, -distance)

		if item.WeaponData.Type.Value == "Crystal" then
			trail.Beam.Color = ColorSequence.new(LootStyles[item.WeaponData.Rarity.Value].Color)
		end

		trail.Parent = EFFECTS

		spawn(function()
			local start	= tick()

			repeat
				local alpha	= math.min((tick() - start) / 0.2, 1)
				trail.Beam.Transparency	= NumberSequence.new(alpha)

				RunService.RenderStepped:wait()
			until alpha == 1
			trail:Destroy()
		end)
		-- end
	end
end