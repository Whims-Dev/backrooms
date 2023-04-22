-- pikahub script
-- made by tk

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GroupService = game:GetService("GroupService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris");
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local CoreGui = game.CoreGui;

local Player = Players.LocalPlayer;
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera;

local SectionsData = {}

local function Notify(Title, Text, Duration)
	StarterGui:SetCore("SendNotification", {Title=Title, Text=Text, Duration=(Duration or 5), Button1="OK"})
end

if (shared.PikaHubDisconnect) then
	shared.PikaHubDisconnect();
end

local function Padding(parent, bottom, left, right, top)
	local uIPadding = Instance.new("UIPadding")
	uIPadding.Name = "UIPadding"
	uIPadding.PaddingBottom = UDim.new(bottom or 0, 0)
	uIPadding.PaddingLeft = UDim.new(left or 0, 0)
	uIPadding.PaddingRight = UDim.new(right or 0, 0)
	uIPadding.PaddingTop = UDim.new(top or 0, 0)
	uIPadding.Parent = parent
	return uIPadding;
end

local function FeatureText(parent, text)
	local feature = Instance.new("TextLabel")
	feature.Name = "Feature"
	feature.FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json")
	feature.Text = text
	feature.TextColor3 = Color3.fromRGB(255, 255, 255)
	feature.TextScaled = true
	feature.TextSize = 14
	feature.TextWrapped = true
	feature.TextXAlignment = Enum.TextXAlignment.Left
	feature.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	feature.BackgroundTransparency = 1
	feature.Position = UDim2.fromScale(0.03, 0.15)
	feature.Size = UDim2.fromScale(0.55, 0.7)
	feature.Parent = parent;
	return feature;
end

local function Roundify(parent, scale, offset)
	local uICorner = Instance.new("UICorner")
	uICorner.Name = "UICorner"
	uICorner.CornerRadius = UDim.new(scale or 0.5, offset or 0)
	uICorner.Parent = parent
	return uICorner;
end

local pikaHub = Instance.new("ScreenGui")
pikaHub.Name = "PikaHub"
pikaHub.IgnoreGuiInset = true
pikaHub.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
pikaHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local main = Instance.new("Frame")
main.Name = "Main"
main.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
main.BorderSizePixel = 0
main.Position = UDim2.fromScale(0.0158, 0.338)
main.Size = UDim2.fromScale(0.289, 0.333)
main.Active = true
main.Draggable = true

Roundify(main, 0, 4)

local scriptTitle = Instance.new("TextLabel")
scriptTitle.Name = "ScriptTitle"
scriptTitle.FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json")
scriptTitle.Text = "PIKAHUB"
scriptTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
scriptTitle.TextScaled = true
scriptTitle.TextSize = 14
scriptTitle.TextWrapped = true
scriptTitle.TextXAlignment = Enum.TextXAlignment.Left
scriptTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
scriptTitle.BackgroundTransparency = 1
scriptTitle.Position = UDim2.fromScale(0.05, 0.01)
scriptTitle.Size = UDim2.fromScale(0.9, 0.075)
scriptTitle.Parent = main

local scrolling = Instance.new("ScrollingFrame")
scrolling.Name = "Scrolling"
scrolling.CanvasSize = UDim2.new()
scrolling.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
scrolling.ScrollBarThickness = 0
scrolling.Active = true
scrolling.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
scrolling.BackgroundTransparency = 1
scrolling.BorderSizePixel = 0
scrolling.Position = UDim2.fromScale(0, 0.1)
scrolling.Size = UDim2.fromScale(1, 0.08)

local scrollingUIListLayout = Instance.new("UIListLayout")
scrollingUIListLayout.Name = "UIListLayout"
scrollingUIListLayout.FillDirection = Enum.FillDirection.Horizontal
scrollingUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
scrollingUIListLayout.Parent = scrolling

scrolling.Parent = main

local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
uIAspectRatioConstraint.Name = "UIAspectRatioConstraint"
uIAspectRatioConstraint.AspectRatio = 1.33
uIAspectRatioConstraint.Parent = main

main.Parent = pikaHub
pikaHub.Parent = CoreGui

local Connections = {}
local function DestroyConnection(Name)
	if (Connections[Name]) then
		Connections[Name]:Disconnect()
		Connections[Name] = nil;
	end
end
local function MakeConnection(Name, Connection)
	DestroyConnection(Name);
	Connections[Name] = Connection;
end

local function SettingsLibrary()
	local Library, Current = {}, {}
	local settingsdoc = "Settings.pikahub"
	local function GetConfigs()
		local exists, saved = isfile(settingsdoc), {}
		if (exists) then
			saved = HttpService:JSONDecode(readfile(settingsdoc))
		end
		if (not writing) then
			writefile(settingsdoc, HttpService:JSONEncode(saved))
		end
		return saved
	end
	function Library.new(Section)
		local Library = {}
		local SectionSettings = {}
		Current[Section] = SectionSettings
		function Library.EditSetting(Setting, Value)
			SectionSettings[Setting] = Value
		end
		function Library.GetSetting(Setting)
			return SectionSettings[Setting]
		end
		return Library
	end
	function Library.save(name)
		local saved = GetConfigs()
		saved[name] = Current
		writefile(settingsdoc, HttpService:JSONEncode(saved))
		Notify("Configuration saved", string.format("\"%s\" saved!", name), math.huge)
	end
	function Library.load(name)
		local saved = GetConfigs()
		if (saved[name]) then
			for s, data in pairs(saved[name]) do
				local section = SectionsData[s]
				for name, value in pairs(data) do
					local info = section[name]
					if (info) and (info.internalcallback) then
						info.internalcallback(value)
					end
				end
			end
			Notify("Configuration loaded", string.format("\"%s\" loaded!", name), math.huge)
		else
			Notify("Load failed", string.format("\"%s\" doesn't exist.", name), math.huge)
		end
	end
	return Library
