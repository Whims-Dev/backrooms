assert(Drawing, 'exploit not supported')

if not syn and not PROTOSMASHER_LOADED then print'Unnamed ESP only officially supports Synapse and Protosmasher! If you\'re an exploit developer and have added drawing API to your exploit, try setting syn as true then checking if that works, otherwise, DM me on discord @ cppbook.org#1968 or add an issue to the Unnamed ESP Github Repository and I\'ll see it through email!' end

if not cloneref then cloneref = function(o) return o end end

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local UserInputService = cloneref(game:GetService'UserInputService')
local HttpService = cloneref(game:GetService'HttpService')
local TweenService = cloneref(game:GetService'TweenService')
local RunService = cloneref(game:GetService'RunService')
local Players = game:GetService'Players'
local VRService = game:GetService('VRService')
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local V2New = Vector2.new
local V3New = Vector3.new
local WTVP = Camera.WorldToViewportPoint
local WorldToViewport = function(...) return WTVP(Camera, ...) end
local Menu = {}
local MouseHeld = false
local LastRefresh = 0
local OptionsFile = 'IC3_ESP_SETTINGS.dat'
local Binding = false
local BindedKey = nil
local OIndex = 0
local LineBox = {}
local UIButtons = {}
local Sliders = {}
local ColorPicker = { Loading = false, LastGenerated = 0 }
local Dragging = false
local DraggingUI = false
local Rainbow = false
local DragOffset = V2New()
local DraggingWhat = nil
local OldData = {}
local IgnoreList = {}
local EnemyColor = Color3.new(1, 0, 0)
local TeamColor = Color3.new(0, 1, 0)
local MenuLoaded = false
local ErrorLogging = false
local TracerPosition = V2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 135)
local DragTracerPosition = false
local SubMenu = {}
local IsSynapse = syn and not PROTOSMASHER_LOADED
local Connections = { Active = {} }
local Signal = {} Signal.__index = Signal
local GetCharacter, CurrentColorPicker, Spectating

local QUAD_SUPPORTED_EXPLOIT = pcall(function() Drawing.new('Quad'):Remove() end)

shared.MenuDrawingData = shared.MenuDrawingData or { Instances = {} }
shared.InstanceData = shared.InstanceData or {}
shared.RSName = shared.RSName or ('UnnamedESP_by_ic3-' .. HttpService:GenerateGUID(false))

local GetDataName = shared.RSName .. '-GetData'
local UpdateName = shared.RSName .. '-Update'

local Debounce = setmetatable({}, {
	__index = function(t, i)
		return rawget(t, i) or false
	end
})

if shared.UESP_InputChangedCon then shared.UESP_InputChangedCon:Disconnect() end
if shared.UESP_InputBeganCon then shared.UESP_InputBeganCon:Disconnect() end
if shared.UESP_InputEndedCon then shared.UESP_InputEndedCon:Disconnect() end
if shared.CurrentColorPicker then shared.CurrentColorPicker:Dispose() end

local function IsStringEmpty(String)
	if type(String) == 'string' then
		return String:match'^%s+$' ~= nil or #String == 0 or String == '' or false;
	end
	
	return false;
end

local function Set(t, i, v) t[i] = v end

local Teams = {};
local CustomTeams = {};

local RenderList = {Instances = {}};

function RenderList:AddOrUpdateInstance(Instance, Obj2Draw, Text, Color)
	RenderList.Instances[Instance] = { ParentInstance = Instance; Instance = Obj2Draw; Text = Text; Color = Color };
	return RenderList.Instances[Instance];
end

local CustomPlayerTag;
local CustomESP;
local CustomCharacter;
local GetHealth;
local GetAliveState;
local CustomRootPartName;

local function Round(num, dec)
    local dec = (dec or 2);
    return (math.round(num*(10^dec)))/(10^dec)
end

local function GrammaticallyCorrect(str)
	local spl = string.split(str, " ")
	for i, v in pairs(spl) do
		spl[i] = v:sub(1,1):upper() .. v:sub(2)
	end
	return table.concat(spl, " ");
end

function GetCharacter(Player)
	return CustomCharacter and CustomCharacter(Player) or Player.Character
end

function GetMouseLocation()
	return UserInputService:GetMouseLocation();
end

function MouseHoveringOver(Values)
	local X1, Y1, X2, Y2 = Values[1], Values[2], Values[3], Values[4]
	local MLocation = GetMouseLocation();
	return (MLocation.x >= X1 and MLocation.x <= (X1 + (X2 - X1))) and (MLocation.y >= Y1 and MLocation.y <= (Y1 + (Y2 - Y1)));
end

function GetTableData(t) -- basically table.foreach i dont even know why i made this
	if typeof(t) ~= 'table' then return end

	return setmetatable(t, {
		__call = function(t, func)
			if typeof(func) ~= 'function' then return end;
			for i, v in pairs(t) do
				pcall(func, i, v);
			end
		end;
	});
end
local function Format(format, ...)
	return string.format(format, ...);
end
function CalculateValue(Min, Max, Percent)
	return Min + math.floor(((Max - Min) * Percent) + .5);
end

function NewDrawing(InstanceName)
	local Instance = Drawing.new(InstanceName)

	return (function(Properties)
		for i, v in pairs(Properties) do
			pcall(Set, Instance, i, v)
		end

		return Instance
	end)
end

function Menu:AddMenuInstance(Name, DrawingType, Properties)
	local Instance;

	if shared.MenuDrawingData.Instances[Name] ~= nil then
		Instance = shared.MenuDrawingData.Instances[Name];
		for i, v in pairs(Properties) do
			pcall(Set, Instance, i, v);
		end
	else
		Instance = NewDrawing(DrawingType)(Properties);
	end

	shared.MenuDrawingData.Instances[Name] = Instance;

	return Instance;
end
function Menu:UpdateMenuInstance(Name)
	local Instance = shared.MenuDrawingData.Instances[Name];
	if Instance ~= nil then
		return (function(Properties)
			for i, v in pairs(Properties) do
				pcall(Set, Instance, i, v);
			end
			return Instance;
		end)
	end
end
function Menu:GetInstance(Name)
	return shared.MenuDrawingData.Instances[Name];
end

local Options = setmetatable({}, {
	__call = function(t, ...)
		local Arguments = {...};
		local Name = Arguments[1];
		OIndex = OIndex + 1;
		rawset(t, Name, setmetatable({
			Name			= Arguments[1];
			Text			= Arguments[2];
			Value			= Arguments[3];
			DefaultValue	= Arguments[3];
			AllArgs			= Arguments;
			Index			= OIndex;
		}, {
			__call = function(t, v, force)
				local self = t;

				if typeof(t.Value) == 'function' then
					t.Value();
				elseif typeof(t.Value) == 'EnumItem' then
					local BT = Menu:GetInstance(Format('%s_BindText', t.Name));
					if not force then
						Binding = true;
						local Val = 0
						while Binding do
							wait();
							Val = (Val + 1) % 17;
							BT.Text = Val <= 8 and '|' or '';
						end
					end
					t.Value = force and v or BindedKey;
					if BT and t.BasePosition and t.BaseSize then
						BT.Text = tostring(t.Value):match'%w+%.%w+%.(.+)';
						BT.Position = t.BasePosition + V2New(t.BaseSize.X - BT.TextBounds.X - 20, -10);
					end
				else
					local NewValue = v;
					if NewValue == nil then NewValue = not t.Value; end
					rawset(t, 'Value', NewValue);

					if Arguments[2] ~= nil and Menu:GetInstance'TopBar'.Visible then
						if typeof(Arguments[3]) == 'number' then
							local AMT = Menu:GetInstance(Format('%s_AmountText', t.Name));
							if AMT then
								AMT.Text = tostring(t.Value);
							end
						else
							local Inner = Menu:GetInstance(Format('%s_InnerCircle', t.Name));
							if Inner then Inner.Visible = t.Value; end
						end
					end
				end
			end;
		}));
	end;
})

local function load(parent, array, check)
	local check = check or function() return true end;
	local function new(v)
		if (check(v)) and (not table.find(array, v)) then
			table.insert(array, v)
			v.AncestryChanged:Connect(function()
				local index = table.find(array, v);
				if (not v:IsDescendantOf(parent)) and (index) then
					table.remove(array, index)
				end
			end)
		end
	end
	parent.ChildAdded:Connect(new)
	for _, v in pairs(parent:GetChildren()) do
		task.spawn(new, v)
	end
end

local ActiveWorldMarkers = {};
local LiveNPCs, NPCs, Thrown, Workspaced = {}, {}, {}, {};
local dwColors = {
	jsBeacon = Color3.new(0.694117, 1, 0.933333),
	Interactable = Color3.new(1, 1, 0.5),
};

