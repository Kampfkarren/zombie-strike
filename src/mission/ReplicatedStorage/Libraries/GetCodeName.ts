import Dungeon from "./Dungeon"

export = function (): string {
	if (Dungeon.GetDungeonData("Gamemode") === "Boss") {
		return Dungeon.GetDungeonData("BossInfo").RoomName
	} else {
		return tostring(Dungeon.GetDungeonData("Campaign"))
	}
}
