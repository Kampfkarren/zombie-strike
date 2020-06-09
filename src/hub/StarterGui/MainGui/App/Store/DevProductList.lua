local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProductCard = require(ReplicatedStorage.Components.ProductCard)
local Promise = require(ReplicatedStorage.Core.Promise)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement
local LocalPlayer = Players.LocalPlayer

local DevProductList = Roact.PureComponent:extend("DevProductList")

local function copy(list)
	local copy = {}
	for key, value in pairs(list) do
		copy[key] = value
	end
	return copy
end

function DevProductList:init()
	local products = {}

	for index, product in pairs(self.props.products) do
		Promise.promisify(function()
			local productInfo = MarketplaceService:GetProductInfo(product, Enum.InfoType.Product)

			return {
				Cost = productInfo.PriceInRobux,
				Product = product,
				Name = productInfo.Name,
			}
		end)():andThen(function(product)
			products = copy(products)
			products[index] = product
			self:setState({
				products = products,
			})
		end)
	end

	self:setState({
		products = products,
	})
end

function DevProductList:render()
	local children = copy(self.props[Roact.Children] or {})

	for index in pairs(self.props.products) do
		local product = self.state.products[index]
		if product then
			children["Product" .. index] = e(ProductCard, {
				activate = function()
					MarketplaceService:PromptProductPurchase(LocalPlayer, product.Product)
				end,
				product = product,
				renderButton = self.props.renderButton,
				imageButtonProps = self.props.imageButtonProps,
			})
		end
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, children)
end

return DevProductList