local DeepwokenInfo = {
    CustomESP = function()
		for _, v in pairs(Workspaced) do
			if (v.Name == "DepthsWhirlpool") then
				local Center = Options.ShowWhirlpools.Value and v:FindFirstChild("Center") or nil;
				RenderList:AddOrUpdateInstance(v, Center, "Whirlpool", Color3.new(0.5, 0.5, 1))
			elseif (v.Name == "WindrunnerOrb") then
				local entry = Options.ShowJSOrbs.Value and v or nil;
                RenderList:AddOrUpdateInstance(v, entry, "Jetstriker Beacon", dwColors.jsBeacon);
			elseif (v.Name:match("GuildDoor_")) then
				local Sign, Text = Options.GuildBases.Value and v:FindFirstChild("Sign", true) or nil, "";
				if (Sign ~= nil) then
					local Label = Sign:FindFirstChild("TextLabel", true)
					if (Label ~= nil) then
						Text = Label.Text
					end
				end
				RenderList:AddOrUpdateInstance(v, Sign, ("Guild Base [%s]"):format(Text), Color3.new(0.450980, 0.250980, 1));
			end
		end
		for _, v in pairs(Thrown) do
			if (v.Name == "Model") and (v:FindFirstChild("Lid")) then
				RenderList:AddOrUpdateInstance(v, Options.ShowChests.Value and v:FindFirstChild("RootPart") or nil, "Chest", Color3.new(1, 0.5, 1))
			elseif (v.Name == "BagDrop") then
				RenderList:AddOrUpdateInstance(v, Options.DeathBags.Value and v or nil, "Death Bag", Color3.new(0.305882, 0.149019, 0));
			elseif (v.Name == "EventFeatherRef") then
				RenderList:AddOrUpdateInstance(v, Options.OwlFeathers.Value and v or nil, "Owl", Color3.new(0.172549, 0, 0.188235));
			end
		end
		for _, v in pairs(NPCs) do
			local RootPart, entry = Options.ShowInteractable.Value and v:FindFirstChild("HumanoidRootPart") or nil, Options.ShowJSOrbs.Value and v or nil;
			local jsOrb = (v.Name == "WindrunnerOrb")
			RenderList:AddOrUpdateInstance(v, jsOrb and entry or RootPart, jsOrb and "Jetstriker Beacon" or v.Name, jsOrb and dwColors.jsBeacon or dwColors.Interactable)
		end
		for _, v in pairs(LiveNPCs) do
			local Name = string.lower(v.Name:gsub("%d+", "")):gsub("_", " ")
			if (Name:sub(1, 1) == ".") then
				Name = string.sub(Name, 2);
			end
			local RootPart = Options.ShowMobs.Value and v:FindFirstChild("HumanoidRootPart") or nil;
			local Humanoid = v:FindFirstChild("Humanoid")
			local Health, MaxHealth, Percent = 0, 0, 0;
			if (Humanoid ~= nil) then
				Health, MaxHealth = Humanoid.Health, Humanoid.MaxHealth;
				Percent = (Health/MaxHealth)
			end
			RenderList:AddOrUpdateInstance(v, RootPart, string.format('%s\n[%s/%s]', GrammaticallyCorrect(Name), Round(Health), MaxHealth), Color3.new(1-Percent, Percent, 0))
		end
		if (Options.dwWorldLocations.Value) and (ReplicatedStorage:FindFirstChild("MarkerWorkspace")) and (ReplicatedStorage.MarkerWorkspace:FindFirstChild("AreaMarkers")) then
			for _, f in pairs(ReplicatedStorage.MarkerWorkspace.AreaMarkers:GetChildren()) do
				local marker = f:FindFirstChild("AreaMarker")
				if (ActiveWorldMarkers[f] ~= marker) then
					ActiveWorldMarkers[f] = marker;
				end
				RenderList:AddOrUpdateInstance(f, marker, f.Name, Color3.new(0, 0.317647, 1))
			end
		else
			for f in pairs(ActiveWorldMarkers) do
				RenderList:AddOrUpdateInstance(f, nil, "Despawning...", Color3.new(0, 0, 0));
				ActiveWorldMarkers[f] = nil;
			end
		end
    end;
    CustomPlayerTag = function(Player)
        local Name = '';
        local CharacterName = Player:GetAttribute('CharacterName');
        if not IsStringEmpty(CharacterName) then
            Name = ('\n[%s]'):format(CharacterName);
            local Character = GetCharacter(Player);
            local Extra = {};
            if Character then
				local PointsInvested = -10;
				for i, v in pairs(Character:GetAttributes()) do
					if (i:sub(1, 5) == "Stat_") then
						PointsInvested += v;
					end
				end
				local Power = math.floor(PointsInvested/15)
				table.insert(Extra, ("P%d"):format(math.clamp(Power, 1, 20)))
                local Blood, Armor = Character:FindFirstChild('Blood'), Character:FindFirstChild('Armor');
                if Blood and Blood.ClassName == 'DoubleConstrainedValue' then
                    table.insert(Extra, ('B%d'):format(Blood.Value));
                end
                if Armor and Armor.ClassName == 'DoubleConstrainedValue' then
                    table.insert(Extra, ('A%d'):format(math.floor(Armor.Value / 10)));
                end
            end
            local BackpackChildren = Player.Backpack:GetChildren()
            for index = 1, #BackpackChildren do
                local Item = BackpackChildren[index]
                if Item.ClassName == 'Folder' and Item.Name:find('Talent:Oath') then
                    local OathName = Item.Name:gsub('Talent:Oath: ', '')
                    table.insert(Extra, OathName);
                end
				if (Item:IsA("Tool") and Item.Name == "Talent:Voideye") then
					table.insert(Extra, "VW")
				end
            end
            if #Extra > 0 then Name = Name .. ' [' .. table.concat(Extra, '-') .. ']'; end
        end
        return Name;
    end;
	Initialize = function()
		local live = workspace:WaitForChild("Live")
		local npcs = workspace:WaitForChild("NPCs")
		local thrown = workspace:WaitForChild("Thrown")
		load(live, LiveNPCs, function(v)
			return not Players:GetPlayerFromCharacter(v);
		end)
		load(npcs, NPCs)
		load(thrown, Thrown, function(v)
			if (v:IsA("Model")) and (v.Name == "Model") then
				return true
			end
			if (v:IsA("MeshPart")) and (v.Name == "BagDrop") then
				return true
			end
			if (v.Name == "EventFeatherRef") then
				return true
			end
		end)
		load(workspace, Workspaced, function(v)
			if ((v:IsA("Model")) and (v.Name == "DepthsWhirlpool")) or (v.Name == "WindrunnerOrb") or (v.Name:match("GuildDoor_")) then
				return true
			end
		end)
	end;
	MoreOptions = {
		{'ShowMobs', 'Show Mobs', true},
		{'ShowInteractable', 'Show Interactable', true},
		{'ShowWhirlpools', 'Show Whirlpools', true},
		{'ShowJSOrbs', 'Show Jetstriker Orbs', true},
		{'ShowChests', 'Show Chests', true},
		{'DeathBags', 'Show Death Bags', true},
		{'GuildBases', "Show Guild Bases", true},
		{'dwWorldLocations', "Show World Locations", true},
		{'OwlFeathers', "Show Owl Events", true},
	};
};

local SavedParents = {}

local function GetParent(Ancestor, Descendant)
	if (SavedParents[Descendant]) then return SavedParents[Descendant]; end
	local Return = nil;
	if (Descendant.Parent == Ancestor) then Return = Ancestor; end
	for _, c in pairs(Ancestor:GetChildren()) do
		if (Descendant:IsDescendantOf(c)) then
			Return = c;
			break;
		end
	end
	SavedParents[Descendant] = Return;
	return Return;
end

