local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local BackButton = require(ReplicatedStorage.Core.UI.Components.BackButton)
local EventConnection = require(ReplicatedStorage.Core.UI.Components.EventConnection)
local Fireworks = require(ReplicatedStorage.Core.UI.Components.Fireworks)
local FocusContent = require(ReplicatedStorage.Core.UI.Components.FocusContent)
local GlowAura = require(ReplicatedStorage.Core.UI.Components.GlowAura)
local GradientButton = require(ReplicatedStorage.Core.UI.Components.GradientButton)
local InventorySpace = require(ReplicatedStorage.Core.InventorySpace)
local ItemDetails = require(ReplicatedStorage.Core.UI.Components.ItemDetails)
local Loot = require(ReplicatedStorage.Core.Loot)
local LootStyles = require(ReplicatedStorage.Core.LootStyles)
local PerfectTextLabel = require(ReplicatedStorage.Core.UI.Components.PerfectTextLabel)
local PerkDetails = require(ReplicatedStorage.Core.UI.Components.PerkDetails)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local Scale = require(ReplicatedStorage.Core.UI.Components.Scale)
local Tagged = require(ReplicatedStorage.Core.UI.Components.Tagged)

local ImageFloat = require(ReplicatedStorage.Assets.Tarmac.UI.float)
local ImageVoucher = require(ReplicatedStorage.Assets.Tarmac.UI.voucher)
local ImageVoucherBox = require(ReplicatedStorage.Assets.Tarmac.UI.voucher_box)

local VoucherOpen = SoundService.SFX.VoucherOpen
local VoucherOpened = SoundService.SFX.VoucherOpened

local e = Roact.createElement
local LocalPlayer = Players.LocalPlayer

local Vouchers = Roact.Component:extend("Vouchers")

local ANIMATION_SETUP_TIME = 0.2
local ANIMATION_SHOW_COOL_BUTTON_DELAY = 0.3
local ANIMATION_SHOW_COOL_BUTTON_TIME = 1
local ANIMATION_SHOW_ITEM_DELAY = 0.3
local ANIMATION_SHOW_ITEM_TIME = 0.2
local ANIMATION_VOUCHER_GO_IN_DELAY = 0.5
local ANIMATION_VOUCHER_GO_IN_TIME = 0.3
local MAIN_EXPLODE_SIZE = Vector2.new(1243, 900)

local fadeOutVoucherOpen = TweenService:Create(
	VoucherOpen,
	TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	{ Volume = 0 }
)

local function lerp(a, b, t)
	return a + (b - a) * t
end

function Vouchers:init()
	self.counter, self.setCounter = Roact.createBinding(0)

	self:setState({
		receivedAt = 0,
	})

	self.startRedeem = function()
		local redeemPromise = self.props.redeem()

		redeemPromise:andThen(function(item)
			self:setState({
				item = item,
				receivedAt = tick(),
			})
		end)

		VoucherOpen:Play()

		self:setState({
			redeeming = true,
		})
	end

	self.activateRedeem = function()
		if not self.state.redeeming then
			self.startRedeem()
		end
	end

	local celebrated = false

	self.hideItem = function()
		celebrated = false

		self:setState({
			item = Roact.None,
			redeeming = false,
			showFireworks = false,
		})

		self.setCounter(0)

		VoucherOpen:Stop()
		VoucherOpen.Volume = 1
	end

	self.tick = function(delta)
		if self.state.redeeming then
			local counter = self.counter:getValue() + delta
			self.setCounter(counter)

			if not celebrated then
				local timeUntilShow = ANIMATION_SETUP_TIME
					+ ANIMATION_VOUCHER_GO_IN_DELAY
					+ ANIMATION_VOUCHER_GO_IN_TIME
					+ ANIMATION_SHOW_ITEM_DELAY

				if counter >= timeUntilShow then
					celebrated = true
					self:setState({
						showFireworks = true,
					})
					fadeOutVoucherOpen:Play()
					VoucherOpened:Play()
				end
			end
		end
	end

	self:CheckInventorySpace()
end

function Vouchers:CheckInventorySpace()
	InventorySpace(LocalPlayer):andThen(function(space)
		self:setState({
			inventoryFull = #self.props.inventory >= space
		})
	end)
end

