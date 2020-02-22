local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Collection = require(ReplicatedStorage.Core.Collection)
local RealDelay = require(ReplicatedStorage.Core.RealDelay)

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local FADE_TIME = 0.5

local teleporting = false

local fadeGui = Instance.new("ScreenGui")
fadeGui.DisplayOrder = 10
fadeGui.IgnoreGuiInset = true

local fadeFrame = Instance.new("Frame")
fadeFrame.BackgroundColor3 = Color3.new()
fadeFrame.BackgroundTransparency = 1
fadeFrame.Size = UDim2.fromScale(1, 1)
fadeFrame.Parent = fadeGui

fadeGui.Parent = PlayerGui

local fadeIn = TweenService:Create(
	fadeFrame,
	TweenInfo.new(
		FADE_TIME,
		Enum.EasingStyle.Quint,
		Enum.EasingDirection.Out
	),
	{ BackgroundTransparency = 0 }
)

local fadeOut = TweenService:Create(
	fadeFrame,
	TweenInfo.new(
		0.2,
		Enum.EasingStyle.Quint,
		Enum.EasingDirection.Out
	),
	{ BackgroundTransparency = 1 }
)

Collection("ObbyBrick", function(part)
	part.Touched:connect(function(touched)
		local character = LocalPlayer.Character
		if character and touched:IsDescendantOf(character) then
			if teleporting then return end
			teleporting = true

			fadeIn:Play()
			RealDelay(FADE_TIME, function()
				local respawnPoint
				local parent = part.Parent

				while parent ~= nil do
					local locatedRespawnPoint = parent:FindFirstChild("RespawnPoint", true)
					if locatedRespawnPoint then
						respawnPoint = locatedRespawnPoint
						break
					end

					parent = parent.Parent
				end

				assert(respawnPoint ~= nil)

				if #CollectionService:GetTagged("Boss") == 0 then
					LocalPlayer.Character:SetPrimaryPartCFrame(respawnPoint.WorldCFrame)
				end

				fadeOut:Play()
				teleporting = false
			end)
		end
	end)
end)
