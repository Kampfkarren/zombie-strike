local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Alert = require(ReplicatedStorage.Core.UI.Components.Alert)
local EventConnection = require(ReplicatedStorage.Core.UI.Components.EventConnection)
local InventorySpace = require(ReplicatedStorage.Core.InventorySpace)
local PetsDictionary = require(ReplicatedStorage.Core.PetsDictionary)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local StyledButton = require(ReplicatedStorage.Core.UI.Components.StyledButton)

local e = Roact.createElement
local LocalPlayer = Players.LocalPlayer

local COLOR_GRADIENT_1 = Color3.fromRGB(255, 253, 76)
local COLOR_GRADIENT_2 = Color3.fromRGB(250, 255, 61)

local EggPrompt = Roact.Component:extend("Pets")
local UpdatePetCoins = ReplicatedStorage.Remotes.UpdatePetCoins

local function OffsetPadding()
	return e("UIPadding", {
		PaddingBottom = UDim.new(0.01, 0),
		PaddingLeft = UDim.new(0.01, 0),
		PaddingRight = UDim.new(0.01, 0),
		PaddingTop = UDim.new(0.01, 0),
	})
end

function EggPrompt:init()
	self:setState({
		alertOpen = nil,
		petCoins = 0,
	})

	self.buyEgg = function()
		if self.state.loading then return end
		if self.props.eggOpen:getValue() then return end

		if self.state.petCoins < PetsDictionary.EggCost then
			self:setState({
				alertOpen = true,
				alertText = "You don't have enough pet coins. Get more by playing!",
			})
		else
			self:setState({
				loading = true,
			})

			InventorySpace(LocalPlayer):andThen(function(space)
				if space <= self.props.inventoryAmount then
					self:setState({
						alertOpen = true,
						alertText = "Your inventory is full, please sell something.",
					})
				else
					ReplicatedStorage.Remotes.OpenEgg:FireServer()
				end
			end)
		end
	end

	self.closeAlert = function()
		self:setState({
			alertOpen = Roact.None,
		})
	end

	self.updatePetCoins = function(newCoins)
		self:setState({
			loading = false,
			petCoins = newCoins,
		})
	end
end

function EggPrompt:render()
	return e("TextButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutoButtonColor = false,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.4, 0.6),
		Text = "",
		Visible = self.props.visible,
	}, {
		UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
			AspectRatio = 1.5,
			AspectType = Enum.AspectType.ScaleWithParentSize,
			DominantAxis = Enum.DominantAxis.Height,
		}),

		UIGradient = e("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0.0, COLOR_GRADIENT_1),
				ColorSequenceKeypoint.new(0.5, COLOR_GRADIENT_2),
				ColorSequenceKeypoint.new(1.0, COLOR_GRADIENT_1),
			}),
		}),

		UIListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0.01, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Padding = e(OffsetPadding),

		ProgressText = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			LayoutOrder = 1,
			Size = UDim2.fromScale(1, 0.15),
			Text = "PET EGGS",
			TextColor3 = Color3.new(0.9, 0.9, 0.9),
			TextScaled = true,
			TextStrokeTransparency = 0.5,
			TextYAlignment = Enum.TextYAlignment.Center,
		}),

		Image = e("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = "rbxassetid://4596405369",
			LayoutOrder = 2,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.28, 1),
		}, {
			e("UIAspectRatioConstraint"),
		}),

		OK = e(StyledButton, {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = Color3.fromRGB(32, 146, 81),
			LayoutOrder = 3,
			Position = UDim2.fromScale(0.5, 0.98),
			Size = UDim2.fromScale(0.5, 0.15),
			[Roact.Event.Activated] = self.buyEgg,
		}, {
			Label = e("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.95, 0.95),
				Text = "BUY FOR " .. PetsDictionary.EggCost .. " 🐾",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
			}),
		}),

		Amount = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			LayoutOrder = 4,
			Size = UDim2.fromScale(1, 0.15),
			Text = "You have " .. self.state.petCoins .. " 🐾\nGet more by playing!",
			TextColor3 = Color3.new(0.9, 0.9, 0.9),
			TextScaled = true,
			TextStrokeTransparency = 0.5,
			TextYAlignment = Enum.TextYAlignment.Center,
		}),

		Alert = (self.state.alertOpen or nil) and e(Alert, {
			OnClose = self.closeAlert,
			Open = self.state.alertOpen,
			Text = self.state.alertText,
		}),

		UpdatePetCoins = e(EventConnection, {
			event = UpdatePetCoins.OnClientEvent,
			callback = self.updatePetCoins,
		}),
	})
end

return RoactRodux.connect(function(state)
	return {
		inventoryAmount = #(state.inventory or {}),
		visible = state.page.current == "PetShop",
	}
end)(EggPrompt)
