local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

local App = require(ReplicatedStorage.Core.UI.Components.App)
local assign = require(ReplicatedStorage.Core.assign)
local Counter = require(ReplicatedStorage.Core.UI.Components.Counter)
local DungeonTiming = require(ReplicatedStorage.Libraries.DungeonTiming)
local EnglishNumbers = require(ReplicatedStorage.Core.EnglishNumbers)
local EventConnection = require(ReplicatedStorage.Core.UI.Components.EventConnection)
local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)
local Fireworks = require(ReplicatedStorage.Core.UI.Components.Fireworks)
local GradientButton = require(ReplicatedStorage.Core.UI.Components.GradientButton)
local HoverStack = require(ReplicatedStorage.Core.UI.Components.HoverStack)
local Interval = require(ReplicatedStorage.Core.Interval)
local ItemDetails = require(ReplicatedStorage.Core.UI.Components.ItemDetails)
local ItemPreview = require(ReplicatedStorage.Core.UI.Components.ItemPreview)
local Loot = require(ReplicatedStorage.Core.Loot)
local LootStyles = require(ReplicatedStorage.Core.LootStyles)
local Memoize = require(ReplicatedStorage.Core.Memoize)
local PlaceIds = require(ReplicatedStorage.Core.PlaceIds)
local PerfectTextLabel = require(ReplicatedStorage.Core.UI.Components.PerfectTextLabel)
local RealDelay = require(ReplicatedStorage.Core.RealDelay)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local Scale = require(ReplicatedStorage.Core.UI.Components.Scale)

local ImageFloat = require(ReplicatedStorage.Assets.Tarmac.UI.float)
local ImageItemButton = require(ReplicatedStorage.Assets.Tarmac.UI.item_button)

local e = Roact.createElement
local Finish = SoundService.SFX.Finish
local GoingUp = SoundService.SFX.GoingUp

local ANIMATE_GOLD_DELAY = 0.5
local ANIMATE_XP_DELAY = 1.3

local FULL_TIME_ANIMATION = 1
local FULL_TIME_GOLD = 250
local FULL_TIME_XP = 2000

local SHAKE_RANGE = 0.05
local SHAKE_TIME = 0.3

local QUESTION_MARK_ANIMATE_DELAY = 0.5
local QUESTION_MARK_ANIMATE_TIME = 0.6

local ITEM_TYPES = {
	[Loot.IsAttachment] = {
		Angle = Vector3.new(-1, 0.8, -1),
	},

	[Loot.IsArmor] = {
		Angle = Vector3.new(-1, 0.8, -1),
		EquippedItem = "equippedArmor",
		ShowGearScore = true,
	},

	[Loot.IsHelmet] = {
		Angle = Vector3.new(1, 0, 0),
		Distance = 0.8,
		EquippedItem = "equippedHelmet",
		ShowGearScore = true,
	},

	[Loot.IsWeapon] = {
		EquippedItem = "equippedWeapon",
		ShowGearScore = true,
	},
}

local function getLootType(loot)
	local itemData
	for condition, data in pairs(ITEM_TYPES) do
		if condition(loot) then
			itemData = data
			break
		end
	end

	assert(itemData ~= nil, loot.Type .. " has unknown type")
	return itemData
end

local function noop()
	return function()
	end
end

local function lerp(a, b, t)
	return a + (b - a) * t
end

local RevealButton = Roact.Component:extend("RevealButton")