function Vouchers:didUpdate(oldProps)
	if #self.props.inventory ~= #oldProps.inventory then
		self:CheckInventorySpace()
	end
end

function Vouchers:render()
	if not self.props.visible and not self.state.redeeming then
		return nil
	end

	local counter = self.counter
	local showItemDetails = counter:map(function()
		local timeUntilExplode = ANIMATION_SETUP_TIME
			+ ANIMATION_VOUCHER_GO_IN_DELAY
			+ ANIMATION_VOUCHER_GO_IN_TIME
			+ ANIMATION_SHOW_ITEM_DELAY
			+ 0.05 -- Bit of leeway so that it doesn't show before it's ready

		return tick() - (self.state.receivedAt or tick()) >= timeUntilExplode
	end)

	local canRedeem = self.props.vouchers > 0 and not self.state.inventoryFull

	return e(FocusContent, {
		BackgroundColor = Color3.new(1, 0.6, 1),
	}, {
		HideCrosshair = e(Tagged, {
			Tag = "HideCrosshair",
		}, {
			Full = e("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				ClipsDescendants = true,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(1920, 1080),
			}, {
				Scale = e(Scale, {
					Size = Vector2.new(1920, 1080),
				}),

				Item = self.state.item and e("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = counter:map(function(counter)
						local timeUntilExplode = ANIMATION_SETUP_TIME
							+ ANIMATION_VOUCHER_GO_IN_DELAY
							+ ANIMATION_VOUCHER_GO_IN_TIME
							+ ANIMATION_SHOW_ITEM_DELAY

						if counter >= timeUntilExplode then
							local t = TweenService:GetValue(
								(tick() - self.state.receivedAt - timeUntilExplode)
									/ ANIMATION_SHOW_ITEM_TIME,
								Enum.EasingStyle.Quint,
								Enum.EasingDirection.Out
							)

							return UDim2.fromOffset(
								t * MAIN_EXPLODE_SIZE.X,
								t * MAIN_EXPLODE_SIZE.Y
							)
						else
							return UDim2.fromOffset(0, 0)
						end
					end),
				}, {
					GlowAura = e("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.5, 0.5),
						Rotation = counter:map(function(counter)
							return counter * 8
						end),
						Size = UDim2.fromScale(1, 1),
						ZIndex = 0,
					}, {
						GlowAura = e(GlowAura, {
							Color = LootStyles[self.state.item.Rarity].Color,
						}),

						Fireworks = self.state.showFireworks and e(Fireworks, {
							ParticleColor = LootStyles[self.state.item.Rarity].Color,
						}),

						UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
					}),

					ItemDetails = e("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0.7, 1),
						Visible = showItemDetails,
					}, {
						e(ItemDetails, {
							CompareTo = self.state.item,
							Item = self.state.item,
							GetName = Loot.GetLootName,
							ShowGearScore = true,
						}),
					}),

					PerkDetails = e(PerkDetails, {
						Perks = self.state.item.Perks,
						Seed = self.state.item.Seed,

						RenderParent = function(element, size)
							return e("Frame", {
								AnchorPoint = Vector2.new(1, 1),
								BackgroundTransparency = 1,
								Position = UDim2.new(0.8, 0, 1, -75),
								Size = UDim2.new(size.X, UDim.new(1, 0)),
								Visible = showItemDetails,
							}, {
								Bottom = e("Frame", {
									AnchorPoint = Vector2.new(0, 1),
									BackgroundTransparency = 1,
									Position = UDim2.new(1, -100, 1, 0),
									Size = size,
								}, {
									PerkDetails = element,

									UIScale = e("UIScale", {
										Scale = 1.4,
									}),
								}),
							})
						end,
					}),
				}),

				Notice = e("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundTransparency = 1,
					Font = Enum.Font.Gotham,
					Position = UDim2.fromScale(0.5, 0),
					Size = UDim2.new(1, 0, 0, 56),
					Text = self.props.vouchers == 0
						and "You don't have any vouchers!\nEnter codes from our social media for some."
						or (self.state.inventoryFull and "Your inventory is full! Sell something so you can redeem vouchers." or ""),
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 56,
					TextStrokeTransparency = 0.2,
					TextYAlignment = Enum.TextYAlignment.Top,
					Visible = not self.state.redeeming,
				}),

				ImageVoucherBox = e("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = ImageVoucherBox,
					Position = UDim2.fromOffset(960, 491),
					Size = counter:map(function(counter)
						local timeUntilExplode = ANIMATION_SETUP_TIME
							+ ANIMATION_VOUCHER_GO_IN_DELAY
							+ ANIMATION_VOUCHER_GO_IN_TIME
							+ ANIMATION_SHOW_ITEM_DELAY

						if self.state.item ~= nil and counter >= timeUntilExplode then
							local t = TweenService:GetValue(
								(tick() - self.state.receivedAt - timeUntilExplode)
									/ ANIMATION_SHOW_ITEM_TIME,
								Enum.EasingStyle.Quint,
								Enum.EasingDirection.Out
							)

							return UDim2.fromOffset(
								lerp(MAIN_EXPLODE_SIZE.X, 0, t),
								lerp(MAIN_EXPLODE_SIZE.Y, 0, t)
							)
						end

						local t = TweenService:GetValue(
							counter / ANIMATION_SETUP_TIME,
							Enum.EasingStyle.Quint,
							Enum.EasingDirection.Out
						)

						return UDim2.fromOffset(
							lerp(835, MAIN_EXPLODE_SIZE.X, t),
							lerp(604, MAIN_EXPLODE_SIZE.Y, t)
						)
					end),
				}),

				Voucher = e("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(918, 785),
					Size = UDim2.fromOffset(288, 73),
				}, {
					ImageVoucher = e("ImageLabel", {
						BackgroundTransparency = 1,
						Image = ImageVoucher,
						Position = counter:map(function(counter)
							local t = TweenService:GetValue(
								counter / ANIMATION_SETUP_TIME,
								Enum.EasingStyle.Quint,
								Enum.EasingDirection.Out
							)

							local goInOffset = 0
							local timeUntilGoIn = ANIMATION_SETUP_TIME + ANIMATION_VOUCHER_GO_IN_DELAY

							if counter >= timeUntilGoIn + ANIMATION_VOUCHER_GO_IN_TIME then
								return UDim2.fromOffset(0, 340)
							elseif counter >= timeUntilGoIn then
								goInOffset = TweenService:GetValue(
									(counter - timeUntilGoIn) / ANIMATION_VOUCHER_GO_IN_TIME,
									Enum.EasingStyle.Quint,
									Enum.EasingDirection.Out
								) * -280
							end

							return UDim2.fromOffset(
								lerp(0, 800, t) + goInOffset,
								lerp(0, -380, t)
							)
						end),
						ScaleType = Enum.ScaleType.Fit,
						Size = counter:map(function(counter)
							local scale = lerp(1, 1.38, TweenService:GetValue(
								counter / ANIMATION_SETUP_TIME,
								Enum.EasingStyle.Quint,
								Enum.EasingDirection.Out
							))

							return UDim2.fromOffset(223 * scale, 73 * scale)
						end),
					}),

					VoucherCount = e("TextLabel", {
						BackgroundTransparency = 1,
						Font = Enum.Font.GothamSemibold,
						Position = counter:map(function(counter)
							return UDim2.fromOffset(
								223,
								lerp(
									0, 320,
									TweenService:GetValue(
										counter / ANIMATION_SETUP_TIME,
										Enum.EasingStyle.Quint,
										Enum.EasingDirection.Out
									)
								)
							)
						end),
						Size = UDim2.fromOffset(82, 73),
						Text = self.props.vouchers .. "x",
						TextColor3 = Color3.new(1, 1, 1),
						TextStrokeTransparency = 0.2,
						TextSize = 60,
						TextXAlignment = Enum.TextXAlignment.Left,
					}),
				}),

				BackButton = canRedeem and e(BackButton, {
					GoBack = self.props.close,
					Position = counter:map(function(counter)
						return UDim2.new(
							0, lerp(
								0, -188,
								TweenService:GetValue(
									counter / ANIMATION_SETUP_TIME,
									Enum.EasingStyle.Quint,
									Enum.EasingDirection.Out
								)
							),
							1, lerp(
								-15, 55,
								TweenService:GetValue(
									counter / ANIMATION_SETUP_TIME,
									Enum.EasingStyle.Quint,
									Enum.EasingDirection.Out
								)
							)
						)
					end),
				}),

				CoolButton = self.state.item and e(PerfectTextLabel, {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Font = Enum.Font.GothamSemibold,
					Position = UDim2.fromScale(0.5, 0.5),
					Text = "Cool!",
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 80,

					RenderParent = function(element, size)
						return e(GradientButton, {
							AnchorPoint = Vector2.new(0.5, 1),
							BackgroundColor3 = Color3.new(1, 1, 1),
							BackgroundTransparency = 1,
							Image = ImageFloat,
							Position = counter:map(function(counter)
								local timeUntilShow = ANIMATION_SETUP_TIME
									+ ANIMATION_VOUCHER_GO_IN_DELAY
									+ ANIMATION_VOUCHER_GO_IN_TIME
									+ ANIMATION_SHOW_ITEM_DELAY
									+ ANIMATION_SHOW_ITEM_TIME
									+ ANIMATION_SHOW_COOL_BUTTON_DELAY

								if counter >= timeUntilShow then
									local t = TweenService:GetValue(
										(tick() - self.state.receivedAt - timeUntilShow)
											/ ANIMATION_SHOW_COOL_BUTTON_TIME,
										Enum.EasingStyle.Quint,
										Enum.EasingDirection.Out
									)

									return UDim2.new(
										0.5, 0,
										1, lerp(
											111, -20,
											TweenService:GetValue(
												t,
												Enum.EasingStyle.Quint,
												Enum.EasingDirection.Out
											)
										)
									)
								end
							end),
							ScaleType = Enum.ScaleType.Slice,
							SliceCenter = Rect.new(6, 4, 86, 20),
							Size = UDim2.fromOffset(math.max(size.X.Offset + 30, 300), 110),

							AnimateSpeed = 14,
							MinGradient = Color3.fromRGB(49, 152, 48),
							MaxGradient = Color3.fromRGB(88, 169, 86),
							HoveredMaxGradient = Color3.fromRGB(120, 238, 118),

							[Roact.Event.Activated] = self.hideItem,
						}, {
							Label = element,
						})
					end,
				}),

				RedeemButton = e(PerfectTextLabel, {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Font = Enum.Font.GothamSemibold,
					Position = UDim2.fromScale(0.5, 0.5),
					Text = canRedeem and "Redeem" or "Back",
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 80,

					RenderParent = function(element, size)
						return e(GradientButton, {
							AnchorPoint = Vector2.new(0.5, 1),
							BackgroundColor3 = Color3.new(1, 1, 1),
							BackgroundTransparency = 1,
							Image = ImageFloat,
							Position = counter:map(function(counter)
								return UDim2.new(
									0.5, 0,
									1, lerp(
										-102, 111,
										TweenService:GetValue(
											counter / ANIMATION_SETUP_TIME,
											Enum.EasingStyle.Quint,
											Enum.EasingDirection.Out
										)
									)
								)
							end),
							ScaleType = Enum.ScaleType.Slice,
							SliceCenter = Rect.new(6, 4, 86, 20),
							Size = UDim2.fromOffset(math.max(size.X.Offset + 30, 457), 110),

							AnimateSpeed = 14,
							MinGradient = canRedeem
								and Color3.fromRGB(49, 152, 48)
								or Color3.fromRGB(201, 51, 37),
							MaxGradient = canRedeem
								and Color3.fromRGB(88, 169, 86)
								or Color3.fromRGB(175, 38, 25),
							HoveredMaxGradient = canRedeem
								and Color3.fromRGB(120, 238, 118)
								or Color3.fromRGB(197, 44, 30),

							[Roact.Event.Activated] = canRedeem
								and self.activateRedeem
								or self.props.close,
						}, {
							Label = element,
						})
					end,
				}),

				UpdateCounter = e(EventConnection, {
					callback = self.tick,
					event = RunService.Heartbeat,
				}),
			}),
		}),
	})
end

return RoactRodux.connect(function(state)
	return {
		inventory = state.inventory or {},
		visible = state.page.current == "Vouchers",
		vouchers = state.vouchers,
	}
end, function(dispatch)
	return {
		close = function()
			dispatch({
				type = "CloseVouchers",
			})
		end,
	}
end)(Vouchers)