end

local SettingsLibrary = SettingsLibrary()
local SettingsLib = SettingsLibrary.new;

local function NewSection(Section)
	local sectionData = {};
	SectionsData[Section] = sectionData;
	local Settings = SettingsLib(Section);
	local sectionButton = Instance.new("TextButton")
	sectionButton.Name = "SectionButton"
	sectionButton.FontFace = Font.new("rbxassetid://12187365977")
	sectionButton.Text = Section
	sectionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	sectionButton.TextScaled = true
	sectionButton.TextWrapped = true
	sectionButton.Active = false
	sectionButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	sectionButton.BorderSizePixel = 0
	sectionButton.Selectable = false
	sectionButton.Size = UDim2.new(0, 30 + (7*string.len(Section)), 1, 0)
	sectionButton.Parent = scrolling
	sectionButton.BackgroundTransparency = (Section == "Universal") and 0.8 or 1
	scrolling.CanvasSize = UDim2.fromOffset(scrollingUIListLayout.AbsoluteContentSize.X, 0)
	Padding(sectionButton, 0.15, 0.05, 0.05, 0.15)
	local container = Instance.new("ScrollingFrame")
	container.Name = "Container"
	container.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
	container.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
	container.ScrollBarThickness = 8
	container.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
	container.Active = true
	container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Position = UDim2.fromScale(0, 0.18)
	container.Size = UDim2.fromScale(1, 0.81)
	container.Changed:Connect(function()
		sectionButton.BackgroundTransparency = container.Visible and 0.8 or 1
	end)
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Name = "UIListLayout"
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Parent = container
	uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		container.CanvasSize = UDim2.fromOffset(0, uIListLayout.AbsoluteContentSize.Y)
	end)
	sectionButton.MouseButton1Click:Connect(function()
		for _, c in pairs(main:GetChildren()) do
			if (c.Name == "Container") then
				c.Visible = false;
			end
		end
		container.Visible = true;
	end)
	container.Visible = false;
	container.Parent = main;
	local Create = {}
	function Create.Button(Text, Callback)
		local info = { internalcallback = Callback }
		local button = Instance.new("Frame")
		button.Name = "Button"
		button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		button.BackgroundTransparency = 0.8
		button.BorderSizePixel = 0
		button.Size = UDim2.new(1, 0, 0, 25)
		FeatureText(button, Text)
		info.type = button.Name
		local button1 = Instance.new("TextButton")
		button1.Name = "Button"
		button1.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
		button1.Text = "O"
		button1.TextColor3 = Color3.fromRGB(255, 255, 255)
		button1.TextScaled = true
		button1.TextSize = 14
		button1.TextWrapped = true
		button1.TextYAlignment = Enum.TextYAlignment.Top
		button1.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		button1.BackgroundTransparency = 0.5
		button1.Position = UDim2.fromScale(0.85, 0.1)
		button1.Size = UDim2.fromScale(0.1, 0.8)
		Roundify(button1)
		button1.Parent = button
		button.Parent = container;
		sectionData[Text] = info
		local click;
		if (Callback ~= nil) then
			click = button1.MouseButton1Click:Connect(Callback)
		end
		return button, click;
	end
	function Create.Number(Text, Default, Min, Max, Callback)
		local Default, Min, Max = (tonumber(Default) or 0), (tonumber(Min) or -math.huge), (tonumber(Max) or math.huge);
		local info = { value = Default };
		local number = Instance.new("Frame")
		number.Name = "Number"
		number.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		number.BackgroundTransparency = 0.8
		number.BorderSizePixel = 0
		number.Size = UDim2.new(1, 0, 0, 25)
		FeatureText(number, Text)
		info.type = number.Name
		local button = Instance.new("TextBox")
		button.Name = "Button"
		button.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
		button.Text = tostring(Default or Min or 0)
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.TextScaled = true
		button.TextSize = 14
		button.TextWrapped = true
		button.TextYAlignment = Enum.TextYAlignment.Top
		button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		button.BackgroundTransparency = 0.5
		button.Position = UDim2.fromScale(0.75, 0.1)
		button.Size = UDim2.fromScale(0.2, 0.8)
		Roundify(button)
		Padding(button, 0.17, 0.05, 0.05, 0.17)
		button.Parent = number
		number.Parent = container;
		local lastValue = info.value;
		info.internalcallback = function(value)
			local value = tonumber(value);
			if (value ~= nil) and (value >= Min) and (value <= Max) then
				info.value, lastValue = value, value;
				if (Callback ~= nil) then
					task.spawn(Callback, value);
				end
				Settings.EditSetting(Text, info.value)
			end
			button.Text = lastValue;
		end
		sectionData[Text] = info
		local controller = button.FocusLost:Connect(function()
			info.internalcallback(button.Text)
		end)
		if (Callback ~= nil) then
			Callback(info.value);
		end
		return info, number, controller;
	end
	function Create.String(Text, Default, Callback)
		local Default = Default or "";
		local info = { value = Default };
		local number = Instance.new("Frame")
		number.Name = "String"
		number.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		number.BackgroundTransparency = 0.8
		number.BorderSizePixel = 0
		number.Size = UDim2.new(1, 0, 0, 25)
		FeatureText(number, Text)
		info.type = number.Name
		local button = Instance.new("TextBox")
		button.Name = "Button"
		button.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
		button.Text = Default
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.TextScaled = true
		button.TextSize = 14
		button.TextWrapped = true
		button.TextYAlignment = Enum.TextYAlignment.Top
		button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		button.BackgroundTransparency = 0.5
		button.Position = UDim2.fromScale(0.65, 0.1)
		button.Size = UDim2.fromScale(0.3, 0.8)
		Roundify(button)
		Padding(button, 0.17, 0.05, 0.05, 0.17)
		button.Parent = number
		number.Parent = container;
		info.internalcallback = function(input)
			info.value = input;
			button.Text = info.value;
			if (Callback ~= nil) then
				task.spawn(Callback, info.value);
			end
			Settings.EditSetting(Text, info.value)
		end
		local controller = button.FocusLost:Connect(function()
			info.internalcallback(button.Text)
		end)
		info.internalcallback(info.value)
		sectionData[Text] = info
		return info, number, controller;
	end
	function Create.Toggle(Text, Default, Callback)
		local info = { value = Default };
		local toggle = Instance.new("Frame")
		toggle.Name = "Toggle"
		toggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		toggle.BackgroundTransparency = 0.8
		toggle.BorderSizePixel = 0
		toggle.Size = UDim2.new(1, 0, 0, 25)
		FeatureText(toggle, Text)
		info.type = toggle.Name
		local button = Instance.new("TextButton")
		button.Name = "Button"
		button.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
		button.Text = ""
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.TextScaled = true
		button.TextSize = 14
		button.TextWrapped = true
		button.TextYAlignment = Enum.TextYAlignment.Top
		button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		button.BackgroundTransparency = 0.5
		button.Position = UDim2.fromScale(0.8, 0.1)
		button.Size = UDim2.fromScale(0.15, 0.8)
		Roundify(button)
		local frame = Instance.new("Frame")
		frame.Name = "Frame"
		frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		frame.BackgroundTransparency = 0.9
		frame.Size = UDim2.fromScale(0.5, 1)
		Roundify(frame)
		frame.Parent = button
		button.Parent = toggle
		toggle.Parent = container;
		info.internalcallback = function(value)
			frame.BackgroundColor3 = (value and Color3.new(0, 1, 0) or Color3.new(1, 0, 0))
			frame.Position = (value and UDim2.fromScale(0.5, 0) or UDim2.fromScale(0, 0))
			info.value = value;
			if (Callback ~= nil) then
				task.spawn(Callback, info.value);
			end
			Settings.EditSetting(Text, info.value)
		end
		info.internalcallback(info.value)
		local controller = button.MouseButton1Click:Connect(function()
			info.internalcallback(not info.value)
		end)
		sectionData[Text] = info
		return info, toggle, controller;
	end
	return Create, container;
