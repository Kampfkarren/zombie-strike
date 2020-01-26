import { GamemodeInfo } from "../GamemodeInfo/Gamemode";

declare namespace Dungeon {
	export function GetDungeonData(boss: "BossInfo"): BossInfo
	export function GetGamemodeInfo(): GamemodeInfo
}

export = Dungeon
