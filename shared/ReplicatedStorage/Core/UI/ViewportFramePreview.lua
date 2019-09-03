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

	local distance = size.Magnitude * 0.8
	local dir = Vector3.new(-1, 0, -1).Unit
	camera.CFrame = CFrame.new(distance * dir, Vector3.new(0, 0, 0))

	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera
end
