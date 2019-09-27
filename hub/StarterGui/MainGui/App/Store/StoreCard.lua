local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Cosmetics = require(ReplicatedStorage.Cosmetics)
local CosmeticPreview = require(script.Parent.CosmeticPreview)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)

local e = Roact.createElement
local StoreCard = Roact.PureComponent:extend("StoreCard")

local COSMETIC_COLORS = {
	Face = Color3.fromRGB(156, 136, 255),
	LowTier = Color3.fromRGB(9, 132, 227),
	HighTier = Color3.fromRGB(238, 82, 83),
}

local COSMETIC_TYPE_NAMES = {
	Face = "Face",
	LowTier = "Bundle",
	HighTier = "LIMITED Bundle",
}

function StoreCard:init()
	local previewScale, previewScaleSet = Roact.createBinding(1)
	self.update, self.updateSet = Roact.createBinding(function() end)

	local hover = Instance.new("NumberValue")
	hover:GetPropertyChangedSignal("Value"):connect(function()
		previewScaleSet(hover.Value)
		self.update:getValue()()
	end)
	hover.Value = 1

	local tweenHoverIn = TweenService:Create(
		hover,
		TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{ Value = 1.4 }
	)

	local tweenHoverOut = TweenService:Create(
		hover,
		TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{ Value = 1 }
	)

	self.hoverIn = function()
		tweenHoverIn:Play()
	end

	self.hoverOut = function()
		tweenHoverOut:Play()
	end

	self.previewScale = previewScale
end

function StoreCard:GetItem()
	return Cosmetics.GetStoreItems()[self.props.ItemType][self.props.ItemIndex]
end

function StoreCard:GetPreview()
	-- TODO
	local item = self:GetItem()
	return e(CosmeticPreview, {
		item = item,
		previewScale = self.previewScale,
		updateSet = self.updateSet,
	})
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

	children.Preview = self:GetPreview()

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

	return e("ImageButton", {
		BackgroundColor3 = COSMETIC_COLORS[self.props.ItemType],
		BorderSizePixel = 0,
		Image = "",
		LayoutOrder = self.props.LayoutOrder,
		Size = self.props.Size,

		[Roact.Event.MouseEnter] = self.hoverIn,
		[Roact.Event.MouseLeave] = self.hoverOut,
	}, children)
end

return RoactRodux.connect(function(state, props)
	local owned = false
	local item = Cosmetics.GetStoreItems()[props.ItemType][props.ItemIndex]

	for _, cosmetic in pairs(state.store.contents) do
		if Cosmetics.Cosmetics[cosmetic] == item then
			owned = true
			break
		end
	end

	return {
		owned = owned,
	}
end)(StoreCard)
