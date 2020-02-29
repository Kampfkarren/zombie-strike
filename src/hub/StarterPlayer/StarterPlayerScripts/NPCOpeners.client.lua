local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NPCOpener = require(ReplicatedStorage.Libraries.NPCOpener)

local requestedLog = false
NPCOpener("CollectionLog", function()
	if not requestedLog then
		requestedLog = true
		ReplicatedStorage.Remotes.UpdateCollectionLog:FireServer()
	end
end)

NPCOpener("Equipment")
NPCOpener("Shopkeeper")
NPCOpener("PetShop")
