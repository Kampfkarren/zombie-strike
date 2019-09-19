return function(item, hand) -- move an item from the back to the hand
	local character = item.Parent
	local handle = item.PrimaryPart

	-- remove unequipped stuff
	if handle:FindFirstChild("UnequippedWeld") then
		handle.UnequippedWeld:Destroy()
	end

	-- add equipped stuff
	local gripMotor = Instance.new("Motor6D")
		gripMotor.Name = "GripMotor"
		gripMotor.Part0 = hand or character.RightHand
		gripMotor.Part1 = handle
		gripMotor.C0 = CFrame.Angles(-math.pi / 2, 0, 0)
		gripMotor.C1 = handle.Grip.CFrame
		gripMotor.Parent = handle
end
