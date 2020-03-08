local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AutomatedScrollingFrameComponent = require(ReplicatedStorage.Core.UI.Components.AutomatedScrollingFrameComponent)
local Close = require(script.Parent.Parent.Close)
local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)
local Memoize = require(ReplicatedStorage.Core.Memoize)
local Reward = require(script.Parent.Reward)
local RewardInfo = require(script.Parent.RewardInfo)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local StyledButton = require(ReplicatedStorage.Core.UI.Components.StyledButton)
local ZombiePassDictionary = require(ReplicatedStorage.Core.ZombiePassDictionary)

local e = Roact.createElement
local LocalPlayer = Players.LocalPlayer

local BattlePassMenu = Roact.PureComponent:extend("BattlePassMenu")

local COLOR_LEVEL = Color3.fromRGB(9, 132, 227)

local COLOR_FREE = Color3.fromRGB(0, 148, 50)
local COLOR_PAID = Color3.fromRGB(253, 167, 223)

local COLOR_FREE_BG = Color3.fromRGB(0, 209, 70)
local COLOR_PAID_BG = Color3.fromRGB(255, 203, 237)

local MORE_COMING_SOON = true
local PRODUCT_ID = 945698356

local function copy(list)
	local copy = {}
	for key, value in pairs(list) do
		copy[key] = value
	end
	return copy
end

local function Tier(props)
	local contents = {}
	contents.UIListLayout = e("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
		[Roact.Ref] = props.Layout,
	})

	for level, rewards in ipairs(ZombiePassDictionary) do
		local maxRewards = math.max(#rewards.FreeLoot, #rewards.PaidLoot)

		local rewardsContents = {
			UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
				AspectRatio = 1 + ((maxRewards - 1) * 0.84),
			}),

			UIListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0.01, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = props.ShowLevel
					and Enum.VerticalAlignment.Bottom
					or Enum.VerticalAlignment.Center,
			}),
		}

		for rewardIndex, reward in ipairs(rewards[props.Key] or {}) do
			rewardsContents["Reward" .. rewardIndex] = e(Reward, {
				LayoutOrder = rewardIndex,
				Locked = (props.Key == "PaidLoot" and not props.Premium)
					or (props.Level <= level),
				Reward = reward,
				Premium = props.Premium,

				Hover = props.Hover(reward),
				Unhover = props.Unhover(reward),
			})
		end

		if props.ShowLevel then
			rewardsContents.NoAlign = e("Folder", {}, {
				Level = e("Frame", {
					BackgroundColor3 = COLOR_LEVEL,
					BorderSizePixel = 0,
					Size = UDim2.fromScale(1, 0.18),
				}, {
					Text = e("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Font = Enum.Font.GothamBold,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0.95, 0.99),
						Text = level,
						TextColor3 = Color3.new(0.9, 0.9, 0.9),
						TextScaled = true,
					})
				}),
			})

			rewardsContents.Padding = e("UIPadding", {
				PaddingBottom = UDim.new(0.03, 0),
			})
		end

		local levelProps = {
			BackgroundTransparency = 0.6,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			LayoutOrder = level,
			Size = UDim2.fromScale(1, 1),
		}

		if props.Level == level then
			levelProps[Roact.Ref] = props.LevelRef
		end

		contents["Level" .. level] = e("Frame", levelProps, rewardsContents)
	end

	if MORE_COMING_SOON then
		local ref

		if (props.Level or 0) > #ZombiePassDictionary then
			ref = props.LevelRef
		end

		contents.ComingSoon = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			LayoutOrder = #ZombiePassDictionary + 1,
			Text = "More coming soon!",
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			TextStrokeTransparency = 0.2,
			Size = UDim2.fromScale(1, 1),
			[Roact.Ref] = ref,
		}, {
			e("UIAspectRatioConstraint", {
				AspectRatio = 2.2,
			}),
		})
	end

	return e("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.fromScale(1, 1),
	}, contents)
end