end

local Universal, MC = NewSection("Universal")
Universal.Button("Unnamed ESP", function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Whims-Dev/backrooms/main/scripts/Unnamed%20ESP%20Edit.lua", true))()
end)
local speedInfo = Universal.Toggle("Speedhack", false)
local speedSpeedInfo = Universal.Number("Dash Speed (ms)", 60, 60, 120)
local jumpInfo = Universal.Number("Jump Strength", 100, 0, 600)
Universal.Button("Super Jump", function()
	Player.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, jumpInfo.value, 0)
end)
Universal.Toggle("Fly (F2)", false, function(value)
	if (value) then
		loadstring(game:HttpGet("https://raw.githubusercontent.com/Whims-Dev/backrooms/main/scripts/VelocityBasedFly.lua", true))()
	else
		if (shared.flyinput) then shared.flyinput:Disconnect() end
		if (shared.FlyHandler) then shared.FlyHandler:Disconnect() end
	end
end)
Universal.Toggle("Noclip", false, function(value)
	if (value) then
		MakeConnection("Noclip", RunService.Stepped:Connect(function()
			local Character = Player.Character;
			if (Character == nil) then return end
			for _, p in pairs(Character:GetDescendants()) do
				if (p:IsA("BasePart")) and (p.CanCollide) then
					p.CanCollide = false
				end
			end
		end))
	else
		DestroyConnection("Noclip")
		local Character = Player.Character;
		if (Character ~= nil) then
			if (Character:FindFirstChild("UpperTorso")) then
				Character.UpperTorso.CanCollide = true
				Character.Head.CanCollide = true
			elseif (Character:FindFirstChild("Torso")) then
				Character.Torso.CanCollide = true
				Character.Head.CanCollide = true
			end
		end
	end
end)
local aimbotInfo = Universal.Toggle("Aimbot", false, function(value)
	if (not value)then
		DestroyConnection("ActiveAimbot")
	end
end)
local aimbotIgnoreTeam = Universal.Toggle("Ignore Team", true)
local aimbotLegit = Universal.Toggle("Legit Measure", false)
local aimbotSmoothingInfo = Universal.Number("Smoothing (1-10)", 3, 1, 10)
local function CreateViewExample(sp)
	local sg = Instance.new("ScreenGui")
	local frame = Instance.new("Frame")
	frame.Rotation = 45
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BorderSizePixel = 0
	frame.Size = UDim2.fromOffset(5, 5)
	frame.Position = UDim2.fromOffset(sp.X, sp.Y)
	frame.Parent = sg
	sg.Parent = CoreGui
	Debris:AddItem(sg, 1)
