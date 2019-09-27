local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AutomatedScrollingFrame = require(ReplicatedStorage.Core.UI.AutomatedScrollingFrame)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local AutomatedScrollingFrameComponent = Roact.PureComponent:extend("AutomatedScrollingFrameComponent")
local e = Roact.createElement

function AutomatedScrollingFrameComponent:init()
	self.ref = Roact.createRef()
end

function AutomatedScrollingFrameComponent:render()
	self.props[Roact.Ref] = self.ref
	return e("ScrollingFrame", self.props)
end

function AutomatedScrollingFrameComponent:didMount()
	AutomatedScrollingFrame(self.ref:getValue())
end

return AutomatedScrollingFrameComponent
