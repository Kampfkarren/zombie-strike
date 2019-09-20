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
end
