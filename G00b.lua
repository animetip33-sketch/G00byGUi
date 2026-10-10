local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Удаляем старое гуи
if PlayerGui:FindFirstChild("G00byExecutorMenu_v2") then
    PlayerGui["G00byExecutorMenu_v2"]:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "G00byExecutorMenu_v2"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Обводка
local function addBorder(parent)
    local border = Instance.new("UIStroke")
    border.Color = Color3.fromRGB(0, 100, 0)
    border.Thickness = 2
    border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    border.Parent = parent
    return border
end

-- Drag
local function makeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ======================
-- СОХРАНЕНИЕ ЧЕРЕЗ getgenv (работает в Velocity)
-- ======================
local function loadData()
    if getgenv().G00byAuthSave then
        return getgenv().G00byAuthSave
    end
    return {username = "", password = "", mode = "Старый"}
end

local function saveData(username, password, mode)
    getgenv().G00byAuthSave = {
        username = username or "",
        password = password or "",
        mode = mode or "Старый"
    }
end

local savedAuth = loadData()

-- ==========================================
-- ПАНЕЛЬ АВТОРИЗАЦИИ
-- ==========================================
local AuthFrame = Instance.new("Frame")
AuthFrame.Size = UDim2.new(0, 320, 0, 320)
AuthFrame.Position = UDim2.new(0.5, -160, 0.5, -160)
AuthFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
AuthFrame.BorderSizePixel = 0
AuthFrame.Parent = ScreenGui
addBorder(AuthFrame)
makeDraggable(AuthFrame, AuthFrame)

local AuthTitle = Instance.new("TextLabel")
AuthTitle.Size = UDim2.new(1, 0, 0, 35)
AuthTitle.BackgroundTransparency = 1
AuthTitle.Text = "Авторизация G00b"
AuthTitle.TextColor3 = Color3.fromRGB(0, 200, 0)
AuthTitle.TextSize = 18
AuthTitle.Font = Enum.Font.SourceSansBold
AuthTitle.Parent = AuthFrame

local CloseBtn1 = Instance.new("TextButton")
CloseBtn1.Size = UDim2.new(0, 30, 0, 30)
CloseBtn1.Position = UDim2.new(1, -33, 0, 3)
CloseBtn1.BackgroundTransparency = 1
CloseBtn1.Text = "X"
CloseBtn1.TextColor3 = Color3.fromRGB(200, 0, 0)
CloseBtn1.TextSize = 18
CloseBtn1.Font = Enum.Font.SourceSansBold
CloseBtn1.Parent = AuthFrame
CloseBtn1.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local function createAuthInput(placeholder, yOffset)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 240, 0, 35)
    box.Position = UDim2.new(0.5, -120, 0, yOffset)
    box.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderText = placeholder
    box.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    box.Text = ""
    box.TextSize = 14
    box.Font = Enum.Font.SourceSans
    box.Parent = AuthFrame
    addBorder(box)
    return box
end

local KeyInput = createAuthInput("Введите ключ (g00b)...", 50)
local UserInput = createAuthInput("Никнейм...", 95)
local PassInput = createAuthInput("Пароль...", 140)
PassInput.TextPassword = true

UserInput.Text = savedAuth.username or ""
PassInput.Text = savedAuth.password or ""

local ModeInput = Instance.new("TextBox")
ModeInput.Size = UDim2.new(0, 240, 0, 35)
ModeInput.Position = UDim2.new(0.5, -120, 0, 185)
ModeInput.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ModeInput.TextColor3 = Color3.fromRGB(0, 180, 0)
ModeInput.Text = savedAuth.mode or "Старый"
ModeInput.TextSize = 14
ModeInput.Font = Enum.Font.SourceSansBold
ModeInput.ClearTextOnFocus = false
ModeInput.Parent = AuthFrame
addBorder(ModeInput)

ModeInput.Focused:Connect(function()
    ModeInput.Text = (ModeInput.Text == "Старый") and "Новый" or "Старый"
    ModeInput:ReleaseFocus()
end)

local EnterBtn = Instance.new("TextButton")
EnterBtn.Size = UDim2.new(0, 120, 0, 40)
EnterBtn.Position = UDim2.new(0.5, -60, 0, 245)
EnterBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
EnterBtn.TextColor3 = Color3.fromRGB(0, 200, 0)
EnterBtn.Text = "Enter"
EnterBtn.TextSize = 16
EnterBtn.Font = Enum.Font.SourceSansBold
EnterBtn.Parent = AuthFrame
addBorder(EnterBtn)

-- ==========================================
-- ГЛАВНАЯ ПАНЕЛЬ
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 340)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
addBorder(MainFrame)
makeDraggable(MainFrame, MainFrame)

local MainTitle = Instance.new("TextLabel")
MainTitle.Size = UDim2.new(1, 0, 0, 30)
MainTitle.BackgroundTransparency = 1
MainTitle.Text = "G00by Menu"
MainTitle.TextColor3 = Color3.fromRGB(0, 200, 0)
MainTitle.TextSize = 18
MainTitle.Font = Enum.Font.SourceSansBold
MainTitle.Parent = MainFrame

