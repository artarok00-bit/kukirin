-- [[ БЕСКОНЕЧНАЯ ПЛАТФОРМА — v1.0 ]]
-- Создает платформу под ногами и удерживает на ней персонажа

local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local PlatformActive = false
local Platform = nil
local HeartbeatConn = nil
local PlatformHeight = 3 -- Высота над землей

-- ===== GUI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PlatformGUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 200, 0, 50)
ToggleBtn.Position = UDim2.new(0.5, -100, 0.5, -25)
ToggleBtn.Text = "ПЛАТФОРМА: ВЫКЛ"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 16
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)

-- ===== СОЗДАНИЕ ПЛАТФОРМЫ =====
local function CreatePlatform()
    if Platform then Platform:Destroy() end
    
    Platform = Instance.new("Part")
    Platform.Name = "InfinitePlatform"
    Platform.Size = Vector3.new(500, 1, 500) -- Огромная, чтобы казалась бесконечной
    Platform.Anchored = false -- Не anchored, чтобы двигать
    Platform.CanCollide = true
    Platform.Transparency = 0.8 -- Полупрозрачная, чтобы видеть, где стоишь
    Platform.Color = Color3.fromRGB(0, 255, 255)
    Platform.Material = Enum.Material.Neon
    Platform.Parent = workspace
    
    -- Привязываем к персонажу, чтобы не улетала
    local Weld = Instance.new("WeldConstraint")
    Weld.Part0 = Platform
    Weld.Part1 = Player.Character.HumanoidRootPart
    Weld.Parent = Platform
end

-- ===== ВКЛЮЧЕНИЕ =====
local function EnablePlatform()
    if not Player.Character then return end
    PlatformActive = true
    ToggleBtn.Text = "ПЛАТФОРМА: ВКЛ"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    
    CreatePlatform()
    
    -- Цикл удержания
    if HeartbeatConn then HeartbeatConn:Disconnect() end
    HeartbeatConn = RunService.Heartbeat:Connect(function()
        if not PlatformActive or not Platform then return end
        local char = Player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        -- Ставим платформу ровно под ноги (с учетом высоты)
        Platform.CFrame = CFrame.new(root.Position - Vector3.new(0, PlatformHeight, 0))
        
        -- Удерживаем игрока на платформе (чтобы не скользил и не падал)
        -- Это предотвращает падение, если платформа уходит из-под ног
        root.Velocity = Vector3.new(0, 0, 0) -- Гасим падение
    end)
end

-- ===== ВЫКЛЮЧЕНИЕ =====
local function DisablePlatform()
    PlatformActive = false
    ToggleBtn.Text = "ПЛАТФОРМА: ВЫКЛ"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    
    if HeartbeatConn then
        HeartbeatConn:Disconnect()
        HeartbeatConn = nil
    end
    
    if Platform then
        Platform:Destroy()
        Platform = nil
    end
end

-- ===== КНОПКА =====
ToggleBtn.MouseButton1Click:Connect(function()
    if PlatformActive then
        DisablePlatform()
    else
        EnablePlatform()
    end
end)

-- ===== ОБНОВЛЕНИЕ ПРИ РЕСПАВНЕ =====
Player.CharacterAdded:Connect(function()
    if PlatformActive then
        DisablePlatform()
        task.wait(0.5)
        EnablePlatform()
    end
end)

print("✅ Платформа загружена")
