--[[
    designed for deepwoken lol!
    - tk
    
    toggle with F2
--]]

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

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

if (shared.flyinput) then shared.flyinput:Disconnect() end
shared.flyinput = UserInputService.InputBegan:Connect(function(input, gpe)
    if (gpe) then return end
    if (input.KeyCode == Enum.KeyCode.F2) then
        Flying = not Flying;
        if (not Flying) then
            LastControl = { F = 0, B = 0, L = 0, R = 0 }
            shared.FlyHandler:Disconnect()
        else
            FlySpeed = 50;
            shared.FlyHandler = RunService.RenderStepped:Connect(function()
                local Character = Player.Character;
                if (Character == nil) then return end
                local Torso = Character:FindFirstChild("HumanoidRootPart");
                if (Torso == nil) then return end
                local Control = { F = 0, B = 0, L = 0, R = 0 }
                for k, v in pairs(FlyDirections) do
                    if (UserInputService:IsKeyDown(k)) then
                        Control[v[1]] = v[2];
                    end
                end
                if (Control.L + Control.R ~= 0) or (Control.F + Control.B ~= 0) then
                    FlySpeed = math.min(FlySpeed + 0.5 + (FlySpeed / MaxFlySpeed), 200)
                elseif (((Control.L + Control.R == 0) or (Control.F + Control.B == 0)) and FlySpeed ~= 0) then
                    FlySpeed = math.max(FlySpeed - 5, 0);
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
