import { HttpService, Players, ReplicatedStorage } from "@rbxts/services"
import Data from "shared/ReplicatedStorage/Core/Data"
import InventorySpace from "shared/ReplicatedStorage/Core/InventorySpace"
import { GenerateWeaponPerksForRarity } from "shared/ReplicatedStorage/Core/Perks"
import { GunItem, GunTypes } from "shared/ReplicatedStorage/Core/Loot"
import { RarityIndex } from "types/Rarity"

const RedeemVoucher = ReplicatedStorage.Remotes.RedeemVoucher
const UpdateVouchers = ReplicatedStorage.Remotes.UpdateVouchers

const CHANCE_FOR_LEGENDARY = 0.65
const LEGENDARY_PERK_ROLL_CHANCE = 0.25
const MINIMUM_BONUS = 29
const PERKS = 4

Players.PlayerAdded.Connect(player => {
	const [vouchers, vouchersStore] = Data.GetPlayerData(player, "Vouchers")

	vouchersStore.OnUpdate(value => {
		UpdateVouchers.FireClient(player, value)
	})

	UpdateVouchers.FireClient(player, vouchers)
})

RedeemVoucher.OnServerEvent.Connect(player => {
	const [vouchers, vouchersStore] = Data.GetPlayerData(player, "Vouchers")
	if (vouchers <= 0) {
		warn("RedeemVoucher: player has no vouchers")
		return
	}

	const rng = new Random()

	const [inventory, inventoryStore] = Data.GetPlayerData(player, "Inventory")
	const [_, equippedWeaponStore] = Data.GetPlayerData(player, "EquippedWeapon")
	const [level] = Data.GetPlayerData(player, "Level")
	const [voucherUsedEver, voucherUsedEverStore] = Data.GetPlayerData(player, "VoucherUsedEver")

	const [success, value] = InventorySpace(player).await()
	if (success === false) {
		warn("RedeemVoucher: InventorySpace failed?")
		return
	}

	if (inventory.size() >= (value as number)) {
		warn("RedeemVoucher: inventory is full")
		return
	}

	const rarity = voucherUsedEver
		? (rng.NextNumber() <= CHANCE_FOR_LEGENDARY ? RarityIndex.Legendary : RarityIndex.Epic)
		: RarityIndex.Legendary // First use of voucher is ALWAYS a legendary
	const bonus = rng.NextInteger(MINIMUM_BONUS, 35)

	const gunItem = {
		Type: GunTypes[rng.NextInteger(0, GunTypes.size() - 1)],
		Level: level,
		Rarity: rarity,

		Bonus: bonus,
		Seed: rng.NextInteger(0, 1000),
		Favorited: false,
		UUID: HttpService.GenerateGUID(false).gsub("-", "")[0],

		Perks: [] as GunItem["Perks"],
		Model: rarity,
	}

	let firstPerk = true

	const perks = GenerateWeaponPerksForRarity(gunItem, rarity, {
		ForcePerks: PERKS,
		RollLegendaryStrategy: () => {
			if (firstPerk) {
				firstPerk = false
				return true
			} else {
				return rng.NextNumber() <= LEGENDARY_PERK_ROLL_CHANCE
			}
		}
	})

	const gun = {
		...gunItem,
		Perks: perks,
	}

	inventoryStore.Set([...inventory, gun])
	equippedWeaponStore.Set(inventory.size() + 1) // Equip our new gun

	voucherUsedEverStore.Set(true)
	vouchersStore.Increment(-1)

	RedeemVoucher.FireClient(player, gun.UUID)
})
