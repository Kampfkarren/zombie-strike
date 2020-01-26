local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local EventConnection = require(ReplicatedStorage.Core.UI.Components.EventConnection)
local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)
local ItemButton = require(script.Parent.Parent.Inventory.ItemButton)
local InventoryContents = require(script.Parent.Parent.Inventory.InventoryContents)
local LootInfo = require(ReplicatedStorage.Core.UI.Components.LootInfo)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local StyledButton = require(ReplicatedStorage.Core.UI.Components.StyledButton)

local AcceptTrade = ReplicatedStorage.Remotes.AcceptTrade
local PingTrade = ReplicatedStorage.Remotes.PingTrade
local UpdateTrade = ReplicatedStorage.Remotes.UpdateTrade

local e = Roact.createElement

local ITEMS_PER_OFFER = 10
local PING_COUNT = 11
local PING_DELAY = 3

local lastPing = 0
local pingEvent = Instance.new("BindableEvent")

PingTrade.OnClientEvent:connect(function(uuid)
	pingEvent:Fire(uuid)
end)

local function OfferContents(props)
	local children = {}

	children.UIGridLayout = e("UIGridLayout", {
		CellPadding = UDim2.fromScale(0.03, 0.03),
		CellSize = UDim2.fromScale(0.15, 0.47),
		FillDirectionMaxCells = ITEMS_PER_OFFER / 2,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	}, {
		UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
	})

	for index = 1, ITEMS_PER_OFFER do
		local child

		if props.Offer[index] then
			child = e(ItemButton, {
				LayoutOrder = index,
				HideFavorites = true,
				Loot = props.Offer[index],

				onHover = props.onHover,
				onUnhover = props.onUnhover,
				onClickUnequipped = props.onClickUnequipped,
			})
		else
			child = e(StyledButton, {
				LayoutOrder = index,
				Square = true,
			})
		end

		table.insert(children, child)
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, children)
end

local PingBackground = Roact.PureComponent:extend("PingBackground")

function PingBackground:init()
	self.ref = Roact.createRef()

	self.ping = function(uuid)
		if uuid == self.props.uuid then
			FastSpawn(function()
				for count = 0, PING_COUNT do
					local ref = assert(self.ref:getValue()).Parent
					ref.BackgroundTransparency = count % 2

					local dt = 0
					repeat
						dt = dt + RunService.Heartbeat:wait()
					until dt >= 0.15
				end
			end)
		end
	end
end

function PingBackground:render()
	return e("Frame", {
		[Roact.Ref] = self.ref,
	}, {
		Ping = e(EventConnection, {
			callback = self.ping,
			event = pingEvent.Event,
		}),
	})
end

function PingBackground:didMount()
	local parent = assert(self.ref:getValue()).Parent
	parent.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
	parent.BackgroundTransparency = 1
	parent.BorderColor3 = Color3.fromRGB(231, 76, 60)
	parent.BorderSizePixel = 5
end

local TradeScreen = Roact.Component:extend("TradeScreen")

local function copy(list)
	local copy = {}
	for index, value in pairs(list) do
		copy[index] = value
	end
	return copy
end

function TradeScreen:init()
	self:setState({
		lootStack = {},
	})

	self.pingCallbacks = {}

	self.ping = function(loot)
		if tick() - lastPing >= PING_DELAY then
			lastPing = tick()
			pingEvent:Fire(loot.UUID)
			PingTrade:FireServer(loot.UUID)
		end
	end

	self.acceptTrade = function()
		AcceptTrade:FireServer()
	end

	self.acceptTradeEvent = function(us, accepted)
		self:setState({
			[(us and "we" or "they") .. "Accept"] = accepted,
		})
	end

	self.offerLoot = function(loot)
		if table.find(self.props.trade.yourOfferUuids, loot.UUID) == nil then
			UpdateTrade:FireServer(loot.UUID)
		end

		self:setState({
			theyAccept = false,
			weAccept = false,
		})
	end

	self.onHover = function(loot, us)
		local lootStack = copy(self.state.lootStack)
		lootStack[loot.UUID] = { loot = loot, us = us }
		self:setState({
			lootStack = lootStack,
		})
	end

	self.onUnhover = function(loot)
		local lootStack = copy(self.state.lootStack)
		lootStack[loot.UUID] = nil
		self:setState({
			lootStack = lootStack,
		})
	end

	self.onHoverUs = function(loot)
		self.onHover(loot, true)
	end

	self.onHoverThem = function(loot)
		self.onHover(loot, false)
	end

	self.removeLoot = function(loot)
		UpdateTrade:FireServer(loot.UUID, true)

		self:setState({
			theyAccept = false,
			weAccept = false,
		})
	end
