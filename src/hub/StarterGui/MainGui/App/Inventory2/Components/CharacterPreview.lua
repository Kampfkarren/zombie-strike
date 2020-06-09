local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)
local ItemModel = require(ReplicatedStorage.Core.UI.Components.ItemModel)
local Maid = require(ReplicatedStorage.Core.Maid)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement
local LocalPlayer = Players.LocalPlayer

local CharacterPreview = Roact.Component:extend("CharacterPreview")

local ANIMATION_IDLE = Instance.new("Animation")
ANIMATION_IDLE.AnimationId = "rbxassetid://4847229688"

function CharacterPreview:init()
	self.maid = Maid.new()
	self.referenceInstance = nil
	self.referenceWatch = nil

	local function characterAdded(character)
		FastSpawn(function()
			character.Archivable = true
			character:WaitForChild("HumanoidRootPart")

			local function setCharacterState()
				local newCharacter = character:Clone()

				for _, thing in ipairs(newCharacter:GetDescendants()) do
					if thing:IsA("Motor6D") then
						local dummyEquivalent = ReplicatedStorage.Dummy:FindFirstChild(thing.Name, true)
						if dummyEquivalent ~= nil then
							thing.C0 = dummyEquivalent.C0
							thing.C1 = dummyEquivalent.C1
							thing.Transform = dummyEquivalent.Transform
						end
					elseif thing:IsA("LuaSourceContainer") then
						thing:Destroy()
					end
				end

				if self.referenceInstance ~= nil then
					self.referenceInstance:Destroy()
					self.referenceWatch:Disconnect()
				end

				-- TODO

				-- local reference = newCharacter:Clone()
				-- reference.PrimaryPart.Anchored = true
				-- reference:SetPrimaryPartCFrame(CFrame.new())
				-- reference.Parent = Workspace
				-- self.referenceInstance = reference

				-- self.referenceWatch = RunService.Heartbeat:connect(function()
				-- 	for _, part in ipairs(reference:GetChildren()) do
				-- 		if part:IsA("BasePart") then
				-- 			newCharacter[part.Name].CFrame = part.CFrame
				-- 		end
				-- 	end
				-- end)

				-- self:PlayAnimation(ANIMATION_IDLE)

				-- self.maid:GiveTask(self.referenceInstance)
				-- self.maid:GiveTask(self.referenceWatch)

				self:setState({
					character = newCharacter,
				})
			end

			local function updateCharacter()
				if self.state.character == character then
					setCharacterState()
				end
			end

			self.maid:GiveTask(character.DescendantAdded:connect(updateCharacter))
			self.maid:GiveTask(character.DescendantRemoving:connect(updateCharacter))

			setCharacterState()
		end)
	end

	if RunService:IsRunning() then
		if LocalPlayer.Character then
			characterAdded(LocalPlayer.Character)
		end

		self.maid:GiveTask(LocalPlayer.CharacterAdded:connect(characterAdded))
	else
		self:setState({
			character = ReplicatedStorage.Dummy:Clone(),
		})
	end
end

function CharacterPreview:PlayAnimation(animation)
	if self.referenceInstance then
		local animationTrack = self.referenceInstance.Humanoid:LoadAnimation(animation)
		animationTrack:Play()
	end
end

function CharacterPreview:willUnmount()
	self.maid:DoCleaning()
end

function CharacterPreview:render()
	if self.state.character == nil then
		return
	end

	return e(ItemModel, {
		Distance = 0.8,
		Model = self.state.character,
		SpinSpeed = 1,
		UseDirectly = true,
	})
end

FastSpawn(function()
	ContentProvider:PreloadAsync({ ANIMATION_IDLE })
end)

return CharacterPreview