function BattlePassMenu:init()
	self.layout = Roact.createRef()
	self.levelRef = Roact.createRef()
	self.rewardsFrame = Roact.createRef()

	self.canvasPosition, self.updateCanvasPosition = Roact.createBinding(Vector2.new())

	self:setState({
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

	self.upgradeUpsell = function()
		FastSpawn(function()
			MarketplaceService:PromptProductPurchase(LocalPlayer, PRODUCT_ID)
		end)
	end
end

function BattlePassMenu:didUpdate(prevProps)
	if self.props.open ~= prevProps.open then
		local levelFrame = self.levelRef:getValue()

		if levelFrame then
			self.updateCanvasPosition(
				levelFrame.AbsolutePosition
				- self.rewardsFrame:getValue().AbsolutePosition
			)
		end
	end
end

function BattlePassMenu:render()
	local currentLevel = ZombiePassDictionary[self.props.level]
	local xp = self.props.xp

	if not currentLevel then
		currentLevel = ZombiePassDictionary[#ZombiePassDictionary]
		xp = currentLevel.GamesNeeded
	end

	local progress = {
		UIListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0.01, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	}

	for index = 1, currentLevel.GamesNeeded do
		progress["Notch" .. index] = e("Frame", {
			BackgroundColor3 = Color3.fromRGB(104, 109, 224),
			BorderColor3 = Color3.fromRGB(72, 52, 212),
			BorderSizePixel = 2,
			LayoutOrder = index,
			Size = UDim2.fromScale(1 / currentLevel.GamesNeeded, 1),
		}, {
			Inner = e("Frame", {
				BackgroundColor3 = Color3.fromRGB(43, 27, 144),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(math.clamp(xp - index + 1, 0, 1), 1),
			}),
		})
	end

	local topbarContents = {
		Contents = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		}, {
			UIListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0.01, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			LevelFrame = e("Frame", {
				BackgroundColor3 = Color3.fromRGB(48, 51, 107),
				BorderSizePixel = 0,
				LayoutOrder = 1,
				Size = UDim2.fromScale(1, 1),
			}, {
				UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
				UIListLayout = e("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0.01, 0),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				TextLabel = e("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamSemibold,
					LayoutOrder = 1,
					Size = UDim2.fromScale(0.9, 0.2),
					Text = "TIER",
					TextColor3 = Color3.new(0.9, 0.9, 0.9),
					TextScaled = true,
				}),

				Level = e("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamSemibold,
					LayoutOrder = 2,
					Size = UDim2.fromScale(0.9, 0.75),
					Text = math.min(#ZombiePassDictionary, self.props.level),
					TextColor3 = Color3.new(0.9, 0.9, 0.9),
					TextScaled = true,
				}),
			}),

			XPFrame = e("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 2,
				Size = UDim2.fromScale(0.3, 0.7),
			}, {
				UIListLayout = e("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0.03, 0),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				ProgressText = e("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamSemibold,
					Size = UDim2.fromScale(1, 0.49),
					Text = ("%.2g/%d"):format(xp, currentLevel.GamesNeeded),
					TextColor3 = Color3.new(0.9, 0.9, 0.9),
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
				}),

				Progress = e("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 0.49),
				}, progress),
			}),
		}),
	}

	if self.props.premium then
		topbarContents.PremiumActivated = e("TextLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			Size = UDim2.fromScale(0.25, 0.65),
			Position = UDim2.fromScale(0.97, 0.5),
			Text = "Upgraded ✅",
			TextColor3 = Color3.new(0.9, 0.9, 0.9),
			TextScaled = true,
		})
	else
		topbarContents.BuyPremium = e(StyledButton, {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Color3.fromRGB(68, 189, 50),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.25, 0.65),
			Position = UDim2.fromScale(0.97, 0.5),
			[Roact.Event.Activated] = self.upgradeUpsell,
		}, {
			Label = e("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.9, 0.8),
				Text = "UPGRADE",
				TextColor3 = Color3.new(0.9, 0.9, 0.9),
				TextScaled = true,
			}),
		})
	end

	local hovered = next(self.state.hoverStack)

	return e("TextButton", {
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.7, 0.7),
		Text = "",
		Visible = self.props.open,
	}, {
		UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
			AspectRatio = 2.5,
			AspectType = Enum.AspectType.ScaleWithParentSize,
			DominantAxis = Enum.DominantAxis.Height,
		}),

		Rewards = e("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = COLOR_PAID_BG,
			BackgroundTransparency = 0,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.fromScale(0.8, 0.75),
		}, {
			Tiers = e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.2, 1),
			}, {
				FreeTier = e("Frame", {
					BackgroundColor3 = COLOR_FREE,
					BorderSizePixel = 0,
					Size = UDim2.fromScale(1, 0.5),
				}, {
					Text = e("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Font = Enum.Font.GothamBold,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0.95, 0.99),
						Text = "FREE",
						TextColor3 = Color3.new(0.9, 0.9, 0.9),
						TextScaled = true,
						TextStrokeTransparency = 0.2,
					}),
				}),

				PaidTier = e("Frame", {
					AnchorPoint = Vector2.new(0, 1),
					BackgroundColor3 = COLOR_PAID,
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0, 1),
					Size = UDim2.fromScale(1, 0.5),
				}, {
					Text = e("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Font = Enum.Font.GothamBold,
						Position = UDim2.fromScale(0.5, 0.5),
						Rotation = -20,
						Size = UDim2.fromScale(0.95, 0.99),
						Text = "PREMIUM",
						TextColor3 = Color3.new(0.9, 0.9, 0.9),
						TextScaled = true,
						TextStrokeTransparency = 0.2,
					}),
				}),
			}),

			Rewards = e(AutomatedScrollingFrameComponent, {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				CanvasPosition = self.canvasPosition,
				HorizontalScrollBarInset = Enum.ScrollBarInset.Always,
				Layout = self.layout,
				ScrollBarImageColor3 = Color3.new(1, 0, 0),
				ScrollingDirection = Enum.ScrollingDirection.X,
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.fromScale(0.8, 1),
				[Roact.Change.CanvasPosition] = function(rbx)
					self.updateCanvasPosition(rbx.CanvasPosition)
				end,
				[Roact.Ref] = self.rewardsFrame,
			}, {
				UITableLayout = e("UITableLayout", {
					FillEmptySpaceColumns = true,
					FillEmptySpaceRows = true,
				}),

				FreeTier = e("Frame", {
					BackgroundColor3 = COLOR_FREE_BG,
					BorderSizePixel = 0,
					Size = UDim2.fromScale(1, 0.5),
				}, {
					e(Tier, {
						Key = "FreeLoot",
						Layout = self.layout,
						Level = self.props.level,
						LevelRef = self.levelRef,
						ShowLevel = true,
						Premium = self.props.premium,

						Hover = self.hover,
						Unhover = self.unhover,
					}),
				}),

				PaidTier = e("Frame", {
					AnchorPoint = Vector2.new(0, 1),
					BackgroundColor3 = COLOR_PAID_BG,
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0, 1),
					Size = UDim2.fromScale(1, 0.52),
				}, {
					e(Tier, {
						Key = "PaidLoot",
						Level = self.props.level,
						Premium = self.props.premium,

						Hover = self.hover,
						Unhover = self.unhover,
					}),
				}),
			}),
		}),

		RewardInfoFrame = e("Frame", {
			AnchorPoint = Vector2.new(1, 1),
			BackgroundColor3 = Color3.new(0.2, 0.2, 0.2),
			BorderSizePixel = 0,
			BackgroundTransparency = 0.3,
			Position = UDim2.fromScale(1, 1),
			Size = UDim2.fromScale(0.2, 0.75),
		}, {
			RewardInfo = e(RewardInfo, {
				Reward = hovered,
			}),
		}),

		Topbar = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0.24),
		}, topbarContents),

		Close = e(Close, {
			onClose = self.props.close,
		}),
	})
end

return RoactRodux.connect(function(state)
	return {
		open = state.page.current == "ZombiePass",

		level = state.zombiePass.level,
		premium = state.zombiePass.premium,
		xp = state.zombiePass.xp,
	}
end, function(dispatch)
	return {
		close = function()
			dispatch({
				type = "CloseZombiePass",
			})
		end,
	}
end)(BattlePassMenu)
