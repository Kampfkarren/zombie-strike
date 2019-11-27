local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local EnglishNumbers = require(ReplicatedStorage.Core.EnglishNumbers)
local Spring = require(ReplicatedStorage.RuddevModules.Spring)

local DamageNumber = ReplicatedStorage.DamageNumber

local HEIGHT_SCALE = 1
local LIFETIME = 0.8
local STRAY_SCALE = 5

local damageOffsets = {}

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function updateColor(label, health, maxHealth)
	if health == 0 then
		label.TextColor3 = Color3.fromHSV(1, 1, 0.71)
	else
		label.TextColor3 = Color3.fromHSV(1, lerp(0.5, 0, health / maxHealth), 0.95)
	end
end

ReplicatedStorage.Remotes.DamageNumber.OnClientEvent:connect(function(humanoid, damage, crit)
	if not humanoid then
		warn("DamageNumber: no humanoid, probably the grenade bug")
		return
	end

	if crit then
		local critEffect = ReplicatedStorage.CritEffect:Clone()
		critEffect.Parent = humanoid.Parent.PrimaryPart
		critEffect:Emit(15)

		local critSound = SoundService.Crit:Clone()
		critSound.Parent = SoundService
		critSound:Play()

		Debris:AddItem(critEffect)
		Debris:AddItem(critSound)
	end

	if damageOffsets[humanoid] then
		local offset = damageOffsets[humanoid]
		offset.damage = offset.damage + damage
		offset.stray = math.random(-100, 100) / 100
		offset.text.Text = EnglishNumbers(math.floor(offset.damage))
		offset.timeSinceLast = 0
		updateColor(offset.text, humanoid.Health, humanoid.MaxHealth)
		return
	end

	local damageNumber = DamageNumber:Clone()
	local damageText = damageNumber.TextLabel
	damageText.Text = EnglishNumbers(damage)
	damageNumber.Parent = humanoid.Parent.HumanoidRootPart
	updateColor(damageText, humanoid.Health, humanoid.MaxHealth)

	if CollectionService:HasTag(humanoid.Parent, "Boss") then
		damageText.UIScale.Scale = damageText.UIScale.Scale * 5
	end

	local base = damageNumber.ExtentsOffsetWorldSpace
	local baseSizeY = damageNumber.Size.Y.Scale

	local offset = {
		damage = damage,
		stray = math.random(-100, 100) / 100,
		text = damageText,
		timeSinceLast = 0,
	}

	damageOffsets[humanoid] = offset

	local deathSpring = Spring:Create(nil, 150, nil, 2)

	local diedConnection = humanoid.Died:connect(function()
		deathSpring:Shove(Vector3.new(10, 0, 0))
		damageText.UIScale.Scale = damageText.UIScale.Scale * 2
		damageText.Font = Enum.Font.GothamBlack
		offset.timeSinceLast = -0.5
	end)

	local connection do
		connection = RunService.Heartbeat:connect(function(dt)
			offset.timeSinceLast = offset.timeSinceLast + dt

			local timeSinceLast = offset.timeSinceLast

			local deathStray = 2 * (deathSpring:Update(dt).X + 10 / 2) - 10

			damageNumber.ExtentsOffsetWorldSpace = base + Vector3.new(
				offset.stray * timeSinceLast * STRAY_SCALE + deathStray,
				((LIFETIME - timeSinceLast) * HEIGHT_SCALE) ^ 2,
				0
			)

			local sizeY = math.clamp(
				lerp(0.2, baseSizeY, (LIFETIME - timeSinceLast) / LIFETIME),
				0.2,
				baseSizeY
			)

			damageNumber.Size = UDim2.new(
				damageNumber.Size.X.Scale, 0,
				sizeY, 0
			)

			damageText.TextTransparency = math.clamp(
				lerp(1, 0, (LIFETIME - timeSinceLast) / LIFETIME),
				0,
				1
			)

			damageText.TextStrokeTransparency = math.clamp(
				lerp(1, 0.2, (LIFETIME - timeSinceLast) / LIFETIME),
				0.2,
				1
			)

			if timeSinceLast >= LIFETIME then
				connection:disconnect()
				diedConnection:disconnect()
				Debris:AddItem(damageNumber)
				damageOffsets[humanoid] = nil
			end
		end)
	end
end)
