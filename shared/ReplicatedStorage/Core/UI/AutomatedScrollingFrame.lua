return function(scrollingFrame, layout)
	layout = layout or scrollingFrame:FindFirstChildWhichIsA("UIGridStyleLayout")

	local function updateFrame()
		scrollingFrame.CanvasSize = UDim2.new(0, layout.AbsoluteContentSize.X, 0, layout.AbsoluteContentSize.Y)
	end

	updateFrame()
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):connect(updateFrame)
end
