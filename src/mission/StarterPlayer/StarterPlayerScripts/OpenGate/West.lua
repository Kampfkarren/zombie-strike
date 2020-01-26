local RunService = game:GetService("RunService")

local West = {}
West.DontClone = true

local FADE_TIME = 1.2
local OFFSET = Vector3.new(0, 20, 0)

function West.Open(gate)
	gate.PrimaryPart.Attachment.ParticleEmitter.LockedToPart = true

	local start = gate.PrimaryPart.Position
	local goal = start - OFFSET

	local total = 0
	local fadeConnection
	fadeConnection = RunService.Heartbeat:connect(function(step)
		total = total + step
		gate.PrimaryPart.Position = start:Lerp(goal, math.sin(total / FADE_TIME))

		if total >= FADE_TIME then
			fadeConnection:Disconnect()
		end
	end)

	return gate
end

return West
