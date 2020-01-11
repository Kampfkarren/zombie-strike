local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Pets = ReplicatedStorage.Pets

local function pet(name, model)
	return {
		Name = name,
		Model = model,
	}
end

return {
	pet("Mario", Pets.Mario),
}
