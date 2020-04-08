local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Color3Lerp = require(ReplicatedStorage.Core.Color3Lerp)
local GradientButton = require(ReplicatedStorage.Core.UI.Components.GradientButton)
local LootStyles = require(ReplicatedStorage.Core.LootStyles)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local function copy(list)
	local copy = {}
	for key, value in pairs(list) do
		copy[key] = value
	end
	return copy
end

local function tint(base, tint)
	return Color3Lerp(base, tint, 0.2)
end

local function RarityTintedGradientButton(props)
	local props = copy(props)

	if props.Rarity and props.Rarity > 1 then
		local minGradient = props.MinGradient or GradientButton.defaultProps.MinGradient
		local maxGradient = props.MaxGradient or GradientButton.defaultProps.MaxGradient
		local hoveredMaxGradient = props.HoveredMaxGradient or GradientButton.defaultProps.HoveredMaxGradient

		local rarity = LootStyles[props.Rarity].Color

		props.MinGradient = tint(minGradient, rarity)
		props.MaxGradient = tint(maxGradient, rarity)
		props.HoveredMaxGradient = tint(hoveredMaxGradient, rarity)
	end

	props.Rarity = nil

	return e(GradientButton, props)
end

return RarityTintedGradientButton
