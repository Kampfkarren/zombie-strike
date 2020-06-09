local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local App = require(ReplicatedStorage.Core.UI.Components.App)
local GradientButton = require(ReplicatedStorage.Core.UI.Components.GradientButton)
local HoverStack = require(ReplicatedStorage.Core.UI.Components.HoverStack)
local LootStyles = require(ReplicatedStorage.Core.LootStyles)
local Memoize = require(ReplicatedStorage.Core.Memoize)
local PerfectTextLabel = require(ReplicatedStorage.Core.UI.Components.PerfectTextLabel)
local PerkUtil = require(ReplicatedStorage.Core.Perks.PerkUtil)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local Tooltip = require(ReplicatedStorage.Core.UI.Components.Tooltip)
local t = require(ReplicatedStorage.Vendor.t)

local ImagePanel2 = require(ReplicatedStorage.Assets.Tarmac.UI.panel2)
local ImageStar = require(ReplicatedStorage.Assets.Tarmac.UI.star)

local e = Roact.createElement

local Perks = Roact.Component:extend("Perks")

Perks.validateProps = t.interface({
	RightAligned = t.optional(t.boolean),
	Perks = t.table,
	Seed = t.number,
})

function Perks:init()
	self.openPerkDetails = Memoize(function(openPerkDetails)
		return function()
			openPerkDetails(self.props.Perks, self.props.Seed)
		end
	end)
end

function Perks:render()
	local props = self.props

	return e(App.Context.Consumer, {
		render = function(value)
			return e(HoverStack, {
				Render = function(hovered, hover, unhover)
					local children = {
						UIListLayout = e("UIListLayout", {
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = props.RightAligned and Enum.HorizontalAlignment.Right,
							Padding = UDim.new(0, 8),
							SortOrder = Enum.SortOrder.LayoutOrder,
						}),
					}

					for index, perk in ipairs(props.Perks) do
						local perkNameSize = TextService:GetTextSize(
							perk.Perk.Name,
							22,
							Enum.Font.GothamBold,
							Vector2.new(250, 2^50)
						) + Vector2.new(2, 2)

						local perkDescription = PerkUtil.GetPerkDescription(
							perk.Perk,
							props.Seed,
							perk.Upgrades
						)

						local perkDescriptionSize = TextService:GetTextSize(
							perkDescription,
							22,
							Enum.Font.Gotham,
							Vector2.new(250, 2^50)
						) + Vector2.new(5, 5)

						local perkColor = perk.Perk.LegendaryPerk
							and Color3.fromRGB(219, 144, 83)
							or Color3.new(0.5, 0.5, 0.5)

						local h, s, v = Color3.toHSV(perkColor)
						local hoveredColor = Color3.fromHSV(h, s, v / 2.5)

						local perkElement = e(GradientButton, {
							BackgroundTransparency = 1,
							Image = ImagePanel2,
							LayoutOrder = index,
							ScaleType = Enum.ScaleType.Slice,
							SliceCenter = Rect.new(13, 10, 369, 82),
							Size = UDim2.fromOffset(props.Size, props.Size),

							MinGradient = perkColor,
							MaxGradient = perkColor,
							HoveredMaxGradient = hoveredColor,

							[Roact.Event.Activated] = self.openPerkDetails(value.openPerkDetails),
							[Roact.Event.MouseEnter] = hover(index),
							[Roact.Event.MouseLeave] = unhover(index),
						}, {
							Icon = e("ImageLabel", {
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundTransparency = 1,
								Image = perk.Perk.Icon,
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.new(1, -8, 1, -8),
							}, {
								Tooltip = e(Tooltip, {
									Size = UDim2.fromOffset(
										math.max(perkDescriptionSize.X, perkNameSize.X + (22 * perk.Upgrades)) + 10,
										perkDescriptionSize.Y + perkNameSize.Y + 30
									),
									Open = hovered == index,
									Render = function(transparency)
										local stars = {}
										for index = 1, perk.Upgrades do
											stars["Star" .. index] = e("ImageLabel", {
												BackgroundTransparency = 1,
												Image = ImageStar,
												ImageColor3 = Color3.new(1, 1, 0.4),
												ImageTransparency = transparency,
												Size = UDim2.fromOffset(22, 22),
											})
										end

										return {
											PerkName = e("Frame", {
												BackgroundTransparency = 1,
												Position = UDim2.fromOffset(0, 16),
												Size = UDim2.new(1, 0, 0, perkNameSize.Y),
											}, {
												UIListLayout = e("UIListLayout", {
													FillDirection = Enum.FillDirection.Horizontal,
													HorizontalAlignment = Enum.HorizontalAlignment.Center,
													SortOrder = Enum.SortOrder.LayoutOrder,
												}),

												Name = e(PerfectTextLabel, {
													BackgroundTransparency = 1,
													Font = Enum.Font.GothamBold,
													LayoutOrder = -1,
													Position = UDim2.fromOffset(0, 16),
													Size = UDim2.new(0, perkNameSize.X, 1, 0),
													Text = perk.Perk.Name,
													TextColor3 = Color3.new(1, 1, 1),
													TextSize = 22,
													TextTransparency = transparency,
												}),

												Stars = Roact.createFragment(stars),
											}),

											PerkDescription = e("TextLabel", {
												AnchorPoint = Vector2.new(0, 1),
												BackgroundTransparency = 1,
												Font = Enum.Font.Gotham,
												Position = UDim2.new(0, 0, 1, -5),
												Size = UDim2.new(1, 0, 0, perkDescriptionSize.Y),
												Text = perkDescription,
												TextColor3 = Color3.new(1, 1, 1),
												TextScaled = true,
												TextSize = 22,
												TextTransparency = transparency,
											}),
										}
									end,
								}),
							}),
						})

						children["Perk" .. index] = perkElement
					end

					return e("Frame", {
						BackgroundTransparency = 1,
						Position = props.Position,
						Size = UDim2.new(
							1, -props.Position.X.Offset + (props.RightMargin or 0),
							0, props.Size
						),
						ZIndex = props.ZIndex,
					}, children)
				end,
			})
		end,
	})
end

return Perks
