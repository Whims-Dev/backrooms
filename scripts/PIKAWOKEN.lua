-- pikahub script
-- made by tk

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GroupService = game:GetService("GroupService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris");
local TweenService = game:GetService("TweenService")
local CoreGui = game.CoreGui;

local Player = Players.LocalPlayer;

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
    feature.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    feature.Text = text
    feature.TextColor3 = Color3.fromRGB(255, 255, 255)
    feature.TextScaled = true
    feature.TextSize = 14
    feature.TextWrapped = true
    feature.TextXAlignment = Enum.TextXAlignment.Left
    feature.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    feature.BackgroundTransparency = 1
    feature.Position = UDim2.fromScale(0.0381, 0.26)
    feature.Size = UDim2.fromScale(0.708, 0.46)
    feature.Parent = parent;
    return feature;
end

local function Roundify(parent)
    local uICorner = Instance.new("UICorner")
    uICorner.Name = "UICorner"
    uICorner.CornerRadius = UDim.new(0.5, 0)
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
main.BackgroundColor3 = Color3.fromRGB(26, 32, 36)
main.BorderColor3 = Color3.fromRGB(13, 16, 21)
main.BorderSizePixel = 3
main.Position = UDim2.fromScale(0.0211, 0.576)
main.Size = UDim2.fromScale(0.46, 0.394)
main.Active = true
main.Draggable = true

local top = Instance.new("Frame")
top.Name = "Top"
top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
top.BackgroundTransparency = 0.5
top.BorderColor3 = Color3.fromRGB(27, 42, 53)
top.BorderSizePixel = 0
top.Size = UDim2.fromScale(1, 0.2)

local scriptTitle = Instance.new("TextLabel")
scriptTitle.Name = "ScriptTitle"
scriptTitle.FontFace = Font.new(
  "rbxasset://fonts/families/GothamSSm.json",
  Enum.FontWeight.Heavy,
  Enum.FontStyle.Normal
)
scriptTitle.Text = "PIKA HUB"
scriptTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
scriptTitle.TextScaled = true
scriptTitle.TextSize = 14
scriptTitle.TextWrapped = true
scriptTitle.TextXAlignment = Enum.TextXAlignment.Left
scriptTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
scriptTitle.BackgroundTransparency = 1
scriptTitle.BorderColor3 = Color3.fromRGB(27, 42, 53)
scriptTitle.Position = UDim2.fromScale(0.054, 0.186)
scriptTitle.Size = UDim2.fromScale(0.508, 0.606)
scriptTitle.Parent = top

top.Parent = main

local scrolling = Instance.new("ScrollingFrame")
scrolling.Name = "Scrolling"
scrolling.BottomImage = "rbxassetid://1195495135"
scrolling.MidImage = "rbxassetid://1195495135"
scrolling.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
scrolling.ScrollBarImageTransparency = 0.5
scrolling.ScrollBarThickness = 0
scrolling.TopImage = "rbxassetid://1195495135"
scrolling.BackgroundColor3 = Color3.fromRGB(33, 40, 45)
scrolling.BorderSizePixel = 0
scrolling.ClipsDescendants = false
scrolling.Position = UDim2.fromScale(0, 0.2)
scrolling.Selectable = false
scrolling.Size = UDim2.fromScale(0.239, 0.797)
scrolling.SelectionGroup = false
scrolling.Parent = main
local scrollingUIListLayout = Instance.new("UIListLayout")
scrollingUIListLayout.Name = "UIListLayout"
scrollingUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
scrollingUIListLayout.Parent = scrolling

local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
uIAspectRatioConstraint.Name = "UIAspectRatioConstraint"
uIAspectRatioConstraint.AspectRatio = 1.46
uIAspectRatioConstraint.Parent = main

main.Parent = pikaHub
pikaHub.Parent = CoreGui

