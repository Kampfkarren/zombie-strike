local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Raycast = require(ReplicatedStorage.Core.Raycast)

local LineOfSight = {}

function LineOfSight.__call(_, origin, character, range, blacklist)
	if typeof(origin) == "Instance" then
		if origin.Position:isClose(character.PrimaryPart.Position) then
			return origin, origin.Position
		end

		origin = origin.Position
	end

	blacklist = blacklist or {}

	local hit, point do
		-- luacheck: ignore
		while true do
			hit, point = Raycast(origin, (origin - character.PrimaryPart.Position).Unit * -range, blacklist)

			if hit and hit:IsDescendantOf(character) then
				break
			-- elseif hit and ignoreIf(hit) then
			-- 	debug("IGNORING OFF IF", hit:GetFullName())
			-- 	blacklist[#blacklist + 1] = hit
			else
				break
			end
		end
	end

	return hit and hit:IsDescendantOf(character), point
end

return setmetatable(LineOfSight, LineOfSight)
