local function CreateMockRemote()
	local remote = {}

	local onClientEvent = Instance.new("BindableEvent")
	local onServerEvent = Instance.new("BindableEvent")

	remote.OnClientEvent = onClientEvent.Event
	remote.OnServerEvent = onServerEvent.Event

	function remote.FireServer(_, ...)
		onServerEvent:Fire(...)
	end

	function remote.FireClient(_, _, ...)
		onClientEvent:Fire(...)
	end

	function remote.FireClient(_, ...)
		onClientEvent:Fire(...)
	end

	return remote
end

return CreateMockRemote
