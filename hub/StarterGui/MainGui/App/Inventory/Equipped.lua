local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CosmeticButton = require(script.Parent.Parent.Store.CosmeticButton)
local Cosmetics = require(ReplicatedStorage.Core.Cosmetics)
local Data = require(ReplicatedStorage.Core.Data)
local Loot = require(ReplicatedStorage.Core.Loot)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local ViewportFramePreviewComponent = require(ReplicatedStorage.Core.UI.Components.ViewportFramePreviewComponent)

local e = Roact.createElement
local UpdateCosmetics = ReplicatedStorage.Remotes.UpdateCosmetics

local Equipped = Roact.PureComponent:extend("Equipped")

function Equipped:init()
	self:ResetModel()
end

function Equipped:didUpdate(oldProps)
	if oldProps.equipped ~= self.props.equipped then
		self:ResetModel()
	end
end

function Equipped:ResetModel()
	if not self.props.Cosmetic then
		if self.props.equipped ~= nil then
			self:setState({
				model = Data.GetModel(self.props.equipped),
			})
		end
	end
end

function Equipped:render()
	local props = self.props

	local label = e("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Position = UDim2.fromScale(0.5, 1),
		Size = UDim2.fromScale(0.9, 0.3),
		Text = props.Name,
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
		ZIndex = 2,
	})

	if (props.equipped == nil and props.Default == nil) or not props.Cosmetic then
		local backgroundColor = Color3.fromRGB(215, 215, 215)
		local preview

		if props.equipped then
			backgroundColor = Loot.Rarities[props.equipped.Rarity].Color

			if self.state.model then
				preview = e(ViewportFramePreviewComponent, {
					Model = self.state.model,

					Native = {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0.9, 0.9),
					},
				})
			end
		end

		return e("ImageButton", {
			BackgroundTransparency = 1,
			Image = "http://www.roblox.com/asset/?id=3973353646",
			ImageColor3 = backgroundColor,
			LayoutOrder = props.LayoutOrder,
			Size = UDim2.fromScale(0.95, 0.9),
		}, {
			e("UIAspectRatioConstraint"),

			Preview = preview,
			Label = label,
		})
	elseif props.Cosmetic then
		return e(CosmeticButton, {
			Item = props.equipped or props.Default,
			PreviewSize = UDim2.fromScale(1, 1),

			Native = {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = "http://www.roblox.com/asset/?id=3973353646",
				LayoutOrder = props.LayoutOrder,
				Size = UDim2.fromScale(0.95, 0.9),

				[Roact.Event.Activated] = function()
					if props.equipped ~= nil then
						UpdateCosmetics:FireServer(props.Key)
					end
				end,
			},
		}, {
			e("UIAspectRatioConstraint"),
			Label = label,
		})
	end
end

return RoactRodux.connect(function(state, props)
	if props.Cosmetic then
		return {
			equipped = Cosmetics.Cosmetics[state.store.equipped[props.Key]],
		}
	else
		return {
			equipped = (state.equipment or {})["equipped" .. props.Key],
		}
	end
end)(Equipped)
