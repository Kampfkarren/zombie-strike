local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer

local loadingGui = TeleportService:GetArrivingTeleportGui()
if not loadingGui then return end
loadingGui.Parent = LocalPlayer.PlayerGui

if not LocalPlayer.Character then
	LocalPlayer.CharacterAdded:wait()
end

loadingGui:Destroy()
