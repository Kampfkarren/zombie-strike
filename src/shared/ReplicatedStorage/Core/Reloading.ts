import WeakInstanceTable from "shared/ReplicatedStorage/Core/WeakInstanceTable"

const reloading = WeakInstanceTable<Player, boolean>()

export function SetReloading(player: Player, isReloading: boolean): void {
	reloading.set(player, isReloading)
}

export function IsReloading(player: Player): boolean {
	return reloading.get(player) === true
}
