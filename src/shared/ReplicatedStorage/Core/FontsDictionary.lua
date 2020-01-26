local function font(name, font)
	return {
		Font = font or Enum.Font[name],
		Name = name,
	}
end

return {
	font("Fantasy"),
	font("Cartoon"),
	font("Code"),
	font("Sci-Fi", Enum.Font.SciFi),
	font("Arcade"),
}
