local ESP_SETTINGS = {
    ChamsColor = Color3.fromRGB(255, 152, 220),  -- Customize your color here
    Teamcheck = false,   -- Only show ESP for enemy teams if true
    playerChams = false,  -- Change to true to enable player Chams (highlight players)
    glowChamsEnabled = false,  -- Change to true to enable glow around Chams
    boxEspEnabled = true, -- Change to true to enable box ESP around players
}

local function isValidSurface(part)
    return part:IsA("BasePart") and
           part.Name ~= "HumanoidRootPart" and
           part.Parent ~= game.Players.LocalPlayer.Character
end

local function destroyBoxHandleAdornment(part)
    if not isValidSurface(part) then
        return
    end

    if part:FindFirstChild("BoxHandleAdornment") and part:FindFirstChild("BoxHandleAdornment").Name ~= "InvisGlowChams" and part:FindFirstChild("BoxHandleAdornment").Name ~= "GlowChams" then
        part.BoxHandleAdornment:Destroy()
    end
end

local function createBoxHandleAdornment(part)
    if not isValidSurface(part) then
        return
    end

    local boxHandleAdornment = Instance.new("BoxHandleAdornment")
    boxHandleAdornment.Size = part.Size + Vector3.new(0.01, 0.01, 0.01)
    boxHandleAdornment.Color3 = ESP_SETTINGS.ChamsColor
    boxHandleAdornment.AlwaysOnTop = true
    boxHandleAdornment.Adornee = part
    boxHandleAdornment.ZIndex = 10
    boxHandleAdornment.Parent = part
end

local function applyChams()
    while true do
        wait(1)
        if ESP_SETTINGS.playerChams then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player then
                    if player.Character then
                        if ESP_SETTINGS.Teamcheck and player.Team == game.Players.LocalPlayer.Team then
                            continue
                        end
                        for _, part in pairs(player.Character:GetChildren()) do
                            if not part:FindFirstChild("BoxHandleAdornment") then
                                createBoxHandleAdornment(part)
                            end
                        end
                    end
                end
            end
        else
            for _, player in pairs(game.Players:GetPlayers()) do
                if player then
                    if player.Character then
                        for _, part in pairs(player.Character:GetChildren()) do
                            destroyBoxHandleAdornment(part)
                        end
                    end
                end
            end
        end
    end
end

coroutine.wrap(applyChams)()