local CloseBtn2 = CloseBtn1:Clone()
CloseBtn2.Parent = MainFrame
CloseBtn2.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Аватар + ник
local ProfileFrame = Instance.new("Frame")
ProfileFrame.Size = UDim2.new(0, 90, 0, 110)
ProfileFrame.Position = UDim2.new(0, 5, 1, -115)
ProfileFrame.BackgroundTransparency = 1
ProfileFrame.Parent = MainFrame

local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Size = UDim2.new(0, 60, 0, 60)
AvatarImage.Position = UDim2.new(0.5, -30, 0, 5)
AvatarImage.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
AvatarImage.Parent = ProfileFrame
addBorder(AvatarImage)

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = AvatarImage

local ProfileName = Instance.new("TextLabel")
ProfileName.Size = UDim2.new(1, 0, 0, 35)
ProfileName.Position = UDim2.new(0, 0, 0, 70)
ProfileName.BackgroundTransparency = 1
ProfileName.TextColor3 = Color3.fromRGB(0, 200, 0)
ProfileName.TextSize = 11
ProfileName.Font = Enum.Font.SourceSansBold
ProfileName.TextWrapped = true
ProfileName.Parent = ProfileFrame

-- Вкладки
local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(0, 100, 1, -155)
TabsFrame.Position = UDim2.new(0, 0, 0, 30)
TabsFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
TabsFrame.BorderSizePixel = 0
TabsFrame.Parent = MainFrame
addBorder(TabsFrame)

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -115, 1, -45)
ContentFrame.Position = UDim2.new(0, 110, 0, 35)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local Pages = {}
local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.CanvasSize = UDim2.new(0, 0, 0, 400)
    page.ScrollBarThickness = 4
    page.Visible = false
    page.Parent = ContentFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page
    
    Pages[name] = page
    return page
end

local PlayerPage = createPage("Player")
local GamePage = createPage("Game")
local FunctionPage = createPage("Function")

local function showPage(name)
    for _, p in pairs(Pages) do p.Visible = false end
    Pages[name].Visible = true
end

local tabList = {"Player", "Game", "Function"}
for i, tabName in ipairs(tabList) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, -10, 0, 30)
    tabBtn.Position = UDim2.new(0, 5, 0, (i-1)*35 + 5)
    tabBtn.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    tabBtn.TextColor3 = Color3.fromRGB(0, 200, 0)
    tabBtn.Text = tabName
    tabBtn.Font = Enum.Font.SourceSansBold
    tabBtn.TextSize = 14
    tabBtn.Parent = TabsFrame
    addBorder(tabBtn)
    tabBtn.MouseButton1Click:Connect(function() showPage(tabName) end)
end
showPage("Player")

local function createTextBox(parent, placeholder)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -10, 0, 35)
    box.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderText = placeholder
    box.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    box.Text = ""
    box.TextSize = 14
    box.Font = Enum.Font.SourceSans
    box.Parent = parent
    addBorder(box)
    return box
end

-- ==========================================
-- ФУНКЦИОНАЛ
-- ==========================================
-- Player
local WalkSpeedBox = createTextBox(PlayerPage, "Скорость бега (WalkSpeed)")
WalkSpeedBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and tonumber(WalkSpeedBox.Text) then
        local hum = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = tonumber(WalkSpeedBox.Text) end
    end
end)

local JumpPowerBox = createTextBox(PlayerPage, "Сила прыжка (JumpPower)")
JumpPowerBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and tonumber(JumpPowerBox.Text) then
        local hum = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")
        if hum then 
            hum.UseJumpPower = true 
            hum.JumpPower = tonumber(JumpPowerBox.Text) 
        end
    end
end)

-- Game
local SkyboxBox = createTextBox(GamePage, "ID Декала для Скайбокса + Enter")
local PartsBox = createTextBox(GamePage, "ID Декала для всех Партов + Enter")

local MusicRow = Instance.new("Frame")
MusicRow.Size = UDim2.new(1, -10, 0, 50)
MusicRow.BackgroundTransparency = 1
MusicRow.Parent = GamePage

local Slider = Instance.new("TextButton")
Slider.Size = UDim2.new(0.3, 0, 0, 20)
Slider.Position = UDim2.new(0, 0, 0.3, 0)
Slider.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Slider.TextColor3 = Color3.fromRGB(0, 150, 0)
Slider.Text = "Спид: 1"
Slider.Font = Enum.Font.SourceSans
Slider.TextSize = 12
Slider.Parent = MusicRow
addBorder(Slider)

local SongBox = Instance.new("TextBox")
SongBox.Size = UDim2.new(0.65, 0, 0, 35)
SongBox.Position = UDim2.new(0.35, 0, 0.1, 0)
SongBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
SongBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SongBox.PlaceholderText = "ID Песни + Enter"
SongBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
SongBox.Text = ""
SongBox.TextSize = 14
SongBox.Font = Enum.Font.SourceSans
SongBox.Parent = MusicRow
addBorder(SongBox)

local currentPitch = 1
local isSliding = false

