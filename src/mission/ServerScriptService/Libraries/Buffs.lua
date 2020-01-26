local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local BUFF_DELAY = 90
local BUFF_DROP_CHANCE = 0.05
local BUFF_LIFETIME = 16
local BUFF_SPEED_INCREASE = 0.4

local BuffModels = ReplicatedStorage.Buffs
local CurrentPowerup = ReplicatedStorage.CurrentPowerup

local Buffs = {}

local lastBuffUsed = 0

Buffs.BuffTypes = {
	{
		Name = "Rage",
		Part = BuffModels.Rage,
		Timer = 16,
	},

	{
		Name = "Tank",
		Part = BuffModels.Tank,
		Timer = 16,
	},

	{
		Name = "Bulletstorm",
		Part = BuffModels.Bulletstorm,
		Timer = 16,
	},
}

function Buffs.DropBuff(position)
	local buff = Buffs.BuffTypes[math.random(#Buffs.BuffTypes)]

	local part = buff.Part:Clone()
	part.Position = position
	part.Parent = Workspace

	local activated = false

	part.Touched:connect(function(touch)
		if activated then return end
		local player = Players:GetPlayerFromCharacter(touch.Parent)
		if player then
			activated = true
			part:Destroy()

			CurrentPowerup.Value = buff.Name .. "/" .. buff.Timer

			local light = Instance.new("PointLight")
			light.Color = buff.Part.Color
			light.Brightness = 18
			light.Range = 9

			for _, player in pairs(Players:GetPlayers()) do
				local speedMultiplier = player:WaitForChild("SpeedMultiplier")
				speedMultiplier.Value = speedMultiplier.Value + BUFF_SPEED_INCREASE
				delay(buff.Timer, function()
					speedMultiplier.Value = speedMultiplier.Value - BUFF_SPEED_INCREASE
				end)

				local character = player.Character

				if character then
					local characterLight = light:Clone()
					characterLight.Parent = character.PrimaryPart
					Debris:AddItem(characterLight, buff.Timer)
				end
			end

			delay(buff.Timer, function()
				CurrentPowerup.Value = ""
			end)
		end
	end)

	Debris:AddItem(part, BUFF_LIFETIME)
end

function Buffs.MaybeDropBuff(position)
	if tick() - lastBuffUsed <= BUFF_DELAY then return end

	if math.random() <= BUFF_DROP_CHANCE then
		lastBuffUsed = tick()
		Buffs.DropBuff(position)
	end
end

return Buffs