local Modules = {
	[6032399813] = DeepwokenInfo, -- Etrean
	[6473861193] = DeepwokenInfo, -- Eastern Luminent
	[5735553160] = DeepwokenInfo, -- Depths
	[8668476218] = DeepwokenInfo, -- Layer 2/Trial of One
	[3223065041] = { -- Write a Letter
		CustomESP = function()
			if (workspace:FindFirstChild('Pickups')) then
				for i, v in pairs(workspace.Pickups:GetDescendants()) do
					local Name = GetParent(workspace.Pickups, v).Name;
					if (v:IsA("ClickDetector")) and (v.Parent:IsA("BasePart")) then
						local Parent = v.Parent;
						if (not Options.ShowPickupsWAL.Value) then Parent = nil end
						pcall(RenderList.AddOrUpdateInstance, RenderList, v.Parent, Parent, Name, Color3.new(0.6, 0, 1));
					end
				end
			end
			if (workspace:FindFirstChild('Interactables')) then
				for i, v in pairs(workspace.Interactables:GetDescendants()) do
					local Name = GetParent(workspace.Interactables, v).Name;
					if (v:IsA("ClickDetector")) and (v.Parent:IsA("BasePart")) then
						local Parent = v.Parent;
						if (not Options.ShowInteractableWAL.Value) then Parent = nil end
						pcall(RenderList.AddOrUpdateInstance, RenderList, v.Parent, Parent, Name, Color3.new(0, 0.8, 1));
					end
				end
			end
		end;
		MoreOptions = {
			{'ShowInteractableWAL', 'Show Interactable', true},
			{'ShowPickupsWAL', 'Show Pickups', true},
		};
	},
	[504234221] = { -- Vampire Hunters 3
		CustomPlayerTag = function(Player)
			local Role = "";
			if (Player.Backpack:FindFirstChild("Gun")) or (Player.Character:FindFirstChild("Gun", true)) then
				Role = "Detective"
			elseif (Player.Character:FindFirstChild("OriginalCol")) then
				Role = "Vampire"
			else
				Role = "Survivor"
			end
			local Inventory = {};
			local cTool = Player.Character:FindFirstChildWhichIsA("Tool")
			if (cTool ~= nil) then
				table.insert(Inventory, cTool.Name)
			else
				table.insert(Inventory, "Nothing")
			end
			return string.format("\n[%s]", Role) .." [".. table.concat(Inventory, "-") .."]"
		end,
		CustomESP = function()
			if (workspace:FindFirstChild('GameStuff')) and (workspace.GameStuff:FindFirstChild("Entities")) then
				for i, v in pairs(workspace.GameStuff.Entities:GetChildren()) do
					local hum = v:FindFirstChildWhichIsA("Humanoid");
					if (v.Name == "GunPickup") then
						local part = v;
						if (not Options.vh3ShowDroppedGun.Value) then part = nil end
						pcall(RenderList.AddOrUpdateInstance, RenderList, v, part, "Gun", Color3.new(0.533333, 1, 0.960784));
					elseif (v.Name == "AmmoBox") then
						local part = v:FindFirstChild("Union");
						if (not Options.vh3ShowAmmoBoxes.Value) then part = nil end
						pcall(RenderList.AddOrUpdateInstance, RenderList, v, part, "Ammo Box", Color3.new(0, 0.274509, 0.023529));
					elseif (v.Name == "Food") then
						local part = v:FindFirstChildWhichIsA("BasePart");
						if (not Options.vh3ShowFood.Value) then part = nil end
						pcall(RenderList.AddOrUpdateInstance, RenderList, v, part, "Food", Color3.new(0.501960, 1, 0.545098));
					elseif (hum ~= nil) then
						local Percent = (hum.Health/hum.MaxHealth)
						local RootPart = v:FindFirstChild("HumanoidRootPart");
						if (not Options.vh3ShowMobs.Value) then RootPart = nil end
						pcall(RenderList.AddOrUpdateInstance, RenderList, v, RootPart, string.format('%s\n[%s/%s]', v.Name, Round(hum.Health), hum.MaxHealth), Color3.new(1-Percent, Percent, 0));
					end
				end
			end
		end,
		MoreOptions = {
			{'vh3ShowMobs', 'Show Mobs', true},
			{'vh3ShowDroppedGun', 'Show Dropped Gun', true},
			{'vh3ShowAmmoBoxes', 'Show Ammo Boxes', true},
			{'vh3ShowFood', 'Show Consumable', true},
		};
	},
	[3809673475] = {
		CustomPlayerTag = function(Player)
			local Character = Player.Character;
			local Status = {};
			local cTool = Character:FindFirstChildWhichIsA("Tool")
			if (cTool ~= nil) and (Options.epShowWeapon.Value) then
				table.insert(Status, cTool.Name)
			end
			if (Character:FindFirstChild("CanBeKilled")) and (Options.epShowHostile.Value) then
				table.insert(Status, "Hostile")
			end
			return (#Status > 0) and ("\n[".. table.concat(Status, " | ") .."]") or ""
		end,
		MoreOptions = {
			{'epShowWeapon', 'Show Held Weapon', true},
			{'epShowHostile', 'Show Hostile', true},
		};
	},
	[2408700413] = {
		CustomESP = function()
			for _, v in pairs(Workspaced) do
				if (v.Name == "Present") then
					local part = Options.kpShowPresent.Value and v:FindFirstChild("BasePart") or nil;
					RenderList:AddOrUpdateInstance(v, part, "Present", Color3.new(1, 0, 0));
				elseif (v.Name == "Pinata") then
					local part = Options.kpShowLlama.Value and v:FindFirstChild("Pinata") or nil;
					RenderList:AddOrUpdateInstance(v, part, "Pinata", Color3.new(0.756862, 0.392156, 1));
				end
			end
		end,
		CustomPlayerTag = function(Player)
			local Character = Player.Character;
			local Status = {};
			if (Character:FindFirstChild("VisualHead")) then
				table.insert(Status, "Kaiju")
			else
				table.insert(Status, "Human")
			end
			return (#Status > 0) and ("\n[".. table.concat(Status, " | ") .."]") or ""
		end,
		Initialize = function()
			load(workspace, Workspaced, function(v)
				if (table.find({"Present", "Pinata"}, v.Name)) then
					return true;
				end
			end)
		end;
		MoreOptions = {
			{'kpShowPresent', 'Show Present', true},
			{'kpShowLlama', 'Show Llama', true},
		};
	},
};

local Module = Modules[game.PlaceId] or Modules[game.GameId]
if Module ~= nil then
	if Module.Initialize then
		Module.Initialize()
	end
	if (Module.MoreOptions) then
		for _, v in pairs(Module.MoreOptions) do
			Options(table.unpack(v));
		end
	end
	CustomPlayerTag = Module.CustomPlayerTag or nil
	CustomESP = Module.CustomESP or nil
	CustomCharacter = Module.CustomCharacter or nil
	GetHealth = Module.GetHealth or nil
	GetAliveState = Module.GetAliveState or nil
	CustomRootPartName = Module.CustomRootPartName or nil
end

function Load()
	local _, Result = pcall(readfile, OptionsFile);
	
	if _ then -- extremely ugly code yea i know but i dont care p.s. i hate pcall
		local _, Table = pcall(HttpService.JSONDecode, HttpService, Result);
		if _ and typeof(Table) == 'table' then
			for i, v in pairs(Table) do
				if typeof(Options[i]) == 'table' and Options[i].Value ~= nil and (typeof(Options[i].Value) == 'boolean' or typeof(Options[i].Value) == 'number') then
					Options[i].Value = v.Value;
					pcall(Options[i], v.Value);
				end
			end

			if Table.TeamColor then TeamColor = Color3.new(Table.TeamColor.R, Table.TeamColor.G, Table.TeamColor.B) end
			if Table.EnemyColor then EnemyColor = Color3.new(Table.EnemyColor.R, Table.EnemyColor.G, Table.EnemyColor.B) end

			if typeof(Table.MenuKey) == 'string' then Options.MenuKey(Enum.KeyCode[Table.MenuKey], true) end
			if typeof(Table.ToggleKey) == 'string' then Options.ToggleKey(Enum.KeyCode[Table.ToggleKey], true) end
		end
	end
end

Options('Enabled', 'ESP Enabled', true);
Options('ShowTeam', 'Show Team', true);
Options('ShowTeamColor', 'Show Team Color', false);
Options('ShowName', 'Show Names', true);
Options('ShowDistance', 'Show Distance', true);
Options('ShowHealth', 'Show Health', true);
Options('ShowBoxes', 'Show Boxes', true);
Options('ShowTracers', 'Show Tracers', true);
Options('ShowDot', 'Show Head Dot', false);
Options('VisCheck', 'Visibility Check', false);
Options('Crosshair', 'Crosshair', false);
Options('TextOutline', 'Text Outline', true);
-- Options('Rainbow', 'Rainbow Mode', false);
Options('TextSize', 'Text Size', syn and 18 or 14, 10, 24); -- cuz synapse fonts look weird???
Options('MaxDistance', 'Max Distance', 2500, 100, 25000);
Options('RefreshRate', 'Refresh Rate (ms)', 5, 1, 200);
Options('YOffset', 'Y Offset', 0, -200, 200);
Options('MenuKey', 'Menu Key', Enum.KeyCode.F4, 1);
Options('ToggleKey', 'Toggle Key', Enum.KeyCode.F3, 1);
Options('ChangeColors', SENTINEL_LOADED and 'Sentinel Unsupported' or 'Change Colors', function()
	if SENTINEL_LOADED then return end

	SubMenu:Show(GetMouseLocation(), 'Unnamed Colors', {
		{
			Type = 'Color'; Text = 'Team Color'; Color = TeamColor;

			Function = function(Circ, Position)
				if tick() - ColorPicker.LastGenerated < 1 then return; end

				if shared.CurrentColorPicker then shared.CurrentColorPicker:Dispose() end
				local ColorPicker = ColorPicker.new(Position - V2New(-10, 50));
				CurrentColorPicker = ColorPicker;
				shared.CurrentColorPicker = CurrentColorPicker;
				ColorPicker.ColorChanged:Connect(function(Color) Circ.Color = Color TeamColor = Color Options.TeamColor = Color end);
			end
		};
		{
			Type = 'Color'; Text = 'Enemy Color'; Color = EnemyColor;

			Function = function(Circ, Position)
				if tick() - ColorPicker.LastGenerated < 1 then return; end

				if shared.CurrentColorPicker then shared.CurrentColorPicker:Dispose() end
				local ColorPicker = ColorPicker.new(Position - V2New(-10, 50));
				CurrentColorPicker = ColorPicker;
				shared.CurrentColorPicker = CurrentColorPicker;
				ColorPicker.ColorChanged:Connect(function(Color) Circ.Color = Color EnemyColor = Color Options.EnemyColor = Color end);
			end
		};
		{
			Type = 'Button'; Text = 'Reset Colors';

			Function = function()
				EnemyColor = Color3.new(1, 0, 0);
				TeamColor = Color3.new(0, 1, 0);

				local C1 = Menu:GetInstance'Sub-ColorPreview.1'; if C1 then C1.Color = TeamColor end
				local C2 = Menu:GetInstance'Sub-ColorPreview.2'; if C2 then C2.Color = EnemyColor end
			end
		};
		{
			Type = 'Button'; Text = 'Rainbow Mode';

			Function = function()
				Rainbow = not Rainbow;
			end
		};
	});
end, 2);
Options('ResetSettings', 'Reset Settings', function()
	for i, v in pairs(Options) do
		if Options[i] ~= nil and Options[i].Value ~= nil and Options[i].Text ~= nil and (typeof(Options[i].Value) == 'boolean' or typeof(Options[i].Value) == 'number' or typeof(Options[i].Value) == 'EnumItem') then
			Options[i](Options[i].DefaultValue, true);
		end
	end
end, 5);
Options('LoadSettings', 'Load Settings', Load, 4);
Options('SaveSettings', 'Save Settings', function()
	local COptions = {};

	for i, v in pairs(Options) do
		COptions[i] = v;
	end
	
	if typeof(TeamColor) == 'Color3' then COptions.TeamColor = { R = TeamColor.R; G = TeamColor.G; B = TeamColor.B } end
	if typeof(EnemyColor) == 'Color3' then COptions.EnemyColor = { R = EnemyColor.R; G = EnemyColor.G; B = EnemyColor.B } end
	
	if typeof(COptions.MenuKey.Value) == 'EnumItem' then COptions.MenuKey = COptions.MenuKey.Value.Name end
	if typeof(COptions.ToggleKey.Value) == 'EnumItem' then COptions.ToggleKey = COptions.ToggleKey.Value.Name end

	writefile(OptionsFile, HttpService:JSONEncode(COptions));
end, 3);

Load(1);

Options('MenuOpen', nil, true);

local function Combine(...)
	local Output = {};
	for i, v in pairs{...} do
		if typeof(v) == 'table' then
			table.foreach(v, function(i, v)
				Output[i] = v;
			end)
		end
	end
	return Output
end

function LineBox:Create(Properties)
	local Box = { Visible = true }; -- prevent errors not really though dont worry bout the Visible = true thing

	local Properties = Combine({
		Transparency	= 1;
		Thickness		= 3;
		Visible			= true;
	}, Properties);

	if shared.am_ic3 then -- sory just my preference, dynamic boxes will be optional in unnamed esp v2
		Box['OutlineSquare']= NewDrawing'Square'(Properties);
		Box['Square'] 		= NewDrawing'Square'(Properties);
	elseif QUAD_SUPPORTED_EXPLOIT then
		Box['Quad']			= NewDrawing'Quad'(Properties);
	else
		Box['TopLeft']		= NewDrawing'Line'(Properties);
		Box['TopRight']		= NewDrawing'Line'(Properties);
		Box['BottomLeft']	= NewDrawing'Line'(Properties);
		Box['BottomRight']	= NewDrawing'Line'(Properties);
	end

	function Box:Update(CF, Size, Color, Properties, Parts)
		if not CF or not Size then return end

		if shared.am_ic3 and typeof(Parts) == 'table' then
			local AllCorners = {};
			
			for i, v in pairs(Parts) do
				-- if not v:IsA'BasePart' then continue end
				
				local CF, Size = v.CFrame, v.Size;
				-- CF, Size = v.Parent:GetBoundingBox();

				local Corners = {
					Vector3.new(CF.X + Size.X / 2, CF.Y + Size.Y / 2, CF.Z + Size.Z / 2);
					Vector3.new(CF.X - Size.X / 2, CF.Y + Size.Y / 2, CF.Z + Size.Z / 2);
					Vector3.new(CF.X - Size.X / 2, CF.Y - Size.Y / 2, CF.Z - Size.Z / 2);
					Vector3.new(CF.X + Size.X / 2, CF.Y - Size.Y / 2, CF.Z - Size.Z / 2);
					Vector3.new(CF.X - Size.X / 2, CF.Y + Size.Y / 2, CF.Z - Size.Z / 2);
					Vector3.new(CF.X + Size.X / 2, CF.Y + Size.Y / 2, CF.Z - Size.Z / 2);
					Vector3.new(CF.X - Size.X / 2, CF.Y - Size.Y / 2, CF.Z + Size.Z / 2);
					Vector3.new(CF.X + Size.X / 2, CF.Y - Size.Y / 2, CF.Z + Size.Z / 2);
				};

				for i, v in pairs(Corners) do
					table.insert(AllCorners, v);
				end

				-- break
			end

			local xMin, yMin = Camera.ViewportSize.X, Camera.ViewportSize.Y;
			local xMax, yMax = 0, 0;
			local Vs = true;

			for i, v in pairs(AllCorners) do				
				local Position, V = WorldToViewport(v);

				if VS and not V then Vs = false break end

				if Position.X > xMax then
					xMax = Position.X;
				end
				if Position.X < xMin then
					xMin = Position.X;
				end
				if Position.Y > yMax then
					yMax = Position.Y;
				end
				if Position.Y < yMin then
					yMin = Position.Y;
				end
			end

			local xSize, ySize = xMax - xMin, yMax - yMin;

			local Outline = Box['OutlineSquare'];
			local Square = Box['Square'];
			Outline.Visible = Vs;
			Square.Visible = Vs;
			Square.Position = V2New(xMin, yMin);
			Square.Color	= Color;
			Square.Thickness = math.floor(Outline.Thickness * 0.3);
			-- Square.Position = V2New(xMin, yMin);
			Square.Size = V2New(xSize, ySize);
			Outline.Position = Square.Position;
			Outline.Size = Square.Size;
			Outline.Color = Color3.new(0.12, 0.12, 0.12);
			Outline.Transparency = 0.75;

			return
		end
		
		local TLPos, Visible1	= WorldToViewport((CF * CFrame.new( Size.X,  Size.Y, 0)).Position);
		local TRPos, Visible2	= WorldToViewport((CF * CFrame.new(-Size.X,  Size.Y, 0)).Position);
		local BLPos, Visible3	= WorldToViewport((CF * CFrame.new( Size.X, -Size.Y, 0)).Position);
		local BRPos, Visible4	= WorldToViewport((CF * CFrame.new(-Size.X, -Size.Y, 0)).Position);

		local Quad = Box['Quad'];

		if QUAD_SUPPORTED_EXPLOIT then
			if Visible1 and Visible2 and Visible3 and Visible4 then
				Quad.Visible = true;
				Quad.Color	= Color;
				Quad.PointA = V2New(TLPos.X, TLPos.Y);
				Quad.PointB = V2New(TRPos.X, TRPos.Y);
				Quad.PointC = V2New(BRPos.X, BRPos.Y);
				Quad.PointD = V2New(BLPos.X, BLPos.Y);
			else
				Box['Quad'].Visible = false;
			end
		else
			Visible1 = TLPos.Z > 0 -- (commented | reason: random flashes);
			Visible2 = TRPos.Z > 0 -- (commented | reason: random flashes);
			Visible3 = BLPos.Z > 0 -- (commented | reason: random flashes);
			Visible4 = BRPos.Z > 0 -- (commented | reason: random flashes);

			-- ## BEGIN UGLY CODE
			if Visible1 then
				Box['TopLeft'].Visible		= true;
				Box['TopLeft'].Color		= Color;
				Box['TopLeft'].From			= V2New(TLPos.X, TLPos.Y);
				Box['TopLeft'].To			= V2New(TRPos.X, TRPos.Y);
			else
				Box['TopLeft'].Visible		= false;
			end
			if Visible2 then
				Box['TopRight'].Visible		= true;
				Box['TopRight'].Color		= Color;
				Box['TopRight'].From		= V2New(TRPos.X, TRPos.Y);
				Box['TopRight'].To			= V2New(BRPos.X, BRPos.Y);
			else
				Box['TopRight'].Visible		= false;
			end
			if Visible3 then
				Box['BottomLeft'].Visible	= true;
				Box['BottomLeft'].Color		= Color;
				Box['BottomLeft'].From		= V2New(BLPos.X, BLPos.Y);
				Box['BottomLeft'].To		= V2New(TLPos.X, TLPos.Y);
			else
				Box['BottomLeft'].Visible	= false;
			end
			if Visible4 then
				Box['BottomRight'].Visible	= true;
				Box['BottomRight'].Color	= Color;
				Box['BottomRight'].From		= V2New(BRPos.X, BRPos.Y);
				Box['BottomRight'].To		= V2New(BLPos.X, BLPos.Y);
			else
				Box['BottomRight'].Visible	= false;
			end
			if Properties and typeof(Properties) == 'table' then
				GetTableData(Properties)(function(i, v)
					pcall(Set, Box['TopLeft'],		i, v);
					pcall(Set, Box['TopRight'],		i, v);
					pcall(Set, Box['BottomLeft'],	i, v);
					pcall(Set, Box['BottomRight'],	i, v);
				end)
			end
			-- ## END UGLY CODE
		end
	end
	function Box:SetVisible(bool)
		if shared.am_ic3 then
			Box['Square'].Visible = bool;
			Box['OutlineSquare'].Visible = bool;
		elseif self.Quad then
			self.Quad.Visible = false
		elseif self.TopLeft and self.TopRight and self.BottomLeft and self.BottomRight then
			self.TopLeft.Visible = bool
			self.TopRight.Visible = bool
			self.BottomLeft.Visible = bool
			self.BottomRight.Visible = bool
		end
	end
	function Box:Remove()
		self:SetVisible(false)

		if shared.am_ic3 then
			Box['Square']:Remove()
			Box['OutlineSquare']:Remove()
		elseif self.Quad then
			Box['Quad']:Remove()
		elseif self.TopLeft and self.TopRight and self.BottomLeft and self.BottomRight then
			self.TopLeft:Remove()
			self.TopRight:Remove()
			self.BottomLeft:Remove()
			self.BottomRight:Remove()
		end
	end

	return Box;
end

local Colors = {
	White = Color3.fromHex'ffffff',
	Primary = {
		Main	= Color3.fromHex'424242',
		Light	= Color3.fromHex'6d6d6d',
		Dark	= Color3.fromHex'1b1b1b'
	},
	Secondary = {
		Main	= Color3.fromHex'e0e0e0',
		Light	= Color3.fromHex'ffffff',
		Dark	= Color3.fromHex'aeaeae'
	}
}

function Connections:Listen(Connection, Function)
    local NewConnection = Connection:Connect(Function);
    table.insert(self.Active, NewConnection);
    return NewConnection;
end

function Connections:DisconnectAll()
    for Index, Connection in pairs(self.Active) do
        if Connection.Connected then
            Connection:Disconnect();
        end
    end
    
    self.Active = {};
end

function Signal.new()
	local self = setmetatable({ _BindableEvent = Instance.new'BindableEvent' }, Signal);
    
	return self;
end

function Signal:Connect(Callback)
    assert(typeof(Callback) == 'function', 'function expected; got ' .. typeof(Callback));

	return self._BindableEvent.Event:Connect(function(...) Callback(...) end);
end

function Signal:Fire(...)
    self._BindableEvent:Fire(...);
end

function Signal:Wait()
    local Arguments = self._BindableEvent:Wait();

    return Arguments;
end

function Signal:Disconnect()
    if self._BindableEvent then
        self._BindableEvent:Destroy();
    end
end

local function GetMouseLocation()
	return UserInputService:GetMouseLocation();
end

local function IsMouseOverDrawing(Drawing, MousePosition)
	local TopLeft = Drawing.Position;
	local BottomRight = Drawing.Position + Drawing.Size;
    local MousePosition = MousePosition or GetMouseLocation();
    
    return MousePosition.X > TopLeft.X and MousePosition.Y > TopLeft.Y and MousePosition.X < BottomRight.X and MousePosition.Y < BottomRight.Y;
end

local ImageCache = {};

local function SetImage(Drawing, Url)
	local Data = IsSynapse and game:HttpGet(Url) or Url;

	Drawing[IsSynapse and 'Data' or 'Uri'] = ImageCache[Url] or Data;
	ImageCache[Url] = Data;
    
	if not IsSynapse then repeat wait() until Drawing.Loaded; end
end

-- oh god unnamed esp needs an entire rewrite, someone make a better one pls im too lazy
-- btw the color picker was made seperately so it doesnt fit with the code of unnamed esp

local function CreateDrawingsTable()
    local Drawings = { __Objects = {} };
    local Metatable = {};

    function Metatable.__index(self, Index)
        local Object = rawget(self.__Objects, Index);
        
        if not Object or (IsSynapse and not Object.__SELF.__OBJECT_EXISTS) then
            local Type = Index:sub(1, Index:find'-' - 1);

            Success, Object = pcall(Drawing.new, Type);

            if not Object or not Success then return function() end; end

            self.__Objects[Index] = setmetatable({ __SELF = Object; Type = Type }, {
                __call = function(self, Properties)
                    local Object = rawget(self, '__SELF'); if IsSynapse and not Object.__OBJECT_EXISTS then return false, 'render object destroyed'; end

                    if Properties == false then
                        Object.Visible = false;
                        Object.Transparency = 0;
                        Object:Remove();
                        
                        return true;
                    end
                    
                    if typeof(Properties) == 'table' then
                        for Property, Value in pairs(Properties) do
                            local CanSet = true;

                            if self.Type == 'Image' and not IsSynapse and Property == 'Size' and typeof(Value) == 'Vector2' then
                                CanSet = false;

                                spawn(function()
                                    repeat wait() until Object.Loaded;
                                    if not self.DefaultSize then rawset(self, 'DefaultSize', Object.Size) end

                                    Property = 'ScaleFactor';
                                    Value = Value.X / self.DefaultSize.X;

                                    Object[Property] = Value
                                end)
                            end
                            
                            if CanSet then Object[Property] = Value end
                        end
                    end

                    return Object;
                end
            });

            Object.Visible = true;
            Object.Transparency = 1; -- Transparency is really Opacity with drawing api (1 being visible, 0 being invisible)
            
            if Type == 'Text' then
                if Drawing.Fonts then Object.Font = Drawing.Fonts.Monospace end
                Object.Size = 20;
                Object.Color = Color3.new(1, 1, 1);
                Object.Center = true;
				Object.Outline = true;
				OutlineOpacity = 0.5;
            elseif Type == 'Square' or Type == 'Rectangle' then
                Object.Thickness = 2;
                Object.Filled = false;
            end

            return self.__Objects[Index];
        end

        return Object;
    end

    function Metatable.__call(self, Delete, ...)
        local Arguments = {Delete, ...};
        
        if Delete == false then
            for Index, Drawing in pairs(rawget(self, '__Objects')) do
                Drawing(false);
            end
        end
    end

    return setmetatable(Drawings, Metatable);
end

local Images = {}

spawn(function()
	Images.Ring = 'https://i.imgur.com/q4qx26f.png'
	Images.Overlay = 'https://i.imgur.com/gOCxbsR.png'
end)

function ColorPicker.new(Position, Size, Color)
	ColorPicker.LastGenerated = tick();
	ColorPicker.Loading = true;

    local self = { Color = Color or Color3.new(1, 1, 1); HSV = { H = 0, S = 1, V = 1 } };
    local Drawings = CreateDrawingsTable();
    local Position = Position or V2New();
    local Size = Size or 150;
    local Padding = { 10, 10, 10, 10 };
    
    self.ColorChanged = Signal.new();

    local Background = Drawings['Square-Background'] {
        Color = Color3.fromRGB(33, 33, 33);
		Filled = false;
		Visible = false;
        Position = Position - V2New(Padding[4], Padding[1]);
        Size = V2New(Size, Size) + V2New(Padding[4] + Padding[2], Padding[1] + Padding[3]);
    };
    local ColorPreview = Drawings['Circle-Preview'] {
        Position = Position + (V2New(Size, Size) / 2);
        Radius = Size / 2 - 8;
        Filled = true;
        Thickness = 0;
        NumSides = 20;
        Color = Color3.new(1, 0, 0);
    };
    local Main = Drawings['Image-Main'] {
        Position = Position;
        Size = V2New(Size, Size);
    }; SetImage(Main, Images.Ring);
    local Preview = Drawings['Square-Preview'] {
        Position = Main.Position + (Main.Size / 4.5);
        Size = Main.Size / 1.75;
        Color = Color3.new(1, 0, 0);
        Filled = true;
        Thickness = 0;
    };
    local Overlay = Drawings['Image-Overlay'] {
        Position = Preview.Position;
        Size = Preview.Size;
        Transparency = 1;
    }; SetImage(Overlay, Images.Overlay);
    local CursorOutline = Drawings['Circle-CursorOutline'] {
        Radius = 4;
        Thickness = 2;
        Filled = false;
        Color = Color3.new(0.2, 0.2, 0.2);
        Position = V2New(Main.Position.X + Main.Size.X - 10, Main.Position.Y + (Main.Size.Y / 2));
    };
    local Cursor = Drawings['Circle-Cursor'] {
        Radius = 3;
        Transparency = 1;
        Filled = true;
        Color = Color3.new(1, 1, 1);
        Position = CursorOutline.Position;
    };
    local CursorOutline = Drawings['Circle-CursorOutlineSquare'] {
        Radius = 4;
        Thickness = 2;
        Filled = false;
        Color = Color3.new(0.2, 0.2, 0.2);
        Position = V2New(Preview.Position.X + Preview.Size.X - 2, Preview.Position.Y + 2);
    };
    Drawings['Circle-CursorSquare'] {
        Radius = 3;
        Transparency = 1;
        Filled = true;
        Color = Color3.new(1, 1, 1);
        Position = CursorOutline.Position;
    };
    
    function self:UpdatePosition(Input)
        local MousePosition = V2New(Input.Position.X, Input.Position.Y + 33);

        if self.MouseHeld then
            if self.Item == 'Ring' then
                local Main = self.Drawings['Image-Main'] ();
                local Preview = self.Drawings['Square-Preview'] ();
                local Bounds = Main.Size / 2;
                local Center = Main.Position + Bounds;
                local Relative = MousePosition - Center;
                local Direction = Relative.unit;
                local Position = Center + Direction * Main.Size.X / 2.15;
                local H = (math.atan2(Position.Y - Center.Y, Position.X - Center.X)) * 60;
                if H < 0 then H = 360 + H; end
                H = H / 360;
                self.HSV.H = H;
                local EndColor = Color3.fromHSV(H, self.HSV.S, self.HSV.V); if EndColor ~= self.Color then self.ColorChanged:Fire(self.Color); end
                local Pointer = self.Drawings['Circle-Cursor'] { Position = Position };
                self.Drawings['Circle-CursorOutline'] { Position = Pointer.Position };
                Bounds = Bounds * 2;
                Preview.Color = Color3.fromHSV(H, 1, 1);
                self.Color = EndColor;
                self.Drawings['Circle-Preview'] { Color = EndColor };
            elseif self.Item == 'HL' then
                local Preview = self.Drawings['Square-Preview'] ();
                local HSV = self.HSV;
                local Position = V2New(math.clamp(MousePosition.X, Preview.Position.X, Preview.Position.X + Preview.Size.X), math.clamp(MousePosition.Y, Preview.Position.Y, Preview.Position.Y + Preview.Size.Y));
                HSV.S = (Position.X - Preview.Position.X) / Preview.Size.X;
                HSV.V = 1 - (Position.Y - Preview.Position.Y) / Preview.Size.Y;
                local EndColor = Color3.fromHSV(HSV.H, HSV.S, HSV.V); if EndColor ~= self.Color then self.ColorChanged:Fire(self.Color); end
                self.Color = EndColor;
                self.Drawings['Circle-Preview'] { Color = EndColor };
                local Pointer = self.Drawings['Circle-CursorSquare'] { Position = Position };
                self.Drawings['Circle-CursorOutlineSquare'] { Position = Pointer.Position };
            end
        end
    end

    function self:HandleInput(Input, P, Type)
        if Type == 'Began' then
            if Input.UserInputType.Name == 'MouseButton1' then
                local Main = self.Drawings['Image-Main'] ();
                local SquareSV = self.Drawings['Square-Preview'] ();
                local MousePosition = V2New(Input.Position.X, Input.Position.Y + 33);
                self.MouseHeld = true;
                local Bounds = Main.Size / 2;
                local Center = Main.Position + Bounds;
                local R = (MousePosition - Center);
        
                if R.Magnitude < Bounds.X and R.Magnitude > Bounds.X - 20 then
                    self.Item = 'Ring';
                end
                
                if MousePosition.X > SquareSV.Position.X and MousePosition.Y > SquareSV.Position.Y and MousePosition.X < SquareSV.Position.X + SquareSV.Size.X and MousePosition.Y < SquareSV.Position.Y + SquareSV.Size.Y then
                    self.Item = 'HL';
                end

                self:UpdatePosition(Input, P);
            end
        elseif Type == 'Changed' then
            if Input.UserInputType.Name == 'MouseMovement' then
                self:UpdatePosition(Input, P);
            end
        elseif Type == 'Ended' and Input.UserInputType.Name == 'MouseButton1' then
            self.Item = nil;
        end
	end
	
	function self:Dispose()
		self.Drawings(false);
		self.UpdatePosition = nil;
		self.HandleInput = nil;
		Connections:DisconnectAll(); -- scuffed tbh
	end

	Connections:Listen(UserInputService.InputBegan, function(Input, Process)
		self:HandleInput(Input, Process, 'Began');
	end);
	Connections:Listen(UserInputService.InputChanged, function(Input, Process)
		if Input.UserInputType.Name == 'MouseMovement' then
			local MousePosition = V2New(Input.Position.X, Input.Position.Y + 33);
			local Cursor = self.Drawings['Triangle-Cursor'] {
				Filled = true;
				Color = Color3.new(0.9, 0.9, 0.9);
				PointA = MousePosition + V2New(0, 0);
				PointB = MousePosition + V2New(12, 14);
				PointC = MousePosition + V2New(0, 18);
				Thickness = 0;
			};
		end
		self:HandleInput(Input, Process, 'Changed');
	end);
	Connections:Listen(UserInputService.InputEnded, function(Input, Process)
		self:HandleInput(Input, Process, 'Ended');
		
		if Input.UserInputType.Name == 'MouseButton1' then
			self.MouseHeld = false
		end
	end)

	ColorPicker.Loading = false

    self.Drawings = Drawings

    return self
end

function SubMenu:Show(Position, Title, Options)
	self.Open = true;

	local Visible = true;
	local BasePosition = Position;
	local BaseSize = V2New(200, 140);
	local End = BasePosition + BaseSize;

	self.Bounds = { BasePosition.X, BasePosition.Y, End.X, End.Y };

	delay(0.025, function()
		if not self.Open then return; end

		Menu:AddMenuInstance('Sub-Main', 'Square', {
			Size		= BaseSize;
			Position	= BasePosition;
			Filled		= false;
			Color		= Colors.Primary.Main;
			Thickness	= 3;
			Visible		= Visible;
		});
	end);
	Menu:AddMenuInstance('Sub-TopBar', 'Square', {
		Position	= BasePosition;
		Size		= V2New(BaseSize.X, 10);
		Color		= Colors.Primary.Dark;
		Filled		= true;
		Visible		= Visible;
	});
	Menu:AddMenuInstance('Sub-TopBarTwo', 'Square', {
		Position 	= BasePosition + V2New(0, 10);
		Size		= V2New(BaseSize.X, 20);
		Color		= Colors.Primary.Main;
		Filled		= true;
		Visible		= Visible;
	});
	Menu:AddMenuInstance('Sub-TopBarText', 'Text', {
		Size 		= 20;
		Position	= shared.MenuDrawingData.Instances['Sub-TopBarTwo'].Position + V2New(15, -3);
		Text		= Title or '';
		Color		= Colors.Secondary.Light;
		Visible		= Visible;
	});
	Menu:AddMenuInstance('Sub-Filling', 'Square', {
		Size		= BaseSize - V2New(0, 30);
		Position	= BasePosition + V2New(0, 30);
		Filled		= true;
		Color		= Colors.Secondary.Main;
		Transparency= .75;
		Visible		= Visible;
	});

	if Options then
		for Index, Option in pairs(Options) do -- currently only supports color and button(but color is a button so), planning on fully rewriting or something
			local function GetName(Name) return ('Sub-%s.%d'):format(Name, Index) end
			local Position = shared.MenuDrawingData.Instances['Sub-Filling'].Position + V2New(20, Index * 25 - 10);
			-- local BasePosition	= shared.MenuDrawingData.Instances.Filling.Position + V2New(30, v.Index * 25 - 10);

			if Option.Type == 'Color' then
				local ColorPreview = Menu:AddMenuInstance(GetName'ColorPreview', 'Circle', {
					Position = Position;
					Color = Option.Color;
					Radius = IsSynapse and 10 or 10;
					NumSides = 10;
					Filled = true;
					Visible = true;
				});
				local Text = Menu:AddMenuInstance(GetName'Text', 'Text', {
					Text = Option.Text;
					Position = ColorPreview.Position + V2New(15, -8);
					Size = 16;
					Color = Colors.Primary.Dark;
					Visible = true;
				});
				UIButtons[#UIButtons + 1] = {
					FromSubMenu = true;
					Option = function() return Option.Function(ColorPreview, BasePosition + V2New(BaseSize.X, 0)) end;
					Instance = Menu:AddMenuInstance(Format('%s_Hitbox', GetName'Button'), 'Square', {
						Position	= Position - V2New(20, 12);
						Size		= V2New(BaseSize.X, 25);
						Visible		= false;
					});
				};
			elseif Option.Type == 'Button' then
				UIButtons[#UIButtons + 1] = {
					FromSubMenu = true;
					Option = Option.Function;
					Instance = Menu:AddMenuInstance(Format('%s_Hitbox', GetName'Button'), 'Square', {
						Size		= V2New(BaseSize.X, 20) - V2New(20, 0);
						Visible		= true;
						Transparency= .5;
						Position	= Position - V2New(10, 10);
						Color		= Colors.Secondary.Light;
						Filled		= true;
					});
				};
				local Text		= Menu:AddMenuInstance(Format('%s_Text', GetName'Text'), 'Text', {
					Text		= Option.Text;
					Size		= 18;
					Position	= Position + V2New(5, -10);
					Visible		= true;
					Color		= Colors.Primary.Dark;
				});
			end
		end
	end
end

function SubMenu:Hide()
	self.Open = false;

	for i, v in pairs(shared.MenuDrawingData.Instances) do
		if i:sub(1, 3) == 'Sub' then
			v.Visible = false;

			if i:sub(4, 4) == ':' then -- ';' = Temporary so remove
				v:Remove();
				shared.MenuDrawingData.Instance[i] = nil;
			end
		end
	end

	for i, Button in pairs(UIButtons) do
		if Button.FromSubMenu then
			UIButtons[i] = nil;
		end
	end

	spawn(function() -- stupid bug happens if i dont use this
		for i = 1, 10 do
			if shared.CurrentColorPicker then -- dont know why 'CurrentColorPicker' isnt a variable in this
				shared.CurrentColorPicker:Dispose();
			end
			wait(0.1);
		end
	end)

	CurrentColorPicker = nil;
end

function CreateMenu(NewPosition) -- Create Menu
	MenuLoaded = false;
	UIButtons  = {};
	Sliders	   = {};

	local BaseSize = V2New(300, 625);
	if (Module ~= nil) and (Module.MoreOptions) then
		for i = 1, #Module.MoreOptions do
			BaseSize = V2New(300, BaseSize.Y + 25)
		end
	end
	local BasePosition = NewPosition or V2New(Camera.ViewportSize.X / 8 - (BaseSize.X / 2), Camera.ViewportSize.Y / 2 - (BaseSize.Y / 2));

	BasePosition = V2New(math.clamp(BasePosition.X, 0, Camera.ViewportSize.X), math.clamp(BasePosition.Y, 0, Camera.ViewportSize.Y));

	Menu:AddMenuInstance('CrosshairX', 'Line', {
		Visible			= false;
		Color			= Color3.new(0, 1, 0);
		Transparency	= 1;
		Thickness		= 1;
	});
	Menu:AddMenuInstance('CrosshairY', 'Line', {
		Visible			= false;
		Color			= Color3.new(0, 1, 0);
		Transparency	= 1;
		Thickness		= 1;
	});

	delay(.025, function() -- since zindex doesnt exist
		Menu:AddMenuInstance('Main', 'Square', {
			Size		= BaseSize;
			Position	= BasePosition;
			Filled		= false;
			Color		= Colors.Primary.Main;
			Thickness	= 3;
			Visible		= true;
		});
	end);
	Menu:AddMenuInstance('TopBar', 'Square', {
		Position	= BasePosition;
		Size		= V2New(BaseSize.X, 15);
		Color		= Colors.Primary.Dark;
		Filled		= true;
		Visible		= true;
	});
	Menu:AddMenuInstance('TopBarTwo', 'Square', {
		Position 	= BasePosition + V2New(0, 15);
		Size		= V2New(BaseSize.X, 45);
		Color		= Colors.Primary.Main;
		Filled		= true;
		Visible		= true;
	});
	Menu:AddMenuInstance('TopBarText', 'Text', {
		Size 		= 25;
		Position	= shared.MenuDrawingData.Instances.TopBarTwo.Position + V2New(25, 10);
		Text		= "tk's Unnamed ESP";
		Color		= Colors.Secondary.Light;
		Visible		= true;
		Transparency= 1; -- proto outline fix
		Outline 	= true;
		OutlineOpacity = 0.5;
	});
	Menu:AddMenuInstance('TopBarTextBR', 'Text', {
		Size 		= 18;
		Position	= shared.MenuDrawingData.Instances.TopBarTwo.Position + V2New(BaseSize.X - 95, 25);
		Text		= 'by ic3w0lf & tk';
		Color		= Colors.Secondary.Light;
		Visible		= true;
		Transparency= 1;
		Outline 	= true;
		OutlineOpacity = 0.5;
	});
	Menu:AddMenuInstance('Filling', 'Square', {
		Size		= BaseSize - V2New(0, 60);
		Position	= BasePosition + V2New(0, 60);
		Filled		= true;
		Color		= Colors.Secondary.Main;
		Transparency= .35;
		Visible		= true;
	});

	local CPos = 0;

	GetTableData(Options)(function(i, v)
		if typeof(v.Value) == 'boolean' and not IsStringEmpty(v.Text) and v.Text ~= nil then
			CPos 				= CPos + 25;
			local BaseSize		= V2New(BaseSize.X, 30);
			local BasePosition	= shared.MenuDrawingData.Instances.Filling.Position + V2New(30, v.Index * 25 - 10);
			UIButtons[#UIButtons + 1] = {
				Option = v;
				Instance = Menu:AddMenuInstance(Format('%s_Hitbox', v.Name), 'Square', {
					Position	= BasePosition - V2New(30, 15);
					Size		= BaseSize;
					Visible		= false;
				});
			};
			Menu:AddMenuInstance(Format('%s_OuterCircle', v.Name), 'Circle', {
				Radius		= 10;
				Position	= BasePosition;
				Color		= Colors.Secondary.Light;
				Filled		= true;
				Visible		= true;
			});
			Menu:AddMenuInstance(Format('%s_InnerCircle', v.Name), 'Circle', {
				Radius		= 7;
				Position	= BasePosition;
				Color		= Colors.Secondary.Dark;
				Filled		= true;
				Visible		= v.Value;
			});
			Menu:AddMenuInstance(Format('%s_Text', v.Name), 'Text', {
				Text		= v.Text;
				Size		= 20;
				Position	= BasePosition + V2New(20, -10);
				Visible		= true;
				Color		= Colors.Secondary.Light;
				Transparency= 1;
				Outline		= true;
				OutlineOpacity = 0.5;
			});
		end
	end)
	GetTableData(Options)(function(i, v) -- just to make sure certain things are drawn before or after others, too lazy to actually sort table
		if typeof(v.Value) == 'number' then
			CPos 				= CPos + 25;

			local BaseSize		= V2New(BaseSize.X, 30);
			local BasePosition	= shared.MenuDrawingData.Instances.Filling.Position + V2New(0, CPos - 10);

			local Line			= Menu:AddMenuInstance(Format('%s_SliderLine', v.Name), 'Square', {
				Transparency	= 1;
				Color			= Colors.Secondary.Light;
				-- Thickness		= 3;
				Filled			= true;
				Visible			= true;
				Position 		= BasePosition + V2New(15, -5);
				Size 			= BaseSize - V2New(30, 10);
				Transparency	= 0.5;
			});
			local Slider		= Menu:AddMenuInstance(Format('%s_Slider', v.Name), 'Square', {
				Visible			= true;
				Filled			= true;
				Color			= Colors.Primary.Dark;
				Size			= V2New(5, Line.Size.Y);
				Transparency	= 0.5;
			});
			local Text			= Menu:AddMenuInstance(Format('%s_Text', v.Name), 'Text', {
				Text			= v.Text;
				Size			= 20;
				Center			= true;
				Transparency	= 1;
				Outline			= true;
				OutlineOpacity  = 0.5;
				Visible			= true;
				Color			= Colors.White;
			}); Text.Position	= Line.Position + (Line.Size / 2) - V2New(0, Text.TextBounds.Y / 1.75);
			local AMT			= Menu:AddMenuInstance(Format('%s_AmountText', v.Name), 'Text', {
				Text			= tostring(v.Value);
				Size			= 22;
				Center			= true;
				Transparency	= 1;
				Outline			= true;
				OutlineOpacity  = 0.5;
				Visible			= true;
				Color			= Colors.White;
				Position		= Text.Position;
			});

			local CSlider = {Slider = Slider; Line = Line; Min = v.AllArgs[4]; Max = v.AllArgs[5]; Option = v};
			local Dummy = Instance.new'NumberValue';

			Dummy:GetPropertyChangedSignal'Value':Connect(function()
				Text.Transparency = Dummy.Value;
				-- Text.OutlineTransparency = 1 - Dummy.Value;
				AMT.Transparency = 1 - Dummy.Value;
			end);

			Dummy.Value = 1;

			function CSlider:ShowValue(Bool)
				self.ShowingValue = Bool;

				TweenService:Create(Dummy, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Value = Bool and 0 or 1 }):Play();
			end

			Sliders[#Sliders + 1] = CSlider;

			-- local Percent = (v.Value / CSlider.Max) * 100;
			-- local Size = math.abs(Line.From.X - Line.To.X);
			-- local Value = Size * (Percent / 100); -- this shit's inaccurate but fuck it i'm not even gonna bother fixing it

			Slider.Position = Line.Position + V2New(35, 0);
			
			v.BaseSize = BaseSize;
			v.BasePosition = BasePosition;
			-- AMT.Position = BasePosition + V2New(BaseSize.X - AMT.TextBounds.X - 10, -10)
		end
	end)
	local FirstItem = false;
	GetTableData(Options)(function(i, v) -- just to make sure certain things are drawn before or after others, too lazy to actually sort table
		if typeof(v.Value) == 'EnumItem' then
			CPos 				= CPos + (not FirstItem and 30 or 25);
			FirstItem			= true;

			local BaseSize		= V2New(BaseSize.X, FirstItem and 30 or 25);
			local BasePosition	= shared.MenuDrawingData.Instances.Filling.Position + V2New(0, CPos - 10);

			UIButtons[#UIButtons + 1] = {
				Option = v;
				Instance = Menu:AddMenuInstance(Format('%s_Hitbox', v.Name), 'Square', {
					Size		= V2New(BaseSize.X, 20) - V2New(30, 0);
					Visible		= true;
					Transparency= .5;
					Position	= BasePosition + V2New(15, -10);
					Color		= Colors.Secondary.Light;
					Filled		= true;
				});
			};
			local Text		= Menu:AddMenuInstance(Format('%s_Text', v.Name), 'Text', {
				Text		= v.Text;
				Size		= 20;
				Position	= BasePosition + V2New(20, -10);
				Visible		= true;
				Color		= Colors.Secondary.Light;
				Transparency= 1;
				Outline		= true;
				OutlineOpacity = 0.5;
			});
			local BindText	= Menu:AddMenuInstance(Format('%s_BindText', v.Name), 'Text', {
				Text		= tostring(v.Value):match'%w+%.%w+%.(.+)';
				Size		= 20;
				Position	= BasePosition;
				Visible		= true;
				Color		= Colors.Secondary.Light;
				Transparency= 1;
				Outline		= true;
				OutlineOpacity = 0.5;
			});

			Options[i].BaseSize = BaseSize;
			Options[i].BasePosition = BasePosition;
			BindText.Position = BasePosition + V2New(BaseSize.X - BindText.TextBounds.X - 20, -10);
		end
	end)
	GetTableData(Options)(function(i, v) -- just to make sure certain things are drawn before or after others, too lazy to actually sort table
		if typeof(v.Value) == 'function' then
			local BaseSize		= V2New(BaseSize.X, 30);
			local BasePosition	= shared.MenuDrawingData.Instances.Filling.Position + V2New(0, CPos + (25 * v.AllArgs[4]) - 35);

			UIButtons[#UIButtons + 1] = {
				Option = v;
				Instance = Menu:AddMenuInstance(Format('%s_Hitbox', v.Name), 'Square', {
					Size		= V2New(BaseSize.X, 20) - V2New(30, 0);
					Visible		= true;
					Transparency= .5;
					Position	= BasePosition + V2New(15, -10);
					Color		= Colors.Secondary.Light;
					Filled		= true;
				});
			};
			local Text		= Menu:AddMenuInstance(Format('%s_Text', v.Name), 'Text', {
				Text		= v.Text;
				Size		= 20;
				Position	= BasePosition + V2New(20, -10);
				Visible		= true;
				Color		= Colors.Secondary.Light;
				Transparency= 1;
				Outline		= true;
				OutlineOpacity = 0.5;
			});

			-- BindText.Position = BasePosition + V2New(BaseSize.X - BindText.TextBounds.X - 10, -10);
		end
	end)

	delay(.1, function()
		MenuLoaded = true;
	end);

	-- this has to be at the bottom cuz proto drawing api doesnt have zindex :triumph:	
	Menu:AddMenuInstance('Cursor1', 'Line', {
		Visible			= false;
		Color			= Color3.new(1, 0, 0);
		Transparency	= 1;
		Thickness		= 2;
	});
	Menu:AddMenuInstance('Cursor2', 'Line', {
		Visible			= false;
		Color			= Color3.new(1, 0, 0);
		Transparency	= 1;
		Thickness		= 2;
	});
	Menu:AddMenuInstance('Cursor3', 'Line', {
		Visible			= false;
		Color			= Color3.new(1, 0, 0);
		Transparency	= 1;
		Thickness		= 2;
	});
end

CreateMenu();
delay(0.1, function()
	SubMenu:Show(V2New()); -- Create the submenu
	SubMenu:Hide();
end);

shared.UESP_InputChangedCon = UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType.Name == 'MouseMovement' and Options.MenuOpen.Value then
		for i, v in pairs(Sliders) do
			local Values = {
				v.Line.Position.X;
				v.Line.Position.Y;
				v.Line.Position.X + v.Line.Size.X;
				v.Line.Position.Y + v.Line.Size.Y;
			};
			if MouseHoveringOver(Values) then
				v:ShowValue(true);
			else
				if not MouseHeld then v:ShowValue(false); end
			end
		end
	end
end)
shared.UESP_InputBeganCon = UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType.Name == 'MouseButton1' and Options.MenuOpen.Value then
		MouseHeld = true;
		local Bar = Menu:GetInstance'TopBar';
		local Values = {
			Bar.Position.X;
			Bar.Position.Y;
			Bar.Position.X + Bar.Size.X;
			Bar.Position.Y + Bar.Size.Y;
		}
		if MouseHoveringOver(Values) then
			DraggingUI = true;
			DragOffset = Menu:GetInstance'Main'.Position - GetMouseLocation();
		else
			for i, v in pairs(Sliders) do
				local Values = {
					v.Line.Position.X;
					v.Line.Position.Y;
					v.Line.Position.X + v.Line.Size.X;
					v.Line.Position.Y + v.Line.Size.Y;
					-- v.Line.From.X	- (v.Slider.Radius);
					-- v.Line.From.Y	- (v.Slider.Radius);
					-- v.Line.To.X		+ (v.Slider.Radius);
					-- v.Line.To.Y		+ (v.Slider.Radius);
				};
				if MouseHoveringOver(Values) then
					DraggingWhat = v;
					Dragging = true;
					break
				end
			end

			if not Dragging then
				local Values = {
					TracerPosition.X - 10;
					TracerPosition.Y - 10;
					TracerPosition.X + 10;
					TracerPosition.Y + 10;
				};
				if MouseHoveringOver(Values) then
					DragTracerPosition = true;
				end
			end
		end
	end
end)
shared.UESP_InputEndedCon = UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType.Name == 'MouseButton1' and Options.MenuOpen.Value then
		MouseHeld = false;
		DragTracerPosition = false;
		local IgnoreOtherInput = false;

		if SubMenu.Open and not MouseHoveringOver(SubMenu.Bounds) then
			if CurrentColorPicker and IsMouseOverDrawing(CurrentColorPicker.Drawings['Square-Background']()) then IgnoreOtherInput = true; end
			if not IgnoreOtherInput then SubMenu:Hide() end
		end

		if not IgnoreOtherInput then
			for i, v in pairs(UIButtons) do
				if SubMenu.Open and MouseHoveringOver(SubMenu.Bounds) and not v.FromSubMenu then continue end

				local Values = {
					v.Instance.Position.X;
					v.Instance.Position.Y;
					v.Instance.Position.X + v.Instance.Size.X;
					v.Instance.Position.Y + v.Instance.Size.Y;
				};
				if MouseHoveringOver(Values) then
					v.Option();
					IgnoreOtherInput = true;
					break -- prevent clicking 2 options
				end
			end
			for i, v in pairs(Sliders) do
				if IgnoreOtherInput then break end

				local Values = {
					v.Line.Position.X;
					v.Line.Position.Y;
					v.Line.Position.X + v.Line.Size.X;
					v.Line.Position.Y + v.Line.Size.Y;
				};
				if not MouseHoveringOver(Values) then
					v:ShowValue(false);
				end
			end
		end
	elseif input.UserInputType.Name == 'MouseButton2' and Options.MenuOpen.Value and not DragTracerPosition then
		local Values = {
			TracerPosition.X - 10;
			TracerPosition.Y - 10;
			TracerPosition.X + 10;
			TracerPosition.Y + 10;
		}
		if MouseHoveringOver(Values) then
			DragTracerPosition = false;
			TracerPosition = V2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 135);
		end
	elseif input.UserInputType.Name == 'Keyboard' then
		if Binding then
			BindedKey = input.KeyCode;
			Binding = false;
		elseif input.KeyCode == Options.MenuKey.Value or (input.KeyCode == Enum.KeyCode.Home and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)) then
			Options.MenuOpen();
		elseif input.KeyCode == Options.ToggleKey.Value then
			Options.Enabled();
		elseif input.KeyCode.Name == 'F1' and UserInputService:IsMouseButtonPressed(1) and shared.am_ic3 then -- hehe hiden spectate feature cuz why not
			local HD, LPlayer, LCharacter = 0.95;

			for i, Player in pairs(Players:GetPlayers()) do
				local Character = GetCharacter(Player);

				if Player ~= LocalPlayer and Player ~= Spectating and Character and Character:FindFirstChild'HumanoidRootPart' then
					local Head = Character:FindFirstChild'Head';
					local Humanoid = Character:FindFirstChildOfClass'Humanoid';
					
					if Head then
						local Distance  = (Camera.CFrame.Position - Head.Position).Magnitude;
						
						if Distance > Options.MaxDistance.Value then continue; end

						local Direction = -(Camera.CFrame.Position - Mouse.Hit.Position).unit;
						local Relative  = Character.Head.Position - Camera.CFrame.Position;
						local Unit      = Relative.unit;

						local DP = Direction:Dot(Unit);

						if DP > HD then
							HD = DP;
							LPlayer = Player;
							LCharacter = Character;
						end
					end
				end
			end
			
			if LPlayer and LPlayer ~= Spectating and LCharacter then
				Camera.CameraSubject = LCharacter.Head;
				Spectating = LPlayer;
			else
				if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass'Humanoid' then
					Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass'Humanoid';
					Spectating = nil;
				end
			end
		end
	end
