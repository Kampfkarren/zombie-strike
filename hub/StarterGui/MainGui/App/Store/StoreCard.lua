local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local BrainsPurchase = require(ReplicatedStorage.Core.UI.Components.BrainsPurchase)
local Cosmetics = require(ReplicatedStorage.Core.Cosmetics)
local CosmeticButton = require(script.Parent.CosmeticButton)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)

local e = Roact.createElement
local StoreCard = Roact.PureComponent:extend("StoreCard")

local COSMETIC_TYPE_NAMES = {
	Face = "Face",
	Particle = "Particle",
	LowTier = "Bundle",
	HighTier = "LIMITED Bundle",
}

local function PriceText(props)
	return e("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutoLocalize = false,
		BackgroundTransparency = 1,
		Font = props.Font or Enum.Font.GothamBold,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = props.Size or UDim2.new(0.95, 0, 0.9, 0),
		Text = props.Price .. "🧠",
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
	}, props[Roact.Children])
end

function StoreCard:GetItem()
	return Cosmetics.GetStoreItems()[self.props.ItemType][self.props.ItemIndex]
end

function StoreCard:init()
	self.buyProduct = function()
		local props = self.props

		if not props.owned then
			SoundService.SFX.Purchase:Play()
			self:setState({
				buyingProduct = true,
			})
		end
	end

	self.closeBuyingProduct = function()
		self:setState({
			buyingProduct = false,
		})
	end

	self.finishBuyProduct = function()
		ReplicatedStorage.Remotes.BuyCosmetic:FireServer(self.props.ItemType, self.props.ItemIndex)
	end
end

function StoreCard:render()
	local children = {}

	local item = self:GetItem()

	local buyCostChildren = {}

	if self.props.Prices.UsualCost then
		buyCostChildren.UIListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.01, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		})

		buyCostChildren.UsualCost = e(PriceText, {
			Price = self.props.Prices.UsualCost,
			Font = Enum.Font.Gotham,
			Size = UDim2.fromScale(0.4, 0.9),
		}, {
			Strikethrough = e("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.98, 0.05),
			}),
		})

		buyCostChildren.Cost = e(PriceText, {
			Price = self.props.Prices.Cost,
			Size = UDim2.fromScale(0.4, 0.9),
		})
	else
		buyCostChildren.Cost = e(PriceText, {
			Price = self.props.Prices.Cost,
		})
	end

	children.BuyCost = e("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = Color3.fromRGB(46, 204, 113),
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0.2, 0),
		ZIndex = 2,
	}, buyCostChildren)

	children.ItemInfo = e("Frame", {
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0.2, 0),
	}, {
		ItemName = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			AutoLocalize = false,
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.new(0.5, 0, 0, 0),
			Size = UDim2.new(0.95, 0, 0.6, 0),
			Text = item.Name,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
		}),

		ItemType = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Position = UDim2.new(0.5, 0, 1, 0),
			Size = UDim2.new(0.95, 0, 0.4, 0),
			Text = COSMETIC_TYPE_NAMES[item.Type],
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
		}),
	})

	if self.props.owned then
		children.Owned = e("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.5,
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 0.15, 0),
		}, {
			e("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0.9, 0, 0.95, 0),
				Text = "OWNED",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
			}),
		})
	end

	if self.state.buyingProduct then
		children.Purchase = e(BrainsPurchase, {
			Cost = self.props.Prices.Cost,
			Name = item.Name,
			Window = self.props.Window,

			OnBuy = self.finishBuyProduct,
			OnClose = self.closeBuyingProduct,
		})
	end

	return e(CosmeticButton, {
		Native = {
			Image = "",
			LayoutOrder = self.props.LayoutOrder,
			Size = self.props.Size,
			[Roact.Event.Activated] = self.buyProduct,
		},

		Item = item,
		PreviewSize = UDim2.new(1, 0, 0.9, 0),
	}, children)
end

return RoactRodux.connect(function(state, props)
	local owned = false

	local itemIndex = Cosmetics.GetStoreItems()[props.ItemType][props.ItemIndex].Index

	if props.ItemType == "LowTier" or props.ItemType == "HighTier" then
		itemIndex = itemIndex + 1
	end

	for _, cosmetic in pairs(state.store.contents) do
		if cosmetic == itemIndex then
			owned = true
			break
		end
	end

	return {
		owned = owned,
	}
end)(StoreCard)
