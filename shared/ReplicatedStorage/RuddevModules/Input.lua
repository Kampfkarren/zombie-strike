-- services

local UserInputService =  game:GetService("UserInputService")
local ReplicatedStorage =  game:GetService("ReplicatedStorage")
local RunService =  game:GetService("RunService")

-- constants

-- variables

local actions =  {}

local actionBegan, actionEnded

-- functions

local function RegisterAction(action, primary, secondary)
	local info =  {
		Primary =  primary;
		Secondary =  secondary;
	}

	actions[action] =  info
end

local function ActionFromInputObject(inputObject)
	for action, info in pairs(actions) do
		if info.Primary then
			if info.Primary.EnumType == Enum.KeyCode then
				if inputObject.KeyCode == info.Primary then
					return action
				end
			elseif info.Primary.EnumType == Enum.UserInputType then
				if inputObject.UserInputType == info.Primary then
					return action
				end
			end
		end

		if info.Secondary then
			if info.Secondary.EnumType == Enum.KeyCode then
				if inputObject.KeyCode == info.Secondary then
					return action
				end
			elseif info.Secondary.EnumType == Enum.UserInputType then
				if inputObject.UserInputType == info.Secondary then
					return action
				end
			end
		end
	end
end

-- events

UserInputService.InputBegan:connect(function(inputObject, processed)
	local action =  ActionFromInputObject(inputObject)

	if action then
		actionBegan:Fire(action, processed)
	end
end)

UserInputService.InputEnded:connect(function(inputObject, processed)
	local action =  ActionFromInputObject(inputObject)

	if action then
		actionEnded:Fire(action, processed)
	end
end)

-- module

local INPUT =  {}

function INPUT.GetActionInput(_, action)
	local input =  "nil"

	local replacements =  {
		Zero =  "0";
		One =  "1";
		Two =  "2";
		Three =  "3";
		Four =  "4";
		Five =  "5";
		Six =  "6";
		Seven =  "7";
		Eight =  "8";
		Nine =  "9";

		MouseButton1 =  "MB1";
		MouseButton2 =  "MB2";
		MouseButton3 =  "MB3";
		Return =  "Enter";
		Slash =  "/";
		Tilde =  "~";
		Backquote =  "`";
	}

	if actions[action] then
		local primary, secondary =  actions[action].Primary, actions[action].Secondary

		if primary then
			input =  primary.Name
		elseif secondary then
			input =  secondary.Name
		end
	end

	if replacements[input] then
		input =  replacements[input]
	end

	return string.upper(input)
end

local keybindChanged =  Instance.new("BindableEvent")
INPUT.KeybindChanged =  keybindChanged.Event

actionBegan =  Instance.new("BindableEvent")
actionEnded =  Instance.new("BindableEvent")

INPUT.ActionBegan =  actionBegan.Event
INPUT.ActionEnded =  actionEnded.Event

-- register actions

local keybinds =  ReplicatedStorage.Keybinds

local function Register(action, bindP, bindS)
	local primary, secondary
	if bindP then
		local A, B =  string.match(bindP, "(.-)%.(.+)")

		if A and B then
			primary =  Enum[A][B]
		end
	end
	if bindS then
		local A, B =  string.match(bindS, "(.-)%.(.+)")

		if A and B then
			secondary =  Enum[A][B]
		end
	end

	RegisterAction(action, primary, secondary)
	keybindChanged:Fire(action)
end

local function Handle(keybind)
	local action =  keybind.Name
	local bind =  keybind.Value

	if string.match(bind, ";") then
		local bindP, bindS =  string.match(bind, "(.-);(.+)")

		if bindP and bindS then
			Register(action, bindP, bindS)
		elseif bindP then
			Register(action, bindP)
		elseif bindS then
			Register(action, nil, bindS)
		end
	else
		Register(action, bind)
	end
end

keybinds.ChildAdded:connect(function(keybind)
	keybind.Changed:connect(function()
		Handle(keybind)
	end)

	RunService.Stepped:wait()
	Handle(keybind)
end)

repeat
	RunService.Stepped:wait()
until #keybinds:GetChildren() > 0

for _, keybind in pairs(keybinds:GetChildren()) do
	keybind.Changed:connect(function()
		Handle(keybind)
	end)

	Handle(keybind)
end

return INPUT