local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Data = require(ReplicatedStorage.Core.Data)
local DressOutfit = require(ReplicatedStorage.Libraries.DressOutfit)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local Promise = require(ReplicatedStorage.Core.Promise)
local ViewportFramePreviewComponent = require(ReplicatedStorage.Core.UI.Components.ViewportFramePreviewComponent)

local e = Roact.createElement

local dummies = {}
local helmetArmorPreviews = {}

local function getDummyFor(instance)
	if dummies[instance] then
		return dummies[instance]
	end

	local dummy = ReplicatedStorage.Dummy:Clone()

	local uuid = Instance.new("ObjectValue")
	uuid.Name = "UUID"
	uuid.Value = instance
	uuid.Parent = dummy

	dummy.Parent = Workspace
	DressOutfit(dummy, instance)
	RunService.Heartbeat:wait()
	dummy.Parent = nil

	dummies[instance] = dummy

	return dummy
end

local function getHelmetArmorPreview(cosmetic)
	if helmetArmorPreviews[cosmetic] then
		return helmetArmorPreviews[cosmetic]
	else
		local promise = Promise.promisify(function()
			local model = Data.GetModel(cosmetic)
			model.Parent = Workspace
			RunService.Heartbeat:wait()
			model.Parent = nil
			return model
		end)()

		helmetArmorPreviews[cosmetic] = promise
		return promise
	end
end

local function ViewportFrameCosmeticPreview(props)
	return e(ViewportFramePreviewComponent, {
		Native = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = props.size,
		},

		Model = props.model,
		Scale = props.previewScale,
		Update = props.updateSet,
	})
end

return function(props)
	local cosmetic = props.item

	if cosmetic.Type == "Face" or cosmetic.Type == "Particle" then
		return e("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = (cosmetic.Image or cosmetic.Instance).Texture,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = props.size,
		}, {
			UIScale = e("UIScale", {
				Scale = props.previewScale,
			}),
		})
	elseif cosmetic.Type == "LowTier" or cosmetic.Type == "HighTier" then
		return e(ViewportFrameCosmeticPreview, {
			model = Promise.promisify(getDummyFor)(cosmetic.Instance),
			previewScale = props.previewScale,
			size = props.size,
			updateSet = props.updateSet,
		})
	elseif cosmetic.Type == "Helmet" or cosmetic.Type == "Armor" then
		cosmetic.UUID = cosmetic.Instance:GetFullName()

		return e(ViewportFrameCosmeticPreview, {
			model = getHelmetArmorPreview(cosmetic),
			previewScale = props.previewScale,
			size = props.size,
			updateSet = props.updateSet,
		})
	else
		error("unknown item type for preview: " .. cosmetic.Type)
	end
end
