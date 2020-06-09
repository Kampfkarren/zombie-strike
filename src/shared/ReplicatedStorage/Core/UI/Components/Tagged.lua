local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Vendor.Roact)

local Tagged = Roact.Component:extend("Tagged")

function Tagged:init()
	self.ref = Roact.createRef()
end

function Tagged:didMount()
	local object = self.ref:getValue()
	if object then
		CollectionService:AddTag(object, self.props.Tag)
	end
end

function Tagged:willUnmount()
	local object = self.ref:getValue()
	if object then
		CollectionService:RemoveTag(object, self.props.Tag)
	end
end

function Tagged:render()
	local child = assert(
		Roact.oneChild(self.props[Roact.Children]),
		"A child needs to be passed to Tagged"
	)

	assert(
		child.props[Roact.Ref] == nil,
		"Child of Tagged cannot have its own ref, Tagged is too dumb"
	)

	child.props[Roact.Ref] = self.ref

	return child
end

return Tagged
