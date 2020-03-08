local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Items = ReplicatedStorage.Items

local function quick(type, instanceType, patch)
	return function(name, codename)
		if codename == nil then
			codename = name:gsub(" ", "")
		end

		local data = {
			Name = name,
			Type = type,
		}

		local item = Items[instanceType .. "_" .. codename]
		patch(data, item)
		return data
	end

end

local function quickInstance(type, instanceType)
	return quick(type, instanceType, function(data, item)
		data.Instance = item
	end)
end

local function dontSellMe(thing)
	thing.DontSellMe = true
	return thing
end

local particle = quick("Particle", "Particle", function(data, item)
	data.Instance = item.Contents
	data.Image = item.Image
end)

local face = quick("Face", "Face", function(data, item)
	data.Instance = item.Face
end)

local lowTier = quickInstance("LowTier", "Bundle")
local highTier = quickInstance("HighTier", "Bundle")

local gunLowTier = quick("GunLowTier", "GunSkin", function(data, item)
	data.Instance = item.Contents
end)

local gunHighTier = quick("GunHighTier", "GunSkin", function(data, item)
	data.Instance = item.Contents
end)

-- DON'T REORDER THIS LIST!
-- ALWAYS PUT NEW COSMETICS AT THE END!
-- DATA IS SAVED AS INDEXES!
return {
	face("Chill"),
	lowTier("Doge"),
	highTier("Ud'zal", "Udzal"),
	particle("Fire"),
	lowTier("Oof"),
	particle("Balls"),
	face("Err"),
	face("Shiny Teeth"),
	face("Super Super Happy Face", "DevFace"),
	face("Friendly Smile"),
	face(":3", "Cat"),
	face("Prankster"),
	face("Bandage"),
	face("Skeptic"),
	face("Blizzard Beast Mode"),
	face("Golden Shiny Teeth"),
	face("Goofball"),
	face("Freckled Cheeks"),
	face("Zorgo"),
	face("Monarch Butterfly Smile", "Butterfly"),
	face("Yum"),
	highTier("Light Dominus: the God", "God1"),
	highTier("Thanoid"),
	lowTier("Valkyrian"),
	lowTier("Skeleton"),
	highTier("Overseer"),
	highTier("Doombringer"),
	highTier("Korblox Deathspeaker", "Korblox"),
	highTier("The Professional", "Professional"),
	highTier("Guardian"),
	highTier("Sir Knight", "Knight"),
	lowTier("Felipe"),
	lowTier("Bunny"),
	lowTier("SinisterBot 5001", "Sinister"),
	lowTier("Gatekeeper"),
	lowTier("Cluck Cluck", "Chicken"),
	lowTier("Nick Bass", "NickBass"),
	particle("Hearts"),
	particle("Starry"),
	particle("Bit"),
	particle("Money"),
	particle("Fireworks"),
	particle("Grid"),
	particle("Bubbles"),
	particle("Rings"),
	particle("Electric"),
	particle("Plasma"),
	dontSellMe(highTier("Santa")),
	dontSellMe(lowTier("Mrs. Claus", "SantaGirl")),
	dontSellMe(lowTier("Penguin")),
	highTier("Dark Age Apprentice", "DarkAgeApprentice"),
	lowTier("Little Ms. Rich", "LittleMsRich"),
	lowTier("Rockstar"),
	lowTier("Blue Dude", "BlueDude"),
	lowTier("White Belt", "WhiteBelt"),
	lowTier("New Kid", "NewKid"),
	lowTier("Ms. Friend", "MsFriend"),
	lowTier("Anime Fan", "AnimeFan"),
	lowTier("Su Tart", "Sutart"),
	highTier("The Dark God", "TheDarkGod"),
	lowTier("Codebreaker"),
	highTier("Swanky"),
	dontSellMe(lowTier("The Noble", "Noble")),
	dontSellMe(lowTier("The Quirky", "Quirky")),
	dontSellMe(lowTier("Athlete")),
	dontSellMe(lowTier("Biker")),
	dontSellMe(lowTier("Photographer")),
	dontSellMe(lowTier("Sleepy")),
	dontSellMe(lowTier("The Comedian", "Comedian")),
	dontSellMe(lowTier("The Leader", "Leader")),
	dontSellMe(lowTier("The Noble", "Noble")),
	dontSellMe(lowTier("The Quirky", "Quirky")),
	dontSellMe(particle("Red Lights", "RedLights")),
	dontSellMe(lowTier("Aesthetic Nerd", "AestheticNerd")),
	dontSellMe(lowTier("Bat & Ghost!", "BatAndGhost")),
	dontSellMe(lowTier("Cat Vibes", "CatVibes")),
	dontSellMe(lowTier("Fear Contestant", "FearContestant")),
	dontSellMe(lowTier("Game Over", "GameOver")),
	dontSellMe(lowTier("Operator")),
	dontSellMe(lowTier("Sea Agent", "SeaAgent")),
	dontSellMe(lowTier("Wanwood")),
	dontSellMe(lowTier("World View", "WorldView")),
	gunHighTier("Enouy"),
	gunHighTier("Henry Rifle", "HenryRifle"),
	gunHighTier("Guycot"),
	gunHighTier("Martin"),
	gunHighTier("Volcanic"),
	gunLowTier("Borchardt"),
	gunLowTier("Coach Gun", "CoachGun"),
	gunLowTier("Derringer"),
	gunLowTier("Lever Shotgun", "LeverShotgun"),
	gunLowTier("Mauser"),
	gunLowTier("Peacemaker"),
	gunLowTier("Revolver Rifle", "RevolverRifle"),
	gunLowTier("Six Shooter", "SixShooter"),
	gunLowTier("Spencer"),
	gunLowTier("Winchest"),
	dontSellMe(lowTier("Oni")),
	dontSellMe(lowTier("Creep")),
	dontSellMe(lowTier("Child of Hope", "ChildOfHope")),
	dontSellMe(lowTier("Canada = France", "CanadaFrance")),
	dontSellMe(lowTier("Loving Sunflower", "LovingSunflower")),
	dontSellMe(lowTier("Golden Carpet", "GoldenCarpet")),
	dontSellMe(lowTier("Baby")),
	dontSellMe(lowTier("Mimic")),
}
