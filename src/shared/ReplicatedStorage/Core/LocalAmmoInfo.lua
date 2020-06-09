-- Is this stupid? Yeah
local LocalAmmoInfo = {}

function LocalAmmoInfo:SetCallback(callback)
	self.callback = callback
end

function LocalAmmoInfo:__call()
	if self.callback then
		return self.callback()
	else
		error("LocalAmmoInfo.callback wasn't set!")
	end
end

return setmetatable(LocalAmmoInfo, LocalAmmoInfo)
