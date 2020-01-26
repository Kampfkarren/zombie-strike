-- TODO: Preload all campaign assets
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local ArenaDifficulty = require(ReplicatedStorage.Libraries.ArenaDifficulty)
local AutomatedScrollingFrame = require(ReplicatedStorage.Core.UI.AutomatedScrollingFrame)
local Campaigns = require(ReplicatedStorage.Core.Campaigns)
local Friends = require(ReplicatedStorage.Libraries.Friends)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local UserThumbnail = require(ReplicatedStorage.Core.UI.UserThumbnail)

local Lobbies = ReplicatedStorage.Lobbies
local LocalPlayer = Players.LocalPlayer
local PlayButton = script.Parent.Main.PlayButton
local PlayFrame = script.Parent.Main.PlayFrame
local Inner = script.Parent.Main.PlayFrame.Inner

local TWEEN_TIME = 0.5

local currentLobby
local kickedFrom = {}
local open, openTick = false, 0
local pageLayout = PlayFrame.Inner.UIPageLayout

local tweens = {
	In = TweenService:Create(
		PlayFrame,
		TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{ Position = UDim2.new(0.5, 0, 0.5, 0) }
	),

	Out = TweenService:Create(
		PlayFrame,
		TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{ Position = UDim2.new(0.5, 0, 1.5, 0) }
	),
}

local function cloneAndDestroy(object)
	local output = object:Clone()
	object:Destroy()
	return output
end

local function toggle(newOpen)
	open = newOpen
	local ourTick = openTick + 1
	openTick = ourTick

	if open then
		PlayFrame.Visible = true
		tweens.In:Play()

		if UserInputService.GamepadEnabled then
			GuiService.SelectedObject = Inner.JoinCreate.Join
		end
	else
		tweens.Out:Play()
		delay(TWEEN_TIME, function()
			if openTick == ourTick then
				PlayFrame.Visible = false
			end
		end)

		GuiService.SelectedObject = nil
	end
end

PlayButton.MouseButton1Click:connect(function()
	toggle(true)
end)

Inner.JoinCreate.Create.MouseButton1Click:connect(function()
	pageLayout:JumpTo(Inner.Create)
end)

Inner.JoinCreate.Join.MouseButton1Click:connect(function()
	pageLayout:JumpTo(Inner.Join)
end)

-- Create campaign
do
	local Create = Inner.Create

	local creating = false

	Roact.mount(Roact.createElement(require(script.Create), {
		OnSubmit = function(state)
			if not creating then
				creating = true
				local success = ReplicatedStorage.Remotes.CreateLobby:InvokeServer(state)

				if success then
					pageLayout:JumpTo(Inner.Lobby)
				end

				creating = false
			end
		end,
	}), Create)
end

local lobbiesUpdated = Instance.new("BindableEvent")

