local CollectionService = game:GetService("CollectionService")

local DELAY = 0.5
local EMIT = 50
local MIN_TIME = 0.5
local MAX_TIME = 1.5

local rng = Random.new()
local scheduled = {}
local scheduledParents = {}
local scheduler

local function startBlipping(parent)
	if scheduledParents[parent] then return end
	scheduledParents[parent] = true

	scheduled[parent] = rng:NextNumber(MIN_TIME, MAX_TIME)

	if not scheduler then
		scheduler = true
		spawn(function()
			while true do
				local delta = wait(0.1)

				for parent, timeLeft in pairs(scheduled) do
					local difference = timeLeft - delta
					if difference < 0 then
						local size = parent.Parent.Size * Vector3.new(0.5, 0, 0.5)
						parent.Position = Vector3.new(
							rng:NextNumber(-size.X, size.X),
							parent.Position.Y,
							rng:NextNumber(-size.Z, size.Z)
						)

						for _, emitter in pairs(parent:GetChildren()) do
							emitter:Emit(EMIT)
						end

						scheduled[parent] = DELAY
					else
						scheduled[parent] = difference
					end
				end
			end
		end)
	end
end

CollectionService:GetInstanceAddedSignal("RainFloor"):connect(startBlipping)

for _, blip in pairs(CollectionService:GetTagged("RainFloor")) do
	coroutine.wrap(startBlipping)(blip.Parent)
end
