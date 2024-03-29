--[[
    designed for deepwoken lol!
    - tk
    
    toggle with F2
--]]

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer;
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera;

local Flying = false;
local FlyDirections = {
    [Enum.KeyCode.W] = { "F", 1 },
    [Enum.KeyCode.S] = { "B", -1 },
    [Enum.KeyCode.A] = { "L", -1 },
    [Enum.KeyCode.D] = { "R", 1 },
};
local LastControl = { F = 0, B = 0, L = 0, R = 0 }; 
local FlySpeed, MaxFlySpeed = 50, 200;

local Foutline = Instance.new("Highlight")
Foutline.FillColor = Color3.new(1, 1, 1)
Foutline.OutlineTransparency = Foutline.FillTransparency
Foutline.Name = "Foutline"
Foutline.Parent = Camera

if (shared.flyinput) then shared.flyinput:Disconnect() end
shared.flyinput = UserInputService.InputBegan:Connect(function(input, gpe)
    if (gpe) then return end
    if (input.KeyCode == Enum.KeyCode.F2) then
        Flying = not Flying;
        if (not Flying) then
            LastControl = { F = 0, B = 0, L = 0, R = 0 }
            shared.FlyHandler:Disconnect()
            for _, c in pairs(Camera:GetChildren()) do
                if (c.Name == "Foutline") then
                    if (Foutline ~= c) then
                        Debris:AddItem(c, 0.6)
                    end
                    TweenService:Create(Foutline, TweenInfo.new(0.6), {
                        OutlineTransparency = 1,
                        FillTransparency = 1,
                    }):Play()
                end
            end
        else
            FlySpeed = 50;
            shared.FlyHandler = RunService.RenderStepped:Connect(function()
                local Character = Player.Character;
                if (Character == nil) then return end
                Foutline.Adornee = Character
                Foutline.FillTransparency = 0.5
                Foutline.OutlineTransparency = 0.5
                local Torso = Character:FindFirstChild("HumanoidRootPart");
                if (Torso == nil) then return end
                local Humanoid = Character:FindFirstChildWhichIsA("Humanoid");
                if (Humanoid ~= nil) and (Humanoid.PlatformStand) and (game.GameId == 1359573625) then
                    keypress(0x30)
                    keyrelease(0x30)
                end
                local Control = { F = 0, B = 0, L = 0, R = 0 }
                for k, v in pairs(FlyDirections) do
                    if (UserInputService:IsKeyDown(k)) then
                        Control[v[1]] = v[2];
                    end
                end
                if (Control.L + Control.R ~= 0) or (Control.F + Control.B ~= 0) then
                    FlySpeed = MaxFlySpeed
                elseif (((Control.L + Control.R == 0) or (Control.F + Control.B == 0)) and FlySpeed ~= 0) then
                    FlySpeed = 0
                end
                local DirectionCF = Camera.CFrame;
                if ((Control.L + Control.R) ~= 0) or ((Control.F + Control.B) ~= 0) then
                    Torso.Velocity = ((DirectionCF.LookVector * (Control.F + Control.B)) + ((DirectionCF * CFrame.new(Control.L + Control.R, ((Control.F + Control.B) * 0.2), 0).Position) - DirectionCF.Position)) * FlySpeed;
                    LastControl = table.clone(Control);
                elseif ((Control.L + Control.R) == 0) and ((Control.F + Control.B) == 0) and (FlySpeed ~= 0) then
                    Torso.Velocity = ((DirectionCF.LookVector * (LastControl.F + LastControl.B)) + ((DirectionCF * CFrame.new(LastControl.L + LastControl.R, ((LastControl.F + LastControl.B) * 0.2), 0).Position) - DirectionCF.Position)) * FlySpeed;
                else
                    Torso.Velocity = Vector3.new(0, 2, 0)
                end
            end)
        end
    end
end)
