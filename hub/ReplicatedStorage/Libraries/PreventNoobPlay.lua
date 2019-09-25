local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

return function()
	if LocalPlayer
		:WaitForChild("PlayerData")
		:WaitForChild("DungeonsPlayed")
		.Value == 0
	then
		LocalPlayer.PlayerGui.MainGui.Main.CantSelect.Visible = true
		return false
	end

	return true
end
