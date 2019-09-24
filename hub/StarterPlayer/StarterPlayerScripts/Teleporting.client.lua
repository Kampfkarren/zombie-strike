local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local Campaigns = require(ReplicatedStorage.Core.Campaigns)

local GetCurrentLobby = ReplicatedStorage.LocalEvents.GetCurrentLobby
local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local TeleportGui = PlayerGui:WaitForChild("TeleportGui")

local LoadingInfo = TeleportGui.Frame.Info

ReplicatedStorage.Remotes.Teleporting.OnClientEvent:connect(function(teleporting)
	if teleporting then
		local lobby = GetCurrentLobby:Invoke()

		local campaign = Campaigns[lobby.Campaign]
		local difficulty = campaign.Difficulties[lobby.Difficulty]

		LoadingInfo.CampaignName.Text = campaign.Name
		LoadingInfo.MapImage.Image = campaign.Image
		LoadingInfo.MapImage.Hardcore.Visible = lobby.Hardcore
		LoadingInfo.Info.Level.Text = "LV. " .. difficulty.MinLevel
		LoadingInfo.Info.PlayerCount.Text = #lobby.Players .. "/4"
		LoadingInfo.Info.Difficulty.Text = difficulty.Style.Name
		LoadingInfo.Info.Difficulty.TextColor3 = difficulty.Style.Color

		TeleportService:SetTeleportGui(TeleportGui)
	end

	TeleportGui.Enabled = teleporting
end)
