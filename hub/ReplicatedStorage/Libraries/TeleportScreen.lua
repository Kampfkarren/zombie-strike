local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Campaigns = require(ReplicatedStorage.Core.Campaigns)

return function(gui, lobby)
	local campaign = Campaigns[lobby.Campaign]
	local difficulty = campaign.Difficulties[lobby.Difficulty]

	local inner = gui.Background.Inner

	inner.Background.ImageColor3 = campaign.LoadingColor
	inner.Cover.Image = campaign.Image
	inner.Cover.CampaignName.Text = campaign.Name

	inner.Info.Difficulty.Text = difficulty.Style.Name
	inner.Info.Difficulty.TextStrokeColor3 = difficulty.Style.Color
	inner.Info.Level.Text = "LV. " .. difficulty.MinLevel
	inner.Info.Hardcore.Visible = lobby.Hardcore
	inner.Info.PlayerCount.Text = #lobby.Players .. "/4"
end
