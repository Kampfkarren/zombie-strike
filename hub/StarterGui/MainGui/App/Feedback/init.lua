local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Close = require(script.Parent.Close)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)

local e = Roact.createElement

local Feedback = Roact.PureComponent:extend("Feedback")

function Feedback:init()
	self.textBoxRef = Roact.createRef()

	self.send = function()
		local textBoxValue = self.textBoxRef:getValue()
		local text = textBoxValue.Text

		if text:match("^%s*$") then
			self.props.close()
		else
			ReplicatedStorage.Remotes.SendFeedback:FireServer(text)
			self:setState({
				feedbackSent = true,
			})
		end
	end
end

function Feedback:render()
	local children = {}

	children.Close = e(Close, {
		onClose = self.props.close,
	})

	children.UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
		AspectRatio = 2,
	})

	if self.state.feedbackSent then
		children.Label = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.95, 0.85),
			Text = "Thanks for your feedback!",
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			ZIndex = 0,
		})
	else
		children.Label = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			Position = UDim2.fromScale(0.5, 0.01),
			Size = UDim2.fromScale(0.95, 0.2),
			Text = "Tell us your feedback!",
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			ZIndex = 0,
		})

		children.Frame = e("Frame", {
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.01, 0.22),
			Size = UDim2.fromScale(0.85, 0.75),
		}, {
			Input = e("TextBox", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				ClearTextOnFocus = false,
				Font = Enum.Font.GothamBold,
				PlaceholderColor3 = Color3.new(0.88, 0.88, 0.88),
				PlaceholderText = "Enter feedback here...",
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.98, 0.98),
				Text = "",
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 24,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				[Roact.Ref] = self.textBoxRef,
			}),
		})

		children.SendFrame = e("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Color3.fromRGB(76, 209, 55),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.98, 0.6),
			Size = UDim2.fromScale(0.1, 0.75),
			Text = "",
			[Roact.Event.MouseButton1Click] = self.send,
		}, {
			Send = e("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromScale(0.5, 0.5),
				Rotation = 90,
				Size = UDim2.fromScale(3, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				Text = "SEND",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
			})
		})
	end

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 190, 118),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 0.55),
		Visible = self.props.open,
	}, children)
end

return RoactRodux.connect(function(state)
	return {
		open = state.page.current == "Feedback",
	}
end, function(dispatch)
	return {
		close = function()
			dispatch({
				type = "CloseFeedback",
			})
		end,
	}
end)(Feedback)
