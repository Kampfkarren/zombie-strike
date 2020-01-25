local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BrainsPurchase = require(ReplicatedStorage.Core.UI.Components.BrainsPurchase)
local ProductCard = require(script.Parent.ProductCard)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local XPMultiplierDictionary = require(ReplicatedStorage.XPMultiplierDictionary)

local e = Roact.createElement
local XPMultipliers = Roact.PureComponent:extend("XPMultipliers")

function XPMultipliers:init()
	self.timer, self.updateTimer = Roact.createBinding(0)

	self.closeBuy = function()
		self:setState({
			buying = Roact.None,
			buyingIndex = Roact.None,
		})
	end

	self.finishBuy = function()
		ReplicatedStorage.Remotes.XPMultipliers:FireServer(self.state.buyingIndex)
		self.closeBuy()
	end

	self.renderProductCard = function(product, nameRotation, nameTextRef)
		return {
			Name = e("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				LayoutOrder = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.35, 0.9),
			}, {
				Label = e("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Rotation = nameRotation,
					Size = UDim2.fromScale(1, 1),
					Text = product.Name,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					[Roact.Ref] = nameTextRef,
				}),
			}),

			Cost = e("TextLabel", {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				LayoutOrder = 2,
				Position = UDim2.fromScale(0.95, 0.5),
				Size = UDim2.fromScale(0.2, 0.95),
				Text = product.Cost .. "🧠",
				TextColor3 = Color3.fromRGB(255, 205, 248),
				TextScaled = true,
			}),
		}
	end

	self:SetTimer()
end

function XPMultipliers:didMount()
	self:StartTimer()
end

function XPMultipliers:didUpdate(oldProps)
	if self.props.expiration ~= oldProps.expiration and self.timer:getValue() == 0 then
		self:SetTimer()
		self:StartTimer()
	end
end

function XPMultipliers:SetTimer()
	self.updateTimer(math.max(0, self.props.expiration - os.time()))
end

function XPMultipliers:StartTimer()
	spawn(function()
		while self.timer:getValue() > 0 do
			self:SetTimer()
			wait(1)
		end
	end)
end

function XPMultipliers:render()
	local props = self.props

	local products = {}
	for productIndex, product in pairs(XPMultiplierDictionary) do
		table.insert(products, e(ProductCard, {
			imageButtonProps = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				ImageColor3 = Color3.fromRGB(154, 255, 110),
				Position = UDim2.fromScale(0.5, 0.5),
			},

			activate = function()
				self:setState({
					buying = product,
					buyingIndex = productIndex,
				})
			end,

			product = product,
			renderButton = self.renderProductCard,
		}))
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Size = UDim2.fromScale(0.9, 0.9),
		[Roact.Ref] = props[Roact.Ref],
	}, {
		Purchase = self.state.buying and e(BrainsPurchase, {
			Cost = self.state.buying.Cost,
			Name = self.state.buying.Name,
			Window = props[Roact.Ref],

			OnBuy = self.finishBuy,
			OnClose = self.closeBuy,
		}),

		Products = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0.8),
		}, {
			UIListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0.02, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			Products = Roact.createFragment(products),
		}),

		Timer = e("TextLabel", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.fromScale(1, 0.15),
			Text = self.timer:map(function(timer)
				if timer == 0 then
					return "No multiplier active!"
				else
					return ("Active for %d:%02d:%02d"):format(
						math.floor(timer / 3600),
						math.floor(timer / 60) % 60,
						timer % 60
					)
				end
			end),
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
		}),
	})
end

return RoactRodux.connect(function(state)
	return {
		expiration = state.store.xpExpiration,
	}
end)(XPMultipliers)
