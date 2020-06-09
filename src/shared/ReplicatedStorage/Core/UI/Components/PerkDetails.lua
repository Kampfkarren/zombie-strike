local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PerfectTextLabel = require(ReplicatedStorage.Core.UI.Components.PerfectTextLabel)
local PerkUtil = require(ReplicatedStorage.Core.Perks.PerkUtil)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local ImagePanel2 = require(ReplicatedStorage.Assets.Tarmac.UI.panel2)
local ImageStar = require(ReplicatedStorage.Assets.Tarmac.UI.star)

local LINE_DETAILS_GAP = 30
local ICON_TEXT_GAP = 8
local ICON_SIZE = 60
local LIST_PADDING = 6
local WINDOW_WIDTH = 500

local function PerkDetails(props)
	local iconSize = props.IconSize or ICON_SIZE

	local perkDetails = {}

	perkDetails.UIListLayout = e("UIListLayout", {
		Padding = UDim.new(0, LIST_PADDING),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local size

	if #props.Perks > 0 then
		for index, perk in ipairs(props.Perks) do
			local upgradeStars = {
				UIListLayout = e("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 3),
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
			}

			for _ = 1, perk.Upgrades do
				table.insert(upgradeStars, e("ImageLabel", {
					BackgroundTransparency = 1,
					Image = ImageStar,
					ImageColor3 = Color3.new(1, 1, 0.4),
					Size = UDim2.fromScale(1, 1),
				}, {
					UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
				}))
			end

			perkDetails["Perk" .. index] = e("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = index,
				Size = UDim2.fromOffset(WINDOW_WIDTH - LINE_DETAILS_GAP, iconSize),
			}, {
				Icon = e("ImageLabel", {
					BackgroundTransparency = 1,
					Image = ImagePanel2,
					ImageColor3 = perk.Perk.LegendaryPerk
						and Color3.fromRGB(219, 144, 83)
						or Color3.fromRGB(77, 77, 77),
					LayoutOrder = index,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(13, 10, 369, 82),
					Size = UDim2.fromOffset(iconSize, iconSize),
				}, {
					Icon = e("ImageLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Image = perk.Perk.Icon,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.new(1, -8, 1, -8),
					}),
				}),

				Details = e("Frame", {
					AnchorPoint = Vector2.new(1, 0),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(1, 0),
					Size = UDim2.new(1, -ICON_TEXT_GAP - iconSize, 1, 0),
				}, {
					UIListLayout = e("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),

					PerkName = e(PerfectTextLabel, {
						Font = Enum.Font.GothamBold,
						LayoutOrder = 1,
						Text = perk.Perk.Name,
						TextColor3 = Color3.new(1, 1, 1),
						TextStrokeTransparency = 0.6,
						TextSize = 21,
					}, {
						Upgrades = e("Frame", {
							BackgroundTransparency = 1,
							Position = UDim2.fromScale(1, 0),
							Size = UDim2.fromScale(1, 1),
						}, upgradeStars),
					}),

					PerkDescription = e(PerfectTextLabel, {
						Font = Enum.Font.Gotham,
						LayoutOrder = 2,
						MaxWidth = WINDOW_WIDTH - LINE_DETAILS_GAP - ICON_TEXT_GAP - iconSize,
						MaxHeight = iconSize - 21,
						Text = PerkUtil.GetPerkDescription(
							perk.Perk,
							props.Seed,
							perk.Upgrades
						),
						TextColor3 = Color3.new(1, 1, 1),
						TextScaled = true,
						TextSize = 21,
						TextStrokeTransparency = 0.6,
						TextXAlignment = Enum.TextXAlignment.Left,
					}, {
						UITextSizeConstraint = e("UITextSizeConstraint", {
							MaxTextSize = 21,
						}),
					}),
				}),
			})
		end

		size = UDim2.fromOffset(
			WINDOW_WIDTH,
			(#props.Perks * iconSize) + ((#props.Perks - 1) * LIST_PADDING)
		)
	else
		perkDetails.NoPerks = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Size = UDim2.new(1, 0, 0, 30),
			Text = "Weapon has no perks",
			TextColor3 = Color3.new(1, 1, 1),
			TextStrokeTransparency = 0.6,
			TextSize = 30,
			TextXAlignment = Enum.TextXAlignment.Left,
		})

		size = UDim2.fromOffset(WINDOW_WIDTH, 30)
	end

	local element = e("Frame", {
		BackgroundTransparency = 1,
		Size = size,
	}, {
		Contents = e("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.new(0, WINDOW_WIDTH - LINE_DETAILS_GAP, 1, 0),
		}, perkDetails),

		Line = e("Frame", {
			BackgroundColor3 = Color3.fromRGB(155, 155, 155),
			BorderSizePixel = 0,
			Size = UDim2.new(0, 6, 1, 0),
		}),
	})

	if props.RenderParent then
		return props.RenderParent(element, size)
	else
		return element
	end
end

return PerkDetails
