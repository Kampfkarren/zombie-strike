local ReplicatedStorage = game:GetService("ReplicatedStorage")

local News = script.Parent.Main.News
local SendNews = ReplicatedStorage.Remotes.SendNews

SendNews.OnClientEvent:connect(function(news)
	if #news == 0 then return end
	local newsRead = 0

	for _, entry in pairs(news) do
		News.Inner.Image[entry].Visible = true
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
