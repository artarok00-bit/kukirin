-- [[ ARTARIO HUB — ПЛАТФОРМА + СТАНТ + АНТИ-АФК ]]
-- Разработчик: artar

local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- ===== ДАННЫЕ ПЛАТФОРМЫ =====
local PlatformActive = false
local Platform = nil
local HeartbeatConn = nil
local ChunkSize = 2048
local PlatformHeight = 500
local SpawnOffsetY = 6.0 

-- ===== ДАННЫЕ СТАНТА =====
local autoWheelieActive = false

-- ===== GUI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ArtarioPlatformHub"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 240) -- 🔥 УВЕЛИЧИЛИ ВЫСОТУ (было 220)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(40, 30, 30)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.Text = "ARTARIO HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Parent = TopBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -75, 0.15, 0)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.TextSize = 18
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0.15, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.TextSize = 18
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -40)
Content.Position = UDim2.new(0, 0, 0, 40)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local TogglePlatformBtn = Instance.new("TextButton")
TogglePlatformBtn.Size = UDim2.new(0.9, 0, 0, 45)
TogglePlatformBtn.Position = UDim2.new(0.05, 0, 0.05, 0) -- Чуть подняли
TogglePlatformBtn.Text = "ВКЛЮЧИТЬ ПЛАТФОРМУ"
TogglePlatformBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TogglePlatformBtn.TextSize = 14
TogglePlatformBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
TogglePlatformBtn.Font = Enum.Font.GothamBold
TogglePlatformBtn.Parent = Content
Instance.new("UICorner", TogglePlatformBtn).CornerRadius = UDim.new(0, 8)

local ToggleStuntBtn = Instance.new("TextButton")
ToggleStuntBtn.Size = UDim2.new(0.9, 0, 0, 45)
ToggleStuntBtn.Position = UDim2.new(0.05, 0, 0.35, 0) -- Чуть подняли
ToggleStuntBtn.Text = "СТАНТ: ВЫКЛ"
ToggleStuntBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleStuntBtn.TextSize = 14
ToggleStuntBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleStuntBtn.Font = Enum.Font.GothamBold
ToggleStuntBtn.Parent = Content
Instance.new("UICorner", ToggleStuntBtn).CornerRadius = UDim.new(0, 8)

-- 🔥 НОВАЯ НАДПИСЬ ВНИЗУ
local AntiAfkLabel = Instance.new("TextLabel")
AntiAfkLabel.Size = UDim2.new(1, 0, 0, 25)
AntiAfkLabel.Position = UDim2.new(0, 0, 1, -25) -- Самый низ
AntiAfkLabel.Text = "🟢 Анти-АФК включено"
AntiAfkLabel.TextColor3 = Color3.fromRGB(150, 150, 150) -- Серый, чтобы не отвлекать
AntiAfkLabel.TextSize = 11
AntiAfkLabel.Font = Enum.Font.Gotham
AntiAfkLabel.BackgroundTransparency = 1
AntiAfkLabel.Parent = MainFrame


-- ===== ЛОГИКА ПЛАТФОРМЫ =====
local function DisablePlatform()
    PlatformActive = false
    TogglePlatformBtn.Text = "ВКЛЮЧИТЬ ПЛАТФОРМУ"
    TogglePlatformBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    if HeartbeatConn then HeartbeatConn:Disconnect() HeartbeatConn = nil end
    if Platform then Platform:Destroy() Platform = nil end
end

local function CreatePlatform()
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local RootPart = Character:WaitForChild("HumanoidRootPart")
    if Platform then Platform:Destroy() end
    
    Platform = Instance.new("Part")
    Platform.Name = "InfinitePlatform"
    Platform.Size = Vector3.new(ChunkSize, 5, ChunkSize)
    Platform.Anchored = true
    Platform.CanCollide = true
    Platform.Transparency = 0.5
    Platform.Color = Color3.fromRGB(0, 255, 255)
    Platform.Material = Enum.Material.Neon
    
    local TargetPos = Vector3.new(RootPart.Position.X, PlatformHeight, RootPart.Position.Z)
    Platform.Position = TargetPos
    Platform.Parent = workspace
    RootPart.CFrame = CFrame.new(Vector3.new(TargetPos.X, TargetPos.Y + SpawnOffsetY, TargetPos.Z))
    
    if HeartbeatConn then HeartbeatConn:Disconnect() end
    HeartbeatConn = RunService.Heartbeat:Connect(function()
        if not PlatformActive or not Platform then return end
        local char = Player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local half = ChunkSize / 2
        local rootPos = root.Position
        local platPos = Platform.Position
        if math.abs(rootPos.X - platPos.X) > (half - 100) or math.abs(rootPos.Z - platPos.Z) > (half - 100) then
            local newX = math.floor(rootPos.X / ChunkSize + 0.5) * ChunkSize
            local newZ = math.floor(rootPos.Z / ChunkSize + 0.5) * ChunkSize
            Platform.Position = Vector3.new(newX, PlatformHeight, newZ)
        end
    end)
end

local function EnablePlatform()
    PlatformActive = true
    TogglePlatformBtn.Text = "ВЫКЛЮЧИТЬ ПЛАТФОРМУ"
    TogglePlatformBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    CreatePlatform()
end

-- ===== ЛОГИКА СТАНТА =====
local function getScooterPitch()
   local char = Player.Character
   if char and char:FindFirstChild("HumanoidRootPart") then
      local hrp = char.HumanoidRootPart
      local lookVector = hrp.CFrame.LookVector
      return math.deg(math.asin(lookVector.Y))
   end
   return 0
end

local function startAutoWheelie()
   task.spawn(function()
      while autoWheelieActive do
         task.wait(0.015)
         local pitch = getScooterPitch()
         if pitch > 42 then
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.S, false, game)
            task.wait(0.04)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.S, false, game)
         else
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
            task.wait(0.18)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
         end
      end
      VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
      VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
      VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.S, false, game)
   end)
end

local function ToggleStunt()
    autoWheelieActive = not autoWheelieActive
    if autoWheelieActive then
        ToggleStuntBtn.Text = "СТАНТ: ВКЛ"
        ToggleStuntBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        startAutoWheelie()
    else
        ToggleStuntBtn.Text = "СТАНТ: ВЫКЛ"
        ToggleStuntBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end

-- ===== КНОПКИ =====
TogglePlatformBtn.MouseButton1Click:Connect(function()
    if PlatformActive then DisablePlatform() else EnablePlatform() end
end)
ToggleStuntBtn.MouseButton1Click:Connect(ToggleStunt)

local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Content.Visible = not minimized
    AntiAfkLabel.Visible = not minimized -- Прячем надпись при сворачивании
    MinimizeBtn.Text = minimized and "+" or "—"
    MainFrame.Size = minimized and UDim2.new(0, 320, 0, 40) or UDim2.new(0, 320, 0, 240) -- Не забываем обновить размер
end)

CloseBtn.MouseButton1Click:Connect(function()
    autoWheelieActive = false
    DisablePlatform()
    ScreenGui:Destroy()
end)

Player.CharacterAdded:Connect(function()
    if PlatformActive then
        DisablePlatform()
        task.wait(1)
        EnablePlatform()
    end
end)

print("✅ ARTARIO HUB (со Стантом и Анти-АФК) загружен")
