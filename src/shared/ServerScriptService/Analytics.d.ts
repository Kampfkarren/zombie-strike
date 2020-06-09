import { GoldShopWeapon } from "hub/ReplicatedStorage/Libraries/GoldShopItemsUtil"

declare namespace Analytics {
	function CapsBought(player: Player, caps: number): void

	function CollectionLogRequested(player: Player): void

	function WeaponShopBoughtItem(player: Player, weapon: Readonly<GoldShopWeapon>): void
	function WeaponShopRequested(player: Player): void
}

export = Analytics
