local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Core.Promise)

local LocalPlayer = Players.LocalPlayer

local mobileButtonsGuiPromise = Promise.promisify(function()
	return LocalPlayer
		:WaitForChild("PlayerGui")
		:WaitForChild("RuddevGui")
		:WaitForChild("MobileButtons")
end)()

local actions = {}

mobileButtonsGuiPromise:andThen(function(mobileButtonsGui)
	mobileButtonsGui.Alternate.MouseButton1Click:connect(function()
		local action = actions[1]
		if action ~= nil then
			action.Activate()
		end
	end)
end)

local function updateUi()
	mobileButtonsGuiPromise:andThen(function(mobileButtonsGui)
		if #actions == 0 then
			mobileButtonsGui.Reload.Visible = true
			mobileButtonsGui.Alternate.Visible = false
		else
			mobileButtonsGui.Alternate.Icon.Image = actions[1].Image
			mobileButtonsGui.Alternate.Visible = true
		end
	end)
end

local function AlternateMobileButton(info)
	table.insert(actions, info)
	if #actions == 1 then
		updateUi()
	end

	local killed = false
	return function()
		if killed then return end
		killed = true
		table.remove(actions, table.find(actions, info))
		updateUi()
	end
end

return AlternateMobileButton
