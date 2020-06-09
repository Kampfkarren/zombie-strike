local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local CalculateGearScore = require(ReplicatedStorage.Core.CalculateGearScore)
local EventConnection = require(ReplicatedStorage.Core.UI.Components.EventConnection)
local GradientButton = require(ReplicatedStorage.Core.UI.Components.GradientButton)
local ItemImage = require(ReplicatedStorage.Core.UI.Components.ItemImage)
local ItemType = require(ReplicatedStorage.Core.UI.Components.ItemType)
local Loot = require(ReplicatedStorage.Core.Loot)
local PerfectTextLabel = require(ReplicatedStorage.Core.UI.Components.PerfectTextLabel)
local Perks = require(ReplicatedStorage.Core.UI.Components.Perks)
local PlayerDataConsumer = require(ReplicatedStorage.Core.UI.Components.PlayerDataConsumer)
local Rarity = require(ReplicatedStorage.Core.UI.Components.Rarity)
local RarityTintedGradientButton = require(ReplicatedStorage.Core.UI.Components.RarityTintedGradientButton)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local ImageFavoriteBorder = require(ReplicatedStorage.Assets.Tarmac.UI.favorite_border)
local ImageFavoriteFilled = require(ReplicatedStorage.Assets.Tarmac.UI.favorite_filled)
local ImageItemButton = require(ReplicatedStorage.Assets.Tarmac.UI.item_button)
local ImageSelected2 = require(ReplicatedStorage.Assets.Tarmac.UI.selected2)
local ImageStar = require(ReplicatedStorage.Assets.Tarmac.UI.star)

local FavoriteButton = Roact.PureComponent:extend("FavoriteButton")

local FAVORITE_HOVER_SPEED = 6

function FavoriteButton:init()
	self.fill, self.setFill = Roact.createBinding(0)

	self.hovering = false

	self.hover = function()
		self.hovering = true
	end

	self.unhover = function()
		self.hovering = false
	end

	self.tick = function(delta)
		delta = delta * FAVORITE_HOVER_SPEED
		local value = self.fill:getValue()

		if self.hovering then
			value = value + delta
		else
			value = value - delta
		end

		value = math.clamp(value, 0, 1)
		if value ~= self.fill:getValue() then
			self.setFill(value)
		end
	end

	self.toggleFavorite = function()
		ReplicatedStorage.Remotes.FavoriteLoot:FireServer(self.props.UUID)
	end
end

function FavoriteButton:render()
	return e("ImageButton", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		Image = ImageFavoriteBorder,
		Position = UDim2.new(1, -10, 0, 50),
		Size = UDim2.fromOffset(30, 27),

		[Roact.Event.MouseEnter] = self.hover,
		[Roact.Event.MouseLeave] = self.unhover,
		[Roact.Event.Activated] = self.toggleFavorite,
	}, {
		Fill = e("ImageLabel", {
			BackgroundTransparency = 1,
			Image = ImageFavoriteFilled,
			ImageTransparency = self.props.Favorited
				and 0
				or self.fill:map(function(transparency)
					return TweenService:GetValue(
						1 - transparency / 2,
						Enum.EasingStyle.Quad,
						Enum.EasingDirection.InOut
					)
				end),
			Size = UDim2.fromScale(1, 1),
		}),

		Heartbeat = e(EventConnection, {
			callback = self.tick,
			event = RunService.Heartbeat,
		}),
	})
end

