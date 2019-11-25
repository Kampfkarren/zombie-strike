local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Campaigns = require(ReplicatedStorage.Core.Campaigns)

local News = script.Parent.Main.News
local SendNews = ReplicatedStorage.Remotes.SendNews

local CampaignUnlocked = News.Inner.Image.CampaignUnlocked
local DifficultyUnlocked = News.Inner.Image.DifficultyUnlocked

local newsFormatters = {}

function newsFormatters.CampaignUnlocked(format)
	local campaign = format[1]

	CampaignUnlocked.CoverImage.Image = Campaigns[campaign].Image
	CampaignUnlocked.CampaignName.Text = ("\"%s\""):format(
		Campaigns[campaign].Name
	)
end

function newsFormatters.DifficultyUnlocked(format)
	local campaign, difficulty = unpack(format)

	DifficultyUnlocked.CoverImage.Image = Campaigns[campaign].Image
	DifficultyUnlocked.DifficultyName.Text = ("\"%s\""):format(
		Campaigns[campaign]
			.Difficulties[difficulty]
			.Style
			.Name
	)
end

SendNews.OnClientEvent:connect(function(news)
	if #news == 0 then return end
	local newsRead = 0

	for _, entry in pairs(news) do
		if #entry > 1 then
			newsFormatters[entry[1]](entry[2])
		end

		News.Inner.Image[entry[1]].Visible = true
	end

	for _, image in pairs(News.Inner.Image:GetChildren()) do
		if image:IsA("Frame") and not image.Visible then
			image:Destroy()
		end
	end

	News.Inner.OK.MouseButton1Click:connect(function()
		newsRead = newsRead + 1
		if newsRead == #news then
			News.Visible = false
		else
			News.Inner.Image.UIPageLayout:NextPage()
		end
	end)

	News.Visible = true
end)
