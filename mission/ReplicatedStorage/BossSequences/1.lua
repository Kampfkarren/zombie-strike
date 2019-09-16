local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Promise = require(ReplicatedStorage.Core.Promise)
local SequenceUtil = require(script.Parent.SequenceUtil)

local Sequence = {}

local BOSS_ANIMATE_TIME = 2.5
local BOSS_JUMP_HEIGHT = 100

local yellAnimation = Instance.new("Animation")
yellAnimation.AnimationId = "rbxassetid://3906229018"

Sequence.Assets = {
	Yell = yellAnimation,
}

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function animate(boss, camera)
	local jumpCFrame = SequenceUtil.GetAttachmentCFrame("BossJumpPosition")
	local jumpAngle = jumpCFrame - jumpCFrame.Position

	local start = boss.PrimaryPart.CFrame
	local startAngle = start - start.Position

	if RunService:IsClient() then
		local time = 0
		while time < BOSS_ANIMATE_TIME do
			time = time + RunService.RenderStepped:wait()

			local x = time / BOSS_ANIMATE_TIME
			local yScale = -4 * x * (x - 1)

			local alpha = TweenService:GetValue(
				x,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.InOut
			)

			local height = lerp(start.Position.Y, jumpCFrame.Position.Y, x) + yScale * BOSS_JUMP_HEIGHT
			local position = start.Position:Lerp(jumpCFrame.Position, alpha)
			local angle = startAngle:Lerp(jumpAngle, alpha)

			boss:SetPrimaryPartCFrame(CFrame.new(
				position.X,
				height,
				position.Z
			) * angle)
		end
	else
		wait(BOSS_ANIMATE_TIME)
	end

	return boss, camera
end

function Sequence.Start(boss)
	local focus = SequenceUtil.Focus()

	return SequenceUtil.Init(boss)
		:andThen(SequenceUtil.TeleportToAttachment("BossSequenceStart1"))
		:andThen(SequenceUtil.MoveToAttachment("BossSequenceStart2", TweenInfo.new(3.0, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)))
		:andThen(SequenceUtil.Animate(yellAnimation))
		:andThen(SequenceUtil.Delay(3.3))
		:andThen(focus)
		:andThen(Promise.promisify(animate))
		:andThen(Promise.promisify(Promise.prototype.cancel, focus))
		:andThen(SequenceUtil.Delay(1))
		:andThen(SequenceUtil.Finish)
end

return Sequence
