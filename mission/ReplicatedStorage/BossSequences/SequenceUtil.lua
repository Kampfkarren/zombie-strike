local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Promise = require(ReplicatedStorage.Core.Promise)

local CurrentCamera = Workspace.CurrentCamera
local Mode = ReplicatedStorage.RuddevEvents.Mode

local SequenceUtil = {}

local cameraAttachments = {}

-- TODO: Make boss invincible
function SequenceUtil.Init(boss)
	for _, cameraAttachment in pairs(CollectionService:GetTagged("BossSequencePoint")) do
		local name = cameraAttachment.Name
		assert(cameraAttachments[name] == nil, "camera attachment already exists: " .. name)
		cameraAttachments[name] = cameraAttachment
	end

	if RunService:IsClient() then
		Mode:Fire("Sequence")
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

function SequenceUtil.Finish()
	if RunService:IsClient() then
		Mode:Fire("Default")
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

function SequenceUtil.Focus()
	return function(boss, camera)
		local base = camera.CFrame.Position
		local offset = camera.CFrame - boss.PrimaryPart.Position
		local offsetAngle = offset - offset.Position

		return Promise.new(function(resolve, _, onCancel)
			if RunService:IsClient() then
				local connection = RunService.RenderStepped:connect(function()
					camera.CFrame = CFrame.new(base, boss.PrimaryPart.Position)-- * offsetAngle
				end)

				onCancel(function()
					connection:Disconnect()
				end)
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

return SequenceUtil
