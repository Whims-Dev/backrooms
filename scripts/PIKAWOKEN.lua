-- pornhub script
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

local GroupInfo = GroupService:GetGroupInfoAsync(5212858);
local function GetRoleInfoFromRank(Rank)
    for _, info in pairs(GroupInfo.Roles) do
        if (info.Rank == Rank) then
            return info;
        end
    end
end

local function Notify(Title, Text, Duration)
    StarterGui:SetCore("SendNotification", {Title=Title, Text=Text, Duration=(Duration or 5), Button1="OK"})
end

if (shared.WokenHubDisconnect) then
    shared.WokenHubDisconnect();
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
    feature.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
    feature.Text = text
    feature.TextColor3 = Color3.fromRGB(255, 255, 255)
    feature.TextScaled = true
    feature.TextSize = 14
    feature.TextWrapped = true
    feature.TextXAlignment = Enum.TextXAlignment.Left
    feature.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    feature.BackgroundTransparency = 1
    feature.Size = UDim2.fromScale(0.8, 1)
    Padding(feature, 0.2, 0.05, 0, 0.2)
    local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
    uITextSizeConstraint.Name = "UITextSizeConstraint"
    uITextSizeConstraint.MaxTextSize = 16
    uITextSizeConstraint.Parent = feature
    local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
    uIAspectRatioConstraint.Name = "UIAspectRatioConstraint"
    uIAspectRatioConstraint.AspectRatio = 8.6
    uIAspectRatioConstraint.Parent = feature
    feature.Parent = parent
    return feature;
end

local function Roundify(parent)
    local uICorner = Instance.new("UICorner")
    uICorner.Name = "UICorner"
    uICorner.CornerRadius = UDim.new(0.5, 0)
    uICorner.Parent = parent
    return uICorner;
end

local hubMain = Instance.new("ScreenGui")
hubMain.Name = "PIKAWOKENHUB"
hubMain.IgnoreGuiInset = true
hubMain.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
hubMain.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
hubMain.Parent = CoreGui;

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.BackgroundColor3 = Color3.fromRGB(27, 42, 53)
mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.BorderSizePixel = 2
mainFrame.Position = UDim2.fromScale(0.763, 0.357)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Size = UDim2.fromScale(0.226, 0.488)

local title = Instance.new("TextLabel")
title.Name = "Title"
title.FontFace = Font.new(
  "rbxasset://fonts/families/GothamSSm.json",
  Enum.FontWeight.Heavy,
  Enum.FontStyle.Normal
)
title.Text = "PIKA HUB"
title.TextColor3 = Color3.fromRGB(27, 42, 53)
title.TextScaled = true
title.TextSize = 14
title.TextWrapped = true
title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
title.BorderColor3 = Color3.fromRGB(27, 42, 53)
title.BorderSizePixel = 0
title.Size = UDim2.fromScale(1, 0.0659)

Padding(title, 0.125, 0, 0, 0.1)

local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
uITextSizeConstraint.Name = "UITextSizeConstraint"
uITextSizeConstraint.MaxTextSize = 22
uITextSizeConstraint.Parent = title

local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
uIAspectRatioConstraint.Name = "UIAspectRatioConstraint"
uIAspectRatioConstraint.AspectRatio = 10.4
uIAspectRatioConstraint.Parent = title

title.Parent = mainFrame

local container = Instance.new("ScrollingFrame")
container.Name = "Container"
container.BottomImage = "rbxassetid://5352896021"
container.CanvasSize = UDim2.new()
container.MidImage = "rbxassetid://5352896021"
container.TopImage = "rbxassetid://5352896021"
container.Active = true
container.BackgroundColor3 = Color3.fromRGB(27, 42, 53)
container.BorderColor3 = Color3.fromRGB(255, 255, 255)
container.Position = UDim2.fromScale(0, 0.0659)
container.Size = UDim2.fromScale(1, 0.934)

local uIListLayout = Instance.new("UIListLayout")
uIListLayout.Name = "UIListLayout"
uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout.Parent = container

container.CanvasSize = UDim2.fromOffset(uIListLayout.AbsoluteContentSize.X, uIListLayout.AbsoluteContentSize.Y)
uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    container.CanvasSize = UDim2.fromOffset(uIListLayout.AbsoluteContentSize.X, uIListLayout.AbsoluteContentSize.Y)
end)

local uIAspectRatioConstraint1 = Instance.new("UIAspectRatioConstraint")
uIAspectRatioConstraint1.Name = "UIAspectRatioConstraint"
uIAspectRatioConstraint1.AspectRatio = 0.732
uIAspectRatioConstraint1.Parent = container

container.Parent = mainFrame

local uIAspectRatioConstraint2 = Instance.new("UIAspectRatioConstraint")
uIAspectRatioConstraint2.Name = "UIAspectRatioConstraint"
uIAspectRatioConstraint2.AspectRatio = 0.684
uIAspectRatioConstraint2.Parent = mainFrame

