local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Alert = require(ReplicatedStorage.Core.UI.Components.Alert)
local Close = require(script.Parent.Close)
local ConfirmPrompt = require(ReplicatedStorage.Core.UI.Components.ConfirmPrompt)
local EventConnection = require(ReplicatedStorage.Core.UI.Components.EventConnection)
local GamePasses = require(ReplicatedStorage.Core.GamePasses)
local Loot = require(ReplicatedStorage.Core.Loot)
local InventoryPage = require(script.InventoryPage)
local InventorySpace = require(ReplicatedStorage.Core.InventorySpace)
local Memoize = require(ReplicatedStorage.Core.Memoize)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local StatsPage = require(script.StatsPage)
local TitlesPage = require(script.TitlesPage)

local e = Roact.createElement
local LocalPlayer = Players.LocalPlayer
local UpdateEquipment = ReplicatedStorage.Remotes.UpdateEquipment

local Inventory = Roact.Component:extend("Inventory")

local function Tab(props)
	return e("TextButton", {
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromScale(0.25, 1),
		Text = "",

		[Roact.Event.Activated] = props.Activate,
		[Roact.Ref] = function(instance)
			if instance ~= nil then
				-- :/
				CollectionService:AddTag(instance, "UIClick")
			end
		end,
	}, {
		Text = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Font = props.Active and Enum.Font.GothamBold or Enum.Font.Gotham,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.95, 0.95),
			Text = props.Text,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
		}),
	})
end

function Inventory:init()
	self:setState({
		levelWarningOpen = false,
		tab = "inventory",
	})

	InventorySpace(LocalPlayer):andThen(function(space)
		self:setState({
			space = space,
		})
	end)

	self.resetInventorySpace = function()
		InventorySpace(LocalPlayer):andThen(function(space)
			self:setState({
				space = space,
			})
		end)
	end

	self.onCloseLevelWarning = function()
		self:setState({
			levelWarningOpen = false,
		})
	end

	self.equipAttachment = function()
		UpdateEquipment:FireServer(self.state.equipAttachmentId)

		self:setState({
			equipAttachment = Roact.None,
		})
	end

	self.closeAttachmentConfirm = function()
		self:setState({
			equipAttachment = Roact.None,
		})
	end

	self.openLevelWarning = function()
		self:setState({
			levelWarningOpen = true,
		})
	end

	self.openAttachmentPrompt = function(loot, id)
		self:setState({
			equipAttachment = loot,
			equipAttachmentId = id,
		})
	end

	self.switchTab = Memoize(function(tab)
		return function()
			self:setState({
				tab = tab,
			})
		end
	end)

	self.ref = Roact.createRef()
end

function Inventory:render()
	local props = self.props

	local attachmentConfirm

	if self.state.equipAttachment then
		attachmentConfirm = e(ConfirmPrompt, {
			Window = self.ref:getValue(),
			Text = string.format(
				"Are you sure you want to equip '%s'? It can not be removed from your gun later!",
				Loot.GetLootName(self.state.equipAttachment)
			),
			Yes = self.equipAttachment,
			No = self.closeAttachmentConfirm,
		})
	end

	return e("Frame", {
		Active = true,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(18, 18, 18),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.6, 0.7),
		Visible = self.props.open,
		ZIndex = 2,
		[Roact.Ref] = self.ref,
	}, {
		e("UIAspectRatioConstraint", {
			AspectRatio = 2.3,
			AspectType = Enum.AspectType.ScaleWithParentSize,
			DominantAxis = Enum.DominantAxis.Height,
		}),

		e(Close, {
			onClose = props.onClose,
			ZIndex = 2,
		}),

		InventoryPageFrame = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Visible = self.state.tab == "inventory",
		}, {
			InventoryPage = e(InventoryPage, {
				inventory = props.inventory,
				space = self.state.space,

				openLevelWarning = self.openLevelWarning,
				equipAttachment = self.openAttachmentPrompt,
			}),
		}),

		StatsPageFrame = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Visible = self.state.tab == "stats",
		}, {
			StatsPage = e(StatsPage),
		}),

		TitlesPageFrame = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Visible = self.state.tab == "titles",
		}, {
			TitlesPage = e(TitlesPage),
		}),

		AttachmentConfirm = attachmentConfirm,

		LevelWarning = e(Alert, {
			OnClose = self.onCloseLevelWarning,
			Open = self.state.levelWarningOpen,
			Text = "You're not a high enough level to equip that!",
		}),

		GamePassConnection = e(EventConnection, {
			callback = self.resetInventorySpace,
			event = GamePasses.BoughtPassUpdated(LocalPlayer).Event,
		}),

		Tabs = e("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0.1),
		}, {
			UIListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0.01, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			TabInventory = e(Tab, {
				Active = self.state.tab == "inventory",
				Activate = self.switchTab("inventory"),
				LayoutOrder = 1,
				Text = "Inventory",
			}),

			TabTitles = e(Tab, {
				Active = self.state.tab == "titles",
				Activate = self.switchTab("titles"),
				LayoutOrder = 2,
				Text = "Titles",
			}),

			TabStats = e(Tab, {
				Active = self.state.tab == "stats",
				Activate = self.switchTab("stats"),
				LayoutOrder = 3,
				Text = "Stats",
			}),
		}),
	})
end

return RoactRodux.connect(function(state)
	return {
		inventory = state.inventory,
		open = state.page.current == "Inventory",
	}
end, function(dispatch)
	return {
		onClose = function()
			dispatch({
				type = "ToggleInventory",
			})
		end,
	}
end)(Inventory)
