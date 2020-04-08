local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local SequenceUtil = require(script.Parent.SequenceUtil)

local MOVE_FORWARD = 58
local MOVE_FORWARD_TIME = 1.65

local Sequence = {}

Sequence.Assets = {}

function Sequence.Start(boss)
	local initial = boss.PrimaryPart.CFrame
	local goal = initial
		+ (boss.PrimaryPart.CFrame.LookVector * MOVE_FORWARD)

	return SequenceUtil.Init(boss)
		:andThen(SequenceUtil.TeleportToAttachment("BossSequenceStart"))
		:andThen(SequenceUtil.MoveToAttachment("BossSequenceEnd", TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)))
		:tap(function()
			if RunService:IsClient() then
				local total = 0

				local connection
				connection = RunService.Heartbeat:connect(function(delta)
					total = total + delta
					if total >= MOVE_FORWARD_TIME then
						boss:SetPrimaryPartCFrame(goal)
						connection:Disconnect()
					else
						boss:SetPrimaryPartCFrame(initial:Lerp(
							goal,
							TweenService:GetValue(total / MOVE_FORWARD_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
						))
					end
				end)
			end
		end)
		:andThen(SequenceUtil.Delay(1.5))
		:andThen(SequenceUtil.ShowName)
		:andThen(SequenceUtil.Delay(2.3))
		:tap(function()
			if RunService:IsServer() then
				boss:SetPrimaryPartCFrame(goal)
			end
		end)
		:andThen(SequenceUtil.Finish)
end

return Sequence
