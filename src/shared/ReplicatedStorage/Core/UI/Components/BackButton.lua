local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local EventConnection = require(ReplicatedStorage.Core.UI.Components.EventConnection)
local GradientButton = require(ReplicatedStorage.Core.UI.Components.GradientButton)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local ImageArrow = require(ReplicatedStorage.Assets.Tarmac.UI.arrow)
local ImageFloat = require(ReplicatedStorage.Assets.Tarmac.UI.float)

local e = Roact.createElement

local function BackButton(props)
	return e(GradientButton, {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		Image = ImageFloat,
		Position = props.Position or UDim2.new(0, 0, 1, -15),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(6, 4, 86, 20),
		Size = UDim2.fromOffset(188, 54),

		AnimateSpeed = 14,
		MinGradient = Color3.fromRGB(201, 51, 37),
		MaxGradient = Color3.fromRGB(175, 38, 25),
		HoveredMaxGradient = Color3.fromRGB(197, 44, 30),

		[Roact.Event.Activated] = props.GoBack,
	}, {
		GoBackLabel = e("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			Position = UDim2.new(0, 57, 0.5, 0),
			Size = UDim2.fromOffset(105, 28),
			Text = "Go back",
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 24,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextYAlignment = Enum.TextYAlignment.Center,
		}),

		ArrowImage = e("ImageLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Image = ImageArrow,
			Position = UDim2.new(0, 30, 0.5, 0),
			Size = UDim2.fromOffset(22, 14),
		}),

		GamepadConnection = e(EventConnection, {
			callback = function(inputObject, gameProcessed)
				if gameProcessed then return end

				if inputObject.KeyCode == Enum.KeyCode.ButtonB then
					props.GoBack()
				end
			end,
			event = UserInputService.InputBegan,
		}),
	})
end

return BackButton