-- Lobby browser
do
	local Join = Inner.Join

	local LobbyInfo = Join.LobbyInfo
	local LobbyTemplate = cloneAndDestroy(Join.Lobbies.Template)
	local lobbyButtons = {}

	local currentlySelected
	local selectTick = 0

	local function selectLobby(lobby)
		local level = Players.LocalPlayer:WaitForChild("PlayerData"):WaitForChild("Level").Value

		local campaign = assert(Campaigns[lobby.Campaign])
		local difficulty = lobby.Gamemode == "Arena"
			and ArenaDifficulty(lobby.ArenaLevel)
			or assert(campaign.Difficulties[lobby.Difficulty])

		currentlySelected = lobby.Unique

		local ourTick = selectTick + 1
		selectTick = ourTick

		local lobbyInfo = cloneAndDestroy(LobbyInfo.Inner)

		lobbyInfo.MapImage.Image = campaign.Image
		lobbyInfo.MapImage.Hardcore.Visible = lobby.Hardcore

		lobbyInfo.User.Username.Text = lobby.Owner.Name
		UserThumbnail(lobby.Owner):andThen(function(avatar)
			if selectTick == ourTick then
				lobbyInfo.User.Avatar.Image = avatar
			end
		end)

		lobbyInfo.Info.Campaign.Text = campaign.Name
		lobbyInfo.Info.Level.Text = "LV. " .. difficulty.MinLevel .. "+"
		lobbyInfo.Info.Players.Text = #lobby.Players .. "/4"

		lobbyInfo.Info.Difficulty.Text = lobby.Gamemode == "Arena" and "THE ARENA" or difficulty.Style.Name
		lobbyInfo.Info.Difficulty.TextStrokeColor3 = difficulty.Style.Color

		if difficulty.MinLevel > level or #lobby.Players == 4 or kickedFrom[lobby.Unique] then
			lobbyInfo.Join.ImageColor3 = Color3.fromRGB(234, 32, 39)
		else
			lobbyInfo.Join.ImageColor3 = Color3.fromRGB(32, 187, 108)
			lobbyInfo.Join.MouseButton1Click:connect(function()
				if ReplicatedStorage.Remotes.JoinLobby:InvokeServer(lobby.Unique) then
					pageLayout:JumpTo(Inner.Lobby)
				end
			end)
		end

		lobbyInfo.Visible = true
		lobbyInfo.Parent = LobbyInfo
	end

	lobbiesUpdated.Event:connect(function(lobbies)
		local level = Players.LocalPlayer:WaitForChild("PlayerData"):WaitForChild("Level").Value

		for _, button in pairs(lobbyButtons) do
			button.button:Destroy()
		end

		lobbyButtons = {}

		local unselect = true

		for _, lobby in pairs(lobbies) do
			if lobby.Owner then
				local button = LobbyTemplate:Clone()

				local friends = Friends.IsFriendsWith(lobby.Owner)

				if friends then
					button.ImageColor3 = Color3.fromRGB(9, 132, 227)
				end

				local campaign = Campaigns[lobby.Campaign]

				local difficulty = lobby.Gamemode == "Arena"
					and ArenaDifficulty(lobby.ArenaLevel)
					or campaign.Difficulties[lobby.Difficulty]

				local cantJoin = difficulty.MinLevel > level
					or #lobby.Players == 4
					or kickedFrom[lobby.Unique]
					or (not lobby.Public and not friends)

				if cantJoin then
					button.ImageColor3 = Color3.fromRGB(252, 92, 101)
				end

				UserThumbnail(lobby.Owner):andThen(function(avatar)
					button.Inner.Avatar.Image = avatar
				end)

				button.Inner.Players.Text = #lobby.Players .. "/4"

				local campaignName = campaign.Name .. " - " .. difficulty.Style.Name

				if lobby.Gamemode == "Arena" then
					campaignName = campaignName .. "⚔"
				end

				if lobby.Hardcore then
					campaignName = campaignName .. "💀"
				end

				if not lobby.Public then
					campaignName = campaignName .. "🔒"
				end

				button.Inner.Info.Campaign.Text = campaignName
				button.Inner.Info.Username.Text = lobby.Owner.Name

				button.MouseButton1Click:connect(function()
					selectLobby(lobby)
				end)

				button.SelectionGained:connect(function()
					selectLobby(lobby)
				end)

				table.insert(lobbyButtons, {
					button = button,
					cantJoin = cantJoin,
					fallback = lobby.Unique,
					friends = friends,
					level = difficulty.MinLevel,
				})

				if lobby.Unique == currentlySelected then
					unselect = false
					selectLobby(lobby)
				end
			end
		end

		table.sort(lobbyButtons, function(a, b)
			if a.friends ~= b.friends then
				return a.friends
			end

			if a.cantJoin ~= b.cantJoin then
				return b.cantJoin
			end

			-- TODO: If the lobby has a higher level than you, put it to the bottom
			if a.level ~= b.level then
				return a.level > b.level
			end

			-- More recent missions go on the bottom
			return a.fallback < b.fallback
		end)

		for index, button in ipairs(lobbyButtons) do
			button.LayoutOrder = index
			button.button.Parent = Join.Lobbies
		end

		LobbyInfo.Inner.Visible = LobbyInfo.Inner.Visible and not unselect
		Join.Lobbies.NoLobbies.Visible = #lobbies == 0
		Join.LobbyInfo.CreateButton.Visible = #lobbies == 0
	end)

	Join.LobbyInfo.CreateButton.MouseButton1Click:connect(function()
		pageLayout:JumpTo(Inner.Create)
	end)

	AutomatedScrollingFrame(Join.Lobbies)
end

