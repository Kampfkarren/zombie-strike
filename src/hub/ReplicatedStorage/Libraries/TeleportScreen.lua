local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Campaigns = require(ReplicatedStorage.Core.Campaigns)

return function(gui, lobby)
	local campaign = Campaigns[lobby.Campaign]

	local inner = gui.Background.Inner

	gui.Background.ImageColor3 = campaign.LoadingColor
	inner.Cover.Image = campaign.Image
	inner.Cover.CampaignName.Text = campaign.Name

	if lobby.Gamemode == "Arena" then
		inner.Info.Difficulty.Text = "THE ARENA"
		inner.Info.Difficulty.TextStrokeColor3 = Color3.new(1, 1, 1)
		inner.Info.Level.Text = "LV. " .. lobby.ArenaLevel
	else
		local difficulty = campaign.Difficulties[lobby.Difficulty]
		inner.Info.Difficulty.Text = difficulty.Style.Name
		inner.Info.Difficulty.TextStrokeColor3 = difficulty.Style.Color
		inner.Info.Level.Text = "LV. " .. difficulty.MinLevel
	end

	inner.Info.Hardcore.Visible = lobby.Hardcore
	inner.Info.PlayerCount.Text = #lobby.Players .. "/4"
end
