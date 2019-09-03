local Workspace = game:GetService("Workspace")

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

return Raycast
