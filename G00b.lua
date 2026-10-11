local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("G00byExecutorMenu_v2") then
    PlayerGui["G00byExecutorMenu_v2"]:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "G00byExecutorMenu_v2"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local function addBorder(parent)
    local border = Instance.new("UIStroke")
    border.Color = Color3.fromRGB(0, 100, 0)
    border.Thickness = 2
    border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    border.Parent = parent
    return border
end

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

-- Сохранение через getgenv
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
    page.CanvasSize = UDim2.new(0, 0, 0, 600)
    page.ScrollBarThickness = 4
    page.Visible = false
    page.Parent = ContentFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
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

-- Универсальная функция: поле + кнопка
local function createInputWithButton(parent, placeholder, buttonText)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 70)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, 0, 0, 32)
    box.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderText = placeholder
    box.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    box.Text = ""
    box.TextSize = 14
    box.Font = Enum.Font.SourceSans
    box.Parent = container
    addBorder(box)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.Position = UDim2.new(0, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    btn.TextColor3 = Color3.fromRGB(0, 200, 0)
    btn.Text = buttonText or "Применить"
    btn.TextSize = 14
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = container
    addBorder(btn)

    return box, btn
end

-- ==========================================
-- PLAYER
-- ==========================================
local WalkSpeedBox, WalkSpeedBtn = createInputWithButton(PlayerPage, "Скорость бега (WalkSpeed)", "Применить WalkSpeed")
local JumpPowerBox, JumpPowerBtn = createInputWithButton(PlayerPage, "Сила прыжка (JumpPower)", "Применить JumpPower")

local function applyWalkSpeed()
    local val = tonumber(WalkSpeedBox.Text)
    if val then
        local hum = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = val end
    end
end

local function applyJumpPower()
    local val = tonumber(JumpPowerBox.Text)
    if val then
        local hum = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = val
        end
    end
end

WalkSpeedBtn.MouseButton1Click:Connect(applyWalkSpeed)
JumpPowerBtn.MouseButton1Click:Connect(applyJumpPower)

WalkSpeedBox.FocusLost:Connect(function(enter) if enter then applyWalkSpeed() end end)
JumpPowerBox.FocusLost:Connect(function(enter) if enter then applyJumpPower() end end)

-- ==========================================
-- GAME
-- ==========================================
local SkyboxBox, SkyboxBtn = createInputWithButton(GamePage, "ID Декала для Скайбокса", "Применить Skybox")
local PartsBox, PartsBtn = createInputWithButton(GamePage, "ID Декала для всех Партов", "Применить на Parts")

-- Музыка (отдельно, потому что слайдер)
local MusicContainer = Instance.new("Frame")
MusicContainer.Size = UDim2.new(1, -10, 0, 90)
MusicContainer.BackgroundTransparency = 1
MusicContainer.Parent = GamePage

local SongBox = Instance.new("TextBox")
SongBox.Size = UDim2.new(1, 0, 0, 32)
SongBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
SongBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SongBox.PlaceholderText = "ID Песни"
SongBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
SongBox.Text = ""
SongBox.TextSize = 14
SongBox.Font = Enum.Font.SourceSans
SongBox.Parent = MusicContainer
addBorder(SongBox)

local Slider = Instance.new("TextButton")
Slider.Size = UDim2.new(0.35, 0, 0, 26)
Slider.Position = UDim2.new(0, 0, 0, 38)
Slider.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Slider.TextColor3 = Color3.fromRGB(0, 150, 0)
Slider.Text = "Спид: 1"
Slider.Font = Enum.Font.SourceSans
Slider.TextSize = 12
Slider.Parent = MusicContainer
addBorder(Slider)

local SongBtn = Instance.new("TextButton")
SongBtn.Size = UDim2.new(0.62, 0, 0, 26)
SongBtn.Position = UDim2.new(0.38, 0, 0, 38)
SongBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
SongBtn.TextColor3 = Color3.fromRGB(0, 200, 0)
SongBtn.Text = "Применить Музыку"
SongBtn.TextSize = 13
SongBtn.Font = Enum.Font.SourceSansBold
SongBtn.Parent = MusicContainer
addBorder(SongBtn)

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

local function applySkybox()
    if SkyboxBox.Text ~= "" then
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
end

local function applyParts()
    if PartsBox.Text ~= "" then
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
end

local function applySong()
    if SongBox.Text ~= "" then
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
end

SkyboxBtn.MouseButton1Click:Connect(applySkybox)
PartsBtn.MouseButton1Click:Connect(applyParts)
SongBtn.MouseButton1Click:Connect(applySong)

SkyboxBox.FocusLost:Connect(function(enter) if enter then applySkybox() end end)
PartsBox.FocusLost:Connect(function(enter) if enter then applyParts() end end)
SongBox.FocusLost:Connect(function(enter) if enter then applySong() end end)

-- ==========================================
-- FUNCTION
-- ==========================================
local Func1Box, Func1Btn = createInputWithButton(FunctionPage, "1: Стандартный Notify", "Отправить Notify")
local Func2Box, Func2Btn = createInputWithButton(FunctionPage, "2: Hint на 10 сек", "Показать Hint")
local Func3Box, Func3Btn = createInputWithButton(FunctionPage, "3: Большое сообщение (Msg)", "Показать Message")
local Func4Box, Func4Btn = createInputWithButton(FunctionPage, "4: Кастомный Notify справа снизу", "Кастомный Notify")

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

Func1Btn.MouseButton1Click:Connect(function()
    if Func1Box.Text ~= "" then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "G00by",
            Text = Func1Box.Text,
            Duration = 5
        })
    end
end)

Func2Btn.MouseButton1Click:Connect(function()
    if Func2Box.Text ~= "" then
        local hint = Instance.new("Hint", workspace)
        hint.Text = Func2Box.Text
        task.delay(10, function() hint:Destroy() end)
    end
end)

Func3Btn.MouseButton1Click:Connect(function()
    if Func3Box.Text ~= "" then
        local msg = Instance.new("Message", workspace)
        msg.Text = Func3Box.Text
        task.delay(5, function() msg:Destroy() end)
    end
end)

Func4Btn.MouseButton1Click:Connect(function()
    if Func4Box.Text ~= "" then
        createCustomNotify(Func4Box.Text)
    end
end)

-- Enter тоже работает
Func1Box.FocusLost:Connect(function(enter) if enter and Func1Box.Text ~= "" then Func1Btn.MouseButton1Click:Fire() end end)
Func2Box.FocusLost:Connect(function(enter) if enter and Func2Box.Text ~= "" then Func2Btn.MouseButton1Click:Fire() end end)
Func3Box.FocusLost:Connect(function(enter) if enter and Func3Box.Text ~= "" then Func3Btn.MouseButton1Click:Fire() end end)
Func4Box.FocusLost:Connect(function(enter) if enter and Func4Box.Text ~= "" then Func4Btn.MouseButton1Click:Fire() end end)

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
