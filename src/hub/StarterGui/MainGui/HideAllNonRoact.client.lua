local ReplicatedStorage = game:GetService("ReplicatedStorage")

local State = require(ReplicatedStorage.State)

local Main = script.Parent.Main

local HIDE_ELEMENTS = {
	Main.Abilities,
	Main.Brains,
	Main.Buttons,
	Main.Gold,
	Main.PlayFrame,
	Main.SquadMembers,
	Main.Trading,
	Main.PlayButton,
	Main.Ammo,
}

State.changed:connect(function(state)
	for _, element in ipairs(HIDE_ELEMENTS) do
		element.Visible = state.hideUi == 0
	end
end)
