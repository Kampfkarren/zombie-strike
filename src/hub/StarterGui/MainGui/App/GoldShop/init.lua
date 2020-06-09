local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Closed = require(script.Pages.Closed)
local FocusContent = require(ReplicatedStorage.Core.UI.Components.FocusContent)
local GoldShopItemsUtil = require(ReplicatedStorage.Libraries.GoldShopItemsUtil)
local Interval = require(ReplicatedStorage.Core.Interval)
local Memoize = require(ReplicatedStorage.Core.Memoize)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local Scale = require(ReplicatedStorage.Core.UI.Components.Scale)
local Tagged = require(ReplicatedStorage.Core.UI.Components.Tagged)
local Topbar = require(script.Topbar)
local Weapons = require(script.Pages.Weapons)

local e = Roact.createElement

local GoldShop = Roact.Component:extend("GoldShop")

local CLOSING_TIMES = 10

function GoldShop:init()
	self:setState({
		page = "Weapons",
	})

	self.setPage = Memoize(function(page)
		return function()
			self:setState({
				page = page,
			})
		end
	end)

	self.cancelCountdown = Interval(1, function()
		self:CheckClosingTimes()
	end)

	self:CheckClosingTimes()
end

function GoldShop:CheckClosingTimes()
	local timeLeft = GoldShopItemsUtil.ROTATE_EVERY_SECONDS - (os.time() % GoldShopItemsUtil.ROTATE_EVERY_SECONDS)

	if timeLeft <= CLOSING_TIMES then
		self:setState({
			closedAtTimestamp = self.props.timestamp,
			closing = true,
		})
	end
end

function GoldShop:didUpdate()
	if self.state.closing and self.props.timestamp ~= self.state.closedAtTimestamp then
		self:setState({
			closing = false,
			closedAtTimestamp = Roact.None,
		})
	end
end

function GoldShop:shouldUpdate(newProps)
	if self.state.closing then
		return newProps.timestamp ~= self.state.closedAtTimestamp
	end

	return true
end

function GoldShop:willUnmount()
	self.cancelCountdown()
end

function GoldShop:render()
	if not self.props.visible then
		return nil
	end

	local pageElement

	if self.state.page == "Weapons" then
		pageElement = e(Weapons)
	end

	return e(FocusContent, {
		BackgroundColor = Color3.fromRGB(255, 66, 66),
	}, {
		HideCrosshair = e(Tagged, {
			Tag = "HideCrosshair",
		}, {
			Full = e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}, {
				Contents = e("Frame", {
					AnchorPoint = Vector2.new(0.5, 1),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.95),
					Size = UDim2.fromOffset(1575, 1030),
				}, {
					Scale = e(Scale, {
						Scale = 0.8,
						Size = Vector2.new(1575, 1030),
					}),

					Inner = e("Frame", {
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 1),
					}, self.state.closing and {
						Closed = e(Closed),
					} or {
						Topbar = e("Frame", {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 65),
						}, {
							e(Topbar, {
								ClosingTimes = CLOSING_TIMES,
								CurrentPage = self.state.page,
								SelectPage = self.setPage,
								Timestamp = self.props.timestamp,
							}),
						}),

						Page = pageElement,
					}),
				}),
			}),
		})
	})
end

return RoactRodux.connect(function(state)
	return {
		timestamp = state.goldShop.timestamp,
		visible = state.page.current == "GoldShop",
	}
end)(GoldShop)
