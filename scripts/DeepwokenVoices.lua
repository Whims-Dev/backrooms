local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local Player = Players.LocalPlayer

local MoveSounds = {
    -- Medium
    ["Master's Flourish"] = {4729774926, 1, 1},
    -- Strength
    ["Rapid Punches"] = {6995604483, 1, 2},
    ["Strong Left"] = {5205486984, 1, 2},
    -- Starkindred
    ["Ascension"] = {2404991944, 1, 2},
    ["Sinister Halo"] = {3714683219, 1, 1},
    -- Flamecharm
    ["Fire Blade"] = {2390708317, 1, 0.8},
    ["Flame Grab"] = {877368576, 1, 1},
    -- Shadowcast
    ["Dark Blade"] = {6945516323, 1, 1},
    ["Shadow Eruption"] = {5535518052, 1, 1},
    ["Shadow Gun"] = {877368576, 1, 1},
};

local function CreateSound(Parent, Id, Pitch, Volume)
    local Sound = Instance.new("Sound")
    Sound.Volume = (Volume or 1)
    Sound.PlaybackSpeed = (Pitch or 1)
    Sound.SoundId = (tonumber(Id) and ("rbxassetid://".. Id) or Id)
    Sound.Parent = Parent
    if (not Sound.IsLoaded) then
        Sound.Loaded:Wait()
    end
    Sound:Play()
    Debris:AddItem(Sound, Sound.TimeLength)
end

local function NewSharedConnection(Name, Connection)
    if (shared[Name]) then shared[Name]:Disconnect() end
    shared[Name] = Connection;
end

local function NewCharacter(Character)
    if (Players:GetPlayerFromCharacter(Character) == Player) then
        NewSharedConnection("CharacterAddedDsounds", Character.ChildAdded:Connect(function(t)
            if (t:IsA("Tool")) then
                for i, v in pairs(MoveSounds) do
                    if (string.match(t.Name, i)) then
                        CreateSound(Character.Head, table.unpack(v))
                    end
                end
            end
        end))
    end
end

NewSharedConnection("PlayerAddedDsounds", workspace.Live.ChildAdded:Connect(NewCharacter))
if (Player.Character) then
    NewCharacter(Player.Character)
end
