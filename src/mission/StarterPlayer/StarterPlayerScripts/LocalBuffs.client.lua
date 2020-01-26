local CollectionService = game:GetService("CollectionService")
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local BuffTimer = Players.LocalPlayer
	:WaitForChild("PlayerGui")
	:WaitForChild("MainGui")
	:WaitForChild("Main")
	:WaitForChild("BuffTimer")
local CurrentPowerup = ReplicatedStorage.CurrentPowerup

local BUFF_SPIN_RATE = math.pi

CollectionService:GetInstanceAddedSignal("Buff"):connect(function(buff)
	local connection = RunService.Heartbeat:connect(function(delta)
		buff.CFrame = buff.CFrame * CFrame.Angles(0, BUFF_SPIN_RATE * delta, 0)
	end)

	buff.AncestryChanged:connect(function()
		if not buff:IsDescendantOf(game) then
			connection:Disconnect()
		end
	end)
end)

local lastPowerup = ""

CurrentPowerup.Changed:connect(function(powerupData)
	local powerup, timer = unpack(powerupData:split("/"))
	timer = tonumber(timer)

	if powerup ~= lastPowerup and powerup ~= "" then
		SoundService.SFX.Buffs.BuffActivated:Play()
		SoundService.SFX.Buffs.BuffLoop:Play()

		BuffTimer.Visible = true
		BuffTimer.CurrentBuff.Text = powerup:upper() .. " BUFF!"
		BuffTimer.Percent.Inner.Size = UDim2.fromScale(1, 1)

		local total = 0
		local connection

		connection = RunService.Heartbeat:connect(function(delta)
			total = total + delta

			BuffTimer.Percent.Inner.Size = UDim2.fromScale((timer - total) / timer, 1)

			if total >= timer then
				connection:Disconnect()
				BuffTimer.Visible = false
				SoundService.SFX.Buffs.BuffLoop:Stop()
				SoundService.SFX.Buffs.BuffOver:Play()
			end
		end)
	end
end)

ContentProvider:PreloadAsync(SoundService.SFX.Buffs:GetChildren())
