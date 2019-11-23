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
	self.ref = Roact.createRef()
end

function AutomatedScrollingFrameComponent:render()
	local props = copy(self.props)
	props[Roact.Ref] = self.ref
	return e("ScrollingFrame", props)
end

function AutomatedScrollingFrameComponent:didMount()
	AutomatedScrollingFrame(self.ref:getValue())
end

return AutomatedScrollingFrameComponent
