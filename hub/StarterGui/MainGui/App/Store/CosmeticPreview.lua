local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Data = require(ReplicatedStorage.Core.Data)
local Loot = require(ReplicatedStorage.Core.Loot)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local Promise = require(ReplicatedStorage.Core.Promise)
local ViewportFramePreviewComponent = require(ReplicatedStorage.Core.UI.Components.ViewportFramePreviewComponent)

local e = Roact.createElement

-- https://devforum.roblox.com/t/view-port-frame-accessories/227171/2
local function addAccessory(character, accessory)
	local attachment = accessory.Handle:FindFirstChildOfClass("Attachment") -- Not all Accessories are guaranteed to have an Attachment - if not, we'll use default hat placement.
	local weld = Instance.new("Weld")
	weld.Name = "AccessoryWeld"
	weld.Part0 = accessory.Handle

	if attachment then
		-- The found attachment name in the accessory matches an existing attachment in the character rig, which we'll make the weld connect to.
		local other = character:FindFirstChild(tostring(attachment), true)
		weld.C0 = attachment.CFrame
		weld.C1 = other.CFrame
		weld.Part1 = other.Parent
	else
		-- No attachment found. The placement is defined using the legacy hat placement.
		weld.C1 = CFrame.new(0, character.Head.Size.Y / 2, 0) * accessory.AttachmentPoint:inverse()
		weld.Part1 = character.Head
	end

	-- Updates the accessory to be positioned accordingly to the weld we just created.
	accessory.Handle.CFrame = weld.Part1.CFrame * weld.C1 * weld.C0:inverse()
	accessory.Parent = character
	weld.Parent = accessory.Handle
end

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

	if instance.ItemType.Value == "BundleSimple" then
		local contents = instance.Contents.Armor:GetChildren()

		if instance.Contents.Helmet:IsA("Folder") then
			for _, helmet in pairs(instance.Contents.Helmet:GetChildren()) do
				table.insert(contents, helmet)
			end
		else
			table.insert(contents, instance.Contents.Helmet)
		end

		for _, clothing in pairs(contents) do
			local clothing = clothing:Clone()
			clothing.Parent = dummy

			if clothing:IsA("Accessory") then
				addAccessory(dummy, clothing)
			end
		end
	elseif instance.ItemType.Value == "BundleComplex" then
		dummy.Parent = Workspace

		for _, bodyPart in pairs(instance.Contents.Armor:GetChildren()) do
			if bodyPart:IsA("BasePart") then
				dummy.Humanoid:ReplaceBodyPartR15(bodyPart.Name, bodyPart:Clone())
			elseif bodyPart:IsA("CharacterAppearance") then
				bodyPart:Clone().Parent = dummy
			elseif bodyPart:IsA("Accessory") then
				addAccessory(dummy, bodyPart)
			end
		end

		local helmet = instance.Contents.Helmet:Clone()
		if helmet:IsA("BasePart") then
			dummy.Humanoid:ReplaceBodyPartR15(Enum.BodyPartR15.Head, helmet)
		elseif helmet:IsA("Folder") then
			for _, accessory in pairs(helmet:GetDescendants()) do
				addAccessory(dummy, accessory)
			end
		else
			if helmet:FindFirstChild("NoHead") then
				dummy.Head.Transparency = 1
				dummy.Head:FindFirstChildOfClass("Decal"):Destroy()
			end

			addAccessory(dummy, helmet)
		end

		RunService.Heartbeat:wait()
		dummy.Parent = nil
	end

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
			ScaleType = Enum.ScaleType.Crop,
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
	elseif Loot.IsWearable(cosmetic) then
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
