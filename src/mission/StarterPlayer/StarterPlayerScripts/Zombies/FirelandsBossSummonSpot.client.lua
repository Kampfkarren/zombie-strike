local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)

if Dungeon.GetDungeonData("Campaign") ~= 3 then return end

local SUMMON_TIME = 2

Workspace.ChildAdded:connect(function(child)
	if child.Name == "SummonSpot" then
		local attachment = child:WaitForChild("Attachment")

		TweenService:Create(
			attachment,
			TweenInfo.new(
				SUMMON_TIME,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.Out
			), {
				Position = attachment.Position + Vector3.new(child.Size.X, 0, 0),
			}
		):Play()

		child:GetPropertyChangedSignal("Transparency"):connect(function()
			attachment.Fire.Enabled = false
			attachment.Fire.Lifetime = NumberRange.new(0.3)
			attachment.Fire:Emit(25)
		end)
	end
end)
