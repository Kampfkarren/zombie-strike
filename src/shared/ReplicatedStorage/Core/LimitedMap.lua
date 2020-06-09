local DEFAULT_SIZE = 100

local LimitedMap = {}

function LimitedMap:__index(key)
	return self._map[key]
end

-- TODO: Weird with nil?
function LimitedMap:__newindex(key, value)
	if self._map[key] == nil then
		if self._count == self._size then
			local removeIndex = self._removedSoFar + 1
			self._removedSoFar = removeIndex
			self._map[self._insertOrder[removeIndex]] = nil
			self._insertOrder[removeIndex] = nil
		else
			self._count = self._count + 1
			self._insertOrder[self._count] = key
		end
	end

	self._map[key] = value
end

local LimitedMapConstructor = {}

function LimitedMapConstructor.new(size)
	return setmetatable({
		_count = 0,
		_insertOrder = {},
		_map = {},
		_removedSoFar = 0,
		_size = size or DEFAULT_SIZE,
	}, LimitedMap)
end

return LimitedMapConstructor
