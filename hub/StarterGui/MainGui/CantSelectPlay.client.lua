local ReplicatedStorage = game:GetService("ReplicatedStorage")

script.Parent.Main.CantSelect.PlayButton.MouseButton1Click:connect(function()
	ReplicatedStorage.LocalEvents.PressPlay:Fire()
end)
