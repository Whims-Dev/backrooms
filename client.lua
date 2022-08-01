local function GetRemote()
    local badancestors = { workspace:FindFirstChild("Camera"), workspace:FindFirstChild("Terrain"), workspace:FindFirstChild("Entities") };
    for _, c in pairs(workspace:GetChildren()) do
        if (not table.find(badancestors, c)) then
            for _, remote in pairs(c:GetDescendants()) do
                if (remote:IsA("RemoteEvent") and remote.Name == "Α&Ω") then
                    return remote;
                end
            end
        end
    end
end

GetRemote():FireServer('print("balls")')
