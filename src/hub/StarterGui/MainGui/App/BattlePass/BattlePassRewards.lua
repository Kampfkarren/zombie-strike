local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local AutomatedScrollingFrameComponent = require(ReplicatedStorage.Core.UI.Components.AutomatedScrollingFrameComponent)
local Memoize = require(ReplicatedStorage.Core.Memoize)
local Reward = require(script.Parent.Reward)
local RewardInfo = require(script.Parent.RewardInfo)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local StyledButton = require(ReplicatedStorage.Core.UI.Components.StyledButton)
local ZombiePassDictionary = require(ReplicatedStorage.Core.ZombiePassDictionary)

local e = Roact.createElement

local BattlePassRewards = Roact.PureComponent:extend("BattlePassRewards")

local LOOT_RARITIES = {
	Emote = 1,
	Brains = 2,
	Title = 2,
	Font = 3,
	Skin = 3,
}

local function copy(list)
	local copy = {}
	for key, value in pairs(list) do
		copy[key] = value
	end
	return copy
end

local getLootForLevel = Memoize(function(level, premium)
	local rewards = {}

	local passLevel = ZombiePassDictionary[level]

	for _, freeLoot in ipairs(passLevel.FreeLoot) do
		table.insert(rewards, freeLoot)
	end

	if premium then
		for _, paidLoot in ipairs(passLevel.PaidLoot) do
			table.insert(rewards, paidLoot)
		end
	end

	return rewards
end)

function BattlePassRewards:init()
	self:setState({
		firstLoot = nil,
		hoverStack = {},
	})

	self.hover = Memoize(function(reward)
		return function()
			local hoverStack = copy(self.state.hoverStack)
			hoverStack[reward] = true

			self:setState({
				hoverStack = hoverStack,
			})
		end
	end)

	self.unhover = Memoize(function(reward)
		return function()
			local hoverStack = copy(self.state.hoverStack)
			hoverStack[reward] = nil
			self:setState({
				hoverStack = hoverStack,
			})
		end
	end)
end

function BattlePassRewards:GetFirstLoot()
	local level = self.props.rewards[1]

	if level then
		return getLootForLevel(level)[1]
	end
end

function BattlePassRewards:PlaySound()
	local level = self.props.rewards[1]
	if not level then
		warn("BattlePassRewards:PlaySound called, but no level!")
		return
	end

	local lootRarities = {}
	for _, loot in ipairs(getLootForLevel(level)) do
		table.insert(lootRarities, LOOT_RARITIES[loot.Type])
	end

	SoundService.ImportantSFX.ZombiePass["Unlock" .. math.max(1, unpack(lootRarities))]:Play()
end

function BattlePassRewards:didMount()
	local reward = self:GetFirstLoot()

	if reward then
		self:setState({
			firstLoot = reward,
		})

		self:PlaySound()
	end
end

function BattlePassRewards:didUpdate(oldProps)
	if #self.props.rewards > 0 and #oldProps.rewards == 0 then
		local reward = self:GetFirstLoot()

		if reward then
			self:setState({
				firstLoot = reward,
			})

			self:PlaySound()
		end
	end
end

function BattlePassRewards:render()
	local props = self.props

	local rewards = {}
	local rewardCards = {}

	for _, level in ipairs(props.rewards) do
		local lootForLevel = getLootForLevel(level, props.premium)

		for index, reward in pairs(lootForLevel) do
			table.insert(rewards, reward)
			table.insert(rewardCards, e(Reward, {
				LayoutOrder = index,
				Reward = reward,
				Hover = self.hover(reward),
				Unhover = self.unhover(reward),
			}))
		end
	end

	local hovered = next(self.state.hoverStack) or self.state.firstLoot

	return e("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		Visible = #rewards > 0,
		ZIndex = 2,
	}, {
		Label = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromScale(0.5, 0.02),
			Size = UDim2.fromScale(0.95, 0.1),
			Text = "You unlocked from the Zombie Pass...",
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
		}),

		Rewards = e(AutomatedScrollingFrameComponent, {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.12),
			Size = UDim2.fromScale(0.95, 0.2),
		}, {
			e("UIGridLayout", {
				CellSize = UDim2.fromScale(0.15, 1),
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}, {
				e("UIAspectRatioConstraint"),
			}),

			Rewards = Roact.createFragment(rewardCards),
		}),

		RewardInfoFrame = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.62),
			Size = UDim2.fromScale(0.5, 0.5),
		}, {
			RewardInfo = e(RewardInfo, {
				Reward = hovered,
			}),
		}),

		OK = e(StyledButton, {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = Color3.fromRGB(32, 146, 81),
			Position = UDim2.fromScale(0.5, 0.98),
			Size = UDim2.fromScale(0.3, 0.1),
			[Roact.Event.Activated] = props.close,
		}, {
			Label = e("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.95, 0.95),
				Text = "OK",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
			}),
		}),
	})
end

return RoactRodux.connect(function(state)
	return {
		premium = state.zombiePass.premium,
		rewards = state.zombiePass.rewards,
	}
end, function(dispatch)
	return {
		close = function()
			dispatch({
				type = "SetRewards",
				rewards = {},
			})
		end,
	}
end)(BattlePassRewards)
