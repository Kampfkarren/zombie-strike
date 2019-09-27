local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Core.Promise)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local ViewportFramePreview = require(ReplicatedStorage.Core.UI.ViewportFramePreview)

local e = Roact.createElement
local ViewportFramePreviewComponent = Roact.PureComponent:extend("ViewportFramePreviewComponent")

function ViewportFramePreviewComponent:init()
	self.frameRef = Roact.createRef()

	self.props.Update(function()
		self:setState({
			scale = self.props.Scale:getValue(),
		})
	end)

	self:setState({
		scale = self.props.Scale:getValue(),
	})
end

function ViewportFramePreviewComponent:render()
	self.props.Native[Roact.Ref] = self.frameRef

	return e("ViewportFrame", self.props.Native)
end

function ViewportFramePreviewComponent:didMount()
	local modelPromise = self.props.Model

	if not Promise.is(modelPromise) then
		modelPromise = Promise.resolve(modelPromise)
	end

	modelPromise:andThen(function(model)
		self.viewportFramePreview = ViewportFramePreview(self.frameRef:getValue(), model)
		self.viewportFramePreview:UpdateScale(self.state.scale)
	end)
end

function ViewportFramePreviewComponent:didUpdate()
	if self.viewportFramePreview then
		self.viewportFramePreview:UpdateScale(self.state.scale)
	end
end

return ViewportFramePreviewComponent