end)

local function CameraCon() -- unnamed esp v1 sucks
	workspace.CurrentCamera:GetPropertyChangedSignal'ViewportSize':Connect(function()
		TracerPosition = V2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 135);
	end);
end

CameraCon();

local function ToggleMenu()
	if Options.MenuOpen.Value then
		GetTableData(shared.MenuDrawingData.Instances)(function(i, v)
			if OldData[v] then
				pcall(Set, v, 'Visible', true);
			end
		end)
	else
		GetTableData(shared.MenuDrawingData.Instances)(function(i, v)
			OldData[v] = v.Visible;
			if v.Visible then
				pcall(Set, v, 'Visible', false);
			end
		end)
	end
end

local LastRayIgnoreUpdate, RayIgnoreList = 0, {}

local function CheckRay(Instance, Distance, Position, Unit)
	local Pass = true;
	local Model = Instance;

	if Distance > 999 then return false; end

	if Instance.ClassName == 'Player' then
		Model = GetCharacter(Instance);
	end

	if not Model then
		Model = Instance.Parent;

		if Model.Parent == workspace then
			Model = Instance;
		end
	end

	if not Model then return false end

	local _Ray = Ray.new(Position, Unit * Distance)

	if tick() - LastRayIgnoreUpdate > 3 then
		LastRayIgnoreUpdate = tick()

		table.clear(RayIgnoreList)

		table.insert(RayIgnoreList, LocalPlayer.Character)
		table.insert(RayIgnoreList, Camera)
		
		if Mouse.TargetFilter then table.insert(RayIgnoreList, Mouse.TargetFilter) end

		if #IgnoreList > 64 then
			while #IgnoreList > 64 do
				table.remove(IgnoreList, 1)
			end
		end

		for i, v in pairs(IgnoreList) do table.insert(RayIgnoreList, v) end
	end

	local Hit = workspace:FindPartOnRayWithIgnoreList(_Ray, RayIgnoreList)

	if Hit and not Hit:IsDescendantOf(Model) then
		Pass = false;
		if Hit.Transparency >= .3 or not Hit.CanCollide and Hit.ClassName ~= Terrain then -- Detect invisible walls
			table.insert(IgnoreList, Hit)
			-- IgnoreList[#IgnoreList + 1] = Hit;
		end
	end

	return Pass;
end

local function CheckTeam(Player)
	if Player.Neutral and LocalPlayer.Neutral then return true; end
	return Player.TeamColor == LocalPlayer.TeamColor;
end

local CustomTeam = CustomTeams[game.PlaceId];

if CustomTeam ~= nil then
	if CustomTeam.Initialize then ypcall(CustomTeam.Initialize) end

	CheckTeam = CustomTeam.CheckTeam;
end

local function CheckPlayer(Player, Character)
	if not Options.Enabled.Value then return false end

	local Pass = true;
	local Distance = 0;

	if Player ~= LocalPlayer and Character then
		if not Options.ShowTeam.Value and CheckTeam(Player) then
			Pass = false;
		end

		local Head = Character:FindFirstChild'Head';

		if Pass and Character and Head then
			Distance = (Camera.CFrame.Position - Head.Position).Magnitude;
			if Options.VisCheck.Value then
				Pass = CheckRay(Player, Distance, Camera.CFrame.Position, (Head.Position - Camera.CFrame.Position).unit);
			end
			if Distance > Options.MaxDistance.Value then
				Pass = false;
			end
		end
	else
		Pass = false;
	end

	return Pass, Distance;
end

local function CheckDistance(Instance)
	if not Options.Enabled.Value then return false end

	local Pass = true;
	local Distance = 0;

	if Instance ~= nil then
		Distance = (Camera.CFrame.Position - Instance.Position).Magnitude;
		if Options.VisCheck.Value then
			Pass = CheckRay(Instance, Distance, Camera.CFrame.Position, (Instance.Position - Camera.CFrame.Position).unit);
		end
		if Distance > Options.MaxDistance.Value then
			Pass = false;
		end
	else
		Pass = false;
	end

	return Pass, Distance;
end

local function UpdatePlayerData()
	if (tick() - LastRefresh) > (Options.RefreshRate.Value / 1000) then
		LastRefresh = tick();
		if CustomESP and Options.Enabled.Value then
			local a, b = pcall(CustomESP);
		end
		for i, v in pairs(RenderList.Instances) do
			if v.Instance ~= nil and v.Instance.Parent ~= nil and v.Instance:IsA'BasePart' then
				local Data = shared.InstanceData[v.Instance:GetDebugId()] or { Instances = {}; DontDelete = true };

				Data.Instance = v.Instance;
				Data.Base = i;

				Data.Instances['OutlineTracer'] = Data.Instances['OutlineTracer'] or NewDrawing'Line'{
					Transparency	= 0.75;
					Thickness		= 5;
					Color 			= Color3.new(0.1, 0.1, 0.1);
				}
				Data.Instances['Tracer'] = Data.Instances['Tracer'] or NewDrawing'Line'{
					Transparency	= 1;
					Thickness		= 2;
				}
				Data.Instances['NameTag'] = Data.Instances['NameTag'] or NewDrawing'Text'{
					Size			= Options.TextSize.Value;
					Center			= true;
					Outline			= Options.TextOutline.Value;
					Visible			= true;
				};
				Data.Instances['DistanceTag'] = Data.Instances['DistanceTag'] or NewDrawing'Text'{
					Size			= Options.TextSize.Value - 1;
					Center			= true;
					Outline			= Options.TextOutline.Value;
					Visible			= true;
				};

				local NameTag		= Data.Instances['NameTag'];
				local DistanceTag	= Data.Instances['DistanceTag'];
				local Tracer		= Data.Instances['Tracer'];
				local OutlineTracer	= Data.Instances['OutlineTracer'];

				local Pass, Distance = CheckDistance(v.Instance);

				if Pass then
					local ScreenPosition, Vis = WorldToViewport(v.Instance.Position);
					local Color = v.Color;
					local OPos = Camera.CFrame:pointToObjectSpace(v.Instance.Position);
					
					if ScreenPosition.Z < 0 then
						local AT = math.atan2(OPos.Y, OPos.X) + math.pi;
						OPos = CFrame.Angles(0, 0, AT):vectorToWorldSpace((CFrame.Angles(0, math.rad(89.9), 0):vectorToWorldSpace(V3New(0, 0, -1))));
					end
					
					local Position = WorldToViewport(Camera.CFrame:pointToWorldSpace(OPos));

					if Options.ShowTracers.Value then
						Tracer.Transparency = math.clamp(Distance / 200, 0.45, 0.8);
						Tracer.Visible	= true;
						Tracer.From		= TracerPosition;
						Tracer.To		= V2New(Position.X, Position.Y);
						Tracer.Color	= Color;
						OutlineTracer.Visible = true;
						OutlineTracer.Transparency = Tracer.Transparency - 0.1;
						OutlineTracer.From = Tracer.From;
						OutlineTracer.To = Tracer.To;
						OutlineTracer.Color	= Color3.new(0.1, 0.1, 0.1);
					else
						Tracer.Visible = false;
						OutlineTracer.Visible = false;
					end

					if ScreenPosition.Z > 0 then
						local ScreenPositionUpper = ScreenPosition;
						
						if Options.ShowName.Value then
							LocalPlayer.NameDisplayDistance = 0;
							NameTag.Visible		= true;
							NameTag.Text		= v.Text;
							NameTag.Size		= Options.TextSize.Value;
							NameTag.Outline		= Options.TextOutline.Value;
							NameTag.Position	= V2New(ScreenPositionUpper.X, ScreenPositionUpper.Y);
							NameTag.Color		= Color;
							if Drawing.Fonts and shared.am_ic3 then -- CURRENTLY SYNAPSE ONLY :MEGAHOLY:
								NameTag.Font	= Drawing.Fonts.Monospace;
							end
						else
							LocalPlayer.NameDisplayDistance = 100;
							NameTag.Visible = false;
						end
						if Options.ShowDistance.Value or Options.ShowHealth.Value then
							DistanceTag.Visible		= true;
							DistanceTag.Size		= Options.TextSize.Value - 1;
							DistanceTag.Outline		= Options.TextOutline.Value;
							DistanceTag.Color		= Color3.new(1, 1, 1);
							if Drawing.Fonts and shared.am_ic3 then -- CURRENTLY SYNAPSE ONLY :MEGAHOLY:
								NameTag.Font	= Drawing.Fonts.Monospace;
							end

							local Str = '';

							if Options.ShowDistance.Value then
								Str = Str .. Format('[%d] ', Distance);
							end

							DistanceTag.Text = Str;
							DistanceTag.Position = V2New(ScreenPositionUpper.X, ScreenPositionUpper.Y) + V2New(0, NameTag.TextBounds.Y);
						else
							DistanceTag.Visible = false;
						end
					else
						NameTag.Visible			= false;
						DistanceTag.Visible		= false;
					end
				else
					NameTag.Visible			= false;
					DistanceTag.Visible		= false;
					Tracer.Visible			= false;
					OutlineTracer.Visible	= false;
				end

				Data.Instances['NameTag'] 		= NameTag;
				Data.Instances['DistanceTag']	= DistanceTag;
				Data.Instances['Tracer']		= Tracer;
				Data.Instances['OutlineTracer']	= OutlineTracer;

				shared.InstanceData[v.Instance:GetDebugId()] = Data;
			end
		end
		for i, v in pairs(Players:GetPlayers()) do
			local Data = shared.InstanceData[v.Name] or { Instances = {}; };

			Data.Instances['Box'] = Data.Instances['Box'] or LineBox:Create{Thickness = 4};
			Data.Instances['OutlineTracer'] = Data.Instances['OutlineTracer'] or NewDrawing'Line'{
				Transparency	= 1;
				Thickness		= 3;
				Color			= Color3.new(0.1, 0.1, 0.1);
			}
			Data.Instances['Tracer'] = Data.Instances['Tracer'] or NewDrawing'Line'{
				Transparency	= 1;
				Thickness		= 1;
			}
			Data.Instances['HeadDot'] = Data.Instances['HeadDot'] or NewDrawing'Circle'{
				Filled			= true;
				NumSides		= 30;
			}
			Data.Instances['NameTag'] = Data.Instances['NameTag'] or NewDrawing'Text'{
				Size			= Options.TextSize.Value;
				Center			= true;
				Outline			= Options.TextOutline.Value;
				OutlineOpacity	= 1;
				Visible			= true;
			};
			Data.Instances['DistanceHealthTag'] = Data.Instances['DistanceHealthTag'] or NewDrawing'Text'{
				Size			= Options.TextSize.Value - 1;
				Center			= true;
				Outline			= Options.TextOutline.Value;
				OutlineOpacity	= 1;
				Visible			= true;
			};

			local NameTag		= Data.Instances['NameTag'];
			local DistanceTag	= Data.Instances['DistanceHealthTag'];
			local Tracer		= Data.Instances['Tracer'];
			local OutlineTracer	= Data.Instances['OutlineTracer'];
			local HeadDot		= Data.Instances['HeadDot'];
			local Box			= Data.Instances['Box'];

			local Character = GetCharacter(v);
			local Pass, Distance = CheckPlayer(v, Character);

			if Pass and Character then
				local Humanoid = Character:FindFirstChildOfClass'Humanoid';
				local Head = Character:FindFirstChild'Head';
				local HumanoidRootPart = Character:FindFirstChild(CustomRootPartName or 'HumanoidRootPart')

				local Dead = (Humanoid and Humanoid:GetState().Name == 'Dead')
				if type(GetAliveState) == 'function' then
					Dead = (not GetAliveState(v, Character))
				end

				if Character ~= nil and Head and HumanoidRootPart and not Dead then
					local ScreenPosition, Vis = WorldToViewport(Head.Position);
					local Color = Rainbow and Color3.fromHSV(tick() * 128 % 255/255, 1, 1) or (CheckTeam(v) and TeamColor or EnemyColor); Color = Options.ShowTeamColor.Value and v.TeamColor.Color or Color;
					local OPos = Camera.CFrame:pointToObjectSpace(Head.Position);
					
					if ScreenPosition.Z < 0 then
						local AT = math.atan2(OPos.Y, OPos.X) + math.pi;
						OPos = CFrame.Angles(0, 0, AT):vectorToWorldSpace((CFrame.Angles(0, math.rad(89.9), 0):vectorToWorldSpace(V3New(0, 0, -1))));
					end
					
					local Position = WorldToViewport(Camera.CFrame:pointToWorldSpace(OPos));

					if Options.ShowTracers.Value then
						if TracerPosition.X >= Camera.ViewportSize.X or TracerPosition.Y >= Camera.ViewportSize.Y or TracerPosition.X < 0 or TracerPosition.Y < 0 then
							TracerPosition = V2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 135);
						end

						Tracer.Visible	= true;
						Tracer.Transparency = math.clamp(1 - (Distance / 200), 0.25, 0.75);
						Tracer.From		= TracerPosition;
						Tracer.To		= V2New(Position.X, Position.Y);
						Tracer.Color	= Color;
						OutlineTracer.From = Tracer.From;
						OutlineTracer.To = Tracer.To;
						OutlineTracer.Transparency = Tracer.Transparency - 0.15;
						OutlineTracer.Visible = true;
					else
						Tracer.Visible = false;
						OutlineTracer.Visible = false;
					end
					
					if ScreenPosition.Z > 0 then
						local ScreenPositionUpper	= WorldToViewport((HumanoidRootPart:GetRenderCFrame() * CFrame.new(0, Head.Size.Y + HumanoidRootPart.Size.Y + (Options.YOffset.Value / 25), 0)).Position);
						local Scale					= Head.Size.Y / 2;

						if Options.ShowName.Value then
							NameTag.Visible		= true;
							NameTag.Text		= v.Name .. (CustomPlayerTag and CustomPlayerTag(v) or '');
							NameTag.Size		= Options.TextSize.Value;
							NameTag.Outline		= Options.TextOutline.Value;
							NameTag.Position	= V2New(ScreenPositionUpper.X, ScreenPositionUpper.Y) - V2New(0, NameTag.TextBounds.Y);
							NameTag.Color		= Color;
							NameTag.Color		= Color;
							NameTag.OutlineColor= Color3.new(0.05, 0.05, 0.05);
							NameTag.Transparency= 0.85;
							if Drawing.Fonts and shared.am_ic3 then -- CURRENTLY SYNAPSE ONLY :MEGAHOLY:
								NameTag.Font	= Drawing.Fonts.Monospace;
							end
						else
							NameTag.Visible = false;
						end
						if Options.ShowDistance.Value or Options.ShowHealth.Value then
							DistanceTag.Visible		= true;
							DistanceTag.Size		= Options.TextSize.Value - 1;
							DistanceTag.Outline		= Options.TextOutline.Value;
							DistanceTag.Color		= Color3.new(1, 1, 1);
							DistanceTag.Transparency= 0.85;
							if Drawing.Fonts and shared.am_ic3 then -- CURRENTLY SYNAPSE ONLY :MEGAHOLY:
								NameTag.Font	= Drawing.Fonts.Monospace;
							end

							local Str = '';

							if Options.ShowDistance.Value then
								Str = Str .. Format('[%d] ', Distance);
							end
							if Options.ShowHealth.Value then								
								if typeof(Humanoid) == 'Instance' then
									Str = Str .. Format('[%d/%d] [%s%%]', Humanoid.Health, Humanoid.MaxHealth, math.floor(Humanoid.Health / Humanoid.MaxHealth * 100));
								elseif type(GetHealth) == 'function' then
									local health, maxHealth = GetHealth(v)
									
									if type(health) == 'number' and type(maxHealth) == 'number' then
										Str = Str .. Format('[%d/%d] [%s%%]', health, maxHealth, math.floor(health / maxHealth * 100))
									end
								end
							end

							DistanceTag.Text = Str;
							DistanceTag.OutlineColor = Color3.new(0.05, 0.05, 0.05);
							DistanceTag.Position = (NameTag.Visible and NameTag.Position + V2New(0, NameTag.TextBounds.Y) or V2New(ScreenPositionUpper.X, ScreenPositionUpper.Y));
						else
							DistanceTag.Visible = false;
						end
						if Options.ShowDot.Value and Vis then
							local Top			= WorldToViewport((Head.CFrame * CFrame.new(0, Scale, 0)).Position);
							local Bottom		= WorldToViewport((Head.CFrame * CFrame.new(0, -Scale, 0)).Position);
							local Radius		= math.abs((Top - Bottom).Y);

							HeadDot.Visible		= true;
							HeadDot.Color		= Color;
							HeadDot.Position	= V2New(ScreenPosition.X, ScreenPosition.Y);
							HeadDot.Radius		= Radius;
						else
							HeadDot.Visible = false;
						end
						if Options.ShowBoxes.Value and Vis and HumanoidRootPart then
							local Body = {
								Head;
								Character:FindFirstChild'Left Leg' or Character:FindFirstChild'LeftLowerLeg';
								Character:FindFirstChild'Right Leg' or Character:FindFirstChild'RightLowerLeg';
								Character:FindFirstChild'Left Arm' or Character:FindFirstChild'LeftLowerArm';
								Character:FindFirstChild'Right Arm' or Character:FindFirstChild'RightLowerArm';
							}
							Box:Update(HumanoidRootPart.CFrame, V3New(2, 3, 1) * (Scale * 2), Color, nil, shared.am_ic3 and Body);
						else
							Box:SetVisible(false);
						end
					else
						NameTag.Visible			= false;
						DistanceTag.Visible		= false;
						HeadDot.Visible			= false;
						
						Box:SetVisible(false);
					end
				else
					NameTag.Visible			= false;
					DistanceTag.Visible		= false;
					HeadDot.Visible			= false;
					Tracer.Visible			= false;
					OutlineTracer.Visible 	= false;
					
					Box:SetVisible(false);
				end
			else
				NameTag.Visible			= false;
				DistanceTag.Visible		= false;
				HeadDot.Visible			= false;
				Tracer.Visible			= false;
				OutlineTracer.Visible 	= false;

				Box:SetVisible(false);
			end

			shared.InstanceData[v.Name] = Data;
		end
	end
