local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local AutomatedScrollingFrameComponent = require(script.Parent.Parent.AutomatedScrollingFrameComponent)
local GamePassDictionary = require(ReplicatedStorage.Core.GamePassDictionary)
local GamePasses = require(ReplicatedStorage.Core.GamePasses)
local Memoize = require(ReplicatedStorage.Core.Memoize)
local Promise = require(ReplicatedStorage.Core.Promise)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement
local LocalPlayer = Players.LocalPlayer

local GamePass = Roact.PureComponent:extend("GamePass")
local GamePassesMenu = Roact.PureComponent:extend("GamePassesMenu")

local buyButtonCallback = Memoize(function(gamePassId)
	return function()
		SoundService.SFX.Purchase:Play()
		MarketplaceService:PromptGamePassPurchase(LocalPlayer, gamePassId)
	end
end)

function GamePass:init()
	Promise.promisify(function()
		while true do
			local success, productInfo = pcall(function()
				return MarketplaceService:GetProductInfo(self.props.ID, Enum.InfoType.GamePass)
			end)

			if success then
				return productInfo
			end

			wait(1)
		end
	end)():andThen(function(productInfo)
		self:setState({
			productInfo = productInfo,
		})
	end)
end

function GamePass:render()
	local productInfo = self.state.productInfo

	if productInfo and productInfo.PriceInRobux then
		return e("Frame", {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			LayoutOrder = productInfo.PriceInRobux,
			Size = UDim2.fromScale(0.9, 0.3),
			Visible = not self.props.Owned,
		}, {
			UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
				AspectRatio = 7,
			}),

			UIListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0.03, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			Buy = e("TextButton", {
				BackgroundColor3 = Color3.fromRGB(0, 184, 148),
				BorderSizePixel = 0,
				Font = Enum.Font.GothamBold,
				LayoutOrder = 2,
				Size = UDim2.fromScale(0.2, 0.7),
				Text = "BUY R$" .. productInfo.PriceInRobux,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				[Roact.Event.MouseButton1Click] = buyButtonCallback(self.props.ID),
			}),

			Description = e("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				LayoutOrder = 1,
				Position = UDim2.fromScale(0.5, 0.05),
				Size = UDim2.fromScale(0.5, 0.9),
				Text = productInfo.Description,
				TextColor3 = Color3.fromRGB(9, 132, 227),
				TextScaled = true,
			}),

			Image = e("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Image = "rbxassetid://" .. productInfo.IconImageAssetId,
				LayoutOrder = 0,
				Position = UDim2.fromScale(0.02, 0.5),
				Size = UDim2.fromScale(0.7, 0.9),
			}, {
				e("UIAspectRatioConstraint"),
			}),
		})
	else
		return Roact.createFragment()
	end
end

function GamePassesMenu:init()
	self:GeneratePlayerOwnsPassMap()

	self.purchaseEvent = GamePasses.BoughtPassUpdated().Event:connect(function()
		self:GeneratePlayerOwnsPassMap()
	end)
end

function GamePassesMenu:GeneratePlayerOwnsPassMap()
	local gamePasses = {}

	for _, gamePass in pairs(GamePassDictionary) do
		gamePasses[gamePass] = GamePasses.PlayerOwnsPass(LocalPlayer, gamePass)
	end

	self:setState({
		gamePasses = gamePasses,
	})
end

function GamePassesMenu:render()
	local children = {}

	children.UIListLayout = e("UIListLayout", {
		Padding = UDim.new(0.01, 0),
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	})

	for id, owned in pairs(self.state.gamePasses) do
		children[id] = e(GamePass, {
			ID = id,
			Owned = owned,
		})
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = 4,
		Size = UDim2.fromScale(0.9, 0.9),
		[Roact.Ref] = self.props[Roact.Ref],
	}, {
		e(AutomatedScrollingFrameComponent, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 3,
			ScrollBarThickness = 8,
			Size = UDim2.fromScale(1, 1),
			[Roact.Ref] = self.props[Roact.Ref],
		}, children),
	})
end

function GamePassesMenu:willUnmount()
	self.purchaseEvent:Disconnect()
end

return GamePassesMenu