mainFrame.Parent = hubMain

local Create = {};

function Create.Button(Text, Callback)
    local button = Instance.new("Frame")
    button.Name = "Button"
    button.BackgroundColor3 = Color3.fromRGB(35, 54, 68)
    button.BorderColor3 = Color3.fromRGB(27, 42, 53)
    button.BorderSizePixel = 0
    button.Size = UDim2.new(1, 0, 0, 28)
    FeatureText(button, Text)
    button.Parent = container;
    local button1 = Instance.new("TextButton")
    button1.Name = "Button"
    button1.Text = ""
    button1.TextScaled = true
    button1.TextWrapped = true
    button1.AnchorPoint = Vector2.new(1, 0.5)
    button1.BackgroundColor3 = Color3.fromRGB(27, 42, 53)
    button1.BorderColor3 = Color3.fromRGB(27, 42, 53)
    button1.Position = UDim2.fromScale(0.93, 0.5)
    button1.Size = UDim2.fromScale(0.116, 0.893)
    Roundify(button1)
    local image = Instance.new("ImageLabel")
    image.Name = "Image"
    image.Image = "rbxassetid://11717854254"
    image.ScaleType = Enum.ScaleType.Fit
    image.Active = true
    image.AnchorPoint = Vector2.new(0.5, 0.5)
    image.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    image.BackgroundTransparency = 1
    image.Position = UDim2.fromScale(0.5, 0.5)
    image.Selectable = true
    image.Size = UDim2.fromScale(1, 1)
    image.Parent = button1
    local uITextSizeConstraint1 = Instance.new("UITextSizeConstraint")
    uITextSizeConstraint1.Name = "UITextSizeConstraint"
    uITextSizeConstraint1.MaxTextSize = 8
    uITextSizeConstraint1.Parent = button1
    local uIAspectRatioConstraint1 = Instance.new("UIAspectRatioConstraint")
    uIAspectRatioConstraint1.Name = "UIAspectRatioConstraint"
    uIAspectRatioConstraint1.AspectRatio = 1.4
    uIAspectRatioConstraint1.Parent = button1
    button1.Parent = button
    local uIAspectRatioConstraint2 = Instance.new("UIAspectRatioConstraint")
    uIAspectRatioConstraint2.Name = "UIAspectRatioConstraint"
    uIAspectRatioConstraint2.AspectRatio = 10.8
    uIAspectRatioConstraint2.Parent = button
    local click = button1.MouseButton1Click:Connect(Callback)
    return button, click;
end

function Create.Number(Text, Default, Min, Max, Callback)
    local Default, Min, Max = (tonumber(Default) or 0), (tonumber(Min) or -math.huge), (tonumber(Max) or math.huge);
    local info = { value = Default };
    local number = Instance.new("Frame")
    number.Name = "Number"
    number.BackgroundColor3 = Color3.fromRGB(35, 54, 68)
    number.BorderColor3 = Color3.fromRGB(27, 42, 53)
    number.BorderSizePixel = 0
    number.Size = UDim2.new(1, 0, 0, 28)
    FeatureText(number, Text)
    number.Parent = container;
    local button = Instance.new("TextBox")
    button.Name = "Button"
    button.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
    button.Text = tostring(Default or Min or 0)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.TextSize = 14
    button.TextWrapped = true
    button.AnchorPoint = Vector2.new(1, 0.5)
    button.BackgroundColor3 = Color3.fromRGB(27, 42, 53)
    button.BorderColor3 = Color3.fromRGB(27, 42, 53)
    button.Position = UDim2.fromScale(0.93, 0.5)
    button.Size = UDim2.fromScale(0.116, 0.893)
    Roundify(button)
    Padding(button, 0.2, 0.1, 0.1, 0.2)
    local uITextSizeConstraint1 = Instance.new("UITextSizeConstraint")
    uITextSizeConstraint1.Name = "UITextSizeConstraint"
    uITextSizeConstraint1.MaxTextSize = 15
    uITextSizeConstraint1.Parent = button
    local uIAspectRatioConstraint1 = Instance.new("UIAspectRatioConstraint")
    uIAspectRatioConstraint1.Name = "UIAspectRatioConstraint"
    uIAspectRatioConstraint1.AspectRatio = 1.4
    uIAspectRatioConstraint1.Parent = button
    button.Parent = number
    local uIAspectRatioConstraint2 = Instance.new("UIAspectRatioConstraint")
    uIAspectRatioConstraint2.Name = "UIAspectRatioConstraint"
    uIAspectRatioConstraint2.AspectRatio = 10.8
    uIAspectRatioConstraint2.Parent = number
    local lastValue = info.value;
    local controller = button.FocusLost:Connect(function()
        local value = tonumber(button.Text);
        if (value ~= nil) and (value >= Min) and (value <= Max) then
            info.value, lastValue = value, value;
            Callback(value);
        else
            button.Text = lastValue;
        end
    end)
    return number, controller, info;
