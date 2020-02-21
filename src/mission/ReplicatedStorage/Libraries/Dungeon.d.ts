import { BossInfo } from "shared/ReplicatedStorage/Core/BossInfo";
import { GamemodeInfo } from "../GamemodeInfo/Gamemode";

declare namespace Dungeon {
	export function GetDungeonData(arg: "BossInfo"): BossInfo
	export function GetDungeonData(arg: "Campaign"): number
	export function GetDungeonData(arg: "Difficulty"): number
	export function GetDungeonData(arg: "Gamemode"): "Mission" | "Arena" | "Boss"

	export function GetGamemodeInfo(): GamemodeInfo
}

export = Dungeon
