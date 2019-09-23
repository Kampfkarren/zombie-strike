local RunService = game:GetService("RunService")

local ROTATE_RATE = 1

local bases = {}
local rotators = {}
local totalDelta = 0

RunService.Heartbeat:connect(function(delta)
	totalDelta = totalDelta + delta

	for model in pairs(rotators) do
		model:SetPrimaryPartCFrame(
			CFrame.new(model.PrimaryPart.Position)
			* CFrame.Angles(0, bases[model.UUID.Value] + totalDelta * ROTATE_RATE, 0)
		)
	end
end)

return function(viewportFrame, model)
	local model = model:Clone()

	if viewportFrame.CurrentCamera then
		viewportFrame.CurrentCamera:Destroy()
	end

	local camera = Instance.new("Camera")
	model:SetPrimaryPartCFrame(CFrame.new())
	model.Parent = camera

	local modelCFrame, size = model:GetBoundingBox()
	model:TranslateBy(-modelCFrame.Position)

	local distance = size.Magnitude * 1.2
	local dir = Vector3.new(0.5, 0, 0.5).Unit
	camera.CFrame = CFrame.new(distance * dir, Vector3.new(0, 0, 0))

	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera

	if not bases[model.UUID.Value] then
		bases[model.UUID.Value] = math.random() * math.pi
	end

	rotators[model] = true

	model.AncestryChanged:connect(function()
		if not model:IsDescendantOf(game) then
			rotators[model] = nil
		end
	end)
end
