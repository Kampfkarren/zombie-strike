import ZombieClass from "./ZombieClass";

class BossSamurai implements ZombieClass {
	static Model: string = "Boss"
	static Name: string = "Samurai Master Zombie"

	bossRoom: Model | undefined

	InitializeAI() { }

	InitializeBossAI(room: Model) {
		this.bossRoom = room
	}

	// TODO: Move these out into a bigger BossGamemode class?
	GetHealth() {
		return 100
	}
}

export = BossSamurai
