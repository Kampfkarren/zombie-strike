local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CosmeticPreview = require(script.Parent.Parent.Store.CosmeticPreview)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local function RewardPreview(props)
	local reward = props.Reward
	local rewardType = reward.Type

	local contents = {}

	if rewardType == "Brains" or rewardType == "PetCoins" then
		contents.BrainsImage = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.7, 0.7),
			Text = rewardType == "Brains" and "🧠" or "🐾",
			TextScaled = true,
		})

		contents.Count = e("TextLabel", {
			AnchorPoint = Vector2.new(1, 1),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromScale(0.98, 0.98),
			Size = UDim2.fromScale(0.9, 0.35),
			Text = reward.Brains or reward.PetCoins,
			TextColor3 = Color3.new(0.9, 0.9, 0.9),
			TextScaled = true,
			TextStrokeTransparency = 0.2,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextYAlignment = Enum.TextYAlignment.Bottom,
			ZIndex = 2,
		})
	elseif rewardType == "Emote" then
		local emote = reward.Emote

		contents.Image = e("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = emote.Image,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.8, 0.8),
		})
	elseif rewardType == "Skin" then
		contents.Inner = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.9, 0.9),
		}, {
			Preview = e(CosmeticPreview, {
				item = reward.Skin,
				previewScale = Roact.createBinding(1.5),
				size = UDim2.fromScale(1, 1),
			}),
		})
	elseif rewardType == "Title" then
		contents.FontText = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.7, 0.7),
			Text = '"' .. reward.Title .. '"',
			TextColor3 = Color3.new(0.9, 0.9, 0.9),
			TextScaled = true,
		})
	elseif rewardType == "Font" then
		contents.FontText = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Font = reward.Font.Font,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.7, 0.7),
			Text = reward.Font.Name,
			TextColor3 = Color3.new(0.9, 0.9, 0.9),
			TextScaled = true,
		})
	elseif rewardType == "XP" then
		contents.XPText = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.7, 0.7),
			Text = reward.XP .. "% XP",
			TextColor3 = Color3.new(0.9, 0.9, 0.9),
			TextScaled = true,
		})
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, contents)
end

return RewardPreview
