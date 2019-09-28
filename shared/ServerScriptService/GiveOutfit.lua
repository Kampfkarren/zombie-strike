local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ArmorScaling = require(ReplicatedStorage.Core.ArmorScaling)
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

-- TODO: Check for limbs here for bundle armor/helmets
local function equip(player, character, equippable, maid)
	return Data.GetPlayerDataAsync(player, equippable.Name)
		:andThen(function(equipped)
			local item = ReplicatedStorage.Items[equipped.Type .. equipped.Model]

			for _, thing in pairs(item:GetChildren()) do
				if thing:IsA("CharacterAppearance") or thing:IsA("Accessory") then
					local thing = thing:Clone()
					thing.Parent = character
					maid:GiveTask(thing)
				end
			end

			return equippable.Health(equipped.Level, equipped.Rarity)
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
		end)
end

local function giveOutfit(player, character)
	local maid = Maid.new(true)

	return Promise.all({
		equip(player, character, Armor, maid),
		equip(player, character, Helmet, maid),
		equipGun(player, character, maid),
		Data.GetPlayerDataAsync(player, "Level"):andThen(XP.HealthForLevel),
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
