local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BrainsDictionary = require(ReplicatedStorage.BrainsDictionary)
local DevProductList = require(script.Parent.DevProductList)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local function BuyBrains(props)
	local products = {}

	for _, product in pairs(BrainsDictionary) do
		table.insert(products, product.Product)
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0.9, 0.9),
		[Roact.Ref] = props[Roact.Ref],
	}, {
		ProductList = e(DevProductList, {
			products = products,

			imageButtonProps = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				ImageColor3 = Color3.fromRGB(255, 112, 255),
				Position = UDim2.fromScale(0.5, 0.5),
			},

			renderButton = function(product, nameRotation, nameTextRef)
				return {
					Name = e("Frame", {
						AnchorPoint = Vector2.new(0.5, 0),
						BackgroundTransparency = 1,
						LayoutOrder = 1,
						Position = UDim2.fromScale(0.5, 0.01),
						Size = UDim2.fromScale(0.9, 0.85),
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
						AnchorPoint = Vector2.new(0.5, 1),
						BackgroundTransparency = 1,
						Font = Enum.Font.GothamBold,
						LayoutOrder = 2,
						Position = UDim2.fromScale(0.5, 0.95),
						Size = UDim2.fromScale(0.9, 0.15),
						Text = "R$" .. product.Cost,
						TextColor3 = Color3.fromRGB(92, 255, 67),
						TextScaled = true,
					}),
				}
			end,
		}, {
			UIGridLayout = e("UIGridLayout", {
				CellPadding = UDim2.fromScale(0.01, 0.01),
				CellSize = UDim2.fromScale(0.23, 0.48),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
		}),
	})
end

return BuyBrains
