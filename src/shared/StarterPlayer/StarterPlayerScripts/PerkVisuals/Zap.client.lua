local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Maid = require(ReplicatedStorage.Core.Maid)
local RealDelay = require(ReplicatedStorage.Core.RealDelay)

local DEPTH = 8
local LIFETIME = 0.1
local MIN_WIDTH = 0.3
local MAX_WIDTH = 0.55
local NOISE_STEP = 1 / 10

local rng = Random.new()

local lightningBeam = Instance.new("Beam")
lightningBeam.Color = ColorSequence.new(Color3.new(1, 1, 0))
lightningBeam.FaceCamera = true
lightningBeam.Segments = 5

ReplicatedStorage.Remotes.Perks.Zap.OnClientEvent:connect(function(root, ...)
	local rootPosition = root.Position
	local maid = Maid.new()

	local function newAttachment(position)
		local attachment = Instance.new("Attachment")
		attachment.WorldPosition = position
		attachment.Parent = Workspace.Terrain
		maid:GiveTask(attachment)
		return attachment
	end

	for _, goalPart in ipairs({ ... }) do
		local goal = goalPart.Position
		local randomY, randomZ = rng:NextNumber(), rng:NextNumber()

		local lastAttachment = newAttachment(rootPosition)
		local lastWidth = rng:NextNumber(MIN_WIDTH, MAX_WIDTH)

		for index = 1, DEPTH do
			local attachment = newAttachment(rootPosition:Lerp(goal, index / DEPTH))

			if index ~= DEPTH then
				attachment.Position = attachment.Position + Vector3.new(
					0,
					math.noise(randomY) * 4,
					math.noise(randomZ) * 4
				)
				randomY = randomY + NOISE_STEP
				randomZ = randomZ + NOISE_STEP
			end

			local beam = lightningBeam:Clone()
			beam.Attachment0 = lastAttachment
			beam.Attachment1 = attachment
			beam.Width0 = lastWidth

			lastWidth = rng:NextNumber(MIN_WIDTH, MAX_WIDTH)
			beam.Width1 = lastWidth

			beam.Parent = attachment

			lastAttachment = attachment
			maid:GiveTask(attachment)
		end
	end

	RealDelay(LIFETIME, function()
		maid:DoCleaning()
	end)
end)