-- Lobby screen
do
	local PLAY_BUTTON_COLOR = Color3.fromRGB(59, 215, 48)

	local playButtonCountdown

	local function getCurrentLobby()
		return currentLobby
	end

	ReplicatedStorage.LocalEvents.GetCurrentLobby.OnInvoke = getCurrentLobby

	local Lobby = Inner.Lobby
	local notConnected = Lobby.Players["1"]:Clone()

	Lobby.Info.Leave.MouseButton1Click:connect(function()
		ReplicatedStorage.Remotes.LeaveLobby:FireServer()
	end)

	Lobby.Info.Play.MouseButton1Click:connect(function()
		ReplicatedStorage.Remotes.PlayLobby:FireServer()
	end)

	lobbiesUpdated.Event:connect(function()
		local current = getCurrentLobby()

		local function reset()
			Lobby.Info.Play.ImageColor3 = PLAY_BUTTON_COLOR
			Lobby.Info.Cancel.Visible = false
			Lobby.Info.Leave.Visible = true
		end

		if playButtonCountdown then
			playButtonCountdown:Disconnect()
			reset()
		end

		if not current then
			if pageLayout.CurrentPage == Inner.Lobby then
				pageLayout:JumpTo(Inner.Join)
			end

			return
		end

		local isOwner = current.Owner == LocalPlayer

		-- Map info
		local MapInfo = Lobby.Info.MapInfo
		local campaign = Campaigns[current.Campaign]

		MapInfo.Campaign.Text = campaign.Name
			MapInfo.MapImage.Image = campaign.Image
			MapInfo.MapImage.Hardcore.Visible = current.Hardcore

		if current.Gamemode == "Arena" then
			MapInfo.Info.Difficulty.Text = "THE ARENA"
			MapInfo.Info.Difficulty.TextColor3 = Color3.new(1, 1, 1)
			MapInfo.Info.Level.Text = "LV. " .. current.ArenaLevel .. "+"
		else
			local difficulty = campaign.Difficulties[current.Difficulty]
			MapInfo.Info.Difficulty.Text = difficulty.Style.Name
			MapInfo.Info.Difficulty.TextColor3 = difficulty.Style.Color
			MapInfo.Info.Level.Text = "LV. " .. difficulty.MinLevel .. "+"
		end


		-- Player panel

		for playerIndex, player in pairs(current.Players) do
			local card = Lobby.Players[playerIndex]
			card.Avatar.Image = ""
			card.Avatar.ImageColor3 = Color3.new(1, 1, 1)
			card.Info.Kick.Visible = isOwner and player ~= LocalPlayer
			card.Info.Username.Text = player.Name

			card.Info.Kick.MouseButton1Click:connect(function()
				ReplicatedStorage.Remotes.KickFromLobby:FireServer(player)
			end)

			UserThumbnail(player):andThen(function(userThumbnail)
				local newCurrent = getCurrentLobby()
				if newCurrent == current and newCurrent.Players[playerIndex] == player then
					card.Avatar.Image = userThumbnail
				else
					warn("thumbnail loaded, but no longer matches")
				end
			end)
		end

		for playerIndex = #current.Players + 1, 4 do
			Lobby.Players[playerIndex]:Destroy()

			local notConnected = notConnected:Clone()
			notConnected.Name = playerIndex
			notConnected.Parent = Lobby.Players
		end

		Lobby.Info.Play.Visible = isOwner
	end)

	ReplicatedStorage.Remotes.PlayLobby.OnClientEvent:connect(function(playing, problem)
		Lobby.Info.Play.ImageColor3 = PLAY_BUTTON_COLOR
		Lobby.Info.Play.Label.Text = "PLAY"

		if problem then
			StarterGui:SetCore("ChatMakeSystemMessage", {
				Text = ("Error when playing: %s"):format(problem),
				Color = Color3.fromRGB(252, 92, 101),
				Font = Enum.Font.GothamSemibold,
			})
		end
	end)
end

ReplicatedStorage.Remotes.KickFromLobby.OnClientEvent:connect(function(unique)
	kickedFrom[unique] = true
	StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = "You were kicked from the lobby.",
		Color = Color3.fromRGB(252, 92, 101),
		Font = Enum.Font.GothamSemibold,
	})
end)

local function close()
	if pageLayout.CurrentPage == Inner.Lobby then
		ReplicatedStorage.Remotes.LeaveLobby:FireServer()
	elseif pageLayout.CurrentPage == Inner.JoinCreate then
		toggle(false)
	else
		pageLayout:JumpTo(Inner.JoinCreate)
		if UserInputService.GamepadEnabled then
			GuiService.SelectedObject = Inner.JoinCreate.Join
		end
	end
end

PlayFrame.Close.MouseButton1Click:connect(close)

ReplicatedStorage.LocalEvents.PressPlay.Event:connect(function()
	toggle(true)
end)

local function updateLobbies()
	local oldLobby = currentLobby
	currentLobby = nil
	local lobbies = {}

	for _, lobbyInstance in pairs(Lobbies:GetChildren()) do
		local players = {}
		local ours = false

		for _, player in pairs(lobbyInstance:WaitForChild("Players"):GetChildren()) do
			if tonumber(player.Name) == LocalPlayer.UserId then
				ours = true
			end

			table.insert(players, player.Value)
		end

		local lobby = {
			Campaign = lobbyInstance.Campaign.Value,
			Gamemode = lobbyInstance.Gamemode.Value,
			Players = players,
			Public = lobbyInstance.Public.Value,
			Owner = lobbyInstance.Owner.Value,
			Unique = lobbyInstance.Unique.Value,
			Instance = lobbyInstance,
		}

		if lobby.Gamemode == "Arena" then
			lobby.ArenaLevel = lobbyInstance.Level.Value
		elseif lobby.Gamemode == "Mission" then
			lobby.Difficulty = lobbyInstance.Difficulty.Value
			lobby.Hardcore = lobbyInstance.Hardcore.Value
		end

		if ours then
			currentLobby = lobby
		end

		table.insert(lobbies, lobby)
	end

	if currentLobby ~= oldLobby then
		ReplicatedStorage.LocalEvents.LobbyUpdated:Fire(currentLobby)
	end

	lobbiesUpdated:Fire(lobbies)
end

updateLobbies()

Lobbies.ChildAdded:connect(function(lobby)
	local playersFolder = lobby:WaitForChild("Players")
	playersFolder.ChildAdded:connect(updateLobbies)
	playersFolder.ChildRemoved:connect(updateLobbies)
	lobby.Owner.Changed:Connect(updateLobbies)
	updateLobbies()
end)

Lobbies.ChildRemoved:connect(updateLobbies)

