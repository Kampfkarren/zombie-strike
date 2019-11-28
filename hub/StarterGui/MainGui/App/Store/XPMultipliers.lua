local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local XPMultiplierDictionary = require(ReplicatedStorage.XPMultiplierDictionary)

local e = Roact.createElement
local LocalPlayer = Players.LocalPlayer
local ProductCard = Roact.PureComponent:extend("ProductCard")
local XPMultipliers = Roact.PureComponent:extend("XPMultipliers")

local ROTATE_RATE = 0.3
local TEXT_MAX_ROTATE = 8

function ProductCard:init()
	self.nameTextRef = Roact.createRef()
	self.uiScaleRef = Roact.createRef()

	local nameRotation, setNameRotation = Roact.createBinding(0)
	self.nameRotation = nameRotation

	local rotateConnection, resetConnection

	self.activated = function()
		self.tweens.buttonClick:Play()
		SoundService.SFX.Purchase:Play()
		MarketplaceService:PromptProductPurchase(LocalPlayer, self.props.Product)
	end

	self.hover = function()
		self.tweens.buttonHoverIn:Play()

		if rotateConnection then
			warn("rotateConnection not disconnected on hover")
			rotateConnection:Disconnect()
		end

		if resetConnection then
			resetConnection:Disconnect()
			resetConnection = nil
		end

		local total = 0

		rotateConnection = RunService.RenderStepped:connect(function(delta)
			total = total + (delta / ROTATE_RATE)
			setNameRotation(math.sin(total) * TEXT_MAX_ROTATE)
		end)
	end

	self.unhover = function()
		self.tweens.buttonHoverOut:Play()

		if rotateConnection then
			rotateConnection:Disconnect()
			rotateConnection = nil
		end

		local currentRotation = nameRotation:getValue() / TEXT_MAX_ROTATE
		local sign = math.sign(currentRotation)
		currentRotation = math.abs(currentRotation)

		resetConnection = RunService.RenderStepped:connect(function(delta)
			currentRotation = math.max(0, currentRotation - delta / ROTATE_RATE)
			setNameRotation(currentRotation * TEXT_MAX_ROTATE * sign)

			if currentRotation == 0 then
				resetConnection:Disconnect()
				resetConnection = nil
			end
		end)
	end

	self.tweens = {}
end

function ProductCard:didMount()
	self.tweens.buttonHoverIn = TweenService:Create(
		self.uiScaleRef:getValue(),
		TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{ Scale = 1 }
	)

	self.tweens.buttonHoverOut = TweenService:Create(
		self.uiScaleRef:getValue(),
		TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{ Scale = 0.9 }
	)

	self.tweens.buttonClick = TweenService:Create(
		self.uiScaleRef:getValue(),
		TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true),
		{ Scale = 0.8 }
	)
end

function ProductCard:render()
	local props = self.props

	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = props.Cost,
		Size = UDim2.fromScale(0.23, 1),
	}, {
		e("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = "http://www.roblox.com/asset/?id=3792742614",
			ImageColor3 = Color3.fromRGB(154, 255, 110),
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = Enum.ScaleType.Slice,
			Size = UDim2.fromScale(1, 1),
			SliceCenter = Rect.new(30, 100, 50, 244),
			[Roact.Event.Activated] = self.activated,
			[Roact.Event.MouseEnter] = self.hover,
			[Roact.Event.MouseLeave] = self.unhover,
		}, {
			e("UIScale", {
				Scale = 0.9,
				[Roact.Ref] = self.uiScaleRef,
			}),

			e("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0.02, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			Image = e("ImageLabel", {
				BackgroundTransparency = 1,
				Image = props.Image,
				LayoutOrder = 0,
				Size = UDim2.fromScale(0.9, 0.5),
			}, {
				e("UIAspectRatioConstraint"),
			}),

			Name = e("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 1,
				Size = UDim2.fromScale(0.85, 0.15),
			}, {
				Label = e("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Rotation = self.nameRotation,
					Size = UDim2.fromScale(1, 1),
					Text = props.Name,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					[Roact.Ref] = self.nameTextRef,
				}),
			}),

			Cost = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				LayoutOrder = 2,
				Size = UDim2.fromScale(0.7, 0.12),
				Text = "R$" .. props.Cost,
				TextColor3 = Color3.fromRGB(92, 255, 67),
				TextScaled = true,
			}),
		}),
	})
end

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
			e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0.02, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			One = e(ProductCard, XPMultiplierDictionary[1]),
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
