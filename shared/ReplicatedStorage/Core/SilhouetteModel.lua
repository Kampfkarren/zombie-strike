local function blacken(part)
	part.Color = Color3.new(0, 0, 0)
	part.Material = Enum.Material.SmoothPlastic

	if part:IsA("MeshPart") then
		part.TextureID = ""
	end
end

return function(pvInstance)
	if pvInstance:IsA("Part") then
		blacken(pvInstance)
	else
		for _, part in pairs(pvInstance:GetDescendants()) do
			if part:IsA("BasePart") then
				blacken(part)
			end
		end
	end

	return pvInstance
end
