local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Countdown = script.Parent.Main.Countdown
local LobbyUpdated = ReplicatedStorage.LocalEvents.LobbyUpdated
local LocalPlayer = Players.LocalPlayer
local Maid = require(ReplicatedStorage.Core.Maid)

local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local maid = Maid.new()

local Number = Countdown.Number
local Stop = Countdown.Stop

LobbyUpdated.Event:connect(function(currentLobby)
	Countdown.Visible = false
	maid:DoCleaning()

	if currentLobby then
		maid:GiveTask(currentLobby.Instance:WaitForChild("Countdown").Changed:connect(function(countdown)
			if currentLobby.Owner == LocalPlayer then
				Stop.Label.Text = "STOP"
				maid:GiveTask(Stop.MouseButton1Click:connect(function()
					ReplicatedStorage.Remotes.CancelLobby:FireServer()
				end))
			else
				maid:GiveTask(Stop.MouseButton1Click:connect(function()
					ReplicatedStorage.Remotes.LeaveLobby:FireServer()
				end))
			end

			if countdown == 0 then
				Countdown.Visible = false
			else
				Countdown.Visible = true

				if countdown == 3 then
					SoundService.SFX.Teleporting:Play()
				end

				for _, number in pairs(Number:GetChildren()) do
					number.UIScale.Scale = 0

					if tonumber(number.Name) == countdown then
						TweenService:Create(number.UIScale, tweenInfo, { Scale = 1 }):Play()
					end
				end
			end
		end))
	end
end)
