import { Gun } from "shared/ReplicatedStorage/Core/Loot"

declare namespace GunScaling {
	function StatsFor<I extends {
		Type: Gun["Type"],
	}>(item: I): Gun
}

export = GunScaling
