local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local AdminsDictionary = require(ReplicatedStorage.Libraries.AdminsDictionary)
local Cmdr = require(ServerScriptService.Vendor.Cmdr)

Cmdr.Registry:AddHook("BeforeRun", function(context)
	if context.Executor and not AdminsDictionary[context.Executor.UserId] then
		return "You are not an admin."
	end
end)

Cmdr:RegisterDefaultCommands()
Cmdr:RegisterCommandsIn(ServerScriptService.Commands)
