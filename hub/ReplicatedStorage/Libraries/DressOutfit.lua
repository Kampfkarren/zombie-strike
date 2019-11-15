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

return function(character, outfit)
	if outfit.ItemType.Value == "BundleSimple" then
		local contents = outfit.Contents.Armor:GetChildren()

		if outfit.Contents.Helmet:IsA("Folder") then
			for _, helmet in pairs(outfit.Contents.Helmet:GetChildren()) do
				table.insert(contents, helmet)
			end
		else
			table.insert(contents, outfit.Contents.Helmet)
		end

		for _, clothing in pairs(contents) do
			local clothing = clothing:Clone()
			clothing.Parent = character

			if clothing:IsA("Accessory") then
				addAccessory(character, clothing)
			end
		end
	elseif outfit.ItemType.Value == "BundleComplex" then
		for _, bodyPart in pairs(outfit.Contents.Armor:GetChildren()) do
			if bodyPart:IsA("BasePart") then
				character.Humanoid:ReplaceBodyPartR15(bodyPart.Name, bodyPart:Clone())
			elseif bodyPart:IsA("Accessory") then
				addAccessory(character, bodyPart)
			end
		end

		character.Humanoid:ReplaceBodyPartR15(Enum.BodyPartR15.Head, character.Contents.Helmet:Clone())
	end
end