local function addHighlight(model)
    if model then
        local highlight = Instance.new("Highlight")
        highlight.FillColor = Color3.fromRGB(239, 21, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.fromRGB(215, 147, 255)
        highlight.OutlineTransparency = 0.5
        highlight.Parent = model
    end
end

local function removeHighlight(model)
    if model then
        if model:FindFirstChild("Highlight") then
            model.Highlight:Destroy()
        end
    end
end

local function addItemEsp(part, name)
    if part then
        local billboard = Instance.new("BillboardGui")
        billboard.AlwaysOnTop = true
        billboard.Name = "ItemEsp"
        billboard.Parent = part
        billboard.Size = UDim2.new(1, 0, 1, 0)
        local textLabel = Instance.new("TextLabel")
        textLabel.BackgroundTransparency = 1
        textLabel.RichText = true
        textLabel.TextSize = 8
        textLabel.TextColor3 = Color3.fromRGB(255, 170, 33)
        textLabel.Text = part.Name
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.Parent = billboard

        if name and name ~= nil then
            textLabel.Text = tostring(name)
        end
    end
end

local function removeItemEsp(model)
    if model then
        if model:FindFirstChild("ItemEsp") then
            model.ItemEsp:Destroy()
        end
    end
end

local function addNpcName(model, name)
    if model then
        if model:FindFirstChild("Head") then
            local billboard = Instance.new("BillboardGui")
            billboard.AlwaysOnTop = true
            billboard.StudsOffset = Vector3.new(0, 1.25, 0)
            billboard.Size = UDim2.new(1, 0, 1, 0)
            billboard.Name = "NameEsp"
            billboard.Parent = model.Head
            local textLabel = Instance.new("TextLabel")
            textLabel.BackgroundTransparency = 1
            textLabel.RichText = true
            textLabel.TextSize = 14
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            textLabel.Font = Enum.Font.Highway
            textLabel.Size = UDim2.new(1, 0, 0.2, 0)
            textLabel.TextStrokeTransparency = 0
            textLabel.TextStrokeColor3 = Color3.fromRGB(255, 0, 200)
            textLabel.TextScaled = false
            textLabel.Parent = billboard

            if name and name ~= nil then
                textLabel.Text = name
            else
                textLabel.Text = model.Name
            end

            if model:FindFirstChild("Humanoid") then
                model.Humanoid.HealthDisplayDistance = 0
                model.Humanoid.DisplayDistanceType = "None"
            end
        else
            warn("No Head Part Found For: " .. model.Name)
        end
    end
end

local function removeNpcName(model)
    if model then
        if model:FindFirstChild("Head") then
            if model:FindFirstChild("Head"):FindFirstChild("NameEsp") then
                model.Head.NameEsp:Destroy()
            end
        end
    end
end

local function addNpcChams(model)
    if model then
        for _, part in pairs(model:GetChildren()) do
            if isValidSurface(part) and not part:FindFirstChild("BoxHandleAdornment") then
                createBoxHandleAdornment(part)
            end
        end
    end
end

local function removeNpcChams(model)
    if model then
        for _, part in pairs(model:GetChildren()) do
            if isValidSurface(part) then
                if part:FindFirstChild("BoxHandleAdornment") then
                    part.BoxHandleAdornment:Destroy()
                end
            end
        end
    end
end

local activeBoxes = {}

local function updateBoxes()
    while true do
        wait(0.15)
        for model, boxes in pairs(activeBoxes) do
            for _, box in pairs(boxes) do
                if box and box.Parent and game.Workspace.CurrentCamera then
                    local part = box.Adornee
                    local rayDirection = (part.Position - game.Workspace.CurrentCamera.CFrame.Position).unit * 1000

                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
                    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

                    local raycastResult = game.Workspace:Raycast(game.Workspace.CurrentCamera.CFrame.Position, rayDirection, raycastParams)

                    if raycastResult and raycastResult.Instance:IsDescendantOf(model) then
                        box.Transparency = 1
                    else
                        box.Transparency = 0
                    end
                end
            end
        end
    end
end

local activeGlowChams = {}

local function addGlowChams(model)
    for _, part in pairs(model:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local glowPart = Instance.new("Part")

            if part.Name == "Handle" then
                continue
            end

            if part.Name ~= "Head" then
                glowPart.Size = part.Size * 1.15
                glowPart.CFrame = part.CFrame
                glowPart.Transparency = 0.2
                glowPart.Material = Enum.Material.Neon
                glowPart.Color = Color3.fromRGB(255, 255, 255)
                glowPart.Anchored = false
                glowPart.CanCollide = false
                glowPart.Name = "GlowCHams"
                glowPart.Parent = part

                local outline = Instance.new("BoxHandleAdornment")
                outline.Size = part.Size
                outline.Transparency = 0.4
                outline.Color3 = Color3.fromRGB(255, 152, 22)
                outline.Name = "Outline"
                outline.Parent = part
                outline.ZIndex = 10
                outline.Adornee = part
                outline.AlwaysOnTop = true
                table.insert(activeGlowChams, glowPart)
                table.insert(activeGlowChams, outline)
            end

            if part.Name == "Head" then
                local outline = Instance.new("CylinderHandleAdornment")
                outline.Transparency = 0.4
                outline.Color3 = Color3.fromRGB(255, 152, 22)
                outline.Name = "Outline"
                outline.ZIndex = 10
                outline.Adornee = part
                outline.AlwaysOnTop