function NewSection(Section)
    local sectionButton = Instance.new("TextButton")
    sectionButton.Name = "SectionButton"
    sectionButton.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    sectionButton.Text = Section
    sectionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    sectionButton.TextScaled = true
    sectionButton.TextSize = 14
    sectionButton.TextWrapped = true
    sectionButton.Active = false
    sectionButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    sectionButton.BackgroundTransparency = 0.9
    sectionButton.BorderSizePixel = 0
    sectionButton.Selectable = false
    sectionButton.Size = UDim2.new(1, 0, 0, 60)
    sectionButton.Parent = scrolling
    scrolling.CanvasSize = UDim2.fromOffset(0, scrollingUIListLayout.AbsoluteContentSize.Y)
    local container = Instance.new("ScrollingFrame")
    container.Name = "Container"
    container.BottomImage = "rbxassetid://1195495135"
    container.MidImage = "rbxassetid://1195495135"
    container.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
    container.ScrollBarImageTransparency = 0.5
    container.ScrollBarThickness = 0
    container.TopImage = "rbxassetid://1195495135"
    container.BackgroundColor3 = Color3.fromRGB(24, 29, 33)
    container.BorderSizePixel = 0
    container.ClipsDescendants = false
    container.Position = UDim2.fromScale(0.239, 0.2)
    container.Selectable = false
    container.Size = UDim2.fromScale(0.761, 0.797)
    container.SelectionGroup = false
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
    Padding(sectionButton, 0.1, 0.1, 0.1, 0.1)
    local Create = {}
    function Create.Button(Text, Callback)
        local button = Instance.new("Frame")
        button.Name = "Button"
        button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        button.BackgroundTransparency = 0.8
        button.BorderSizePixel = 0
        button.Size = UDim2.new(1, 0, 0, 50)
        FeatureText(button, Text)
        local button1 = Instance.new("TextButton")
        button1.Name = "Button"
        button1.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
        button1.TextColor3 = Color3.fromRGB(0, 0, 0)
        button1.TextSize = 14
        button1.TextTransparency = 1
        button1.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        button1.BackgroundTransparency = 0.7
        button1.BorderSizePixel = 0
        button1.Position = UDim2.fromScale(0.784, 0.16)
        button1.Size = UDim2.fromScale(0.183, 0.66)
        Roundify(button1)
        local image = Instance.new("ImageLabel")
        image.Name = "Image"
        image.Image = "rbxassetid://11717854254"
        image.ScaleType = Enum.ScaleType.Fit
        image.AnchorPoint = Vector2.new(0.5, 0.5)
        image.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        image.BackgroundTransparency = 1
        image.Position = UDim2.fromScale(0.5, 0.5)
        image.Size = UDim2.fromScale(1, 0.9)
        image.Parent = button1
        button1.Parent = button
        button.Parent = container;
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
        number.Size = UDim2.new(1, 0, 0, 50)
        FeatureText(number, Text)
        local button = Instance.new("TextBox")
        button.Name = "Button"
        button.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        button.Text = tostring(Default or Min or 0)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextScaled = true
        button.TextSize = 14
        button.TextWrapped = true
        button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        button.BackgroundTransparency = 0.7
        button.BorderSizePixel = 0
        button.Position = UDim2.fromScale(0.784, 0.16)
        button.Size = UDim2.fromScale(0.183, 0.66)
        Roundify(button)
        Padding(button, 0.17, 0.05, 0.05, 0.17)
        button.Parent = number
        number.Parent = container;
        local lastValue = info.value;
        local controller = button.FocusLost:Connect(function()
            local value = tonumber(button.Text);
            if (value ~= nil) and (value >= Min) and (value <= Max) then
                info.value, lastValue = value, value;
                if (Callback ~= nil) then
                    Callback(value);
                end
            else
                button.Text = lastValue;
            end
        end)
        if (Callback ~= nil) then
            Callback(info.value);
        end
        return info, number, controller;
    end
    function Create.Toggle(Text, Default, Callback)
        local info = { value = Default };
        local toggle = Instance.new("Frame")
        toggle.Name = "Toggle"
        toggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        toggle.BackgroundTransparency = 0.8
        toggle.BorderSizePixel = 0
        toggle.Size = UDim2.new(1, 0, 0, 50)
        FeatureText(toggle, Text)
        local button = Instance.new("TextButton")
        button.Name = "Button"
        button.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
        button.Text = ""
        button.TextColor3 = Color3.fromRGB(0, 0, 0)
        button.TextSize = 14
        button.TextTransparency = 1
        button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        button.BackgroundTransparency = 0.7
        button.BorderSizePixel = 0
        button.Position = UDim2.fromScale(0.784, 0.16)
        button.Size = UDim2.fromScale(0.183, 0.66)
        Roundify(button)
        local frame = Instance.new("Frame")
        frame.Name = "Frame"
        frame.AnchorPoint = Vector2.new(0, 0.5)
        frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        frame.BackgroundTransparency = 0.5
        frame.BorderSizePixel = 0
        frame.Position = UDim2.fromScale(0, 0.5)
        frame.Size = UDim2.fromScale(0.5, 1)
        Roundify(frame)
        frame.Parent = button
        button.Parent = toggle
        toggle.Parent = container;
        local function NewValue(value)
            frame.Position = (value and UDim2.fromScale(0.5, 0.5) or UDim2.fromScale(0, 0.5))
            frame.BackgroundColor3 = (value and Color3.new(0, 1, 0) or Color3.new(1, 0, 0))
            info.value = value;
            if (Callback ~= nil) then
                Callback(info.value);
            end
        end
        NewValue(Default)
        local controller = button.MouseButton1Click:Connect(function()
            NewValue(not info.value)
        end)
        return info, toggle, controller;
    end
    return Create, container;