end

function TradeScreen:didUpdate(prevProps)
	local theirOfferDifferent = false

	if #prevProps.trade.theirOffer == #self.props.trade.theirOffer then
		for index, value in pairs(prevProps.trade.theirOffer) do
			if self.props.trade.theirOffer[index].UUID ~= value.UUID then
				theirOfferDifferent = true
				break
			end
		end
	else
		theirOfferDifferent = true
	end

	if theirOfferDifferent then
		self:setState({
			theyAccept = false,
			weAccept = false,
		})
	end
end

function TradeScreen:render()
	local lootInfoThem, lootInfoUs
	local _, hovered = next(self.state.lootStack)

	if hovered then
		local lootInfo = e(LootInfo, {
			Native = {
				BackgroundTransparency = 0.3,
				BackgroundColor3 = Color3.new(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 1),
			},

			Loot = hovered.loot,
		})

		if hovered.us then
			lootInfoUs = lootInfo
		else
			lootInfoThem = lootInfo
		end
	end

	local acceptColor, acceptText = Color3.fromRGB(59, 215, 48), "ACCEPT"

	if self.state.weAccept then
		acceptColor = Color3.fromRGB(214, 48, 49)
		acceptText = "UNACCEPT"
	end

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.95, 0.9),
	}, {
		UIListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Offers = e("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Size = UDim2.fromScale(0.5, 1),
		}, {
			YourOffer = e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 0.47),
			}, {
				Contents = e("Frame", {
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0, 0.2),
					Size = UDim2.fromScale(1, 0.9),
				}, {
					OfferContents = e(OfferContents, {
						Offer = self.props.trade.yourOffer,

						onHover = self.onHoverUs,
						onUnhover = self.onUnhover,
						onClickUnequipped = self.removeLoot,
					}),
				}),

				Topbar = e("Frame", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0),
					Size = UDim2.fromScale(0.8, 0.2),
				}, {
					UIListLayout = e("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),

					Label = e("TextLabel", {
						BackgroundTransparency = 1,
						Font = Enum.Font.GothamBlack,
						Size = UDim2.fromScale(0.7, 1),
						Text = "YOUR OFFER",
						TextColor3 = Color3.new(1, 1, 0.5),
						TextScaled = true,
					}),

					AcceptButton = e(StyledButton, {
						BackgroundColor3 = acceptColor,
						LayoutOrder = 1,
						Size = UDim2.fromScale(0.3, 1),
						[Roact.Event.Activated] = self.acceptTrade,
					}, {
						Label = e("TextLabel", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							Font = Enum.Font.GothamBold,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(0.9, 0.75),
							Text = acceptText,
							TextColor3 = Color3.new(1, 1, 1),
							TextScaled = true,
						}),
					}),
				}),
			}),

			TheirOffer = e("Frame", {
				AnchorPoint = Vector2.new(0, 1),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.fromScale(1, 0.47),
			}, {
				UIListLayout = e("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				Contents = e("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 0.9),
				}, {
					OfferContents = e(OfferContents, {
						Offer = self.props.trade.theirOffer,

						onHover = self.onHoverThem,
						onUnhover = self.onUnhover,
					}),
				}),

				Label = e("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBlack,
					LayoutOrder = 1,
					Size = UDim2.fromScale(1, 0.2),
					Text = (self.state.theyAccept and "✅ " or "") .. "THEIR OFFER",
					TextColor3 = Color3.new(1, 1, 0.5),
					TextScaled = true,
				}),
			}),

			Separator = e("Frame", {
				BackgroundColor3 = Color3.fromRGB(50, 50, 50),
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0, 0.52),
				Size = UDim2.fromScale(1, 0.01),
			}),
		}),

		YourInventory = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(0.25, 1),
		}, {
			Contents = e(InventoryContents, {
				Native = {
					AnchorPoint = Vector2.new(0, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0, 1),
					ScrollBarThickness = 4,
					Size = UDim2.fromScale(1, 0.9),
				},

				noInteractiveFavorites = true,

				onHover = self.onHoverUs,
				onUnhover = self.onUnhover,

				onClickInventoryUnequipped = self.offerLoot,

				itemButtonChildren = self.state.itemButtonChildren,
			}),

			Label = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Size = UDim2.fromScale(1, 0.1),
				Text = "YOUR INVENTORY",
				TextColor3 = Color3.new(1, 1, 0.5),
				TextScaled = true,
			}),

			LootInfo = lootInfoThem,
		}),

		TheirInventory = e("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			Size = UDim2.fromScale(0.25, 1),
		}, {
			Contents = e(InventoryContents, {
				Native = {
					AnchorPoint = Vector2.new(0, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0, 1),
					ScrollBarThickness = 4,
					Size = UDim2.fromScale(1, 0.9),
				},

				inventory = self.props.trade.theirInventory,
				hideFavorites = true,

				onHover = self.onHoverThem,
				onUnhover = self.onUnhover,

				onClickInventoryUnequipped = self.ping,

				itemButtonChildren = self.state.itemButtonChildren,
			}),

			Label = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Size = UDim2.fromScale(1, 0.1),
				Text = "THEIR INVENTORY",
				TextColor3 = Color3.fromRGB(255, 121, 63),
				TextScaled = true,
			}),

			LootInfo = lootInfoUs,
		}),

		AcceptTradeConnection = e(EventConnection, {
			callback = self.acceptTradeEvent,
			event = AcceptTrade.OnClientEvent,
		}),
	})
