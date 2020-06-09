import { Players, ReplicatedStorage, HttpService } from "@rbxts/services"
import { GetRotation, GoldShopPacket, MAX_LEVEL } from "hub/ReplicatedStorage/Libraries/GoldShopItemsUtil"
import Analytics from "shared/ServerScriptService/Analytics"
import Data from "shared/ReplicatedStorage/Core/Data"
import GetGoldShopItems from "hub/ReplicatedStorage/Libraries/GetGoldShopItems"
import Interval from "shared/ReplicatedStorage/Core/Interval"
import InventorySpace from "shared/ReplicatedStorage/Core/InventorySpace"
import Promise2 from "shared/ReplicatedStorage/Core/Promise"
import WeakInstanceTable from "shared/ReplicatedStorage/Core/WeakInstanceTable"

const GoldShop = ReplicatedStorage.Remotes.GoldShop

// Refresh everyone's shops on the timer
// This is a dumb way of doing it, but it works and isn't much more expensive than the smarter way
let lastRotation = GetRotation(os.time())
Interval(1, () => {
	const timestamp = os.time()
	const rotation = GetRotation(timestamp)
	if (rotation !== lastRotation) {
		for (const player of Players.GetPlayers()) {
			Promise2.async((resolve) => {
				const [_, boughtThisRotationStore] = Data.GetPlayerData(player, "BoughtThisRotation")
				boughtThisRotationStore.Set({
					Rotation: undefined,
					Bought: undefined,
				})

				resolve()
			}).then(() => {
				GoldShop.FireClient(
					player,
					GoldShopPacket.InitialData,
					timestamp,
					[],
				)
			})
		}

		lastRotation = rotation
	}
})

Players.PlayerAdded.Connect(player => {
	const timestamp = os.time()

	const rotation = GetRotation(timestamp)
	const [boughtThisRotation, boughtThisRotationStore] = Data.GetPlayerData(player, "BoughtThisRotation")

	if (boughtThisRotation.Rotation !== rotation) {
		boughtThisRotationStore.Set({
			Rotation: undefined,
			Bought: undefined,
		})
	}

	GoldShop.FireClient(
		player,
		GoldShopPacket.InitialData,
		timestamp,
		boughtThisRotation.Bought,
	)
})

function getGoldShopItemsSafe(
	player: Player,
	verifyTimestamp: unknown,
): ReturnType<typeof GetGoldShopItems> | undefined {
	if (!typeIs(verifyTimestamp, "number")) {
		warn("getGoldShopItemsSafe: verifyTimestamp is not a number")
		return
	}

	const timestamp = os.time()

	if (GetRotation(timestamp) !== GetRotation(verifyTimestamp)) {
		warn("getGoldShopItemsSafe: rotations do not match")
		return
	}

	const [level] = Data.GetPlayerData(player, "Level")
	return GetGoldShopItems(player.UserId, timestamp, level)
}

const buyingWeapon = WeakInstanceTable()
const hasRequested = WeakInstanceTable()

GoldShop.OnServerEvent.Connect((player, packetType, ...args) => {
	if (packetType === GoldShopPacket.BuyWeapon) {
		if (buyingWeapon.has(player)) {
			warn("GoldShop: already buying item")
			return
		}

		buyingWeapon.set(player, true)

		Promise2.async((resolve) => {
			const [index, verifyTimestamp] = args
			const items = getGoldShopItemsSafe(player, verifyTimestamp)

			if (!typeIs(index, "number")) {
				warn("GoldShop: index is not a number")
				return
			}

			if (items === undefined) {
				return
			}

			const weapon = items.Weapons[index - 1]
			if (weapon === undefined) {
				warn("GoldShop: user buying non-existent weapon")
				return
			}

			const [gold, goldStore] = Data.GetPlayerData(player, "Gold")
			if (gold < weapon.Cost) {
				warn("GoldShop: not enough gold")
				return
			}

			const [boughtThisRotation, boughtThisRotationStore] = Data.GetPlayerData(player, "BoughtThisRotation")
			if (boughtThisRotation.Bought !== undefined
				&& boughtThisRotation.Bought.includes(index)
			) {
				warn("GoldShop: already bought this item")
				return
			}

			const [level] = Data.GetPlayerData(player, "Level")

			const newGun = {
				...weapon.Gun,
				Level: math.min(MAX_LEVEL, level + weapon.LevelOffset),
				Perks: weapon.Perks.map(perk => [perk, 0]) as [number, number][],
				UUID: HttpService.GenerateGUID(false).gsub("-", "")[0],
			}

			const [inventory, inventoryStore] = Data.GetPlayerData(player, "Inventory")

			return InventorySpace(player).then(space => {
				if (inventory.size() >= space) {
					warn("GoldShop: inventory is full")
					return
				}

				// actually give the d*rn gun
				goldStore.Increment(-weapon.Cost)
				inventory.push(newGun)
				inventoryStore.Set(inventory)

				boughtThisRotationStore.Set({
					Rotation: GetRotation(verifyTimestamp as number),
					Bought: boughtThisRotation.Bought ? [...boughtThisRotation.Bought, index] : [index],
				})

				GoldShop.FireClient(player, GoldShopPacket.BuyWeapon, index)

				// Equip the weapon
				if (newGun.Level <= level) {
					const [_, equippedWeaponStore] = Data.GetPlayerData(player, "EquippedWeapon")
					equippedWeaponStore.Set(inventory.size())
				}

				Analytics.WeaponShopBoughtItem(player, weapon)

				resolve()
			})
		}).catch(result => {
			warn(`GoldShop: error while buying item - ${result}`)
		}).finally(() => {
			buyingWeapon.delete(player)
		})
	} else if (packetType === GoldShopPacket.Requesting) {
		if (!hasRequested.has(player)) {
			hasRequested.set(player, true)
			Analytics.WeaponShopRequested(player)
		}
	}
})
