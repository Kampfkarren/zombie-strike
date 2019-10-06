local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local CosmeticPreview = require(script.Parent.CosmeticPreview)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local CosmeticButton = Roact.PureComponent:extend("CosmeticButton")
local e = Roact.createElement

local COSMETIC_COLORS = {
	Default = Color3.fromRGB(215, 215, 215),
	Face = Color3.fromRGB(156, 136, 255),
	Particle = Color3.fromRGB(46, 204, 113),
	LowTier = Color3.fromRGB(9, 132, 227),
	HighTier = Color3.fromRGB(238, 82, 83),
}

function CosmeticButton:init()
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

function CosmeticButton:render()
	local color = COSMETIC_COLORS[
		self.props.Item.ParentType
		or self.props.Item.Type
	]

	local newProps = {
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ImageColor3 = color,

		[Roact.Event.MouseEnter] = self.hoverIn,
		[Roact.Event.MouseLeave] = self.hoverOut,
	}

	for name, property in pairs(self.props.Native or {}) do
		newProps[name] = property
	end

	local children = self.props[Roact.Children] or {}
	children.Preview = e(CosmeticPreview, {
		item = self.props.Item,
		previewScale = self.previewScale,
		size = self.props.PreviewSize,
		updateSet = self.updateSet,
	})

	return e("ImageButton", newProps, children)
end

return CosmeticButton
