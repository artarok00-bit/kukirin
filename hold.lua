-- [[ БОЛЬШАЯ ПЛАТФОРМА НА ВЫСОТЕ — v1.1 ]]
-- Создает платформу на высоте и телепортирует на неё

local Player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local PlatformActive = false
local Platform = nil
local PlatformHeight = 500 -- Высота в небе
local PlatformSize = 100 -- Размер (100x100)

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
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local RootPart = Character:WaitForChild("HumanoidRootPart")

    if Platform then Platform:Destroy() end
    
    -- Создаем платформу
    Platform = Instance.new("Part")
    Platform.Name = "HighPlatform"
    Platform.Size = Vector3.new(PlatformSize, 2, PlatformSize)
    Platform.Anchored = true
    Platform.CanCollide = true
    Platform.Transparency = 0.3
    Platform.Color = Color3.fromRGB(0, 255, 255)
    Platform.Material = Enum.Material.Neon
    
    -- Ставим её на заданной высоте под игроком
    local TargetPos = Vector3.new(RootPart.Position.X, PlatformHeight, RootPart.Position.Z)
    Platform.Position = TargetPos
    
    Platform.Parent = workspace
    
    -- Телепортируем игрока на платформу (чуть выше поверхности)
    RootPart.CFrame = CFrame.new(TargetPos + Vector3.new(0, 5, 0))
end

-- ===== ВКЛЮЧЕНИЕ =====
local function EnablePlatform()
    PlatformActive = true
    ToggleBtn.Text = "ПЛАТФОРМА: ВКЛ"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    
    CreatePlatform()
end

-- ===== ВЫКЛЮЧЕНИЕ =====
local function DisablePlatform()
    PlatformActive = false
    ToggleBtn.Text = "ПЛАТФОРМА: ВЫКЛ"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    
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
        task.wait(1) -- Ждем прогрузки
        EnablePlatform()
    end
end)

print("✅ Платформа на высоте загружена")
