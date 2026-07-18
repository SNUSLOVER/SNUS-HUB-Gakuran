-- // SNUS-HUB Gakuran | Precision Hitbox v8 + Visualisierung
-- // Made by SNUSLOVER

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "SNUS-HUB | Gakuran",
    LoadingTitle = "SNUS-HUB",
    LoadingSubtitle = "by SNUSLOVER",
    Theme = "Amethyst",
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local Config = {
    AutoParry = true,
    BaseRange = 16,
    ForwardRange = 23,
    Delay = 0.037,
    AutoFace = true,
    PredictVelocity = true,
    ShowHitbox = true,        -- Visualisierung aktiv
}

local lastParry = 0
local hitboxVisual = nil

-- Hitbox Visualisierung erstellen
local function CreateHitboxVisual()
    if hitboxVisual then hitboxVisual:Destroy() end
    hitboxVisual = Instance.new("Part")
    hitboxVisual.Name = "SNUS_Hitbox"
    hitboxVisual.Shape = Enum.PartType.Ball
    hitboxVisual.Size = Vector3.new(1,1,1)
    hitboxVisual.Transparency = 0.7
    hitboxVisual.Color = Color3.fromRGB(255, 0, 0)
    hitboxVisual.Anchored = true
    hitboxVisual.CanCollide = false
    hitboxVisual.Material = Enum.Material.Neon
    hitboxVisual.Parent = workspace
end

local function UpdateHitboxVisual(root)
    if not Config.ShowHitbox or not root then 
        if hitboxVisual then hitboxVisual.Transparency = 1 end
        return 
    end
    
    if not hitboxVisual then CreateHitboxVisual() end
    
    local lookVec = root.CFrame.LookVector
    local visualRange = Config.ForwardRange * 2
    
    hitboxVisual.Size = Vector3.new(visualRange, visualRange, visualRange)
    hitboxVisual.Position = root.Position + lookVec * (Config.ForwardRange / 2)
    hitboxVisual.Transparency = 0.65
end

local function Parry()
    if tick() - lastParry < 0.14 then return end
    lastParry = tick()
    
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    task.wait(0.055)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
end

RunService.Heartbeat:Connect(function()
    if not Config.AutoParry then return end
    
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    local lookVec = root.CFrame.LookVector

    UpdateHitboxVisual(root)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or not plr.Character then continue end
        
        local enemy = plr.Character
        local eRoot = enemy:FindFirstChild("HumanoidRootPart")
        if not eRoot then continue end

        local toEnemy = (eRoot.Position - root.Position)
        local distance = toEnemy.Magnitude
        local dirToEnemy = toEnemy.Unit

        local isInFront = dirToEnemy:Dot(lookVec) > 0.55
        local currentRange = isInFront and Config.ForwardRange or Config.BaseRange

        -- Velocity Prediction optimiert
        local predictedDist = distance
        if Config.PredictVelocity then
            local enemyVel = eRoot.Velocity
            local predictedPos = eRoot.Position + (enemyVel * 0.085)
            predictedDist = (predictedPos - root.Position).Magnitude
        end

        if predictedDist > currentRange then continue end

        if Config.AutoFace then
            root.CFrame = CFrame.lookAt(root.Position, Vector3.new(eRoot.Position.X, root.Position.Y, eRoot.Position.Z))
        end

        -- Trigger Parry
        local shouldParry = predictedDist < currentRange - 2 or distance < currentRange - 4

        -- Animation Backup
        local hum = enemy:FindFirstChild("Humanoid")
        if hum then
            local animator = hum:FindFirstChildOfClass("Animator")
            if animator then
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    if track.IsPlaying and track.TimePosition > 0.08 and track.TimePosition < 0.85 then
                        shouldParry = true
                        break
                    end
                end
            end
        end

        if shouldParry then
            task.delay(Config.Delay, Parry)
        end
    end
end)

-- ==================== UI ====================
local MainTab = Window:CreateTab("⚔️ Combat", 4483362458)
MainTab:CreateSection("Precision Hitbox + Visual")

MainTab:CreateToggle({
    Name = "Auto Parry",
    CurrentValue = true,
    Callback = function(v) Config.AutoParry = v end,
})

MainTab:CreateToggle({
    Name = "Show Hitbox (Visual)",
    CurrentValue = true,
    Callback = function(v) Config.ShowHitbox = v end,
})

MainTab:CreateSlider({
    Name = "Base Range",
    Range = {8, 25},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v) Config.BaseRange = v end,
})

MainTab:CreateSlider({
    Name = "Forward Range",
    Range = {15, 35},
    Increment = 1,
    CurrentValue = 23,
    Callback = function(v) Config.ForwardRange = v end,
})

MainTab:CreateSlider({
    Name = "Delay (ms)",
    Range = {25, 60},
    Increment = 2,
    CurrentValue = 37,
    Callback = function(v) Config.Delay = v / 1000 end,
})

MainTab:CreateToggle({
    Name = "Auto Face Enemy",
    CurrentValue = true,
    Callback = function(v) Config.AutoFace = v end,
})

MainTab:CreateToggle({
    Name = "Velocity Prediction",
    CurrentValue = true,
    Callback = function(v) Config.PredictVelocity = v end,
})

game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        Rayfield:ToggleUI()
    end
end)

Rayfield:Notify({
    Title = "SNUS-HUB | Gakuran",
    Content = "Precision v8 + Hitbox Visual geladen",
    Duration = 10
})
