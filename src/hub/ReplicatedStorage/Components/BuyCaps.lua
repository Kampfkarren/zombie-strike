local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local BrainsPurchase = require(ReplicatedStorage.Core.UI.Components.BrainsPurchase)
local CapsDictionary = require(ReplicatedStorage.CapsDictionary)
local FormatNumber = require(ReplicatedStorage.Core.FormatNumber)
local ProductCard = require(script.Parent.ProductCard)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local BuyCaps = Roact.Component:extend("BuyCaps")

function BuyCaps:init()
	local nonce = 0

	self.finishBuy = function()
		local ourNonce = nonce + 1
		nonce = ourNonce

		local connection
		connection = self.props.remote.OnClientEvent:connect(function(nonce)
			if nonce == ourNonce then
				SoundService.SFX.Purchase:Play()
			elseif nonce > ourNonce then
				-- The one we're listening to was ignored for whatever reason
				connection:Disconnect()
			end
		end)

		self.props.remote:FireServer(nonce, self.state.buyingIndex)
		self.closeBuy()
	end

	self.closeBuy = function()
		self:setState({
			buying = Roact.None,
			buyingIndex = Roact.None,
		})
	end
end

function BuyCaps:render()
	local purchasePrompt

	local children = {}
	children.UIGridLayout = e("UIGridLayout", {
		CellPadding = UDim2.fromScale(0.01, 0.01),
		CellSize = UDim2.fromScale(0.23, 0.48),
		FillDirection = Enum.FillDirection.Horizontal,
		FillDirectionMaxCells = 3,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	})

	local function renderButton(product, nameRotation, nameTextRef)
		return {
			Name = e("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				LayoutOrder = 1,
				Position = UDim2.fromScale(0.5, 0.05),
				Size = UDim2.fromScale(0.7, 0.2),
			}, {
				Label = e("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Rotation = nameRotation,
					Size = UDim2.fromScale(1, 1),
					Text = FormatNumber(product.Caps),
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					[Roact.Ref] = nameTextRef,
				}),
			}),

			Value = product.Value and e("TextLabel", {
				AnchorPoint = Vector2.new(0, 1),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromScale(0.07, 0.8),
				Size = UDim2.fromScale(0.9, 0.1),
				TextColor3 = Color3.new(0, 1, 0),
				Text = ("+%d%% Value!"):format(product.Value),
				TextScaled = true,
				TextStrokeColor3 = Color3.new(0, 0.2, 0),
				TextStrokeTransparency = 0.7,
			}),

			Image = e("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = product.Image,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.7, 0.6),
			}, {
				e("UIAspectRatioConstraint"),
			}),

			Cost = e("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				LayoutOrder = 2,
				Position = UDim2.fromScale(0.5, 0.95),
				Size = UDim2.fromScale(0.9, 0.15),
				Text = FormatNumber(product.Cost) .. "🧠",
				TextColor3 = Color3.fromRGB(255, 205, 248),
				TextScaled = true,
			}),
		}
	end

	if self.state.buying then
		purchasePrompt = self.state.buying and e(BrainsPurchase, {
			Cost = self.state.buying.Cost,
			Scale = self.props.ConfirmPromptScale,
			Name = FormatNumber(self.state.buying.Caps) .. " caps",
			Window = self.props[Roact.Ref],

			OnBuy = self.finishBuy,
			OnClose = self.closeBuy,
		})
	end

	for index, product in ipairs(CapsDictionary) do
		children["Product" .. index] = e(ProductCard, {
			imageButtonProps = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				ImageColor3 = Color3.fromRGB(255, 66, 66),
				Position = UDim2.fromScale(0.5, 0.5),
			},

			activate = function()
				self:setState({
					buying = product,
					buyingIndex = index,
				})
			end,

			playPurchaseSound = false,
			product = product,
			renderButton = renderButton,
		}, {
			UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
		})
	end

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		LayoutOrder = 6,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.9, 0.9),
		[Roact.Ref] = self.props[Roact.Ref],
	}, {
		PurchasePrompt = purchasePrompt,

		Inner = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		}, children),
	})
end

return BuyCaps
