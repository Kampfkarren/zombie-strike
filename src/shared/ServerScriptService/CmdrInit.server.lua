local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local AdminsDictionary = require(ReplicatedStorage.Core.AdminsDictionary)
local Cmdr = require(ServerScriptService.Vendor.Cmdr)

Cmdr.Registry:AddHook("BeforeRun", function(context)
	if context.Executor and not AdminsDictionary[context.Executor.UserId] then
		return "You are not an admin."
	end
end)

Cmdr:RegisterDefaultCommands()
Cmdr:RegisterTypesIn(ServerScriptService.Shared.CmdrTypes)
Cmdr:RegisterCommandsIn(ServerScriptService.Commands)
Cmdr:RegisterCommandsIn(ServerScriptService.Shared.Commands)