end

local Universal, MC = NewSection("Universal")
local speedInfo = Universal.Toggle("Speedhack", false)
local speedSpeedInfo = Universal.Number("Dash Speed (ms)", 120, 60, 120)
local jumpInfo = Universal.Number("Jump Strength", 100, 0, 600)
Universal.Button("Super Jump", function()
    Player.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, jumpInfo.value, 0)
end)
Universal.Button("Unnamed ESP", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Whims-Dev/backrooms/main/scripts/Unnamed%20ESP%20Edit.lua", true))()
end)
MC.Visible = true;
local Redwood = NewSection("Redwood Prison: Reworked")
local CurrentWinded, WindedRespawned;
Redwood.Toggle("Disable Mountain Wind", false, function(value)
    if (WindedRespawned) then WindedRespawned:Disconnect() end
    if (value) then
        local function NoWinded(c)
            if (CurrentWinded) then CurrentWinded:Disconnect() end
            CurrentWinded = c.ChildAdded:Connect(function(i)
                if (i:IsA("Folder")) and (i.Name == "Winded") then
                    task.wait(1)
                    i:Destroy()
                end
            end)
            if (c:FindFirstChild("Winded")) and (c.Winded:IsA("Folder")) then
                c.Winded:Destroy()
            end
        end
        WindedRespawned = Player.CharacterAdded:Connect(NoWinded)
        if (Player.Character) then
            NoWinded(Player.Character)
        end
    else
        if (CurrentWinded) then CurrentWinded:Disconnect() end
        if (WindedRespawned) then WindedRespawned:Disconnect() end
    end
end)
local Deepwoken = NewSection("Deepwoken")
local modcheck;
local GroupInfo = GroupService:GetGroupInfoAsync(5212858);
local function GetRoleInfoFromRank(Rank)
    for _, info in pairs(GroupInfo.Roles) do
        if (info.Rank == Rank) then
            return info;
        end
    end
end
Deepwoken.Toggle("Mod Check", false, function(value)
    if (value) then
        Notify("Mod Check", "Checking for moderators, please stand by...", 5)
        modcheck = Players.PlayerAdded:Connect(function(p)
            local Rank = p:GetRankInGroup(5212858);
            if (Rank) and (Rank >= 1) then
                Notify("Mod Alert", string.format("%s (%s)\nRank: %s", p.Name, p.UserId, GetRoleInfoFromRank()), 5)
            end
        end)
        local found = false;
        for _, p in pairs(Players:GetPlayers()) do
            local Rank = p:GetRankInGroup(5212858);
            if (Rank) and (Rank >= 1) then
                xpcall(function()
                    Notify("Mod Alert", string.format("%s (%s)\nRank: %s", p.Name, p.UserId, GetRoleInfoFromRank()), 5)
                end, function(a)
                    
                end)
                found = true;
            end
        end
        if (not found) then
            Notify("Mod Check", "All clear!", 5)
        end
    else
        if (modcheck ~= nil) then
            modcheck:Disconnect()
        end
    end
end)
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
local LeaderboardRespawn;
local spectateInfo = Deepwoken.Toggle("Leaderboard Spectate", false, function(value)
    if (value) then
        if (not LeaderboardRespawn) then
            if (Player:FindFirstChild("PlayerGui")) and (Player.PlayerGui:FindFirstChild("LeaderboardGui")) then
                NewLeaderboard()
            end
            NewLeaderboard = Player.CharacterAdded:Connect(NewLeaderboard)
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
                    if (workspace.CurrentCamera.CameraSubject == humanoid) then
                        workspace.CurrentCamera.CameraSubject = Player.Character.Humanoid
                    else
                        workspace.CurrentCamera.CameraSubject = humanoid;
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
        clone.Parent = workspace.CurrentCamera;
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

local visibilityController = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if (gameProcessedEvent) then return end
    if (input.KeyCode == Enum.KeyCode.End) then
        main.Visible = not main.Visible;
    end
end)

shared.PikaHubDisconnect = function()
	for _, c in pairs(CoreGui:GetChildren()) do
        if (c:IsA("ScreenGui")) and (c.Name == pikaHub.Name) then
            c:Destroy()
        end
	end
    visibilityController:Disconnect();
    speedController:Disconnect();
    speedDash:Disconnect();
    if (CurrentWinded) then CurrentWinded:Disconnect() end
    if (WindedRespawned) then WindedRespawned:Disconnect() end
    if (modcheck) then modcheck:Disconnect() end
end