end
local function GetClosestToScreenPoint(ScreenPoint)
	local Closest, Target = 120, nil;
	local Parent = Player.Character.Parent;
	if (game.GameId == 504234221) and (workspace:FindFirstChild("GameStuff")) and (workspace.GameStuff:FindFirstChild("Entities")) then
		local EntityFolder = workspace.GameStuff.Entities;
		for _, e in pairs(EntityFolder:GetChildren()) do
			if (e:IsA("Model")) and (e.Name:match("Vampire")) then
				Parent = EntityFolder;
				break;
			end
		end
	end
	local teamsToIgnore = { Player.Team.Name };
	if (game.GameId == 3809673475) then
		local Criminals = {"Fugitive", "Prisoners"}
		if (table.find(Criminals, Player.Team.Name)) then
			for _, t in pairs(Criminals) do
				table.insert(teamsToIgnore, t)
			end
		end
	end
	for _, e in pairs(Parent:GetChildren()) do
		if (e == Player.Character) then continue end
		local hum: Humanoid = e:FindFirstChildWhichIsA("Humanoid");
		local head: BasePart = e:FindFirstChild("Head");
		if (aimbotIgnoreTeam.value) then
			local player = Players:GetPlayerFromCharacter(e);
			if (player ~= nil) and (table.find(teamsToIgnore, player.Team.Name)) then
				continue
			end
		end
		if (hum ~= nil) and (head ~= nil) and (hum.Health > 0) then
			local Point, OnScreen = Camera:WorldToScreenPoint(head.Position);
			local Distance = (Vector2.new(Point.X, Point.Y) - ScreenPoint).Magnitude;
			if (OnScreen) and ((not Closest) or (Closest and Distance < Closest)) then
				Closest, Target = Distance, e;
			end
		end
	end
	return Target;
end
local SavedCFrame, SavedCamera;
Universal.Button("Save Current Position", function()
	xpcall(function()
		SavedCFrame, SavedCamera = Player.Character.HumanoidRootPart.CFrame, Camera.CFrame;
	end, function()
		Notify("Error", "You either have not loaded in or this game does not use the default character.", 5)
	end)
end)
Universal.Button("Goto Saved Position", function()
	if (not SavedCFrame) then
		Notify("Error", "You don't have a saved position set.", 5)
	else
		Player.Character.HumanoidRootPart.CFrame, Camera.CFrame = SavedCFrame, SavedCamera;
	end
end)
Universal.Button("Dawnwalker VC Visualizer", function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Whims-Dev/backrooms/main/scripts/Dawnwalker%20VC%20Visualizer.lua", true))()
end)
Universal.Button("Moon's Dex Explorer", function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
end)
MC.Visible = true;
local Redwood = NewSection("Evergreen Prison")
Redwood.Toggle("Disable Mountain Wind", false, function(value)
	if (value) then
		local function NoWinded(c)
			MakeConnection("MountainWinded", c.ChildAdded:Connect(function(i)
				if (i:IsA("Folder")) and (i.Name == "Winded") then
					task.wait(1)
					i:Destroy()
				end
			end))
			if (c:FindFirstChild("Winded")) and (c.Winded:IsA("Folder")) then
				c.Winded:Destroy()
			end
		end
		MakeConnection("WindedRespawned", Player.CharacterAdded:Connect(NoWinded))
		if (Player.Character) then
			NoWinded(Player.Character)
		end
	else
		DestroyConnection("MountainWinded")
		DestroyConnection("WindedRespawned")
	end
end)
local Deepwoken = NewSection("Deepwoken")
local GroupInfo = GroupService:GetGroupInfoAsync(5212858);
local function GetRoleInfoFromRank(Rank)
	for _, info in pairs(GroupInfo.Roles) do
		if (info.Rank == Rank) then
			return info;
		end
	end
end
Deepwoken.Button("Respawn", function()
	Player.Character.Head:Destroy()
end)
Deepwoken.Toggle("Mod Check", false, function(value)
	if (value) then
		Notify("Mod Check", "Checking for moderators, please stand by...", 5)
		MakeConnection("dwModcheck", Players.PlayerAdded:Connect(function(p)
			local Rank = p:GetRankInGroup(5212858);
			if (Rank) and (Rank >= 1) then
				Notify("Mod Alert", string.format("%s (%s)\nRank: %s", p.Name, p.UserId, GetRoleInfoFromRank(Rank).Name), math.huge)
			end
		end))
		local found = false;
		for _, p in pairs(Players:GetPlayers()) do
			xpcall(function()
				local Rank = p:GetRankInGroup(5212858);
				if (Rank) and (Rank >= 1) then
					Notify("Mod Alert", string.format("%s (%s)\nRank: %s", p.Name, p.UserId, GetRoleInfoFromRank(Rank).Name), math.huge)
					found = true;
				end
			end, function(a)
				Notify("Mod Alert", string.format("Error with %s (%s)...\n%s", p.Name, p.UserId, a), 5)
			end)
		end
		if (not found) then
			Notify("Mod Check", "All clear!", 5)
		end
	else
		DestroyConnection("dwModcheck")
	end
end)
local NoFallDamage = Deepwoken.Toggle("No Fall Damage", false);
local call; call = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	local args = {...};
	if (checkcaller()) then return call(self, ...); end
	local method = getnamecallmethod();
	if (method == 'FireServer') and (NoFallDamage.value) and (typeof(args[1]) == "number") then
		return;
	elseif (method == "FindFirstChild") and (args[1] == "BodyVelocity") then
		return;
	end
	return call(self, ...);
