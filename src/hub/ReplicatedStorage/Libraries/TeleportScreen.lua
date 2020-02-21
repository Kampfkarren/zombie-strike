local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Bosses = require(ReplicatedStorage.Core.Bosses)
local Campaigns = require(ReplicatedStorage.Core.Campaigns)

return function(gui, lobby)
	local campaign
	local inner = gui.Background.Inner

	if lobby.Gamemode == "Boss" then
		local boss = Bosses[lobby.Boss]
		gui.Background.ImageColor3 = boss.LoadingColor
		inner.Cover.Image = boss.Image
		inner.Cover.CampaignName.Text = boss.Name
	else
		campaign = Campaigns[lobby.Campaign]
		gui.Background.ImageColor3 = campaign.LoadingColor
		inner.Cover.Image = campaign.Image
		inner.Cover.CampaignName.Text = campaign.Name
	end

	if lobby.Gamemode == "Arena" then
		inner.Info.Difficulty.Text = "THE ARENA"
		inner.Info.Difficulty.TextStrokeColor3 = Color3.new(1, 1, 1)
		inner.Info.Level.Text = "LV. " .. lobby.ArenaLevel
	elseif lobby.Gamemode == "Boss" then
		inner.Info.Difficulty.Text = ""
		inner.Info.Level.Text = "BOSS"
	else
		local difficulty = campaign.Difficulties[lobby.Difficulty]
		inner.Info.Difficulty.Text = difficulty.Style.Name
		inner.Info.Difficulty.TextStrokeColor3 = difficulty.Style.Color

		if difficulty.MinLevel ~= nil then
			inner.Info.Level.Text = "LV. " .. difficulty.MinLevel
		else
			inner.Info.Level.Text = ""
		end
	end

	inner.Info.Hardcore.Visible = lobby.Hardcore
	inner.Info.PlayerCount.Text = #lobby.Players .. "/4"
end
