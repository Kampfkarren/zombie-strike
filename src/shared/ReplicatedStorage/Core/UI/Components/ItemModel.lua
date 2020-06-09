-- TODO: Fake aurora weapons
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local assign = require(ReplicatedStorage.Core.assign)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local ItemModel = Roact.PureComponent:extend("ItemModel")

local function getKey(model)
	if model:FindFirstChild("UUID") then
		return model.UUID.Value
	else
		return model
	end
end

ItemModel.defaultProps = {
	Angle = Vector3.new(-1, 0, 0),
	Distance = 0.5,
	Offset = Vector3.new(0, 0, 0),
	SpinSpeed = 0,
	UseDirectly = false,
}

function ItemModel:init()
	self.cameraRef = Roact.createRef()
	self.viewportRef = Roact.createRef()

	self.totalSpin = 0
end

function ItemModel:didMount()
	self:CreateModel()
end

function ItemModel:didUpdate(oldProps)
	local uuidNew, uuidOld = getKey(self.props.Model), getKey(oldProps.Model)

	if uuidNew == nil or uuidOld == nil or uuidNew ~= uuidOld then
		self:CreateModel()
	end
end

function ItemModel:CreateModel()
	if self.object then
		self.object:Destroy()
	end

	if self.spinHeartbeat then
		self.spinHeartbeat:Disconnect()
	end

	local camera = self.cameraRef:getValue()

	local object = self.props.Model
	if not self.props.UseDirectly then
		object = object:Clone()
	end

	local size = object:GetExtentsSize()

	local offsetX = size.X % 2 * -0.5
	local offsetZ = size.Z % 2 * 0.5
	object:SetPrimaryPartCFrame(CFrame.new(offsetX, size.Y * 0.5, offsetZ))
	object.Parent = self.viewportRef:getValue()
	self.object = object

	local width = size.Magnitude * 3
	local fov = math.rad(90 - camera.FieldOfView)
	-- tan fov = distance / halfWidth
	-- tan fov * halfWidth = distance
	local distance = math.tan(fov) * width * self.props.Distance

	local eyePos = self.props.Angle.Unit * distance
	camera.CFrame = object.PrimaryPart.CFrame * CFrame.new(eyePos, Vector3.new()) + self.props.Offset

	if self.props.SpinSpeed ~= 0 then
		local base = object.PrimaryPart.CFrame

		object:SetPrimaryPartCFrame(base * CFrame.Angles(0, self.totalSpin * self.props.SpinSpeed, 0))

		self.spinHeartbeat = RunService.Heartbeat:connect(function(delta)
			if object.PrimaryPart == nil then
				warn("PrimaryPart to spin was nil!")
				self.spinHeartbeat:Disconnect()
				return
			end

			self.totalSpin = self.totalSpin + delta
			object:SetPrimaryPartCFrame(base * CFrame.Angles(0, self.totalSpin * self.props.SpinSpeed, 0))
		end)
	end
end

function ItemModel:willUnmount()
	if self.spinHeartbeat then
		self.spinHeartbeat:Disconnect()
	end
end

function ItemModel:render()
	return e("ViewportFrame", {
		BackgroundTransparency = 1,
		CurrentCamera = self.cameraRef,
		Size = UDim2.fromScale(1, 1),
		[Roact.Ref] = self.viewportRef,
	}, assign({
		Camera = e("Camera", {
			[Roact.Ref] = self.cameraRef,
		}),
	}, self.props[Roact.Children] or {}))
end

return ItemModel
