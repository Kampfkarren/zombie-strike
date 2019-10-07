local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assign = require(ReplicatedStorage.Core.assign)
local Close = require(script.Parent.Close)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local Shop = require(script.Shop)
local XPMultipliers = require(script.XPMultipliers)

local e = Roact.createElement

local function CategoryButton(props)
	return e("ImageButton", {
		BackgroundColor3 = props.opened and Color3.fromRGB(143, 80, 110) or Color3.fromRGB(231, 133, 181),
		BorderSizePixel = 0,
		Image = "",
		LayoutOrder = props.LayoutOrder,
		Size = props.Size,
		[Roact.Event.Activated] = function()
			props.open(props.Page)
		end,
	}, {
		Label = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0.95, 0, 0.95, 0),
			Text = props.Text,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
		}),
	})
end

local CategoryButton = RoactRodux.connect(function(state, props)
	return {
		opened = state.store.page == props.Page
	}
end, function(dispatch)
	return {
		open = function(page)
			dispatch({
				type = "SetStorePage",
				page = page,
			})
		end,
	}
end)(CategoryButton)

local Store = Roact.PureComponent:extend("Store")

function Store:init()
	self.shopRef = Roact.createRef()
	self.xpMultiplierRef = Roact.createRef()

	self.pageLayoutRef = Roact.createRef()
end

function Store:UpdateCurrentPage()
	local page = self.pageLayoutRef:getValue()

	if self.props.page == "Shop" then
		page:JumpTo(self.shopRef:getValue())
	elseif self.props.page == "XP" then
		page:JumpTo(self.xpMultiplierRef:getValue())
	end
end

function Store:didMount()
	self:UpdateCurrentPage()
end

function Store:didUpdate()
	self:UpdateCurrentPage()
end

function Store:render()
	local props = self.props

	return e("Frame", {
		Active = true,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(232, 67, 147),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Visible = props.open,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.6, 0, 0.7, 0),
		ZIndex = 3,
	}, {
		e("UIAspectRatioConstraint", {
			AspectRatio = 2,
			AspectType = Enum.AspectType.ScaleWithParentSize,
			DominantAxis = Enum.DominantAxis.Height,
		}),

		Close = e(Close, {
			onClose = props.close,
		}),

		Buttons = e("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.02, 0, 0, 0),
			Size = UDim2.new(0.95, 0, 0.1, 0),
		}, {
			e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0.01, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			ShopButton = e(CategoryButton, {
				Page = "Shop",
				Text = "SHOP",
				Size = UDim2.new(0.15, 0, 1, 0),
				LayoutOrder = 1,
			}),

			XPButton = e(CategoryButton, {
				Page = "XP",
				Text = "DOUBLE XP",
				Size = UDim2.new(0.25, 0, 1, 0),
				LayoutOrder = 2,
			}),
		}),

		Contents = e("Frame", {
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 0,
		}, {
			e("UIPageLayout", {
				Animated = true,
				Circular = true,
				EasingDirection = Enum.EasingDirection.Out,
				EasingStyle = Enum.EasingStyle.Quint,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				TweenTime = 0.5,
				VerticalAlignment = Enum.VerticalAlignment.Center,

				GamepadInputEnabled = false,
				ScrollWheelInputEnabled = false,
				TouchInputEnabled = false,

				[Roact.Ref] = self.pageLayoutRef,
			}),

			Shop = e(Shop, {
				[Roact.Ref] = self.shopRef,
			}),

			XPMultipliers = e(XPMultipliers, {
				[Roact.Ref] = self.xpMultiplierRef,
			}),
		}),
	})
end

return RoactRodux.connect(
	function(state)
		return assign({
			open = state.page.current == "Store"
		}, state.store)
	end,

	function(dispatch)
		return {
			close = function()
				dispatch({
					type = "ToggleStore",
				})
			end,
		}
	end
)(Store)
