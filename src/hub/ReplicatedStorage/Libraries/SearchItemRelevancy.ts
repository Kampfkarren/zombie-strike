import LootStyles from "shared/ReplicatedStorage/Core/LootStyles"

// CREDIT: https://gist.github.com/keesey/e09d0af833476385b9ee13b6d26a2b84
function levenshtein(a: string, b: string): number {
	const an = a ? (utf8.len(a)[0] || 0) : 0
	const bn = b ? (utf8.len(b)[0] || 0) : 0

	if (an === 0) {
		return bn
	}

	if (bn === 0) {
		return an
	}

	const matrix = new Array<number[]>(bn + 1)
	for (let i = 0; i <= bn; ++i) {
		let row = matrix[i] = new Array<number>(an + 1)
		row[0] = i
	}

	const firstRow = matrix[0]
	for (let j = 1; j <= an; ++j) {
		firstRow[j] = j
	}

	for (let i = 1; i <= bn; ++i) {
		for (let j = 1; j <= an; ++j) {
			if (utf8.offset(b, i - 1) === utf8.offset(a, j - 1)) {
				matrix[i][j] = matrix[i - 1][j - 1]
			} else {
				matrix[i][j] = math.min(
					matrix[i - 1][j - 1], // substitution
					matrix[i][j - 1], // insertion
					matrix[i - 1][j] // deletion
				) + 1
			}
		}
	}
	return matrix[bn][an]
}

function SearchItemRelevancy(search: string, lootName: string, item: {
	Rarity?: number,
	Type: string,
}): number | undefined {
	lootName = `${lootName} ${item.Type}`

	if (item.Rarity !== undefined) {
		lootName = `${lootName} ${LootStyles[item.Rarity - 1].Name}`
	}

	lootName = lootName.lower()
	search = search.lower()

	if (lootName.find(search, 0, true)[0] !== undefined) {
		return levenshtein(search, lootName)
	}

	return undefined
}

export = SearchItemRelevancy
