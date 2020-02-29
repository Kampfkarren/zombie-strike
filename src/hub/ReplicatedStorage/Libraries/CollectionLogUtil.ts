import { ReplicatedStorage } from "@rbxts/services"
import Bosses from "shared/ReplicatedStorage/Core/Bosses"
import Campaigns from "shared/ReplicatedStorage/Core/Campaigns"
import Loot from "shared/ReplicatedStorage/Core/Loot"
import { LootReward } from "types/Gamemode"
import LootStyles from "shared/ReplicatedStorage/Core/LootStyles"
import PetsDictionary from "shared/ReplicatedStorage/Core/PetsDictionary"
import ZombiePassDictionary from "shared/ReplicatedStorage/Core/ZombiePassDictionary"

export const ItemTypes = (Loot.GunTypes as string[])
	.concat(["Armor", "Helmet"])
	.concat(Loot.Attachments)
	.concat(["Pet"])

const ITEM_TYPES_SET = new Set(ItemTypes)

type Items = { [itemName: string]: Item[] }

export enum ItemSourceMethod {
	Attachments,
	Boss,
	Campaign,
	MultipleSources,
	Pets,
}

type ItemSource = {
	Info?: string,
	Method: ItemSourceMethod,
}

type Item = {
	Type: string,
	Model: number,
	Instance: Instance,
	Rarity: number,
	Source: ItemSource,
	UUID: string, // For convenience
}

const SOURCE_ATTACHMENTS = {
	Method: ItemSourceMethod.Attachments,
}

export function GetAllItems(): Items {
	const modelRarities: { [modelName: string]: number } = {}
	const modelSources: { [modelName: string]: ItemSource } = {}

	// cool 4 layer nested for loop you got there bro
	const locations: {
		Loot: LootReward,
		Source: ItemSource,
	}[] = Campaigns.map((campaign) => {
		return {
			Loot: campaign.Loot,
			Source: {
				Info: campaign.Name,
				Method: ItemSourceMethod.Campaign,
			},
		}
	}).concat(Bosses.map((boss) => {
		return {
			Loot: boss.Loot,
			Source: {
				Info: boss.Name,
				Method: ItemSourceMethod.Boss,
			},
		}
	}))

	for (const location of locations) {
		for (const [lootType, lootRewards] of location.Loot) {
			for (const [rarityName, models] of Object.entries(lootRewards)) {
				for (const model of models) {
					const modelName = `${lootType}${model}`

					modelRarities[modelName] = LootStyles.findIndex(
						(style) => style.Name === rarityName
					) + 1

					if (modelSources[modelName] === undefined) {
						modelSources[modelName] = location.Source
					} else {
						// You can get this item from multiple sources
						modelSources[modelName] = {
							...location.Source,
							Method: ItemSourceMethod.MultipleSources,
						}
					}
				}
			}
		}
	}

	const items: Items = {
		Pet: [],
	}

	for (let item of ReplicatedStorage.Items.GetChildren()) {
		let itemType = (item as Instance & {
			ItemType: StringValue,
		}).ItemType.Value

		if (itemType === "Gun") {
			itemType = item.Name.match("^%a+")[0]!
		}

		if (!ITEM_TYPES_SET.has(itemType)) {
			continue
		}

		if (items[itemType] === undefined) {
			items[itemType] = []
		}

		const model = assert(
			tonumber(item.Name.match("%d+")[0]),
			`${item.Name} can't extract a model number`,
		)

		const isAttachment = (Loot.Attachments as string[]).indexOf(itemType) !== -1

		const rarity = isAttachment
			? model
			: modelRarities[item.Name]

		const source = isAttachment
			? SOURCE_ATTACHMENTS
			: modelSources[item.Name]

		items[itemType].push({
			Type: itemType,
			Instance: item,
			Model: model,
			Rarity: assert(rarity, `Couldn't find rarity of ${item.Name}`),
			Source: source,
			UUID: item.Name,
		})
	}

	for (const [index, pet] of Object.entries(PetsDictionary.Pets)) {
		items.Pet.push({
			Type: "Pet",
			Instance: pet.Model,
			Model: index,
			Rarity: 1,
			Source: {
				Method: ItemSourceMethod.Pets,
			},
			UUID: `Pet${index}`,
		})
	}

	for (const level of ZombiePassDictionary) {
		for (const loot of level.FreeLoot.concat(level.PaidLoot)) {
			switch (loot.Type) {
				case "Skin":
					items.
						break
			}
		}
	}

	for (const itemTypes of Object.values(items)) {
		itemTypes.sort((a, b) => {
			return a.Model < b.Model
		})
	}

	return items
}
