local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Cosmetics = require(ReplicatedStorage.Core.Cosmetics)
local Equipped = require(script.Pages.Equipped)
local Loot = require(ReplicatedStorage.Core.Loot)
local Memoize = require(ReplicatedStorage.Core.Memoize)
local Nametag = require(script.Pages.Nametag)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local SelectScreen = require(script.Pages.SelectScreen)
local SpraysDictionary = require(ReplicatedStorage.Core.SpraysDictionary)
local StatsPage = require(script.Pages.StatsPage)

local e = Roact.createElement
local UnequipPet = ReplicatedStorage.Remotes.UnequipPet
local UpdateCosmetics = ReplicatedStorage.Remotes.UpdateCosmetics
local UpdateEquipment = ReplicatedStorage.Remotes.UpdateEquipment
local UpdateSprays = ReplicatedStorage.Remotes.UpdateSprays

local Inventory2 = Roact.Component:extend("Inventory2")

local inset = GuiService:GetGuiInset()

local FACE_DEFAULT = {
	Name = "Default",
	Type = "Face",

	Instance = ReplicatedStorage.Dummy.Head.face,
}

local function copy(list)
	local copy = {}
	for key, value in pairs(list) do
		copy[key] = value
	end
	return copy
end

local function getName(item)
	return item.Name
end

function Inventory2:init()
	self:setState({
		page = "Equipped",
	})

	self.basicEquip = function(loot)
		UpdateEquipment:FireServer(self:FindUUID(loot.UUID))
	end

	self.equipCosmetic = Memoize(function(key)
		return function(item, forceIsEquipped)
			local isEquipped = forceIsEquipped
				or self.props.cosmetics.equipped[key] == item.Index
				or self.lastEquipped == item.Index

			if isEquipped then
				UpdateCosmetics:FireServer(key)
				self.lastEquipped = nil
			else
				UpdateCosmetics:FireServer(item.UUID)

				-- HACK: We don't update as to preserve the select screen's state...
				-- ...but we need to know if we equipped something and then unequip it without changing pages.
				self.lastEquipped = item.Index
			end
		end
	end)

	self.setPage = Memoize(function(page)
		return function()
			self:setState({
				page = page,
			})
		end
	end)
end

function Inventory2:didUpdate(oldProps)
	if self.props.visible ~= oldProps.visible then
		if self.props.visible then
			self.props.hideUi()
		else
			self.props.showUi()
		end
	end
end

function Inventory2:CosmeticsPage(key, condition, text, plural)
	return e(SelectScreen, {
		Equipped = Cosmetics.Cosmetics[self.props.cosmetics.equipped[key]],
		Inventory = self:GetCosmetics(condition),
		Text = text,
		Plural = plural,

		GetName = getName,
		GoBack = self.setPage("Equipped"),
		Equip = self.equipCosmetic(key),

		ShowGearScore = false,
		AllowUnequip = true,
	})
end

function Inventory2:FindUUID(uuid)
	for index, item in ipairs(self.props.inventory) do
		if item.UUID == uuid then
			return index
		end
	end
end

function Inventory2:GetAttachments()
	local attachments = self:GetItems(Loot.IsAttachment)

	if self.props.equippedAttachment then
		table.insert(attachments, self.props.equippedAttachment)
	end

	return attachments
end

function Inventory2:GetCosmetics(condition)
	local inventory = {}

	for _, index in ipairs(self.props.cosmetics.contents) do
		local item = Cosmetics.Cosmetics[index]
		if condition(item) then
			local newItem = {}
			newItem.UUID = index

			for key, value in pairs(item) do
				newItem[key] = value
			end

			table.insert(inventory, newItem)
		end
	end

	return inventory
end

function Inventory2:GetItems(condition)
	local inventory = {}

	for _, item in ipairs(self.props.inventory) do
		if condition(item) then
			table.insert(inventory, item)
		end
	end

	return inventory
end

