local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PerkDetails = require(ReplicatedStorage.Core.UI.Components.PerkDetails)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local ImageFloat = require(ReplicatedStorage.Assets.Tarmac.UI.float)

local App = {}

App.Context = Roact.createContext({
	openPerkDetails = function() end,
	perkDetailsOpen = false,
})

local AppBase = Roact.Component:extend("AppBase")

function AppBase:init()
	self.closePerkDetails = function()
		self:setState({
			perkDetails = Roact.None,
		})
	end

	self.openPerkDetails = function(perks, seed)
		self:setState({
			perkDetails = {
				Perks = perks,
				Seed = seed,
			},
		})
	end
end

function AppBase:render()
	local children = {}
	children.Contents = Roact.oneChild(self.props[Roact.Children])

	local perkDetails = self.state.perkDetails
	if perkDetails ~= nil then
		children.PerkDetails = e(PerkDetails, {
			Perks = perkDetails.Perks,
			Seed = perkDetails.Seed,

			RenderParent = function(element, size)
				return e("TextButton", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Text = "",
					[Roact.Event.Activated] = self.closePerkDetails,
				}, {
					PerkPopup = e("ImageLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Image = ImageFloat,
						Position = UDim2.fromScale(0.5, 0.5),
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(6, 4, 86, 20),
						Size = size + UDim2.fromScale(0.03, 0.03),
					}, {
						Inner = e("Frame", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = size,
						}, {
							Element = element,
						}),

						UIGradient = e("UIGradient", {
							Color = ColorSequence.new(Color3.fromRGB(65, 65, 65), Color3.fromRGB(82, 82, 82)),
							Rotation = 90,
						}),
					})
				})
			end,
		})
	end

	return e(App.Context.Provider, {
		value = {
			openPerkDetails = self.openPerkDetails,
			perkDetailsOpen = self.state.perkDetails ~= nil,
		},
	}, children)
end

App.AppBase = AppBase

return App