local function updateSlider(input)
    local relativeX = input.Position.X - Slider.AbsolutePosition.X
    local pct = math.clamp(relativeX / Slider.AbsoluteSize.X, 0, 1)
    currentPitch = math.round((0.1 + (pct * 9.9)) * 10) / 10
    Slider.Text = "Спид: " .. tostring(currentPitch)
    local activeSound = SoundService:FindFirstChild("G00byAudio")
    if activeSound then activeSound.PlaybackSpeed = currentPitch end
end

Slider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isSliding = true 
        updateSlider(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
        isSliding = false 
    end
end)

SkyboxBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and SkyboxBox.Text ~= "" then
        local id = string.match(SkyboxBox.Text, "%d+") or SkyboxBox.Text
        local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", Lighting)
        local asset = "rbxassetid://" .. id
        sky.SkyboxBk = asset 
        sky.SkyboxDn = asset 
        sky.SkyboxFt = asset 
        sky.SkyboxLf = asset 
        sky.SkyboxRt = asset 
        sky.SkyboxUp = asset
    end
end)

PartsBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and PartsBox.Text ~= "" then
        local id = string.match(PartsBox.Text, "%d+") or PartsBox.Text
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                for _, face in ipairs(Enum.NormalId:GetEnumItems()) do
                    local t = Instance.new("Texture")
                    t.Texture = "rbxassetid://" .. id
                    t.Face = face
                    t.Parent = obj
                end
            end
        end
    end
end)

SongBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and SongBox.Text ~= "" then
        local id = string.match(SongBox.Text, "%d+") or SongBox.Text
        local old = SoundService:FindFirstChild("G00byAudio") 
        if old then old:Destroy() end
        local sound = Instance.new("Sound")
        sound.Name = "G00byAudio" 
        sound.SoundId = "rbxassetid://" .. id
        sound.Volume = 10 
        sound.PlaybackSpeed = currentPitch 
        sound.Looped = true 
        sound.Parent = SoundService
        sound:Play()
    end
end)

-- Function
local Func1 = createTextBox(FunctionPage, "1: Стандартный Notify")
local Func2 = createTextBox(FunctionPage, "2: Hint на 10 сек")
local Func3 = createTextBox(FunctionPage, "3: Большое сообщение (Msg)")
local Func4 = createTextBox(FunctionPage, "4: Кастомный Notify справа снизу")

Func1.FocusLost:Connect(function(enterPressed)
    if enterPressed and Func1.Text ~= "" then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "G00by", 
            Text = Func1.Text, 
            Duration = 5
        })
    end
end)

Func2.FocusLost:Connect(function(enterPressed)
    if enterPressed and Func2.Text ~= "" then
        local hint = Instance.new("Hint", workspace) 
        hint.Text = Func2.Text
        task.delay(10, function() hint:Destroy() end)
    end
end)

Func3.FocusLost:Connect(function(enterPressed)
    if enterPressed and Func3.Text ~= "" then
        local msg = Instance.new("Message", workspace) 
        msg.Text = Func3.Text
        task.delay(5, function() msg:Destroy() end)
    end
end)

local function createCustomNotify(text)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 250, 0, 80)
    notif.Position = UDim2.new(1, 20, 1, -100)
    notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notif.Parent = ScreenGui
    addBorder(notif)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 1, -10) 
    lbl.Position = UDim2.new(0, 5, 0, 5)
    lbl.BackgroundTransparency = 1 
    lbl.TextColor3 = Color3.fromRGB(0, 200, 0)
    lbl.TextWrapped = true 
    lbl.Text = text 
    lbl.Font = Enum.Font.SourceSansBold 
    lbl.TextSize = 14 
    lbl.Parent = notif
    
    notif:TweenPosition(UDim2.new(1, -270, 1, -100), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.5, true)
    
    task.delay(5, function()
        pcall(function()
            notif:TweenPosition(UDim2.new(1, 20, 1, -100), Enum.EasingDirection.In, Enum.EasingStyle.Quart, 0.5, true)
            task.wait(0.5) 
            notif:Destroy()
        end)
    end)
end

Func4.FocusLost:Connect(function(enterPressed)
    if enterPressed and Func4.Text ~= "" then 
        createCustomNotify(Func4.Text) 
    end
end)

-- ==========================================
-- LOGIN
-- ==========================================
EnterBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == "g00b" then
        local targetUser = UserInput.Text ~= "" and UserInput.Text or LocalPlayer.Name
        local targetId = 1
        
        pcall(function()
            targetId = Players:GetUserIdFromNameAsync(targetUser)
        end)
        
        AvatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. targetId .. "&w=150&h=150"
        ProfileName.Text = targetUser .. "\n[" .. ModeInput.Text .. "]"
        
        -- Сохраняем
        saveData(UserInput.Text, PassInput.Text, ModeInput.Text)
        
        AuthFrame:Destroy()
        MainFrame.Visible = true
    else
        KeyInput.Text = ""
        KeyInput.PlaceholderText = "НЕВЕРНЫЙ КЛЮЧ!"
        task.delay(2, function() 
            KeyInput.PlaceholderText = "Введите ключ (g00b)..." 
        end)
    end
end)