function RevealButton:render()
	if self.state.revealed then
		return Roact.oneChild(self.props[Roact.Children])
	else
		return e(GradientButton, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = ImageItemButton,
			LayoutOrder = self.props.LayoutOrder,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(0, 10, 419, 149),
			Size = UDim2.fromOffset(410, 410),
			ZIndex = self.props.ZIndex,

			MinGradient = Color3.fromRGB(255, 159, 67),
			MaxGradient = Color3.fromRGB(255, 159, 67),
			HoveredMaxGradient = Color3.fromRGB(255, 123, 0),

			[Roact.Event.Activated] = function()
				self.props.Reveal()
				self:setState({
					revealed = true,
				})
			end,
		}, {
			QuestionMark = e(Counter, {
				Render = function(counter)
					return e("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Font = Enum.Font.GothamBlack,
						Position = UDim2.new(0.5, 0, 0.5, -50),
						Size = UDim2.fromScale(1, 0.5),
						Text = "?",
						TextColor3 = Color3.new(1, 1, 1),
						TextSize = 100,
					}, {
						UIScale = e("UIScale", {
							Scale = counter:map(function(counter)
								local mod = counter % (QUESTION_MARK_ANIMATE_TIME + QUESTION_MARK_ANIMATE_DELAY)
								if mod <= QUESTION_MARK_ANIMATE_DELAY then
									counter = 0
								else
									counter = ((mod - QUESTION_MARK_ANIMATE_DELAY) % QUESTION_MARK_ANIMATE_TIME)
										/ QUESTION_MARK_ANIMATE_TIME

									if counter > 0.5 then
										counter = 1 - counter
									end

									counter = counter * 2
								end

								return lerp(
									2, 2.5,
									TweenService:GetValue(
										counter,
										Enum.EasingStyle.Back,
										Enum.EasingDirection.In
									)
								)
							end),
						})
					})
				end,
			}),

			Reveal = e("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBlack,
				Position = UDim2.new(0, 0, 0.5, 75),
				Size = UDim2.new(1, 0, 0, 50),
				Text = "REVEAL",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
			}),
		})
	end
end

local function BrainsButton(props)
	return e("ImageLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = ImageItemButton,
		ImageColor3 = Color3.new(1, 1, 1),
		LayoutOrder = props.LayoutOrder,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(0, 10, 419, 149),
		Size = UDim2.fromOffset(410, 410),
		ZIndex = -10,
	}, {
		BrainsLabel = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.4),
			Size = UDim2.fromScale(0.95, 0.95),
			Text = "🧠",
			TextScaled = true,
		}),

		BrainsCount = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.new(0.5, 0, 1, -20),
			Size = UDim2.new(0.95, 0, 0, 70),
			Text = props.Brains .. " Brains",
			TextColor3 = Color3.new(1, 1, 1),
			TextStrokeTransparency = 0.2,
			TextSize = 70,
		}),

		Gradient = e("UIGradient", {
			Color = ColorSequence.new(
				Color3.fromRGB(255, 88, 233),
				Color3.fromRGB(255, 158, 242)
			),
			Rotation = 90,
		}),
	})
end

local Reward = Roact.Component:extend("Reward")

function Reward:render()
	local props = self.props

	local valueProps = {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, 62),
		Text = "0",
		TextColor3 = props.Color,
		TextSize = 62,
	}

	local value

	if props.AnimateStart then
		value = e(Counter, {
			Render = function(counter)
				valueProps.Text = counter:map(function(counter)
					local timeNeeded = math.min(
						FULL_TIME_ANIMATION,
						lerp(0, FULL_TIME_ANIMATION, props.Value / props.FullTime)
					)

					if counter >= timeNeeded
						and props.OnFinish
						and not self.state.calledFinished
					then
						self:setState({
							calledFinished = true,
						})

						props.OnFinish()
					end

					return EnglishNumbers(math.min(props.Value, lerp(0, props.Value, counter / timeNeeded)))
				end)

				return e("TextLabel", valueProps)
			end,
		})
	else
		value = e("TextLabel", valueProps)
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.new(0, 165, 1, 0),
	}, {
		Label = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			Size = UDim2.new(1, 0, 0, 36),
			Text = props.Text,
			TextColor3 = props.Color,
			TextSize = 36,
		}),

		Value = value,
	})
end

local LootResults = Roact.Component:extend("LootResults")

