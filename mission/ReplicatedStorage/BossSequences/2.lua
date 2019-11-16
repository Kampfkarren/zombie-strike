local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Promise = require(ReplicatedStorage.Core.Promise)
local SequenceUtil = require(script.Parent.SequenceUtil)

local Sequence = {}

local LaughAnimation = ReplicatedStorage.Assets.Campaign.Campaign2.Boss.LaughAnimation

local BOSS_ASCEND_OFFSET = 96
local BOSS_ASCEND_TIME = 4
local BOSS_SHIFT_CAMERA_TIME = 2
local BOSS_SPIN_SPEED = 10
local BOSS_SPIN_TRAIL_TIME = 1

Sequence.Assets = {
	Laugh = LaughAnimation,
}

local function animateUp(boss, camera)
	local start = boss.PrimaryPart.CFrame
	local goal = start + Vector3.new(0, BOSS_ASCEND_OFFSET, 0)

	if not ReplicatedStorage.SkipBossSequence.Value then
		if RunService:IsClient() then
			local shifted = false
			local time = 0

			while time < BOSS_ASCEND_TIME do
				local delta = RunService.RenderStepped:wait()
				time = time + delta

				local alpha = TweenService:GetValue(
					time / BOSS_ASCEND_TIME,
					Enum.EasingStyle.Sine,
					Enum.EasingDirection.Out
				)

				boss:SetPrimaryPartCFrame(start:Lerp(goal, alpha))
				boss.DrumSegment.Rod:SetPrimaryPartCFrame(boss.DrumSegment.Rod.PrimaryPart.CFrame * CFrame.Angles(0, 0, BOSS_SPIN_SPEED * delta))

				if time > BOSS_SHIFT_CAMERA_TIME and not shifted then
					shifted = true
					boss, camera = SequenceUtil.TeleportToAttachment("BossSequenceStart2")(boss, camera)
				end
			end

			time = 0

			start = boss.DrumSegment.Rod.PrimaryPart.CFrame
			local x, y, angle = start:ToEulerAnglesXYZ()
			local goal = CFrame.new(start.Position) * CFrame.Angles(x, y, 0)

			while time < BOSS_SPIN_TRAIL_TIME do
				local delta = RunService.RenderStepped:wait()
				time = time + delta

				local alpha = TweenService:GetValue(
					time / BOSS_SPIN_TRAIL_TIME,
					Enum.EasingStyle.Bounce,
					Enum.EasingDirection.Out
				)

				boss.DrumSegment.Rod:SetPrimaryPartCFrame(start:Lerp(goal, alpha))
			end
		else
			wait(BOSS_ASCEND_TIME + BOSS_SPIN_TRAIL)
		end
	end

	boss:SetPrimaryPartCFrame(goal)

	return boss, camera
end

local function laugh(boss, camera)
	if not ReplicatedStorage.SkipBossSequence.Value and RunService:IsClient() then
		print("ert")
		boss.HeadSegment.RickHeadSegment.Zombie.Humanoid:LoadAnimation(LaughAnimation):Play()
	end

	return boss, camera
end

function Sequence.Start(boss)
	local focusCancel = {}

	return SequenceUtil.Init(boss)
		:andThen(SequenceUtil.TeleportToAttachment("BossSequenceStart1"))
		:andThen(SequenceUtil.Focus(focusCancel))
		:andThen(Promise.promisify(animateUp))
		:andThen(SequenceUtil.Delay(0.7))
		:andThen(Promise.promisify(function(...)
			focusCancel.cancel()
			return ...
		end))
		:andThen(SequenceUtil.MoveToAttachment("BossSequenceStart3", TweenInfo.new(2, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)))
		:andThen(SequenceUtil.Animate(LaughAnimation, function()
			return boss.HeadSegment.RickHeadSegment.Zombie.Humanoid
		end))
		:andThen(SequenceUtil.Delay(1))
		:andThen(SequenceUtil.ShowName)
		:andThen(SequenceUtil.Delay(3.5))
		:andThen(SequenceUtil.Finish)
end

return Sequence