function Inventory2:render()
	if not self.props.visible then
		return nil
	end

	local pageElement

	local page = self.state.page

	-- TODO: DRY, maybe
	if page == "Equipped" then
		pageElement = e(Equipped, {
			SetPage = self.setPage,
		})
	elseif page == "Gun" then
		pageElement = e(SelectScreen, {
			Equipped = self.props.equippedWeapon,
			Inventory = self:GetItems(Loot.IsWeapon),
			Text = "a weapon",

			GetName = Loot.GetLootName,
			GoBack = self.setPage("Equipped"),
			Equip = self.basicEquip,
		})
	elseif page == "Armor" then
		pageElement = e(SelectScreen, {
			Angle = Vector3.new(-1, 0.8, -1),
			Equipped = self.props.equippedArmor,
			Inventory = self:GetItems(Loot.IsArmor),
			Text = "an armor",

			GetName = Loot.GetLootName,
			GoBack = self.setPage("Equipped"),
			Equip = self.basicEquip,
		})
	elseif page == "Helmet" then
		pageElement = e(SelectScreen, {
			Angle = Vector3.new(1, 0, 0),
			Equipped = self.props.equippedHelmet,
			Inventory = self:GetItems(Loot.IsHelmet),
			Text = "a helmet",

			GetName = Loot.GetLootName,
			GoBack = self.setPage("Equipped"),
			Equip = self.basicEquip,
		})
	elseif page == "Attachment" then
		pageElement = e(SelectScreen, {
			Angle = Vector3.new(-1, 0.8, -1),
			Equipped = self.props.equippedAttachment,
			Inventory = self:GetAttachments(),
			ShowGearScore = false,
			Plural = "attachments",
			Text = "an attachment",

			GetName = Loot.GetLootName,
			GoBack = self.setPage("Equipped"),
			Equip = self.basicEquip,
		})
	elseif page == "CosmeticHelmet" then
		pageElement = self:CosmeticsPage("Helmet", Loot.IsHelmet, "a cosmetic", "cosmetics")
	elseif page == "CosmeticArmor" then
		pageElement = self:CosmeticsPage("Armor", Loot.IsArmor, "a cosmetic", "cosmetics")
	elseif page == "GunSkin" then
		pageElement = self:CosmeticsPage("GunSkin", Loot.IsGunSkin, "a gun skin", "gun skins")
	elseif page == "Face" then
		local faces = self:GetCosmetics(function(item)
			return item.Type == "Face"
		end)

		table.insert(faces, FACE_DEFAULT)

		local equippedFace = FACE_DEFAULT
		local faceIndex = self.props.cosmetics.equipped.Face
		if faceIndex ~= nil then
			for _, face in ipairs(faces) do
				if face.Index == faceIndex then
					equippedFace = face
					break
				end
			end
		end

		pageElement = e(SelectScreen, {
			Angle = Vector3.new(-1, 0.8, -1),
			Equipped = equippedFace,
			Inventory = faces,
			Plural = "faces",
			Text = "a face",

			GetName = getName,
			GoBack = self.setPage("Equipped"),
			Equip = function(item)
				local forceIsEquipped = false

				if item == FACE_DEFAULT then
					item = nil
					forceIsEquipped = true
				end

				return self.equipCosmetic("Face")(item, forceIsEquipped)
			end,

			AllowUnequip = false,
			ShowGearScore = false,
		})
	elseif page == "Emote" then
		local inventory, equipped = {}, nil

		for _, owned in ipairs(self.props.emotes.owned) do
			local emote = copy(SpraysDictionary[owned])
			emote.Index = owned

			table.insert(inventory, emote)

			if owned == self.props.emotes.equipped then
				equipped = emote
			end
		end

		pageElement = e(SelectScreen, {
			Angle = Vector3.new(-1, 0.8, -1),
			Equipped = equipped,
			Inventory = inventory,
			Plural = "emotes",
			Text = "an emote",

			GetName = getName,
			GoBack = self.setPage("Equipped"),
			Equip = function(item)
				UpdateSprays:FireServer(item.Index)
			end,

			AllowUnequip = true,
			ShowGearScore = false,
		})
	elseif page == "Pet" then
		pageElement = e(SelectScreen, {
			Equipped = self.props.equippedPet,
			Inventory = self:GetItems(Loot.IsPet),
			Plural = "pets",
			Text = "a pet",

			GetName = Loot.GetLootName,
			GoBack = self.setPage("Equipped"),
			Equip = function(pet)
				if self.props.equippedPet == pet then
					UnequipPet:FireServer()
				else
					self.basicEquip(pet)
				end
			end,

			AllowUnequip = true,
			ShowGearScore = false,
		})
	elseif page == "Particle" then
		pageElement = self:CosmeticsPage("Particle", function(item)
			return item.Type == "Particle"
		end, "a particle", "particles")
	elseif page == "Nametag" then
		pageElement = e(Nametag, {
			GoBack = self.setPage("Equipped"),
		})
	elseif page == "Stats" then
		pageElement = e(StatsPage, {
			GoBack = self.setPage("Equipped"),
		})
	end

	return e("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(-inset.X, -inset.Y),
		Size = UDim2.new(1, inset.X, 1, inset.Y),
	}, {
		UIGradient = e("UIGradient", {
			Color = ColorSequence.new(
				Color3.new(0.6, 0.6, 1),
				Color3.new(1, 1, 1)
			),
			Transparency = NumberSequence.new(0, 1),
			Rotation = 90,
		}),

		Blur = RunService:IsRunning() and e(Roact.Portal, {
			target = Lighting,
		}, {
			BlurEffect = e("BlurEffect"),
		}) or nil,

		Page = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.5, inset.Y / 2),
			Size = UDim2.new(1, -inset.X, 0.95, -inset.Y),
		}, pageElement),
	})
end

return RoactRodux.connect(function(state)
	return {
		cosmetics = state.store,
		emotes = state.sprays,
		inventory = state.inventory,

		equippedArmor = state.equipment.equippedArmor,
		equippedHelmet = state.equipment.equippedHelmet,
		equippedPet = state.equipment.equippedPet,
		equippedWeapon = state.equipment.equippedWeapon,
		equippedAttachment = state.equipment.equippedAttachment,

		visible = state.page.current == "Inventory",
	}
end, function(dispatch)
	return {
		hideUi = function()
			dispatch({
				type = "HideUI",
			})
		end,

		showUi = function()
			dispatch({
				type = "ShowUI",
			})
		end,
	}
end)(Inventory2)