end

local LastInvalidCheck = 0;

local function Update()
	if tick() - LastInvalidCheck > 0.3 then
		LastInvalidCheck = tick();

		if Camera.Parent ~= workspace then
			Camera = workspace.CurrentCamera;
			CameraCon();
			WTVP = Camera.WorldToViewportPoint;
		end

		for i, v in pairs(shared.InstanceData) do
			if not Players:FindFirstChild(tostring(i)) then
				if not v.DontDelete then
					GetTableData(v.Instances)(function(i, obj)
						obj.Visible = false;
						obj:Remove();
						v.Instances[i] = nil;
					end)
					shared.InstanceData[i] = nil;
				else
					if v.Instance == nil or v.Instance.Parent == nil or (RenderList.Instances[v.Base] and RenderList.Instances[v.Base].Instance == nil) or (not v.Instance:IsDescendantOf(workspace)) then
						v.DontDelete = false
					end
				end
			end
		end
	end

	local CX = Menu:GetInstance'CrosshairX';
	local CY = Menu:GetInstance'CrosshairY';
	
	if Options.Crosshair.Value then
		CX.Visible = true;
		CY.Visible = true;

		CX.To = V2New((Camera.ViewportSize.X / 2) - 8, (Camera.ViewportSize.Y / 2));
		CX.From = V2New((Camera.ViewportSize.X / 2) + 8, (Camera.ViewportSize.Y / 2));
		CY.To = V2New((Camera.ViewportSize.X / 2), (Camera.ViewportSize.Y / 2) - 8);
		CY.From = V2New((Camera.ViewportSize.X / 2), (Camera.ViewportSize.Y / 2) + 8);
	else
		CX.Visible = false;
		CY.Visible = false;
	end

	if Options.MenuOpen.Value and MenuLoaded then
		local MLocation = GetMouseLocation();
		shared.MenuDrawingData.Instances.Main.Color = Color3.fromHSV(tick() * 24 % 255/255, 1, 1);
		local MainInstance = Menu:GetInstance'Main';
		
		local Values = {
			MainInstance.Position.X;
			MainInstance.Position.Y;
			MainInstance.Position.X + MainInstance.Size.X;
			MainInstance.Position.Y + MainInstance.Size.Y;
		};
		
		if MainInstance and (MouseHoveringOver(Values) or (SubMenu.Open and MouseHoveringOver(SubMenu.Bounds))) then
			Debounce.CursorVis = true;
			
			Menu:UpdateMenuInstance'Cursor1'{
				Visible	= true;
				From	= V2New(MLocation.x, MLocation.y);
				To		= V2New(MLocation.x + 5, MLocation.y + 6);
			}
			Menu:UpdateMenuInstance'Cursor2'{
				Visible	= true;
				From	= V2New(MLocation.x, MLocation.y);
				To		= V2New(MLocation.x, MLocation.y + 8);
			}
			Menu:UpdateMenuInstance'Cursor3'{
				Visible	= true;
				From	= V2New(MLocation.x, MLocation.y + 6);
				To		= V2New(MLocation.x + 5, MLocation.y + 5);
			}
		else
			if Debounce.CursorVis then
				Debounce.CursorVis = false;
				
				Menu:UpdateMenuInstance'Cursor1'{Visible = false};
				Menu:UpdateMenuInstance'Cursor2'{Visible = false};
				Menu:UpdateMenuInstance'Cursor3'{Visible = false};
			end
		end
		if MouseHeld then
			local MousePos = GetMouseLocation();

			if Dragging then
				DraggingWhat.Slider.Position = V2New(math.clamp(MLocation.X - DraggingWhat.Slider.Size.X / 2, DraggingWhat.Line.Position.X, DraggingWhat.Line.Position.X + DraggingWhat.Line.Size.X - DraggingWhat.Slider.Size.X), DraggingWhat.Slider.Position.Y);
				local Percent	= (DraggingWhat.Slider.Position.X - DraggingWhat.Line.Position.X) / ((DraggingWhat.Line.Position.X + DraggingWhat.Line.Size.X - DraggingWhat.Line.Position.X) - DraggingWhat.Slider.Size.X);
				local Value		= CalculateValue(DraggingWhat.Min, DraggingWhat.Max, Percent);
				DraggingWhat.Option(Value);
			elseif DraggingUI then
				Debounce.UIDrag = true;
				local Main = Menu:GetInstance'Main';
				Main.Position = MousePos + DragOffset;
			elseif DragTracerPosition then
				TracerPosition = MousePos;
			end
		else
			Dragging = false;
			DragTracerPosition = false;
			if DraggingUI and Debounce.UIDrag then
				Debounce.UIDrag = false;
				DraggingUI = false;
				CreateMenu(Menu:GetInstance'Main'.Position);
			end
		end
		if not Debounce.Menu then
			Debounce.Menu = true;
			ToggleMenu();
		end
	elseif Debounce.Menu and not Options.MenuOpen.Value then
		Debounce.Menu = false;
		ToggleMenu();
	end
end

RunService:UnbindFromRenderStep(GetDataName);
RunService:UnbindFromRenderStep(UpdateName);

RunService:BindToRenderStep(GetDataName, 300, UpdatePlayerData);
RunService:BindToRenderStep(UpdateName, 199, Update);
