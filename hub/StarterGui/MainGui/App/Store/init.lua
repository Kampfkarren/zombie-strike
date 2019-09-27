local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Close = require(script.Parent.Close)
local Cosmetics = require(ReplicatedStorage.Cosmetics)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local StoreCard = require(script.StoreCard)

local e = Roact.createElement
local Store = Roact.PureComponent:extend("Store")

local SECONDS_IN_DAY = 24 * 60 * 60

local function timer()
	local date = os.date("!*t", os.time() + SECONDS_IN_DAY)

	return os.time({
		year = date.year,
		month = date.month,
		day = date.day,
		hour = 0,
		minute = 0,
		sec = 0,
	}) - os.time()
end

function Store:init()
	self:setState({
		timer = timer(),
	})
end

function Store:didMount()
	self.running = true

	coroutine.wrap(function()
		while self.running do
			wait(1)
			self:setState(function(state)
				return {
					timer = state.timer - 1,
				}
			end)
		end
	end)()
end

function Store:willUnmount()
	self.running = false
end

function Store:render()
	return e("Frame", {
		Active = true,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(232, 67, 147),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Visible = self.props.open,
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
			onClose = self.props.close,
		}),

		Contents = e("Frame", {
			BackgroundTransparency = 1,
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
			}),

			Shop = e("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 0,
				Size = UDim2.new(1, 0, 1, 0),
			}, {
				Contents = e("Frame", {
					AnchorPoint = Vector2.new(0.5, 1),
					BackgroundTransparency = 1,
					Position = UDim2.new(0.5, 0, 0.985, 0),
					Size = UDim2.new(0.95, 0, 0.9, 0),
				}, {
					UIListLayout = e("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0.01, 0),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),

					Little = e("Frame", {
						BackgroundTransparency = 1,
						LayoutOrder = 3,
						Size = UDim2.new(0.38, 0, 1, 0),
					}, {
						e("UIGridLayout", {
							CellPadding = UDim2.new(0.02, 0, 0.01, 0),
							CellSize = UDim2.new(0.48, 0, 0.495, 0),
							FillDirection = Enum.FillDirection.Horizontal,
							FillDirectionMaxCells = 2,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
							VerticalAlignment = Enum.VerticalAlignment.Center,
						}),

						Face1 = e(StoreCard, {
							ItemIndex = 1,
							ItemType = "Face",

							LayoutOrder = 3,
							Price = 49,
						}),
					}),

					Low = e("Frame", {
						BackgroundTransparency = 1,
						LayoutOrder = 2,
						Size = UDim2.new(0.3, 0, 1, 0),
					}, {
						e("UIListLayout", {
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							Padding = UDim.new(0.01, 0),
							SortOrder = Enum.SortOrder.LayoutOrder,
							VerticalAlignment = Enum.VerticalAlignment.Center,
						}),

						LowTier1 = e(StoreCard, {
							ItemIndex = 1,
							ItemType = "LowTier",
							Size = UDim2.new(1, 0, 0.5, 0),

							LayoutOrder = 1,
							Price = 1,
						}),
					}),

					High = e(StoreCard, {
						ItemIndex = 1,
						ItemType = "HighTier",
						Size = UDim2.new(0.3, 0, 1, 0),

						Price = 1,
					}),
				}),

				Timer = e("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBlack,
					Position = UDim2.new(0.025, 0, 0.01, 0),
					Size = UDim2.new(0.4, 0, 0.07, 0),
					Text = ("%02d:%02d:%02d"):format(
						math.floor(self.state.timer / 3600),
						math.floor(self.state.timer / 60) % 60,
						self.state.timer % 60
					),
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					TextStrokeTransparency = 0,
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
			}),
		}),
	})
end

return RoactRodux.connect(
	function(state)
		return state.store
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
