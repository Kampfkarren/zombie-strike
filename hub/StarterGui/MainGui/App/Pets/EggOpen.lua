local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Data = require(ReplicatedStorage.Core.Data)
local EventConnection = require(ReplicatedStorage.Core.UI.Components.EventConnection)
local GlowAura = require(ReplicatedStorage.Core.UI.Components.GlowAura)
local PetsDictionary = require(ReplicatedStorage.Core.PetsDictionary)
local Spin = require(ReplicatedStorage.Core.UI.Components.Spin)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local StyledButton = require(ReplicatedStorage.Core.UI.Components.StyledButton)
local TweenIn = require(ReplicatedStorage.Core.UI.Components.TweenIn)
local ViewportFramePreviewComponent = require(ReplicatedStorage.Core.UI.Components.ViewportFramePreviewComponent)

local e = Roact.createElement

local EggOpen = Roact.PureComponent:extend("EggOpen")

local COLOR_ACTIVE = Color3.fromRGB(32, 146, 81)

function EggOpen:init()
	self.eggOpened = function(petModel, petRarity)
		self:setState({
			open = true,
			petModel = petModel,
			petRarity = petRarity,
		})
	end

	self.close = function()
		self:setState({
			open = false,
		})
	end
end

function EggOpen:didMount()
	self:SetPetModel()
end

function EggOpen:didUpdate()
	if self.state.open then
		self:SetPetModel()
		SoundService.ImportantSFX.ZombiePass.Unlock1:Play()
	end

	self.props.updateEggOpen(self.state.open)
end

function EggOpen:SetPetModel()
	if self.state.petModel and self.state.model == nil then
		self:setState({
			model = Data.GetModel({
				Model = self.state.petModel,
				Type = "Pet",
				UUID = HttpService:GenerateGUID(false):gsub("-", ""),
			}),
		})
	end
end

function EggOpen:render()
	if not self.state.open or self.state.model == nil then
		return e(EventConnection, {
			callback = self.eggOpened,
			event = ReplicatedStorage.Remotes.OpenEgg.OnClientEvent,
		})
	end

	local pet = PetsDictionary.Pets[self.state.petModel]
	local rarity = PetsDictionary.Rarities[self.state.petRarity]

	local color = rarity.Style.Color
	local h, s, v = Color3.toHSV(color)
	local accentColor = Color3.fromHSV(h, s, v * 0.8)

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		Inner = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.5, 0.9),
		}, {
			UIAspectRatioConstraint = e("UIAspectRatioConstraint"),

			Background = e(TweenIn, {
				TweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			}, {
				Spin = e(Spin, {
					Speed = 8,
				}, {
					GlowAura = e(GlowAura, {
						Color = color,
					}),
				}),

				Preview = e(TweenIn, {
					TweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0.6),
				}, {
					Model = e(ViewportFramePreviewComponent, {
						Model = self.state.model,

						Native = {
							BackgroundTransparency = 1,
							Size = UDim2.fromScale(1, 1),
						},
					}),
				}),
			}),

			TextTopLabel = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Size = UDim2.fromScale(1, 0.07),
				Text = "You earned...",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				TextStrokeColor3 = accentColor,
				TextStrokeTransparency = 0.3,
				ZIndex = 2,
			}),

			TextTopPetName = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamSemibold,
				Position = UDim2.fromScale(0, 0.07),
				Size = UDim2.fromScale(1, 0.13),
				Text = rarity.Style.Name .. " " .. pet.Name,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				TextStrokeColor3 = accentColor,
				TextStrokeTransparency = 0.3,
				ZIndex = 2,
			}),

			OK = e(StyledButton, {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundColor3 = COLOR_ACTIVE,
				Position = UDim2.fromScale(0.5, 0.9),
				Size = UDim2.fromScale(0.65, 0.1),
				ZIndex = 2,
				[Roact.Event.Activated] = self.close,
			}, {
				Label = e("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.75, 0.75),
					Text = "OK",
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
				}),
			}),
		}),
	})
end

return EggOpen

