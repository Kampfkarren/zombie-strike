local TEST_CASES = {
	[9] = "9",
	[99] = "99",
	[999] = "999",
	[1000] = "1.0K",
	[1040] = "1.0K",
	[1050] = "1.1K",
	[1100] = "1.1K",
	[2400] = "2.4K",
	[9999] = "10.0K",
	[10000] = "10.0K",
	[10500] = "10.5K",
	[11000] = "11.0K",
	[11009] = "11.0K",
	[11099] = "11.1K",
	[99999] = "100.0K",
	[100000] = "100.0K",
	[100500] = "100.5K",
	[123456] = "123.5K",
	[1000000] = "1.0M",
	[1234567] = "1.2M",
	[1234567890] = "1.2B",
	[1234567890000] = "1234.6B",
	[-1000] = "-1.0K",
}

local units = { "K", "M", "B" }

local function EnglishNumbers(number, roundDown)
	local negative = number < 0
	number = math.abs(math.floor(number))

	for index = #units, 1, -1 do
		local unit = units[index]
		local size = 10 ^ (index * 3)

		if size <= number then
			if roundDown then
				number = math.floor(number * 10 / size) / 10
			else
				number = math.floor((number * 10 / size) + 0.5) / 10
			end

			if number == 1000 and index < #units then
				number = 1
				unit = units[index + 1]
			end

			number = ("%.1f"):format(number) .. unit
			break
		end
	end

	if negative then
		return "-" .. number
	else
		return tostring(number)
	end
end

for number, expected in pairs(TEST_CASES) do
	local result = EnglishNumbers(number)
	if result ~= expected then
		warn("EnglishNumbers test fail: " .. number .. " was " .. result .. ", not " .. expected)
	end
end

return EnglishNumbers
