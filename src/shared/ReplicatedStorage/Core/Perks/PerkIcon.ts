import { ReplicatedStorage } from "@rbxts/services"

function perkIcon(name: string): string {
	return require(ReplicatedStorage.Assets.Tarmac.UI.perks[name]) as string
}

const PerkIcon = {
	Arrow: perkIcon("arrow"),
	Badge: perkIcon("badge"),
	Bolt: perkIcon("bolt"),
	Bullet: perkIcon("bullet"),
	Bullseye: perkIcon("bullseye"),
	Defense: perkIcon("defense"),
	Dice: perkIcon("dice"),
	Fire: perkIcon("fire"),
	Fist: perkIcon("fist"),
	Heart: perkIcon("heart"),
	Pistol: perkIcon("pistol"),
	Plus: perkIcon("plus"),
	Reload: perkIcon("reload"),
	Skull: perkIcon("skull"),
	Snowflake: perkIcon("snowflake"),
	Starry: perkIcon("starry"),
	Twinkle: perkIcon("twinkle"),
	X: perkIcon("x"),
}

export = PerkIcon
