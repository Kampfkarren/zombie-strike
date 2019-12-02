local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DevProductList = require(script.Parent.DevProductList)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local XPMultiplierDictionary = require(ReplicatedStorage.XPMultiplierDictionary)

local e = Roact.createElement
local XPMultipliers = Roact.PureComponent:extend("XPMultipliers")

function XPMultipliers:init()
	self.timer, self.updateTimer = Roact.createBinding(0)

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
	for _, product in pairs(XPMultiplierDictionary) do
		table.insert(products, product.Product)
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Size = UDim2.fromScale(0.9, 0.9),
		[Roact.Ref] = props[Roact.Ref],
	}, {
		Products = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0.8),
		}, {
			ProductList = e(DevProductList, {
				products = products,

				imageButtonProps = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					ImageColor3 = Color3.fromRGB(154, 255, 110),
					Position = UDim2.fromScale(0.5, 0.5),
				},

				renderButton = function(product, nameRotation, nameTextRef)
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
							Text = "R$" .. product.Cost,
							TextColor3 = Color3.fromRGB(92, 255, 67),
							TextScaled = true,
						}),
					}
				end,
			}, {
				UIListLayout = e("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0.02, 0),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
			})
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
