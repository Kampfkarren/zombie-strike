local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ArmorScaling = require(ReplicatedStorage.Core.ArmorScaling)
local Cosmetics = require(ReplicatedStorage.Core.Cosmetics)
local Data = require(ReplicatedStorage.Core.Data)
local Equip = require(ServerScriptService.Shared.Ruddev.Equip)
local Maid = require(ReplicatedStorage.Core.Maid)
local Promise = require(ReplicatedStorage.Core.Promise)
local Settings = require(ReplicatedStorage.Core.Settings)
local XP = require(ReplicatedStorage.Core.XP)

local Armor = {
	Name = "Armor",
	Health = ArmorScaling.ArmorHealth,
}

local Helmet = {
	Name = "Helmet",
	Health = ArmorScaling.HelmetHealth,
}

local function getLimb(thing)
	local success, limb = pcall(function()
		return Enum.BodyPartR15[thing.Name]
	end)

	if success then
		return limb
	end
end

local function equipModelThing(thing, character, maid)
	if thing:IsA("CharacterAppearance") or thing:IsA("Accessory") then
		local thing = thing:Clone()
		thing.Parent = character
		maid:GiveTask(thing)
	elseif thing.Name == "Helmet" and thing:IsA("BasePart") then
		local head = character.Head:Clone()

		for _, thing in pairs(head:GetChildren()) do
			if not thing:IsA("Attachment") or thing:IsA("Motor6D") then
				thing:Destroy()
			end
		end

		thing.Mesh:Clone().Parent = head

		character.Humanoid:ReplaceBodyPartR15(Enum.BodyPartR15.Head, head)
			maid:GiveTask(function()
				character.Humanoid:ReplaceBodyPartR15(
					Enum.BodyPartR15.Head,
					ReplicatedStorage.Dummy.Head:Clone()
				)
			end)
	else
		local limb = getLimb(thing)
		if limb then
			character.Humanoid:ReplaceBodyPartR15(limb, thing:Clone())
			maid:GiveTask(function()
				character.Humanoid:ReplaceBodyPartR15(limb, ReplicatedStorage.Dummy[limb.Name]:Clone())
			end)
		end
	end
end

local function equipModel(item, character, maid)
	if item:IsA("Folder") then
		for _, thing in pairs(item:GetChildren()) do
			equipModelThing(thing, character, maid)
		end
	else
		equipModelThing(item, character, maid)
	end
end

local function equipCosmetic(player, character, equippable, maid)
	return Data.GetPlayerDataAsync(player, "Cosmetics")
		:andThen(function(data)
			local equipped = data.Equipped[equippable.Name]

			if equipped then
				equipModel(Cosmetics.Cosmetics[equipped].Instance, character, maid)
			end

			return equipped ~= nil
		end)
end

local function equip(player, character, equippable, maid)
	return equipCosmetic(player, character, equippable, maid)
		:andThen(function(cosmeticEquipped)
			return Data.GetPlayerDataAsync(player, equippable.Name)
				:andThen(function(equipped)
					local item = ReplicatedStorage.Items[equipped.Type .. equipped.Model]

					if not cosmeticEquipped then
						equipModel(item, character, maid)
					end

					return equippable.Health(equipped.Level, equipped.Rarity)
				end)
		end)
end

local function equipGun(player, character, maid)
	return Data.GetPlayerDataAsync(player, "Weapon")
		:andThen(function(data)
			local gun = Data.GetModel(data)
			gun.Name = "Gun"

			local weaponData = Instance.new("Folder")
			weaponData.Name = "WeaponData"

			for statName, stat in pairs(data) do
				local statValue = Instance.new((type(stat) == "number" and "Number" or "String") .. "Value")
				statValue.Name = statName
				statValue.Value = stat
				statValue.Parent = weaponData
			end

			gun.Ammo.Value = data.Magazine
			weaponData.Parent = gun
			gun.Parent = character

			maid:GiveTask(gun)
			Equip(gun)
			return gun
		end)
end

local function giveOutfit(player, character)
	local maid = Maid.new(true)

	return Promise.all({
		-- Equip armor
		equip(player, character, Armor, maid),

		-- Equip helmet and face
		equip(player, character, Helmet, maid):andThen(function(health)
			return Data.GetPlayerDataAsync(player, "Cosmetics"):andThen(function(cosmetics)
				local face = cosmetics.Equipped.Face
				if face then
					character.Head.face.Transparency = 1

					local face = Cosmetics.Cosmetics[face].Instance:Clone()
					face.Parent = character.Head
					maid:GiveTask(face)
				else
					character.Head.face.Transparency = 0
				end
			end):andThen(function()
				return health
			end)
		end),

		-- Equip gun
		equipGun(player, character, maid):andThen(function(gun)
			return Data.GetPlayerDataAsync(player, "Cosmetics"):andThen(function(cosmetics)
				local particle = cosmetics.Equipped.Particle
				if particle then
					local particle = particle:Clone()
					particle.Parent = gun.PrimaryPart.Muzzle
					maid:GiveTask(particle)
				end
			end)
		end),

		-- Get XP health
		Data.GetPlayerDataAsync(player, "Level"):andThen(XP.HealthForLevel),

		-- Set skin tone
		Promise.promisify(Settings.GetSetting)("Skin Tone", player)
			:andThen(function(tone)
				return Promise.async(function(resolve)
					local description = Instance.new("HumanoidDescription")
					description.LeftArmColor = tone
					description.LeftLegColor = tone
					description.RightArmColor = tone
					description.RightLegColor = tone
					description.HeadColor = tone
					character.Humanoid:ApplyDescription(description)
					resolve()
				end)
			end)
	}):andThen(function(healths)
		local health = 0

		for _, add in pairs(healths) do
			if add then
				health = health + add
			end
		end

		character.Humanoid.MaxHealth = health
		character.Humanoid.Health = health
	end), maid
end

return giveOutfit
