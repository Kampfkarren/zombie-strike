-- services

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- constants

local PLAYER = Players.LocalPlayer
local EVENTS = ReplicatedStorage:WaitForChild("RuddevEvents")
local REMOTES = ReplicatedStorage:WaitForChild("RuddevRemotes")
local MODULES = ReplicatedStorage:WaitForChild("RuddevModules")
	local CONFIG = require(MODULES:WaitForChild("Config"))
	local MOUSE = require(MODULES:WaitForChild("Mouse"))
	local EFFECTS = require(MODULES:WaitForChild("Effects"))
	local DAMAGE = require(MODULES:WaitForChild("Damage"))
	local INPUT = require(MODULES:WaitForChild("Input"))


local EQUIP_COOLDOWN = 0.2

local HubWorld = ReplicatedStorage.HubWorld.Value

-- functions

local function wait(t)
	local start = tick()
	repeat
		RunService.Stepped:Wait()
	until tick() - start >= t
end

local function Raycast(position, direction, ignore)
	local ray = Ray.new(position, direction)
	local success
	local h, p, n, humanoid

	table.insert(ignore, Workspace.Effects)

	repeat
		h, p, n = Workspace:FindPartOnRayWithIgnoreList(ray, ignore)

		if h then
			humanoid = h.Parent:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health <= 0 then
				humanoid = nil
			end
			if humanoid then
				success = true
			else
				if h.CanCollide and h.Transparency < 1 then
					success = true
				else
					table.insert(ignore, h)
					success = false
				end
			end
		else
			success = true
		end
	until success

	return h, p, n, humanoid
end

local function aimAssist(cframe, range)
	if HubWorld then return end
	local LineOfSight = require(ReplicatedStorage.Libraries.LineOfSight)

	local aimAssist = Instance.new("Part")
	aimAssist.Anchored = true
	aimAssist.CanCollide = false
	aimAssist.Size = Vector3.new(3, 5, range)
	aimAssist.Transparency = 1
	aimAssist.CFrame = cframe + cframe.LookVector * range / 2
	aimAssist.Touched:connect(function() end)
	aimAssist.Parent = Workspace.Effects

	local closestZombie = { nil, math.huge }
	local zombiesChecked = {}

	for _, touchingPart in pairs(aimAssist:GetTouchingParts()) do
		if touchingPart:IsDescendantOf(Workspace.Zombies) then
			local zombie = touchingPart
			while zombie.Parent ~= Workspace.Zombies do
				zombie = zombie.Parent
			end

			if not zombiesChecked[zombie] then
				zombiesChecked[zombie] = true

				if zombie.Humanoid.Health > 0 then
					if LineOfSight(cframe.Position, zombie, range, { aimAssist }) then
						local zombiePrimary = zombie.PrimaryPart
						local dist = (zombiePrimary.Position - cframe.Position).Magnitude
						if dist < closestZombie[2] then
							closestZombie = { zombie, dist }
						end
					end
				end
			end
		end
	end

	aimAssist:Destroy()

	if closestZombie[1] then
		local zombieScreen = Workspace.CurrentCamera:WorldToScreenPoint(closestZombie[1].PrimaryPart.Position)
		local assistScreen = Workspace.CurrentCamera:WorldToScreenPoint(aimAssist.CFrame.Position)
		local humanoid = closestZombie[1].Humanoid

		if zombieScreen.Y / assistScreen.Y >= 1.1 then
			return closestZombie[1].Head, humanoid
		else
			return closestZombie[1].PrimaryPart, humanoid
		end
	end
end

-- modules

local module = {}