local function ItemPreview(props)
	local rarityAndLevel = {
		UIListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Gap = e("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = 3,
			Size = UDim2.fromOffset(14, 0),
		}),
	}

	if props.Item.Level then
		rarityAndLevel.LevelLabel = e(PerfectTextLabel, {
			Font = Enum.Font.Gotham,
			LayoutOrder = 1,
			Text = "LV",
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		})

		rarityAndLevel.Level = e(PerfectTextLabel, {
			Font = Enum.Font.GothamBold,
			LayoutOrder = 2,
			Text = props.Item.Level,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 19,
			TextXAlignment = Enum.TextXAlignment.Right,
		})
	end

	if props.Item.Rarity then
		rarityAndLevel.Rarity = e(Rarity, {
			LayoutOrder = 4,
			Rarity = props.Item.Rarity,
			Style = "Right",

			Padding = {
				Left = 11,
				Right = 11,
			},
		})
	end

	local gearScoreChildren

	if props.ShowGearScore then
		gearScoreChildren = e("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 25, 1, -20),
			Size = UDim2.fromOffset(116, 42),
		}, {
			UIListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			ItemGearScore = e(PerfectTextLabel, {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBlack,
				Position = UDim2.fromOffset(25, 110),
				Text = CalculateGearScore(props.Item),
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 48,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),

			GearScoreLabel = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				LayoutOrder = 2,
				Position = UDim2.fromOffset(90, 135),
				Size = UDim2.new(0, 47, 1, 0),
				Text = "Power",
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 30,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Bottom,
				TextTransparency = 0.01,
			}),
		})
	end

	local upgradeStars

	if props.Item.Upgrades then
		upgradeStars = {
			UIListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				Padding = UDim.new(0, 3),
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
		}

		for _ = 1, props.Item.Upgrades do
			table.insert(upgradeStars, e("ImageLabel", {
				BackgroundTransparency = 1,
				Image = ImageStar,
				ImageColor3 = Color3.new(1, 1, 0.4),
				Size = UDim2.fromScale(1, 1),
			}, {
				UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
			}))
		end
	end

	local buttonProps = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = props.LayoutOrder,
		Image = ImageItemButton,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(0, 10, 419, 149),
		Size = props.FrameSize or UDim2.fromOffset(430, 160),
		ZIndex = props.ZIndex,

		Rarity = props.Item.Rarity,

		[Roact.Event.MouseEnter] = props.Hover,
		[Roact.Event.MouseLeave] = props.Unhover,
		[Roact.Event.SelectionGained] = props.Hover,
		[Roact.Event.SelectionLost] = props.Unhover,
		[Roact.Event.Activated] = props.Equip,
	}

	local showFavorites = not props.HideFavorites

	local buttonChildren = {
		Selected = props.Equipped and e("ImageLabel", {
			BackgroundTransparency = 1,
			Image = ImageSelected2,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 1,
		}),

		ItemImage = props.CenterWeapon
		and e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(0.8, 0, 1, -120),
		}, {
			UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
				AspectRatio = 1.4,
			}),

			Model = e(ItemImage, {
				Angle = props.Angle,
				Distance = props.Distance,
				Item = props.Item,
			}, {
				Gradient = e("UIGradient", {
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(0.1, 0.3),
						NumberSequenceKeypoint.new(0.9, 0.3),
						NumberSequenceKeypoint.new(1, 1),
					}),
				}),

				GradientVertical = e("UIGradient", {
					Rotation = 90,
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(0.2, 0.3),
						NumberSequenceKeypoint.new(0.8, 0.3),
						NumberSequenceKeypoint.new(1, 1),
					}),
				}),
			}),
		})
		or e("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			ClipsDescendants = false,
			Position = UDim2.new(1, 40, 0, 0),
			Size = UDim2.new(0, 350, 1, 0),
			ZIndex = 0,
		}, {
			Model = e(ItemImage, {
				Angle = props.Angle,
				Item = props.Item,
			}, {
				Gradient = e("UIGradient", {
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.3),
						NumberSequenceKeypoint.new(0.8, 0.3),
						NumberSequenceKeypoint.new(1, 1),
					}),
				}),
			}),
		}),

		ItemTypeLabel = e(ItemType, {
			Native = {
				Position = UDim2.fromOffset(25, 25),
				ZIndex = 2,
			},
			Item = props.Item,
			TextSize = 20,
		}),

		ItemName = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Position = UDim2.fromOffset(25, 57),
			Size = UDim2.new(1, -150, 0, 50),
			Text = props.Name,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		}, {
			UITextSizeConstraint = e("UITextSizeConstraint", {
				MaxTextSize = 32,
			}),
		}),

		RarityAndLevel = e("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 1, -52),
			Size = UDim2.new(1, 0, 0, 32),
		}, rarityAndLevel),

		Perks = props.Item.Perks and e(Perks, {
			Position = UDim2.fromOffset(0, 10),
			RightAligned = true,
			RightMargin = props.Equipped and -45 or -10,
			Size = 34,
			ZIndex = 10,

			Seed = props.Item.Seed,
			Perks = props.Item.Perks,
		}),

		Upgrades = props.Item.Upgrades and e("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, 7),
			Size = UDim2.new(1, props.Equipped and -45 or -12, 0, 22),
		}, upgradeStars),

		FavoriteIcon = showFavorites and e(FavoriteButton, {
			Favorited = props.Item.Favorited,
			UUID = props.Item.UUID,
		}),

		Scale = props.Size and e("UIScale", {
			Scale = props.Size / 430,
		}),

		gearScoreChildren,
	}

	if props[Roact.Children] ~= nil then
		buttonChildren.ProvidedChildren = Roact.createFragment(props[Roact.Children])
	end

	-- Arena gives attachments with levels, this hasn't been fixed yet
	if props.Item.Level and not Loot.IsAttachment(props.Item) and not props.IgnoreLevelCap then
		return e(PlayerDataConsumer, {
			Name = "Level",
			Render = function(level)
				if level >= props.Item.Level then
					return e(RarityTintedGradientButton, buttonProps, buttonChildren)
				else
					buttonProps[Roact.Event.Activated] = props.OpenLevelWarning
					buttonProps.Rarity = nil
					buttonProps.MinGradient = Color3.fromRGB(152, 49, 48)
					buttonProps.MaxGradient = Color3.fromRGB(169, 88, 86)
					buttonProps.HoveredMaxGradient = Color3.fromRGB(238, 120, 118)
					return e(GradientButton, buttonProps, buttonChildren)
				end
			end,
		})
	else
		return e(RarityTintedGradientButton, buttonProps, buttonChildren)
	end
end

return ItemPreview
