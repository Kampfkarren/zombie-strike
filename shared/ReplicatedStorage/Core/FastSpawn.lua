return function(callback)
	local event = Instance.new("BindableEvent")
	event.Event:connect(callback)
	event:Fire()
end
