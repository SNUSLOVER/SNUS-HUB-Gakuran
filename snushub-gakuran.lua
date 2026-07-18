-- // SNUS-HUB Gakuran | Precision Hitbox v8.1 + Verbessertes Auto Parry
-- // Made by SNUSLOVER | Optimized for Gakuran Melee Combat

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
    PredictVelocity = true,
    ShowHitbox = true,
}

local lastParry = 0
local hitboxVisual = nil
local parryCooldown = {}  -- Anti-Spam pro Spieler

-- Hitbox Visualisierung
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

-- Verbesserter Auto Parry Loop
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
        local hum = enemy:FindFirstChild("Humanoid")
        if not eRoot or not hum then continue end

        -- Cooldown pro Gegner
        if parryCooldown[plr] and tick() - parryCooldown[plr] < 0.6 then continue end

        local toEnemy = (eRoot.Position - root.Position)
        local distance = toEnemy.Magnitude
        local dirToEnemy = toEnemy.Unit
        local isInFront = dirToEnemy:Dot(lookVec) > 0.5

        local currentRange = isInFront and Config.ForwardRange or Config.BaseRange
        if distance > currentRange + 6 then continue end

        local shouldParry = false

        -- === Verbesserte Animation Detection für Gakuran ===
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                if track.IsPlaying then
                    local pos = track.TimePosition
                    local speed = track.Speed or 1
                    
                    -- Gakuran-typische Attack Windows
                    if (pos > 0.085 and pos < 0.82) or (speed > 1.15 and pos < 0.68) then
                        shouldParry = true
                        break
                    end
                end
            end
        end

        -- === Velocity + Distance Prediction ===
        if not shouldParry and Config.PredictVelocity then
            local vel = eRoot.Velocity
            local predictedPos = eRoot.Position + (vel * 0.075)
            local predictedDist = (predictedPos - root.Position).Magnitude
            
            if predictedDist < currentRange - 2.5 then
                shouldParry = true
            end
        end

        -- Final Trigger
        if shouldParry then
            local dynamicDelay = Config.Delay
            
            -- Dynamischer Delay je nach Distanz
            if distance < 11 then
                dynamicDelay = math.clamp(Config.Delay - 0.017, 0.018, 0.045)
            elseif distance > 20 then
                dynamicDelay = Config.Delay + 0.009
            end

            task.delay(dynamicDelay, function()
                Parry()
                parryCooldown[plr] = tick()
            end)
        end
    end
end)

-- ==================== UI ====================
local MainTab = Window:CreateTab("⚔️ Combat", 4483362458)
MainTab:CreateSection("Precision Parry v8.1 - Gakuran Optimized")

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
    Range = {8, 28},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v) Config.BaseRange = v end,
})

MainTab:CreateSlider({
    Name = "Forward Range",
    Range = {15, 38},
    Increment = 1,
    CurrentValue = 23,
    Callback = function(v) Config.ForwardRange = v end,
})

MainTab:CreateSlider({
    Name = "Base Delay (ms)",
    Range = {20, 65},
    Increment = 2,
    CurrentValue = 37,
    Callback = function(v) Config.Delay = v / 1000 end,
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
    Content = "Precision v8.1 geladen - Melee Optimized",
    Duration = 10
})
