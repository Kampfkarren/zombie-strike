local ReplicatedStorage = game:GetService("ReplicatedStorage")

local State = require(ReplicatedStorage.State)

script.Parent.Main.Buttons.Store.MouseButton1Click:connect(function()
	State:dispatch({
		type = "ToggleStore",
	})
end)
