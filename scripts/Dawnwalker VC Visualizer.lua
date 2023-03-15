local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local BubbleChat = CoreGui:WaitForChild("BubbleChat")

local Player = Players.LocalPlayer
local Character = Player.Character

local Camera = workspace.CurrentCamera
local Head = Character.Head

local Model = Instance.new("Model")
Model.Name = "Dawnwalker_Visualizer"
if (Character:FindFirstChild(Model.Name)) then
    Character[Model.Name]:Destroy()
end
Model.Parent = Character;

local Part = Instance.new("Part")
Part.Anchored = true
Part.CanCollide = false
Part.Color = Color3.new(1, 1, 1)
Part.Material = Enum.Material.Neon
Part.Size = Vector3.new(0.1, 1.3, 0.1)
Part.CFrame = CFrame.new((Head.CFrame * CFrame.new(0, 2.5, 0)).Position)
Part.Name = "Visualizer"
Part.Parent = Model
Instance.new("SpecialMesh", Part).MeshType = Enum.MeshType.Sphere
local Part2 = Part:Clone()
Part2.Name = "Dawnwalker"
Part2.Transparency = 0.85
Part2.Size = Vector3.new(1.3, 0, 1.3)
Part2.Parent = Model
local Part3 = Part:Clone()
Part3.Name = "Dawnwalker2"
Part3.Size = Vector3.new(0.5, 0.5, 0.2)
Part3.Parent = Model

local Prefix = "rbxasset://textures/ui/VoiceChat/MicDark/Unmuted";

while (Model:IsDescendantOf(workspace)) do
    RunService.Stepped:Wait()
    Part.CFrame = Part.CFrame:Lerp(CFrame.new((Head.CFrame * CFrame.new(0, 2.5, 0)).Position), 0.1)
    local PartOrigin = Part.Position;
    Part2.CFrame = CFrame.new(PartOrigin);
    local Direction = Camera.CFrame.LookVector;
    Part3.CFrame = CFrame.new(PartOrigin, Vector3.new(PartOrigin.X + Direction.X, PartOrigin.Y, PartOrigin.Z + Direction.Z));
    local Level;
    pcall(function()
        Level = CoreGui.BubbleChat[string.format("BubbleChat_%s", Player.UserId)].VoiceBubble.RoundedFrame.Contents.Insert;        
    end)
    local Loudness = 0;
    if (Level ~= nil) then
        local Volume = tonumber(string.sub(Level.Image, #Prefix + 1, #Prefix + 2))
        if (Volume) then
            if (Volume > 10) then
                Loudness = Volume;
            elseif (tonumber(string.sub(Level.Image, #Prefix + 3, #Prefix + 3)) == 0) then
                Loudness = 100;
            end
        end
    end
    Part.Size = Part.Size:Lerp(Vector3.new(0.1, 1.3 + (Loudness/50), 0.1), 0.3)
end
