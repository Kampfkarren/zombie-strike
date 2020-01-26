local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CosmeticButton = require(script.Parent.Parent.Store.CosmeticButton)
local Cosmetics = require(ReplicatedStorage.Core.Cosmetics)
local Data = require(ReplicatedStorage.Core.Data)
local Loot = require(ReplicatedStorage.Core.Loot)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local SpraysDictionary = require(ReplicatedStorage.Core.SpraysDictionary)
local StyledButton = require(ReplicatedStorage.Core.UI.Components.StyledButton)
local ViewportFramePreviewComponent = require(ReplicatedStorage.Core.UI.Components.ViewportFramePreviewComponent)

local e = Roact.createElement
local UpdateCosmetics = ReplicatedStorage.Remotes.UpdateCosmetics

local Equipped = Roact.PureComponent:extend("Equipped")

function Equipped:init()
	self:ResetModel()

	self.unequip = self.props.Unequip or function()
		if self.props.Cosmetic and self.props.equipped ~= nil then
			UpdateCosmetics:FireServer(self.props.Key)
		end
	end
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

	local aspectRatioConstraint
	if not props.Size then
		aspectRatioConstraint = e("UIAspectRatioConstraint", {
			AspectRatio = props.AspectRatio,
		})
	end

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

		return e(StyledButton, {
			BackgroundColor3 = backgroundColor,
			BackgroundTransparency = 1,
			LayoutOrder = props.LayoutOrder,
			Square = true,
			Size = props.Size or UDim2.fromScale(0.95, 0.9),
			Square = not props.Rectangle,

			[Roact.Event.Activated] = self.unequip,
		}, {
			UIAspectRatioConstraint = aspectRatioConstraint,
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
				Size = props.Size or UDim2.fromScale(0.95, 0.9),

				[Roact.Event.Activated] = self.unequip,
			},
		}, {
			UIAspectRatioConstraint = aspectRatioConstraint,
			Label = label,
		})
	end
end

return RoactRodux.connect(function(state, props)
	if props.Cosmetic then
		if props.Key == "Spray" then
			local equippedSpray = state.sprays.equipped
			return equippedSpray and {
				equipped = SpraysDictionary[equippedSpray],
			}
		else
			return {
				equipped = Cosmetics.Cosmetics[state.store.equipped[props.Key]],
			}
		end
	else
		return {
			equipped = (state.equipment or {})["equipped" .. props.Key],
		}
	end
end)(Equipped)