function LootResults:init()
	self.totalLoot = #self.props.Loot + #self.props.GamemodeLoot

	self.shakeBase, self.setShakeBase = Roact.createBinding(math.random())
	self.shakeTime, self.setShakeTime = Roact.createBinding(1)

	self:setState({
		clearTime = DungeonTiming.GetTimeSinceStarting(),
		fireworks = {},
		lootLeft = self.totalLoot,
	})

	self.animateGoldDone = function()
		FastSpawn(function()
			if not self.state.showLoot then
				GoingUp:Stop()
				Finish:Play()

				self:setState({
					showLoot = true,
				})
			end
		end)
	end

	self.animateXpDone = function()
		GoingUp:Stop()
		Finish:Play()

		RealDelay(ANIMATE_GOLD_DELAY, function()
			if not self.state.unmounted then
				GoingUp:Play()

				self:setState({
					animateGold = true,
				})
			end
		end)
	end

	self.buttonRefs = {}
	for _ = 1, #self.props.Loot do
		table.insert(self.buttonRefs, Roact.createRef())
	end

	self.onReveal = Memoize(function(hover, buttonRef)
		return function(loot)
			return function()
				local sound = SoundService.SFX.Reveal:Clone()
				sound.PlayOnRemove = true
				sound.Parent = SoundService
				sound:Destroy()

				local lootLeft = self.state.lootLeft - 1

				local fireworks = self.state.fireworks

				if buttonRef ~= nil and loot.Rarity >= 3 then
					fireworks = {}
					for index, data in ipairs(self.state.fireworks) do
						fireworks[index] = data
					end

					table.insert(fireworks, {
						color = LootStyles[loot.Rarity].Color,
						position = buttonRef:getValue().AbsolutePosition,
					})
				end

				self:setState({
					fireworks = fireworks,
					lootLeft = lootLeft,
				})

				self.setShakeTime(0)

				if lootLeft == 0 then
					local leaveTimer = 20
					self:setState({
						leaveTimer = leaveTimer,
					})

					Interval(1, function()
						if self.props.PerkDetailsOpen then
							return
						end

						leaveTimer = leaveTimer - 1
						self:setState({
							leaveTimer = leaveTimer,
						})

						if leaveTimer == 0 then
							self.teleport()
							return false
						end
					end)
				end

				hover(loot)()
			end
		end
	end)

	self.teleport = function()
		self:setState({
			leaving = true,
		})

		if not RunService:IsRunning() then
			print("teleporting...")
			return
		end

		TeleportService:Teleport(PlaceIds.GetHubPlace())
	end

	self.screenShake = function(delta)
		local shakeTime = self.shakeTime:getValue()

		if shakeTime < 1 then
			self.setShakeBase(self.shakeBase:getValue() + delta / SHAKE_TIME)
			self.setShakeTime(math.min(1, shakeTime + delta / SHAKE_TIME))
		end
	end
end

function LootResults:didMount()
	self:CheckAnimateXP()
end

function LootResults:didUpdate()
	self:CheckAnimateXP()
end

function LootResults:CheckAnimateXP()
	if not self.state.animateXp and self.props.AnimateXPNow then
		RealDelay(ANIMATE_XP_DELAY, function()
			GoingUp:Play()
			if not self.state.unmounted then
				self:setState({
					animateXp = true,
				})
			end
		end)
	end
end

