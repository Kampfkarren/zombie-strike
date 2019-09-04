local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Campaigns = require(ReplicatedStorage.Core.Campaigns)
local t = require(ReplicatedStorage.Vendor.t)

local map = {
	"Players",
	"Campaign",
	"Difficulty",
	"Public",
	"Hardcore",
	"Unique",
}

local serializeStruct = t.interface({
	Players = t.array(t.instanceOf("Player")),
	Campaign = t.numberConstrained(1, #Campaigns),
	Difficulty = t.number,
	Public = t.boolean,
	Hardcore = t.boolean,
	Unique = t.number,
})

local Lobby = {}

function Lobby.Deserialize(data)
	local lobby = {}

	for index, key in pairs(map) do
		lobby[key] = data[index]
	end

	assert(serializeStruct(lobby))
	return lobby
end

function Lobby.DeserializeTable(lobbies)
	local deserialized = {}
	for index, lobby in ipairs(lobbies) do
		deserialized[index] = Lobby.Deserialize(lobby)
	end
	return deserialized
end

function Lobby.Serialize(data)
	assert(serializeStruct(data))

	local lobby = {}

	for index, key in pairs(map) do
		lobby[index] = data[key]
	end

	return lobby
end

function Lobby.SerializeTable(lobbies)
	local serialized = {}
	for index, lobby in ipairs(lobbies) do
		serialized[index] = Lobby.Serialize(lobby)
	end
	return serialized
end

return Lobby