end

function TradeScreen.getDerivedStateFromProps(nextProps, lastState)
	local itemButtonChildren = copy(lastState.itemButtonChildren or {})

	for _, item in pairs(nextProps.trade.theirInventory) do
		if not itemButtonChildren[item.UUID] and not item.Equipped then
			itemButtonChildren[item.UUID] = {
				PingBackground = e(PingBackground, {
					uuid = item.UUID,
				}),
			}
		end
	end

	for _, item in pairs(nextProps.inventory) do
		if not itemButtonChildren[item.UUID] and not item.Equipped then
			itemButtonChildren[item.UUID] = {
				PingBackground = e(PingBackground, {
					uuid = item.UUID,
				}),
			}
		end
	end

	return {
		itemButtonChildren = itemButtonChildren,
	}
end

local function offer(uuids, inventory)
	local loot = {}
	local uuidsAndLoot = {}

	for _, item in pairs(inventory) do
		uuidsAndLoot[item.UUID] = item
	end

	for _, uuid in ipairs(uuids) do
		table.insert(loot, assert(uuidsAndLoot[uuid]))
	end

	return loot
end

return RoactRodux.connect(function(state)
	local trading = state.trading

	return {
		inventory = state.inventory,

		trade = {
			trading = trading.trading,

			theirInventory = trading.theirInventory,
			theirOffer = offer(trading.theirOffer, trading.theirInventory),

			yourOffer = offer(trading.yourOffer, state.inventory),
			yourOfferUuids = trading.yourOffer,
		}
	}
end)(TradeScreen)
