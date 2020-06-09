return function()
	local LimitedMap = require(script.Parent.LimitedMap)

	it("should work as a normal map", function()
		local map = LimitedMap.new()
		expect(map.foo).to.equal(nil)
		map.foo = 1
		expect(map.foo).to.equal(1)
	end)

	it("should cull old values", function()
		local map = LimitedMap.new(2)
		map.a = 1
		map.b = 2
		expect(map.a).to.equal(1)
		expect(map.b).to.equal(2)
		map.c = 3
		expect(map.b).to.equal(2)
		expect(map.c).to.equal(3)
		expect(map.a).to.equal(nil)
	end)
end
