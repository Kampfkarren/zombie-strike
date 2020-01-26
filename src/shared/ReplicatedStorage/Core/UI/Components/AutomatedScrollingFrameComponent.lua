local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AutomatedScrollingFrame = require(ReplicatedStorage.Core.UI.AutomatedScrollingFrame)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local AutomatedScrollingFrameComponent = Roact.PureComponent:extend("AutomatedScrollingFrameComponent")
local e = Roact.createElement

local function copy(list)
	local copy = {}
	for key, value in pairs(list) do
		copy[key] = value
	end
	return copy
end

function AutomatedScrollingFrameComponent:init()
	self.ref = self.props[Roact.Ref] or Roact.createRef()
end

function AutomatedScrollingFrameComponent:render()
	local props = copy(self.props)
	props.Layout = nil
	props[Roact.Ref] = self.ref
	return e("ScrollingFrame", props)
end

function AutomatedScrollingFrameComponent:didMount()
	local layout

	if self.props.Layout then
		layout = self.props.Layout:getValue()
	end

	AutomatedScrollingFrame(self.ref:getValue(), layout)
end

return AutomatedScrollingFrameComponent