end

function Create.Toggle(Text, Default, Callback)
    local info = { value = Default };
    local toggle = Instance.new("Frame")
    toggle.Name = "Toggle"
    toggle.BackgroundColor3 = Color3.fromRGB(35, 54, 68)
    toggle.BorderColor3 = Color3.fromRGB(27, 42, 53)
    toggle.BorderSizePixel = 0
    toggle.Size = UDim2.new(1, 0, 0, 28)
    FeatureText(toggle, Text)
    toggle.Parent = container;
    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
    button.Text = ""
    button.TextColor3 = Color3.fromRGB(0, 0, 0)
    button.TextScaled = true
    button.TextSize = 14
    button.TextWrapped = true
    button.AnchorPoint = Vector2.new(1, 0.5)
    button.BackgroundColor3 = Color3.fromRGB(27, 42, 53)
    button.BorderColor3 = Color3.fromRGB(27, 42, 53)
    button.Position = UDim2.fromScale(0.93, 0.5)
    button.Size = UDim2.fromScale(0.116, 0.893)
    Roundify(button)
    local frame = Instance.new("Frame")
    frame.Name = "Frame"
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.fromScale(0.5, 0.5)
    frame.Size = UDim2.fromScale(0.6, 0.6)
    frame.Visible = (Default == true);
    Roundify(frame)
    frame.Parent = button
    local uITextSizeConstraint1 = Instance.new("UITextSizeConstraint")
    uITextSizeConstraint1.Name = "UITextSizeConstraint"
    uITextSizeConstraint1.MaxTextSize = 14
    uITextSizeConstraint1.Parent = button
    local uIAspectRatioConstraint1 = Instance.new("UIAspectRatioConstraint")
    uIAspectRatioConstraint1.Name = "UIAspectRatioConstraint"
    uIAspectRatioConstraint1.AspectRatio = 1.4
    uIAspectRatioConstraint1.Parent = button
    button.Parent = toggle
    local uIAspectRatioConstraint2 = Instance.new("UIAspectRatioConstraint")
    uIAspectRatioConstraint2.Name = "UIAspectRatioConstraint"
    uIAspectRatioConstraint2.AspectRatio = 10.8
    uIAspectRatioConstraint2.Parent = toggle
    info.value = frame.Visible;
    local controller = button.MouseButton1Click:Connect(function()
        frame.Visible = not frame.Visible;
        info.value = frame.Visible;
        Callback(info.value);
    end)
    return toggle, controller, info;
end

local _, _, speedInfo = Create.Toggle("Speedhack", false)
local _, _, speedSpeedInfo = Create.Number("Dash Speed (ms)", 120, 60, 120)
local _, _, jumpInfo = Create.Number("Jump Strength", 100, 0, 600)
Create.Button("Super Jump", function()
    Player.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, jumpInfo.value, 0)
end)
Create.Button("Mod Check", function()
    Notify("Mod Check", "Checking for moderators, please stand by...", 5)
    local found = false;
    for _, p in pairs(Players:GetPlayers()) do
        local Rank = p:GetRankInGroup(5212858);
        if (Rank) and (Rank >= 1) then
            Notify("Mod Alert", string.format("%s (%s)\nRank: %s", p.Name, p.UserId, GetRoleInfoFromRank()), 5)
            found = true;
        end
    end
    if (not found) then
        Notify("Mod Check", "All clear!", 5)
    end
end)
Create.Button("Unnamed ESP", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Whims-Dev/backrooms/main/scripts/Unnamed%20Deepwoken%20ESP%20Edit.lua", true))()
end)
Create.Toggle("Custom Voices", false, function(value)
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
local _, _, spectateInfo = Create.Toggle("Leaderboard Spectate", false)
local function NewSpectate(frame)
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
local function NewLeaderboard()
    Player.PlayerGui.LeaderboardGui.MainFrame.ScrollingFrame.ChildAdded:Connect(NewSpectate)
    for _, f in pairs(Player.PlayerGui.LeaderboardGui.MainFrame.ScrollingFrame:GetChildren()) do
        NewSpectate(f)
    end
end
if (Player:FindFirstChild("PlayerGui")) and (Player.PlayerGui:FindFirstChild("LeaderboardGui")) then
    NewLeaderboard()
end
Player.CharacterAdded:Connect(NewLeaderboard)

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
        mainFrame.Visible = not mainFrame.Visible;
    end
end)

shared.WokenHubDisconnect = function()
    if (CoreGui:FindFirstChild("PIKAWOKENHUB")) then
        CoreGui.PIKAWOKENHUB:Destroy()
    end
    visibilityController:Disconnect();
    speedController:Disconnect();
    speedDash:Disconnect();
end