end))
local dwNPCName = Deepwoken.String("NPC Name", "")
Deepwoken.Button("Delete NPC", function()
	if (table.find({"", " "}, dwNPCName.value)) then
		Notify("Delete NPC", "Invalid NPC name!", 5)
		return
	end
	local target = string.lower(dwNPCName.value);
	local notfound, noownership, name = true, true, "";
	for _, c in pairs(workspace.Live:GetChildren()) do
		if (string.lower(c.Name):match(target)) then
			local humanoid = c:FindFirstChildWhichIsA("Humanoid")
			if (not humanoid) then continue end
			notfound, name = false, c.Name;
			for _, p in pairs(c:GetChildren()) do
				if (p:IsA("BasePart")) and (isnetworkowner(p)) then
					noownership = false;
					humanoid.Health = 0;
					c:Destroy()
					break;
				end
			end
		end
	end
	if (notfound) then
		Notify("Delete NPC", "NPC does not exist or is not spawned in!", 5)
	elseif (noownership) then
		Notify("Delete NPC", "You do not have ownership of this NPC!", 5)
	else
		Notify("Delete NPC", string.format("Successfully deleted %s!", name), 5)
	end
end)
Deepwoken.Toggle("No Fog", false, function(value)
	if (value) then
		MakeConnection("dw No Fog", RunService.Heartbeat:Connect(function()
			Lighting.FogEnd = 10000000
		end))
	else
		DestroyConnection("dw No Fog")
	end
end)
Deepwoken.Toggle("Auto Charisma", false, function(value)
	if (value) then
		local Bindable; do
			for _, c in pairs(getnilinstances()) do
				if (c.Name == "MessagePosted") then
					Bindable = c;
					break;
				end
			end
		end
		MakeConnection("AutoCharisma", Player.DescendantAdded:Connect(function(prompt)
			if (prompt:IsA("TextLabel")) and (prompt.Name == "Prompt") and (prompt.Parent.Name == "SimplePrompt") then
				if (prompt.Text:match("small talk")) then
					local o = prompt.Text:split("'");
					local msg = "";
					for i = 2, #o do
						local v = o[i];
						if (#v == 0) then continue end
						local add = "";
						for e = 1, #v do
							local byte = string.byte(string.sub(v, e, e));
							if (byte >= 65) and (byte <= 122) then
								add = add .. string.lower(string.sub(v, e, e))
							end
						end
						msg = msg .. add;
						if ((#o - 1) ~= i) then
							msg = msg .."'";
						end
					end
					task.wait(0.5)
					Bindable:Fire(msg)
				end
			end
		end))
	else
		DestroyConnection("AutoCharisma")
	end
end)
local sanityMeter;
Deepwoken.Toggle("Sanity Check", false, function(value)
	if (value) then
		if (sanityMeter) then sanityMeter:Destroy() end
		sanityMeter = Instance.new("BillboardGui")
		sanityMeter.Name = "SanityMeter"
		sanityMeter.Active = true
		sanityMeter.AlwaysOnTop = true
		sanityMeter.LightInfluence = 1
		sanityMeter.Size = UDim2.fromScale(0.3, 6)
		sanityMeter.StudsOffset = Vector3.new(3, 0, 0)
		sanityMeter.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		local sanity = Instance.new("Frame")
		sanity.Name = "Sanity"
		sanity.AnchorPoint = Vector2.new(0.5, 0.5)
		sanity.BackgroundColor3 = Color3.fromRGB(27, 42, 53)
		sanity.BorderColor3 = Color3.fromRGB(27, 42, 53)
		sanity.BorderSizePixel = 0
		sanity.BackgroundTransparency = 1
		sanity.Position = UDim2.fromScale(0.5, 0.5)
		sanity.Size = UDim2.fromScale(1, 1)
		Roundify(sanity)
		local fill = Instance.new("Frame")
		fill.Name = "Fill"
		fill.AnchorPoint = Vector2.new(0, 1)
		fill.BackgroundColor3 = Color3.fromRGB(73, 73, 255)
		fill.BorderColor3 = Color3.fromRGB(27, 42, 53)
		fill.BorderSizePixel = 0
		fill.BackgroundTransparency = 1
		fill.Position = UDim2.fromScale(0, 1)
		fill.Size = UDim2.fromScale(1, 0.5)
		Roundify(fill)
		fill.Parent = sanity
		sanity.Parent = sanityMeter
		sanityMeter.Parent = CoreGui;
		local TweenOut0, TweenOut1;
		local function NewCharacter()
			if (Player.PlayerGui:FindFirstChild("StatsGui")) then
				local visibleTimer = 0;
				local Indicator = Player.PlayerGui.StatsGui.CombatStats.Indicators.Parry;
				MakeConnection("parryOverlayChanged", Indicator.Changed:Connect(function()
					if (Indicator.ImageTransparency > 0.1) then
						if (visibleTimer <= 0) then
							visibleTimer = 3;
							if (TweenOut0) then TweenOut0:Pause() end
							if (TweenOut1) then TweenOut1:Pause() end
							sanity.BackgroundTransparency = 0
							fill.BackgroundTransparency = 0
							sanityMeter.Adornee = Player.Character.HumanoidRootPart
							pcall(function()
								repeat
									fill.Size = UDim2.fromScale(1, Player.Character.Sanity.Value/Player.Character.Sanity.MaxValue)
									visibleTimer -= task.wait(0.1)
								until visibleTimer <= 0;
							end)
							TweenOut0 = TweenService:Create(sanity, TweenInfo.new(2), {BackgroundTransparency=1})
							TweenOut1 = TweenService:Create(fill, TweenInfo.new(2), {BackgroundTransparency=1})
							TweenOut0:Play()
							TweenOut1:Play()
						else
							visibleTimer = 3;
						end
					end
				end))
			end
		end
		MakeConnection("ParryRespawned", Player.CharacterAdded:Connect(NewCharacter))
		NewCharacter()
	else
		if (sanityMeter) then
			sanityMeter:Destroy()
			sanityMeter = nil;
		end
		DestroyConnection("parryOverlayChanged")
		DestroyConnection("ParryRespawned")
	end
end)
local LeaderboardRespawn;
local spectateInfo = Deepwoken.Toggle("Leaderboard Spectate", false, function(value)
	if (value) then
		if (not LeaderboardRespawn) then
			if (Player:FindFirstChild("PlayerGui")) and (Player.PlayerGui:FindFirstChild("LeaderboardGui")) then
				NewLeaderboard()
			end
			LeaderboardRespawn = Player.CharacterAdded:Connect(NewLeaderboard)
		end
	end
end)
function NewSpectate(frame)
	if (frame:IsA("Frame")) then
		frame.InputBegan:Connect(function(input, gpe)
			if (not spectateInfo.value) then return end
			if (gpe) then return end
			if (input.UserInputType == Enum.UserInputType.MouseButton1) then
				local plr = Players:FindFirstChild(frame.Player.Text);
				if (plr ~= nil) then
					local character = plr.Character;
					if (character == nil) then return end
					local humanoid = character:FindFirstChild("Humanoid")
					if (humanoid == nil) then return end
					if (Camera.CameraSubject == humanoid) then
						Camera.CameraSubject = Player.Character.Humanoid
					else
						Camera.CameraSubject = humanoid;
					end
				end
			end
		end)
		frame.Player.Changed:Connect(function()
			if (not spectateInfo.value) then return end
			local plr = Players:FindFirstChild(frame.Player.Text);
			if (plr ~= nil) then
				frame.Player.TextColor3 = Color3.new(1, 0, 0)
			else
				frame.Player.TextColor3 = Color3.new(1, 1, 1)
			end
		end)
	end
end
function NewLeaderboard()
	Player.PlayerGui.LeaderboardGui.MainFrame.ScrollingFrame.ChildAdded:Connect(NewSpectate)
	for _, f in pairs(Player.PlayerGui.LeaderboardGui.MainFrame.ScrollingFrame:GetChildren()) do
		NewSpectate(f)
	end
end
Deepwoken.Toggle("Custom Voices", false, function(value)
	if (value) then
		loadstring(game:HttpGet("https://raw.githubusercontent.com/Whims-Dev/backrooms/main/scripts/DeepwokenVoices.lua", true))()
	else
		if (shared.PlayerAddedDsounds) then
			shared.PlayerAddedDsounds:Disconnect()
		end
		if (shared.CharacterAddedDsounds) then
			shared.CharacterAddedDsounds:Disconnect()
		end
	end
end)
local dwCombatMusic = Deepwoken.String("Combat Music", "combat.ogg")
local dwCombatVolume = Deepwoken.String("Combat Volume", 0.35)
local dwAmbientMusic = Deepwoken.String("Ambient Music", "ambient.ogg")
local dwAmbientVolume = Deepwoken.String("Ambient Volume", 0.35)
Deepwoken.Toggle("Custom Music", false, function(value)
	if (value) then
		MakeConnection("dwCustomMusic", RunService.Heartbeat:Connect(function()
			local PlayerGui = Player:FindFirstChild("PlayerGui")
			if (PlayerGui) and (PlayerGui:FindFirstChild("WorldClient")) then
				local combat = PlayerGui.WorldClient:FindFirstChild("Combat", true)
				local ambient = PlayerGui.WorldClient:FindFirstChild("Ambient", true)
				if (combat) then
					combat.SoundId = getsynasset(dwCombatMusic.value)
					combat.BaseVolume.Value = math.min(combat.BaseVolume.Value, dwCombatVolume.value)
				end
				if (ambient) then
					ambient.SoundId = getsynasset(dwAmbientMusic.value)
					ambient.BaseVolume.Value = math.min(ambient.BaseVolume.Value, dwAmbientVolume.value)
				end
			end
		end))
	else
		DestroyConnection("dwCustomMusic")
	end
end)
Deepwoken.Button("Race Morph Menu", function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/AzurasDev/DeepwokenRaceMorpher/main/RaceMorphMenu.lua"))()
end)
Deepwoken.Button("BoobWoken Menu", function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Whims-Dev/backrooms/main/notmyscripts/DoubleDsWoken.lua"))()
end)
local VH3 = NewSection("Vampire Hunters 3")
local autoEscapeInfo; autoEscapeInfo = VH3.Toggle("Auto Escape", false, function(value)
	if (value) then
		local KeysArray = {["Spacebar"] = 0x20, ["A"] = 0x41; ["B"] = 0x42; ["C"] = 0x43; ["D"] = 0x44; ["E"] = 0x45; ["F"] = 0x46; ["G"] = 0x47; ["H"] = 0x48; ["I"] = 0x49; ["J"] = 0x4A; ["K"] = 0x4B; ["L"] = 0x4C; ["M"] = 0x4D; ["N"] = 0x4E; ["O"] = 0x4F; ["P"] = 0x50; ["Q"] = 0x51; ["R"] = 0x52; ["S"] = 0x53; ["T"] = 0x54; ["U"] = 0x55; ["V"] = 0x56; ["W"] = 0x57; ["X"] = 0x58; ["Y"] = 0x59; ["Z"] = 0x5A}
		local lastpress = 0;
		MakeConnection("VH3_autoescape", RunService.Heartbeat:Connect(function()
			if (not autoEscapeInfo.value) then return end
			if (tick() - lastpress) < 0.2 then return end
			if (Player:FindFirstChild("PlayerGui")) then
				local gui = Player.PlayerGui:FindFirstChild("GrabbedGui");
				if (gui) and (gui:FindFirstChild("Frame")) and (gui.Frame:FindFirstChild("Escape")) then
					local keyframe = gui.Frame.Escape:FindFirstChild("Key");
					if (keyframe) and (keyframe:FindFirstChild("KeyName")) then
						local keycode = KeysArray[keyframe.KeyName.Text]
						if (keycode ~= nil) then
							keypress(keycode)
							keyrelease(keycode)
							lastpress = tick()
						end
					end
				end
			end
		end))
	else
		DestroyConnection("VH3_autoescape")
	end
end)
local antiNetInfo; antiNetInfo = VH3.Toggle("Net (1K Escape)", false, function(value)
	if (value) then
		MakeConnection("VH3_1knetescape", RunService.Heartbeat:Connect(function()
			if (not antiNetInfo.value) then return end
			if (Player:FindFirstChild("PlayerGui")) then
				local frame = Player.PlayerGui:FindFirstChild("RemoveNet");
				if (frame) and (frame:FindFirstChild("EscapeProgress")) then
					frame.EscapeProgress.Value = 99
				end
			end
		end))
	else
		DestroyConnection("VH3_1knetescape")
	end
end)
local Criminality = NewSection("Criminality")
local crimAimInfo; crimAimInfo = Criminality.Toggle("Aimbot", false, function(value)
	if (not value)then
		DestroyConnection("ActiveCrimAimbot")
	end
end)
local crimFriends = {}
local crimIgnoreFriends; crimIgnoreFriends = Criminality.Toggle("Ignore Friends", true, function(value)
	if (not value) then
		DestroyConnection("CrimNewFriend")
		table.clear(crimFriends)
	elseif (value) then
		MakeConnection("CrimNewFriend", Players.PlayerAdded:Connect(function(p)
			if (p:IsFriendsWith(Player.UserId)) then
				table.insert(crimFriends, p)
			end
		end))
		for _, p in pairs(Players:GetPlayers()) do
			if (p:IsFriendsWith(Player.UserId)) then
				table.insert(crimFriends, p)
			end
		end
	end
end)

local Config = NewSection("Configuration")
local configInfo = Config.String("Config Name", "")
Config.Button("Save", function()
	SettingsLibrary.save(configInfo.value)
end)
Config.Button("Load", function()
	SettingsLibrary.load(configInfo.value)
end)

local function TEclone(part, dt)
	local clone = Instance.new("Part")
	clone.Size = part.Size;
	clone.Anchored = true
	clone.CanCollide = false
	clone.CFrame = part.CFrame;
	clone.Color = (_G.tpcolor or part.Color);
	clone.Transparency = 0.5;
	clone.Material = Enum.Material.Neon
	coroutine.wrap(function()
		task.wait(dt)
		clone.Parent = Camera;
		Debris:AddItem(clone, 1)
		TweenService:Create(clone, TweenInfo.new(1), {
			Transparency = 1,
			CFrame = CFrame.new(clone.Position) * CFrame.Angles(math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180))),
			Size = Vector3.new(0, 0, math.random(0, 5))
		}):Play()
	end)()
end

local speedController = RunService.Stepped:Connect(function()
	if (not speedInfo.value) then return end
	local char = Player.Character;
	if (not char) then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if (root ~= nil) then
		local newvel = root.AssemblyLinearVelocity/45;
		root.CFrame += Vector3.new(newvel.X, 0, newvel.Z)
	end
end)

local lastTP = tick();
local speedDash = RunService.RenderStepped:Connect(function(dt)
	if (not speedInfo.value) then return end
	local now = tick();
	if (UserInputService:IsKeyDown(Enum.KeyCode.V)) and (not UserInputService:GetFocusedTextBox()) and ((now - lastTP) > speedSpeedInfo.value/1000) then
		lastTP = now;
		local root = Player.Character:FindFirstChild("HumanoidRootPart")
		root.CFrame += root.CFrame.LookVector * 10;
		local sound = Instance.new("Sound");
		sound.SoundId = "rbxassetid://3763437293";
		sound.Volume = 1;
		sound.TimePosition = 0.815;
		sound.Parent = root;
		sound:Play()
		Debris:AddItem(sound, 1);
		for _, name in pairs({"Head", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "Torso"}) do
			local part = Player.Character:FindFirstChild(name);
			if (part ~= nil) then
				TEclone(part, dt)
			end
		end
	end
end)

local function GetCharacters()
	local Characters = {}
	for _, c in pairs(Player.Character.Parent:GetChildren()) do
		if (c == Player.Character) then continue end
		if (c:FindFirstChildOfClass("Humanoid") and c:FindFirstChild("Head") and c:FindFirstChild("HumanoidRootPart")) then
			table.insert(Characters, c)
		end
	end
	return Characters;
end

local InputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
	if (gpe) then return end
	if (input.KeyCode == Enum.KeyCode.End) then
		main.Visible = not main.Visible;
	elseif (input.UserInputType == Enum.UserInputType.MouseButton2) then
		if (aimbotInfo.value) then
			if (crimAimInfo.value) then
				MakeConnection("ActiveCrimAimbot", RunService.Heartbeat:Connect(function()
					local character = Player.Character
					if (character == nil) then return end
					local rootpart = character:FindFirstChild("HumanoidRootPart")
					if (rootpart == nil) then return end
					local withinFOV = {}
					local canBehind = true;
					for _, char in pairs(GetCharacters()) do
						local player = Players:GetPlayerFromCharacter(char)
						if (player) and (crimIgnoreFriends.value) and (table.find(crimFriends, player)) then
							continue
						end
						local head = char:FindFirstChild("Head")
						local hrp = char:FindFirstChild("HumanoidRootPart")
						if (head and hrp) then
							local worldPoint = head.Position;
							local torso = char:FindFirstChild("Torso")
							if (torso) then
								worldPoint = (worldPoint:Lerp(torso.Position, 0.25))
							end
							local vector, onScreen = Camera:WorldToScreenPoint(worldPoint)
							local screenPoint = Vector2.new(vector.X, vector.Y)
							if (not onScreen) then continue end
							local magn = (screenPoint - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
							if (magn < 120) then
								local info = {
									target = worldPoint,
									distanceFromPlayer = (worldPoint - rootpart.Position).Magnitude,
									distanceFromCenter = magn,
									behindWall = false,
									rootpart = hrp
								};
								local rayOrigin = Camera.CFrame.Position
								local rayDirection = (head.Position - Camera.CFrame.Position).Magnitude * (head.Position - Camera.CFrame.Position).Unit
								local raycastParams = RaycastParams.new()
								raycastParams.FilterDescendantsInstances = {Player.Character, char, workspace.Camera}
								raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
								raycastParams.IgnoreWater = true
								local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
								if (raycastResult) then
									info.behindWall = true
								else
									canBehind = false
								end
								table.insert(withinFOV, info)
							end
						end
					end
					if (#withinFOV > 0) then
						local closest, farthestdistance = nil, math.huge
						if (not canBehind) then
							for _, v in pairs(withinFOV) do
								if (not v.behindWall) and (v.distanceFromCenter < farthestdistance) then
									closest, farthestdistance = v, v.distanceFromCenter
								end
							end
						else
							for _, v in pairs(withinFOV) do
								if (v.distanceFromPlayer < farthestdistance) then
									closest, farthestdistance = v, v.distanceFromPlayer
								end
							end
						end
						if (closest) then
							local hrp = closest.rootpart
							local magn = (closest.target - rootpart.Position).Magnitude;
							local distanceMultiplier = (magn / 100);
							Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closest.target + ((hrp.Velocity/15) * distanceMultiplier)), 0.3)
						end
					end
				end))
			else
				local OffsetTimer, Offset, AimName = 0, Vector3.new(), "Head";
				MakeConnection("ActiveAimbot", RunService.Heartbeat:Connect(function(dt)
					local AimEntity = GetClosestToScreenPoint(Vector2.new(Mouse.X, Mouse.Y));
					if (AimEntity ~= nil) then
						local AimPart = AimEntity:FindFirstChild(AimName) or AimEntity:FindFirstChild("Head") or AimEntity:FindFirstChild("Torso");
						if (AimPart ~= nil) then
							if (game.GameId == 3809673475) then
								local distanceMultiplier = ((Player.Character.HumanoidRootPart.Position - AimPart.Position).Magnitude / 100);
								Offset = ((AimPart.Parent.HumanoidRootPart.Velocity/12) * distanceMultiplier) + Vector3.new(0, distanceMultiplier/3, 0)
							end
							Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, AimPart.Position + Offset), aimbotSmoothingInfo.value/10)
						end
					end
					OffsetTimer -= dt;
					if (OffsetTimer <= 0) then
						AimName = (math.random(1, 4) == 1) and "Torso" or "Head";
						if (aimbotLegit.value) then
							Offset = Vector3.new(math.random(-5, 5)/10, math.random(-5, 5)/10, math.random(-5, 5)/10)
						else
							Offset = Vector3.new(0, 0.1, 0)
						end
						OffsetTimer = math.random(5, 30)/100;
					end
				end))
			end
		end
	end
end)

local InputEnded = UserInputService.InputEnded:Connect(function(input)
	if (input.UserInputType == Enum.UserInputType.MouseButton2) then
		DestroyConnection("ActiveAimbot")
		DestroyConnection("ActiveCrimAimbot")
	end
end)

shared.PikaHubDisconnect = function()
	for _, c in pairs(CoreGui:GetChildren()) do
		if (c:IsA("ScreenGui")) and (c.Name == pikaHub.Name) then
			c:Destroy()
		end
	end
	InputBegan:Disconnect();
	InputEnded:Disconnect();
	speedController:Disconnect();
	speedDash:Disconnect();
	for i, v in pairs(Connections) do
		v:Disconnect()
	end
	if (sanityMeter) then sanityMeter:Destroy() end
	if (shared.flyinput) then shared.flyinput:Disconnect() end
	if (shared.FlyHandler) then shared.FlyHandler:Disconnect() end
end
