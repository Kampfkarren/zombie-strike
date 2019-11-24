local ReplicatedStorage = game:GetService("ReplicatedStorage")

local State = require(ReplicatedStorage.State)

local Buttons = script.Parent.Main.Buttons

Buttons.Inventory.MouseButton1Click:connect(function()
	State:dispatch({
		type = "ToggleInventory",
	})
end)

Buttons.Store.MouseButton1Click:connect(function()
	State:dispatch({
		type = "ToggleStore",
	})

	State:dispatch({
		type = "OpenedStore",
	})
end)

Buttons.Small.Feedback.MouseButton1Click:connect(function()
	State:dispatch({
		type = "ToggleFeedback",
	})
end)

Buttons.Small.Settings.MouseButton1Click:connect(function()
	State:dispatch({
		type = "ToggleSettings",
	})
end)

State.changed:connect(function(new)
	Buttons.Store.NewLabel.Visible = new.store.new
end)
