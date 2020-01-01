local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local TouchHurt = {}

function TouchHurt.new(remote)
	local touched = false

	local function touch(part)
		if touched then return end
		if part:IsDescendantOf(LocalPlayer.Character) then
			touched = true
			remote:FireServer()
		end
	end

	return {
		AddPart = function(part)
			part.Touched:connect(touch)
		end
	}
end

return TouchHurt