function module.Create(_, item)
	local itemModule = {
		Item = item;
		Equipped = false;
		Connections = {};
	}

	-- variables

	local animations = {}

	local character = item.Parent
	local handle = item:WaitForChild("Handle")
	local muzzle = handle:WaitForChild("Muzzle")

	local config = CONFIG:GetConfig(item)
	local canShoot = true
	local clicking = false
	local reloading = false
	local rCancelled = false
	local equipTime = 0

	local ammo = item:WaitForChild("Ammo").Value

	local aiming = false

	-- functions

	local mode = "Default"
	if not HubWorld then
		EVENTS.Mode.Event:connect(function(m)
			mode = m
		end)
	end

	local function CanShoot()
		if mode == "Sequence" then return end
		return itemModule.Equipped and canShoot and ammo > 0 and PLAYER.Character.Humanoid.Health > 0
	end

	local function Shoot()
		if not ReplicatedStorage.CurrentPowerup.Value:match("Bulletstorm/") then
			ammo = ammo - 1
		end

		local position = muzzle.WorldPosition
		local directions = {}

		local hits = {}

		for i = 1, config.ShotSize do
			local spread = config.Spread * 10
			local cframe

			if HubWorld and not UserInputService.MouseEnabled then
				cframe = muzzle.WorldCFrame
			else
				cframe = CFrame.new(position, MOUSE.WorldPosition)
			end

			if config.SpreadPattern then
				local x, y = config.SpreadPattern[i][1], config.SpreadPattern[i][2]
				cframe = cframe * CFrame.Angles(math.rad(spread * y / 50), math.rad(spread * x / 50), 0)
			else
				cframe = cframe * CFrame.Angles(math.rad(math.random(-spread, spread) / 50), math.rad(math.random(-spread, spread) / 50), 0)
			end

			local direction = cframe.lookVector
			table.insert(directions, direction)

			local hit, pos, _, humanoid = Raycast(position, direction * config.Range, {character})

			-- aim assist
			if not humanoid then
				hit, humanoid = aimAssist(cframe, config.Range)
			end

			if hit and humanoid then
				if DAMAGE:PlayerCanDamage(PLAYER, humanoid) then
					-- local damage = DAMAGE:Calculate(item, hit, position)
					EVENTS.Hitmarker:Fire(hit.Name == "Head", pos)
					-- REMOTES.Hit:FireServer(hit, i)
					table.insert(hits, { hit, i })
				end
			end
		end

		if aiming then
			animations.AimShoot:Play(0, math.random(5, 10) / 10, 1)
		else
			animations.Shoot:Play(0, math.random(5, 10) / 10, 1)
		end

		EVENTS.Gun:Fire("Update", ammo)
		EFFECTS:Effect("Shoot", item, position, directions, ammo)
		REMOTES.Shoot:FireServer(position, directions, hits)

		EVENTS.Recoil:Fire(Vector3.new(math.random(-config.Recoil, config.Recoil) / 4, 0, math.random(config.Recoil / 2, config.Recoil)))
	end

	local function Reload()
		if (not reloading) and itemModule.Equipped and ammo < config.Magazine then
			reloading = true
			rCancelled = false

			MOUSE.Reticle = "Reloading"
			REMOTES.Reload:FireServer()
			EFFECTS:Effect("Reload", item)
			animations.Reload:Play(0.1, 1, 1/config.ReloadTime)

			local start = tick()
			local elapsed
			repeat
				elapsed = tick() - start
				RunService.Stepped:wait()
			until elapsed >= config.ReloadTime or rCancelled or (not itemModule.Equipped)

			animations.Reload:Stop()

			if itemModule.Equipped then
				if elapsed >= config.ReloadTime then
					ammo = config.Magazine
				end

				MOUSE.Reticle = config.Reticle or "Gun"
				EVENTS.Gun:Fire("Update", ammo)
			end
			reloading = false

			spawn(function()
				if UserInputService.MouseEnabled
					and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
				then
					itemModule:Activate()
				end
			end)
		end
	end

	-- module functions

	function itemModule.Connect(self)
		local character = PLAYER.Character
		local humanoid = character:WaitForChild("Humanoid")

		for _, animation in pairs(self.Item:WaitForChild("Animations"):GetChildren()) do
			animations[animation.Name] = humanoid:LoadAnimation(animation)
		end

		table.insert(self.Connections, INPUT.ActionBegan:connect(function(action, processed)
			if self.Equipped and (not processed) then
				if action == "Reload" then
					Reload()
				end
			end
		end))

		table.insert(self.Connections, item.Attachments.ChildAdded:connect(function()
			config = CONFIG:GetConfig(item)
			if self.Equipped then
				EVENTS.Zoom:Fire(config.Zoom)
			end
		end))

		table.insert(self.Connections, item.Attachments.ChildRemoved:connect(function()
			config = CONFIG:GetConfig(item)
			if self.Equipped then
				EVENTS.Zoom:Fire(config.Zoom)
			end
		end))

		table.insert(self.Connections, EVENTS.Aim.Event:connect(function(a)
			aiming = a

			if self.Equipped then
				if aiming then
					animations.Idle:Stop()
					animations.Aim:Play()
				else
					animations.Aim:Stop()
					animations.Idle:Play()
				end
			end
		end))
	end

	function itemModule.Disconnect(self)
		for _, connection in pairs(self.Connections) do
			connection:Disconnect()
		end
		self.Connections = {}
	end

	function itemModule.Equip(self)
		EVENTS.Zoom:Fire(config.Zoom)
		MOUSE.Reticle = config.Reticle or "Gun"
		if aiming then
			animations.Aim:Play()
		else
			animations.Idle:Play()
		end
		animations.Equip:Play(0, 1, 1)

		ammo = item.Ammo.Value

		EVENTS.Gun:Fire("Enable", config.Size, ammo)

		self.Equipped = true
		equipTime = tick()

		if ammo == 0 then
			spawn(function()
				Reload()
			end)
		end
	end

	function itemModule.Unequip(self)
		EVENTS.Zoom:Fire()
		MOUSE.Reticle = "Default"

		for _, animation in pairs(animations) do
			animation:Stop()
		end

		EVENTS.Gun:Fire("Disable", config.Size, ammo)

		self.Equipped = false
	end

	function itemModule.Activate()
		clicking = true

		if tick() - equipTime >= EQUIP_COOLDOWN then
			if config.FireMode == "Semi" then
				if CanShoot() then
					rCancelled = true
					canShoot = false
					Shoot()
					wait(1 / config.FireRate)
					canShoot = true
				end
			elseif config.FireMode == "Auto" then
				while clicking and CanShoot() do
					rCancelled = true
					canShoot = false
					Shoot()
					wait(1 / config.FireRate)
					canShoot = true
				end
			elseif config.FireMode == "Burst" then
				while clicking and CanShoot() do
					canShoot = false
					for _ = 1, config.BurstAmount do
						if clicking and ammo > 0 then
							rCancelled = true
							Shoot()
							wait(1 / config.BurstRate)
						else
							break
						end
					end
					wait(1 / config.FireRate)
					canShoot = true
				end
			end
			if ammo == 0 then
				Reload()
			end
		end
	end

	function itemModule.Deactivate(_)
		clicking = false
	end

	return itemModule
end

return module