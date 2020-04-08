local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local PlayerModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))

local stunCount = 0

local Stun = {}

function Stun.IsStunned()
	return stunCount > 0
end

function Stun.Stun()
	stunCount = stunCount + 1
	PlayerModule:GetControls():Disable()

	return function()
		stunCount = stunCount - 1
		if not Stun.IsStunned() then
			PlayerModule:GetControls():Enable()
		end
	end
end

return Stun
