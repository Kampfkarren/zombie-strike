local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Promise = require(ReplicatedStorage.Core.Promise)

local CurrentCamera = Workspace.CurrentCamera
local Mode = ReplicatedStorage.RuddevEvents.Mode
local Shake = ReplicatedStorage.RuddevEvents.Shake

local SequenceUtil = {}

local cameraAttachments = {}
local particleEmitters = {}

local realBoss

-- TODO: Make boss invincible
-- TODO: Prevent gun fire
function SequenceUtil.Init(boss)
	for _, cameraAttachment in pairs(CollectionService:GetTagged("BossSequencePoint")) do
		if cameraAttachment:IsDescendantOf(Workspace) then
			local name = cameraAttachment.Name
			assert(cameraAttachments[name] == nil, "already an attachment named " .. name)
			cameraAttachments[name] = cameraAttachment
		end
	end

	for _, particleEmitter in pairs(CollectionService:GetTagged("BossSequenceEmitter")) do
		if particleEmitter:IsDescendantOf(Workspace) then
			local name = particleEmitter.Name
			assert(particleEmitters[name] == nil, "already an attachment named " .. name)
			particleEmitters[name] = particleEmitter
		end
	end

	if RunService:IsClient() then
		Mode:Fire("Sequence")

		realBoss = boss
		realBoss.Parent = nil

		local boss = realBoss:Clone()
		CollectionService:RemoveTag(boss, "Boss")
		boss.Parent = Workspace

		return Promise.new(function(resolve)
			resolve(boss, CurrentCamera)
		end)
	else
		local mockCamera = {}
		return Promise.new(function(resolve)
			resolve(boss, mockCamera)
		end)
	end
end

function SequenceUtil.Finish(boss)
	if RunService:IsClient() then
		boss:Destroy()
		realBoss.Parent = Workspace

		Mode:Fire("Default")
		Players.LocalPlayer.PlayerGui.BossSequenceGui.Enabled = false
	end
end

-- WorldCFrame gives a different orientation
function SequenceUtil.GetAttachmentCFrame(attachmentName)
	local attachment = assert(
		cameraAttachments[attachmentName],
		"no attachment by the name " .. attachmentName
	)

	return CFrame.new(attachment.WorldPosition) * (attachment.CFrame - attachment.CFrame.Position)
end

function SequenceUtil.Emit(name, amount)
	return function(boss, camera)
		assert(particleEmitters[name], "no particle emitters by the name " .. name):Emit(amount)
		return boss, camera
	end
end

function SequenceUtil.TeleportToAttachment(name)
	return function(boss, camera)
		camera.CFrame = SequenceUtil.GetAttachmentCFrame(name)
		return boss, camera
	end
end

function SequenceUtil.MoveToAttachment(name, tweenInfo)
	return function(boss, camera)
		if RunService:IsClient() then
			TweenService:Create(
				camera,
				tweenInfo,
				{ CFrame = SequenceUtil.GetAttachmentCFrame(name) }
			):Play()
		end

		return boss, camera
	end
end

function SequenceUtil.Focus(cancel)
	cancel.cancel = function() end

	return function(boss, camera)
		local base = camera.CFrame.Position
		-- local offset = camera.CFrame - boss.PrimaryPart.Position

		return Promise.new(function(resolve)
			if RunService:IsClient() then
				local connection = RunService.RenderStepped:connect(function()
					camera.CFrame = CFrame.new(base, boss.PrimaryPart.Position)-- * offsetAngle
					camera.Focus = camera.CFrame
				end)

				cancel.cancel = function()
					connection:Disconnect()
				end
			end

			resolve(boss, camera)
		end)
	end
end

function SequenceUtil.Animate(animation)
	return function(boss, camera)
		if RunService:IsClient() then
			boss.Humanoid:LoadAnimation(animation):Play()
		end

		return boss, camera
	end
end

function SequenceUtil.Delay(time)
	return function(...)
		local args = { ... }
		return Promise.async(function(resolve)
			wait(time)
			resolve(unpack(args))
		end)
	end
end

function SequenceUtil.Shake(amount)
	return function(boss, camera)
		Shake:Fire(amount)
		return boss, camera
	end
end

function SequenceUtil.ShowName(boss, camera)
	if RunService:IsClient() then
		local BossSequenceGui = Players.LocalPlayer.PlayerGui.BossSequenceGui
		local Inner = BossSequenceGui.Inner

		local basePosition = Inner.Position
		Inner.Label.Text = boss.Name
		Inner.Position = UDim2.new(UDim.new(-0.7, 0), basePosition.Y)
		BossSequenceGui.Enabled = true
		TweenService:Create(Inner, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
			Position = basePosition,
		}):Play()
	end

	return boss, camera
end

return SequenceUtil
