local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RewardPreview = require(script.Parent.RewardPreview)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local function getRewardName(reward)
	if reward.Type == "Brains" then
		return reward.Brains .. " Brains"
	elseif reward.Type == "Title" then
		return '"' .. reward.Title .. '"'
	elseif reward.Type == "XP" then
		return "XP Multiplier"
	else
		return reward[reward.Type].Name
	end
end

local function RewardInfo(props)
	local reward = props.Reward
	local contents = {}

	if reward then
		contents.UIListLayout = e("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.01, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		})

		contents.ItemType = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			LayoutOrder = 1,
			Size = UDim2.fromScale(0.9, 0.1),
			Text = reward.Type,
			TextColor3 = Color3.fromRGB(227, 227, 227),
			TextScaled = true,
		})

		contents.ItemName = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			LayoutOrder = 2,
			Size = UDim2.fromScale(0.9, 0.15),
			Text = getRewardName(reward),
			TextColor3 = Color3.fromRGB(227, 227, 227),
			TextScaled = true,
		})

		contents.Preview = e("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = 3,
			Size = UDim2.fromScale(0.8, 0.8),
		}, {
			UIAspectRatioConstraint = e("UIAspectRatioConstraint"),

			Preview = e(RewardPreview, {
				Reward = reward,
			}),
		})
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, contents)
end

return RewardInfo