function LootResults:render()
	local props = self.props

	return e(HoverStack, {
		Render = function(hovered, hover, unhover)
			local lootChildren = {}
			lootChildren.UIListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, 10),
				VerticalAlignment = Enum.VerticalAlignment.Center,
			})

			local hoveredLootType = hovered and getLootType(hovered)

			for index, gamemodeLoot in ipairs(props.GamemodeLoot) do
				if gamemodeLoot.Type == "Brains" then
					lootChildren["GamemodeLoot" .. index] = e(RevealButton, {
						LayoutOrder = index,
						Reveal = self.onReveal(noop)(gamemodeLoot),
						ZIndex = -index,
					}, {
						Contents = e(BrainsButton, {
							Brains = gamemodeLoot.Brains,
							LayoutOrder = -index,
						}),
					})
				end
			end

			for index, loot in ipairs(props.Loot) do
				lootChildren["Loot" .. index] = e("Frame", {
					BackgroundTransparency = 1,
					LayoutOrder = index,
					Size = UDim2.fromOffset(410, 410),
					ZIndex = -index,
					[Roact.Ref] = self.buttonRefs[index],
				}, {
					e(RevealButton, {
						Reveal = self.onReveal(hover, self.buttonRefs[index])(loot),
					}, {
						Contents = e("Frame", {
							BackgroundTransparency = 1,
							Size = UDim2.fromOffset(410, 410),
							ZIndex = -index,
						}, {
							ItemPreview = e(ItemPreview, assign({
								CenterWeapon = true,
								FrameSize = UDim2.fromScale(1, 1),
								HideFavorites = true,
								Item = loot,
								LayoutOrder = index,
								Name = Loot.GetLootName(loot),

								Hover = hover(loot),
								Unhover = unhover(loot),
							}, getLootType(loot))),
						}),
					})
				})
			end

			local fireworks = {}
			for index, data in ipairs(self.state.fireworks) do
				fireworks["Firework" .. index] = e("Frame", {
					AnchorPoint = Vector2.new(0.7, 0),
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(data.position.X, data.position.Y),
					Size = UDim2.fromOffset(510, 510),
				}, {
					Fireworks = e(Fireworks, {
						ParticleColor = data.color,
					})
				})
			end

			return e("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 1,
				Position = Roact.joinBindings({
					self.shakeBase,
					self.shakeTime,
				}):map(function(bindings)
					local base, time = unpack(bindings)
					return UDim2.fromScale(0.5, 0.5)
						+ UDim2.fromScale(
							SHAKE_RANGE * math.noise(base) * math.cos((time * math.pi) / 2),
							SHAKE_RANGE * math.noise(base * 10) * math.cos((time * math.pi) / 2)
						)
				end),
				Size = UDim2.fromOffset(1920, 1080),
			}, {
				Scale = e(Scale, {
					Size = Vector2.new(1920, 1080),
				}),

				Fireworks = e("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					ZIndex = 10,
				}, fireworks),

				Contents = e("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -600, 1, 0),
				}, {
					Loot = self.state.showLoot and (
						self.totalLoot > 0
						and e("ScrollingFrame", {
							AnchorPoint = Vector2.new(0, 0.5),
							BackgroundTransparency = 1,
							CanvasSize = UDim2.new(0, (self.totalLoot * 410) + ((self.totalLoot - 1) * 10), 0, 0),
							Position = UDim2.fromScale(0, 0.5),
							Size = UDim2.new(1, 0, 0, 410),
						}, lootChildren)
						or e("TextLabel", {
							AnchorPoint = Vector2.new(0, 0.5),
							BackgroundTransparency = 1,
							Font = Enum.Font.Gotham,
							Position = UDim2.fromScale(0, 0.5),
							Size = UDim2.new(1, 0, 0, 410),
							Text = "Your inventory is full!\nSell something for more loot!",
							TextColor3 = Color3.new(1, 1, 1),
							TextSize = 62,
							TextStrokeColor3 = Color3.new(0.7, 0, 0),
							TextStrokeTransparency = 0.5,
							TextWrapped = true,
						})
					),

					Rewards = e("Frame", {
						AnchorPoint = Vector2.new(0.5, 1),
						BackgroundTransparency = 1,
						Position = UDim2.new(0.5, 0, 1, -55),
						Size = UDim2.new(1, 0, 0, 100),
					}, {
						UIListLayout = e("UIListLayout", {
							FillDirection = Enum.FillDirection.Horizontal,
							Padding = UDim.new(0, 30),
							SortOrder = Enum.SortOrder.LayoutOrder,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Center,
						}),

						XP = e(Reward, {
							Color = Color3.fromRGB(9, 132, 227),
							LayoutOrder = 1,
							Text = "XP",
							Value = props.XP,

							AnimateStart = self.state.animateXp,
							FullTime = FULL_TIME_XP,
							OnFinish = self.animateXpDone,
						}),

						Caps = e(Reward, {
							Color = Color3.fromRGB(214, 48, 48),
							LayoutOrder = 2,
							Text = "CAPS",
							Value = props.Caps,

							AnimateStart = self.state.animateGold,
							FullTime = FULL_TIME_GOLD,
							OnFinish = self.animateGoldDone,
						}),
					}),
				}),

				Sidebar = e("Frame", {
					AnchorPoint = Vector2.new(1, 0),
					BackgroundColor3 = Color3.new(0, 0, 0),
					BackgroundTransparency = 0.3,
					BorderSizePixel = 0,
					Position = UDim2.fromScale(1, 0),
					Size = UDim2.new(0, 600, 1, 0),
				}, {
					Details = e("Frame", {
						AnchorPoint = Vector2.new(0.5, 0),
						BackgroundTransparency = 1,
						Position = UDim2.new(0.5, 0, 0, 50),
						Size = UDim2.fromOffset(535, 895),
					}, {
						ItemDetails = hovered and e(ItemDetails, assign({
							CompareTo = props.equipment[hoveredLootType.EquippedItem] or hovered,
							Item = hovered,
							GetName = Loot.GetLootName,
						}, hoveredLootType)),
					}),

					Bottom = e("Frame", {
						AnchorPoint = Vector2.new(1, 1),
						BackgroundTransparency = 1,
						Position = UDim2.new(1, -27, 1, -35),
						Size = UDim2.new(1, -27, 0, 53),
					}, {
						UIListLayout = e("UIListLayout", {
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Right,
							Padding = UDim.new(0, 20),
							SortOrder = Enum.SortOrder.LayoutOrder,
							VerticalAlignment = Enum.VerticalAlignment.Center,
						}),

						Leave = e(PerfectTextLabel, {
							AnchorPoint = Vector2.new(0.5, 0.5),
							Font = Enum.Font.Gotham,
							Position = UDim2.fromScale(0.5, 0.5),
							Text = self.state.leaving
								and "Leaving..."
								or (
									self.state.leaveTimer == nil
										and "Leave"
										or ("Leave (%d)"):format(self.state.leaveTimer)
								),
							TextColor3 = Color3.new(1, 1, 1),
							TextSize = 24,

							RenderParent = function(label, size)
								return e(GradientButton, {
									BackgroundColor3 = Color3.new(1, 1, 1),
									BackgroundTransparency = 1,
									Image = ImageFloat,
									LayoutOrder = 1,
									ScaleType = Enum.ScaleType.Slice,
									SliceCenter = Rect.new(6, 4, 86, 20),
									Size = UDim2.new(size.X + UDim.new(0, 44), UDim.new(0, 53)),

									AnimateSpeed = 14,
									MinGradient = Color3.fromRGB(201, 51, 37),
									MaxGradient = Color3.fromRGB(175, 38, 25),
									HoveredMaxGradient = Color3.fromRGB(197, 44, 30),

									[Roact.Event.Activated] = self.teleport,
								}, {
									Label = label,
								})
							end,
						}),

						Timer = e(PerfectTextLabel, {
							BackgroundTransparency = 1,
							Font = Enum.Font.Gotham,
							LayoutOrder = 2,
							Text = ("%d:%02d"):format(math.floor(self.state.clearTime / 60), self.state.clearTime % 60),
							TextColor3 = Color3.new(1, 1, 1),
							TextSize = 35,
						}),
					}),
				}),

				ScreenShake = e(EventConnection, {
					callback = self.screenShake,
					event = RunService.Heartbeat,
				}),
			})
		end,
	})
end

local function LootResultsWrapper(props)
	return e(App.Context.Consumer, {
		render = function(state)
			return e(LootResults, assign(props, {
				PerkDetailsOpen = state.perkDetailsOpen,
			}))
		end
	})
end

return RoactRodux.connect(function(state)
	return {
		equipment = state.equipment,
	}
end)(LootResultsWrapper)
