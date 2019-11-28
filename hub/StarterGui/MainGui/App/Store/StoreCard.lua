local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Cosmetics = require(ReplicatedStorage.Core.Cosmetics)
local CosmeticButton = require(script.Parent.CosmeticButton)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)

local e = Roact.createElement
local LocalPlayer = Players.LocalPlayer
local StoreCard = Roact.PureComponent:extend("StoreCard")

local COSMETIC_TYPE_NAMES = {
	Face = "Face",
	Particle = "Particle",
	LowTier = "Bundle",
	HighTier = "LIMITED Bundle",
}

function StoreCard:GetItem()
	return Cosmetics.GetStoreItems()[self.props.ItemType][self.props.ItemIndex]
end

function StoreCard:init()
	self.buyProduct = function()
		local props = self.props

		if not props.owned then
			SoundService.SFX.Purchase:Play()
			MarketplaceService:PromptProductPurchase(
				LocalPlayer,
				Cosmetics.Distribution[props.ItemType][props.ItemIndex]
			)
		end
	end
end

function StoreCard:render()
	local children = {}

	local item = self:GetItem()

	children.BuyCost = e("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = Color3.fromRGB(46, 204, 113),
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0.2, 0),
		ZIndex = 2,
	}, {
		Cost = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			AutoLocalize = false,
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0.95, 0, 0.9, 0),
			Text = "R$" .. self.props.Price,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
		}),
	})

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
