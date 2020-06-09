local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GoldCount = require(ReplicatedStorage.Core.UI.Components.GoldCount)
local GoldShopItemsUtil = require(ReplicatedStorage.Libraries.GoldShopItemsUtil)
local GradientButton = require(ReplicatedStorage.Core.UI.Components.GradientButton)
local Interval = require(ReplicatedStorage.Core.Interval)
local PerfectTextLabel = require(ReplicatedStorage.Core.UI.Components.PerfectTextLabel)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local ImagePanel2 = require(ReplicatedStorage.Assets.Tarmac.UI.panel2)

local GOLD_FONT_SIZE = 45

local TAB_SIZE = UDim2.new(0, 205, 1, 0)

local SELECTED_BORDER = 5

local Timer = Roact.Component:extend("Timer")

function Timer:init()
	self.cancelCountdown = Interval(1, function()
		self:SetTimeLeft()
	end)

	self:SetTimeLeft()
end

function Timer:SetTimeLeft()
	self:setState({
		timeLeft = math.max(0, GoldShopItemsUtil.ROTATE_EVERY_SECONDS
			- (os.time() % GoldShopItemsUtil.ROTATE_EVERY_SECONDS)
			- self.props.ClosingTimes)
	})
end

function Timer:willUnmount()
	self.cancelCountdown()
end

function Timer:render()
	return e(PerfectTextLabel, {
		Font = Enum.Font.Gotham,
		Text = ("%02d:%02d:%02d"):format(
			math.floor(self.state.timeLeft / 3600),
			math.floor(self.state.timeLeft / 60) % 60,
			self.state.timeLeft % 60
		),
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = GOLD_FONT_SIZE,

		ForceY = UDim.new(1, 0),
	}, {
		e("TextLabel", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Size = UDim2.fromScale(1, 1),
			Text = "Refreshing in...",
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 35,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextYAlignment = Enum.TextYAlignment.Bottom,
		}),
	})
end

local function Tab(props)
	local selected = props.CurrentPage == props.Page
	local buttonSize = selected and
		TAB_SIZE - UDim2.fromOffset(SELECTED_BORDER * 2, SELECTED_BORDER * 2)
		or TAB_SIZE

	local button = e(GradientButton, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = ImagePanel2,
		LayoutOrder = props.LayoutOrder,
		Position = UDim2.fromScale(0.5, 0.5),
		ScaleType = Enum.ScaleType.Slice,
		Size = buttonSize,
		SliceCenter = Rect.new(13, 10, 369, 82),

		MaxGradient = Color3.fromRGB(122, 122, 122),
		MinGradient = Color3.fromRGB(122, 122, 122),

		HoveredMaxGradient = Color3.fromRGB(90, 90, 90),

		[Roact.Event.Activated] = props.SelectPage(props.Page),
	}, {
		Text = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Size = UDim2.fromScale(1, 1),
			Text = props.Page,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 33,
		}),
	})

	if props.CurrentPage == props.Page then
		local outline = e("ImageLabel", {
			BackgroundTransparency = 1,
			Image = ImagePanel2,
			ImageColor3 = Color3.fromRGB(48, 147, 251),
			LayoutOrder = props.LayoutOrder,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(13, 10, 369, 82),
			Size = TAB_SIZE,
		}, {
			Button = button,
		})

		return outline
	else
		return button
	end
end

local function Topbar(props)
	return e("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.fromScale(1, 1),
	}, {
		Tabs = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		}, {
			UIListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 14),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			Weapons = e(Tab, {
				CurrentPage = props.CurrentPage,
				LayoutOrder = 1,
				Page = "Weapons",
				SelectPage = props.SelectPage,
			}),

			-- Paints = e(Tab, {
			-- 	CurrentPage = props.CurrentPage,
			-- 	LayoutOrder = 2,
			-- 	Page = "Paints",
			-- 	SelectPage = props.SelectPage,
			-- }),
		}),

		Info = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		}, {
			UIListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				Padding = UDim.new(0, 14),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			GoldCount = e(GoldCount),

			Timer = e(Timer, {
				ClosingTimes = props.ClosingTimes,
				Timestamp = props.Timestamp,
			}),
		}),
	})
end

return Topbar
