local Explosion = require(script.Parent.Explosion)

return function(position, radius)
	Explosion(position, radius, false, {
		Meteors = 1,
		FireEmission = 10,
		SmokeEmission = 5,
		Shake = false,
	})
end
