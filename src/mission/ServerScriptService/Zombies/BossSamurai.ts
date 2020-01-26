import ZombieClass from "./ZombieClass";

class BossSamurai implements ZombieClass {
	static Model: string = "Boss"
	static Name: string = "Samurai Master Zombie"

	bossRoom: Model | undefined

	InitializeAI() { }

	InitializeBossAI(room: Model) {
		this.bossRoom = room
	}
}

export = BossSamurai
