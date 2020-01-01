local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Vendor.Roact)
local UserThumbnailPromise = require(ReplicatedStorage.Core.UI.UserThumbnail)

local e = Roact.createElement

local UserThumbnail = Roact.PureComponent:extend("UserThumbnail")

local function copy(list)
	local copy = {}
	for key, value in pairs(list) do
		copy[key] = value
	end
	return copy
end

function UserThumbnail:init()
	local promise = UserThumbnailPromise(self.props.Player)
	promise:andThen(function(avatar)
		self:setState({
			avatar = avatar,
		})
	end)

	self:setState({
		avatar = "",
	})
end

function UserThumbnail:render()
	local props = copy(self.props)
	props.Image = self.state.avatar
	props.Player = nil

	return e("ImageLabel", props)
end

return UserThumbnail
