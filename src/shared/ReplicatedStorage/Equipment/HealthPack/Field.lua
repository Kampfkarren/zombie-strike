local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local GamePassDictionary = require(ReplicatedStorage.Core.GamePassDictionary)
local GamePasses = require(ReplicatedStorage.Core.GamePasses)
local Maid = require(ReplicatedStorage.Core.Maid)
local Promise = require(ReplicatedStorage.Core.Promise)
local Raycast = require(ReplicatedStorage.Core.Raycast)
local RealDelay = require(ReplicatedStorage.Core.RealDelay)

local LIFETIME = 9
local OFFSET = Vector3.new(0, 0.5, 0)
local RANGE = 30

local HEAL_PER_SECOND = 0.05
local HEAL_PER_SECOND_BETTER = 0.09

local Field = {}

Field.Index = 3
Field.Name = "Health Field"
Field.Icon = "rbxassetid://4515427328"
Field.Cooldown = 18

local function getCharactersInRangeOf(part)
	local characters = {}

	for _, player in pairs(Players:GetPlayers()) do
		local character = player.Character
		if character and (character.PrimaryPart.Position - part.Position).Magnitude <= RANGE / 2 then
			table.insert(characters, character)
		end
	end

	return characters
end

function Field.ServerEffect(player)
	return Promise.new(function(resolve)
		local maid = Maid.new()

		local character = player.Character
		local better = GamePasses.PlayerOwnsPass(
			player, GamePassDictionary.BetterEquipment
		)

		local _, position = Raycast(character.PrimaryPart.Position, Vector3.new(0, -1000, 0), { character })

		local model = ReplicatedStorage.Items.HealthPack3:Clone()
		model:SetPrimaryPartCFrame(
			CFrame.new(position + OFFSET)
			* (model.PrimaryPart.CFrame - model.PrimaryPart.Position)
		)
		model.Range.Transparency = 0.5
		model.Range.Size = Vector3.new(model.Range.Size.X, RANGE, RANGE)
		model.Parent = Workspace
		maid:GiveTask(model)

		local deploySound = SoundService.SFX.Items.HealthFieldDeploy:Clone()
		deploySound.Parent = model.Range
		deploySound:Play()

		local loopSound = SoundService.SFX.Items.HealthFieldLoop:Clone()
		loopSound.Parent = model.Range
		loopSound:Play()

		local healAmount = better and HEAL_PER_SECOND_BETTER or HEAL_PER_SECOND

		maid:GiveTask(RunService.Heartbeat:connect(function(delta)
			for _, character in pairs(getCharactersInRangeOf(model.PrimaryPart)) do
				local humanoid = character.Humanoid
				if humanoid.Health > 0 then
					humanoid.Health = humanoid.Health + (humanoid.MaxHealth * healAmount * delta)
				end
			end
		end))

		RealDelay(LIFETIME, function()
			maid:DoCleaning()
		end)

		resolve()
	end)
end

return Field
