local ReplicatedStorage = game:GetService("ReplicatedStorage")

local App = require(ReplicatedStorage.Core.UI.Components.App)
local AutoFixedScrollingFrame = require(ReplicatedStorage.Core.UI.Components.AutoFixedScrollingFrame)
local GradientButton = require(ReplicatedStorage.Core.UI.Components.GradientButton)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local PerfectTextLabel = require(ReplicatedStorage.Core.UI.Components.PerfectTextLabel)
local Perks = require(ReplicatedStorage.Core.Perks)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)

local ImagePanel2 = require(ReplicatedStorage.Assets.Tarmac.UI.panel2)

local e = Roact.createElement

local function noop()
end

local function CollectionLogPerks(props)
	return e(App.Context.Consumer, {
		render = function(state)
			local perks = {}

			-- Sort perk names into alphabetical order
			local perkNames = {}
			for _, perk in ipairs(Perks.Perks) do
				table.insert(perkNames, perk.Name)
			end
			table.sort(perkNames)

			local owned = 0

			for index, perk in ipairs(Perks.Perks) do
				local layoutOrder = table.find(perkNames, perk.Name)
				local perkOwned = table.find(props.itemsCollected.Perks, index) ~= nil

				local gradientProps = {
					BackgroundTransparency = 1,
					Image = ImagePanel2,
					LayoutOrder = perkOwned and layoutOrder or (#Perks.Perks + layoutOrder),
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(13, 10, 369, 82),

					[Roact.Event.Activated] = perkOwned and function()
						state.openPerkDetails({
							{
								Perk = perk,
								Upgrades = 0,
							},
						}, 0)
					end or noop,
				}

				local perkColor = perk.LegendaryPerk
					and Color3.fromRGB(219, 144, 83)
					or Color3.new(0.65, 0.65, 0.65)
				local h, s, v = Color3.toHSV(perkColor)

				if perkOwned then
					owned = owned + 1

					gradientProps.MaxGradient = Color3.fromHSV(h, s, v * (200 / 255))
					gradientProps.MinGradient = gradientProps.MaxGradient
					gradientProps.HoveredMaxGradient = Color3.fromHSV(h, s, v * (120 / 255))
				end

				perks["Perk" .. index] = e(GradientButton, gradientProps, {
					UIListLayout = e("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						Padding = UDim.new(0, 10),
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),

					Icon = e("ImageLabel", {
						BackgroundTransparency = 1,
						Image = perk.Icon,
						ImageColor3 = perkOwned and Color3.new(1, 1, 1) or Color3.new(0.5, 0.5, 0.5),
						LayoutOrder = 1,
						Size = UDim2.fromScale(1, 0.8),
					}, {
						e("UIAspectRatioConstraint"),
					}),

					Name = e(PerfectTextLabel, {
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						LayoutOrder = 2,
						Size = UDim2.fromScale(0.8, 0.8),
						Text = perkOwned and perk.Name or perk.Name:gsub("[^ ]", "?"),
						TextColor3 = Color3.new(1, 1, 1),
						TextScaled = true,
						TextSize = 25,
					}, {
						UITextSizeConstraint = e("UITextSizeConstraint", {
							MaxTextSize = 25,
						}),
					}),
				})
			end

			return e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}, {
				Completion = e("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.Gotham,
					Size = UDim2.fromScale(0.95, 0.05),
					Text = string.format("%d/%d (%d%%)", owned, #Perks.Perks, math.floor(owned / #Perks.Perks * 100)),
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Right,
				}),

				Contents = e(AutoFixedScrollingFrame, {
					CellsPerRow = 3,
					CellPadding = UDim2.new(0.01, 0, 0, 10),
					CellSize = UDim2.new(0.31, 0, 0, 50),

					ScrollingFrame = {
						Position = UDim2.fromScale(0, 0.05),
						Size = UDim2.fromScale(1, 0.95),
					},
				}, perks),
			})
		end,
	})
end

return RoactRodux.connect(function(state)
	return {
		itemsCollected = state.itemsCollected,
	}
end)(CollectionLogPerks)
