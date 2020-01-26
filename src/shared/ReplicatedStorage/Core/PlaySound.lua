return function(soundFolder, parent)
	local children = soundFolder:GetChildren()
	local sound = children[math.random(#children)]:Clone()
	sound.Parent = parent or soundFolder
	sound:Play()
end
