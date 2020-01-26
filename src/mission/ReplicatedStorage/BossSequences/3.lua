local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Explosion = require(ReplicatedStorage.RuddevModules.Effects.Explosion)
local Promise = require(ReplicatedStorage.Core.Promise)
local SequenceUtil = require(script.Parent.SequenceUtil)

local Sequence = {}

local FirePreview = ReplicatedStorage.Assets.Campaign.Campaign3.Boss.FirePreview

local BOSS_ARRIVE_EXPLOSION_RADIUS = 15
local BOSS_ARRIVE_EXPLOSIONS = 8
local BOSS_ARRIVE_TIME = 1.5
local BOSS_ASCEND_OFFSET = Vector3.new(0, 51, 0)
local BOSS_ASCEND_TIME = 2

Sequence.Assets = {
	FirePreview = FirePreview
}

local function animateUp(boss, camera)
	local start = boss.PrimaryPart.CFrame
	local goal = start + BOSS_ASCEND_OFFSET

	if not ReplicatedStorage.SkipBossSequence.Value then
		if RunService:IsClient() then
			local firePreview = FirePreview:Clone()
			firePreview.CFrame = start
			firePreview.Parent = Workspace

			local time = 0

			while time < BOSS_ASCEND_TIME do
				local delta = RunService.RenderStepped:wait()
				time = time + delta

				local alpha = TweenService:GetValue(
					time / BOSS_ASCEND_TIME,
					Enum.EasingStyle.Sine,
					Enum.EasingDirection.Out
				)

				firePreview.CFrame = start:Lerp(goal, alpha)
			end

			TweenService:Create(
				firePreview,
				TweenInfo.new(
					BOSS_ARRIVE_TIME,
					Enum.EasingStyle.Exponential,
					Enum.EasingDirection.In
				), {
					Transparency = 0,
				}
			):Play()

			wait(BOSS_ARRIVE_TIME)

			local minPosition = boss.PrimaryPart.Position - boss.PrimaryPart.Size / 2
			local maxPosition = boss.PrimaryPart.Position + boss.PrimaryPart.Size / 2

			for _ = 1, BOSS_ARRIVE_EXPLOSIONS do
				Explosion(minPosition:Lerp(maxPosition, math.random()), BOSS_ARRIVE_EXPLOSION_RADIUS)
			end

			firePreview.Transparency = 1
			firePreview.Mid.Fire:Emit(50)
			firePreview.Mid.Fire.Enabled = false
			boss:SetPrimaryPartCFrame(goal)
		else
			wait(BOSS_ARRIVE_TIME + BOSS_ASCEND_TIME)
		end
	end

	boss:SetPrimaryPartCFrame(goal)
	CollectionService:AddTag(boss, "BossOscillate")

	return boss, camera
end

function Sequence.Start(boss)
	return SequenceUtil.Init(boss)
		:andThen(SequenceUtil.TeleportToAttachment("BossSequenceStart1"))
		:andThen(SequenceUtil.MoveToAttachment(
			"BossSequenceStart2",
			TweenInfo.new(3.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
		))
		:andThen(SequenceUtil.Delay(1))
		:andThen(Promise.promisify(animateUp))
		:andThen(SequenceUtil.ShowName)
		:andThen(SequenceUtil.Delay(3.5))
		:andThen(SequenceUtil.Finish)
end

return Sequence
