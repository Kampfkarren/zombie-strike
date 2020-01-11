local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local RealDelay = require(ReplicatedStorage.Core.RealDelay)
local SpraysDictionary = require(ReplicatedStorage.Core.SpraysDictionary)
local State = require(ReplicatedStorage.State)

local Emote = ReplicatedStorage.Assets.Emote
local LocalPlayer = Players.LocalPlayer
local UseSpray = ReplicatedStorage.Remotes.UseSpray

local Main = LocalPlayer
	:WaitForChild("PlayerGui")
	:WaitForChild("MainGui")
	:WaitForChild("Main")

local ENTER_TIME = 0.9
local LOOP_COUNT = 3

local loopTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In, LOOP_COUNT, true)

local function animateEmote(gui)
	local enterTween = TweenService:Create(
		gui,
		TweenInfo.new(ENTER_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Size = UDim2.fromScale(1, 1),
		}
	)

	enterTween.Completed:connect(function()
		local loopTween = TweenService:Create(gui, loopTweenInfo, {
			Size = UDim2.fromScale(1.2, 1.2),
		})

		loopTween.Completed:connect(function()
			local exitTween = TweenService:Create(
				gui,
				TweenInfo.new(ENTER_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				{
					Size = UDim2.fromScale(0, 0),
				}
			)

			exitTween.Completed:connect(function()
				gui.Parent:Destroy()
			end)

			exitTween:Play()
		end)

		loopTween:Play()
	end)

	enterTween:Play()
end

UseSpray.OnClientEvent:connect(function(character, sprayIndex)
	if sprayIndex == nil then return end
	local spray = assert(SpraysDictionary[sprayIndex])

	local emote = Emote:Clone()
	emote.Image.Image = spray.Image
	emote.Parent = character.Head
	animateEmote(emote.Image)

	local sound = SoundService.SFX.Emote:Clone()
	sound.Parent = character.PrimaryPart
	sound:Play()

	RealDelay(10, function()
		sound:Destroy()
	end)
end)

UserInputService.InputBegan:connect(function(inputObject, gameProcessed)
	if gameProcessed then return end

	if inputObject.KeyCode == Enum.KeyCode.B or inputObject.KeyCode == Enum.KeyCode.DPadDown then
		UseSpray:FireServer()
	end
end)

local emoteButton

if ReplicatedStorage.HubWorld.Value then
	emoteButton = Main:WaitForChild("Brains"):WaitForChild("EmoteButton")
else
	emoteButton = Main:WaitForChild("EmoteButton")
end

emoteButton.Activated:connect(function()
	UseSpray:FireServer()
end)

local tooltipType
local function changeTooltip(inputType)
	if tooltipType == inputType then return end
	tooltipType = inputType

	for _, tooltip in pairs(emoteButton.Tooltip:GetChildren()) do
		tooltip.Visible = false
	end

	if inputType == Enum.UserInputType.Keyboard then
		emoteButton.Tooltip.Keyboard.Visible = true
	elseif inputType == Enum.UserInputType.Gamepad1 then
		emoteButton.Tooltip.Gamepad.Visible = true
	end
end

local function checkEquippedSpray()
	emoteButton.Visible = State:getState().sprays.equipped ~= nil
end

UserInputService.LastInputTypeChanged:connect(function(lastInputType)
	if lastInputType == Enum.UserInputType.Keyboard
		or lastInputType == Enum.UserInputType.Gamepad1
		or lastInputType == Enum.UserInputType.Touch
	then
		changeTooltip(lastInputType)
	end
end)

checkEquippedSpray()

State.changed:connect(checkEquippedSpray)
