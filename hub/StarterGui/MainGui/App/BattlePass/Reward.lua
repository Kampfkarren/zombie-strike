local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RewardPreview = require(script.Parent.RewardPreview)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local REWARD_COLORS = {
	Brains = Color3.fromRGB(253, 121, 168),
	Emote = Color3.fromRGB(249, 202, 36),
	Font = Color3.fromRGB(149, 175, 192),
	PetCoins = Color3.fromRGB(248, 194, 145),
	Skin = Color3.fromRGB(235, 77, 75),
	Title = Color3.fromRGB(149, 175, 192),
	XP = Color3.fromRGB(108, 92, 231),
}

local function Reward(props)
	local reward = props.Reward
	local rewardType = reward.Type
	local color = assert(REWARD_COLORS[rewardType], "unknown reward type: " .. rewardType)

	local h, s, v = Color3.toHSV(color)
	local darkColor = Color3.fromHSV(h, s, v * 0.8)

	return e("TextButton", {
		BackgroundColor3 = color,
		BorderColor3 = darkColor,
		BorderMode = Enum.BorderMode.Middle,
		BorderSizePixel = 3,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromScale(1, 0.8),
		Text = "",
		[Roact.Event.MouseEnter] = props.Hover,
		[Roact.Event.MouseLeave] = props.Unhover,
	}, {
		e("UIAspectRatioConstraint"),

		RewardPreview = e(RewardPreview, {
			Reward = reward,
		}),

		Lock = e("TextLabel", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.98, 0.01),
			Size = UDim2.fromScale(0.2, 0.2),
			Text = props.Locked and "🔒" or "✅",
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextYAlignment = Enum.TextYAlignment.Top,
		}, {
			e("UIAspectRatioConstraint"),
		}),
	})
end

return Reward
