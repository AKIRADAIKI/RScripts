--[[
    Frigid UI Library v2.0
    A comprehensive, modern UI library for Roblox scripting
    
    Usage:
        local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/RScripts/Libraries/UILibrary.lua"))()
        local Window = Library:CreateWindow("Script Name")
        local Tab = Window:AddTab("Main")
        Tab:AddToggle("ESP", false, function(value) print(value) end)
--]]

local UILibrary = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Utility Functions
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function Tween(obj, props, duration, easingStyle, easingDirection)
    duration = duration or 0.3
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    easingDirection = easingDirection or Enum.EasingDirection.Out
    
    local tween = TweenService:Create(obj, TweenInfo.new(duration, easingStyle, easingDirection), props)
    tween:Play()
    return tween
end

local function CreateInstance(className, props)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

-- Theme Configuration - Modern Glassmorphism Design
local Theme = {
    -- Primary Colors
    Background = Color3.fromRGB(20, 20, 25),
    BackgroundSecondary = Color3.fromRGB(28, 28, 35),
    BackgroundTertiary = Color3.fromRGB(38, 38, 48),
    
    -- Accent Colors - Vibrant Purple/Blue Gradient
    Accent = Color3.fromRGB(124, 93, 255),
    AccentDark = Color3.fromRGB(99, 74, 204),
    AccentLight = Color3.fromRGB(147, 123, 255),
    
    -- Text Colors
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(160, 160, 170),
    TextMuted = Color3.fromRGB(120, 120, 130),
    
    -- Status Colors
    Success = Color3.fromRGB(67, 217, 134),
    Error = Color3.fromRGB(255, 95, 95),
    Warning = Color3.fromRGB(255, 193, 69),
    Info = Color3.fromRGB(77, 166, 255),
    
    -- Glass Effect Colors
    Glass = Color3.fromRGB(255, 255, 255),
    GlassBorder = Color3.fromRGB(60, 60, 70),
    Shadow = Color3.fromRGB(0, 0, 0),
    
    -- Corner Radius
    CornerRadius = 12,
    ElementCornerRadius = 8,
    
    -- Fonts
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    FontSemibold = Enum.Font.GothamSemibold,
    FontMedium = Enum.Font.GothamMedium
}

-- Notification System
local NotificationGui = nil
local NotificationQueue = {}
local ActiveNotifications = 0

local function InitNotifications()
    if NotificationGui then return end
    
    NotificationGui = CreateInstance("ScreenGui", {
        Name = HttpService:GenerateGUID(false),
        Parent = (gethui and gethui()) or PlayerGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    local Container = CreateInstance("Frame", {
        Name = "Container",
        Size = UDim2.new(0, 300, 1, -20),
        Position = UDim2.new(1, -320, 0, 10),
        BackgroundTransparency = 1,
        Parent = NotificationGui
    })
    
    local ListLayout = CreateInstance("UIListLayout", {
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = Container
    })
end

function UILibrary:Notify(title, message, duration, type)
    duration = duration or 4
    type = type or "info"
    
    InitNotifications()
    
    local Container = NotificationGui:FindFirstChild("Container")
    
    local NotifFrame = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 75),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = Container
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, Theme.CornerRadius),
        Parent = NotifFrame
    })
    
    -- Glass border
    CreateInstance("UIStroke", {
        Color = Theme.Border,
        Thickness = 1,
        Transparency = 0.5,
        Parent = NotifFrame
    })
    
    -- Colored accent bar
    local AccentBar = CreateInstance("Frame", {
        Size = UDim2.new(0, 4, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = type == "success" and Theme.Success or type == "error" and Theme.Error or type == "warning" and Theme.Warning or Theme.Info,
        BorderSizePixel = 0,
        Parent = NotifFrame
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 2),
        Parent = AccentBar
    })
    
    -- Icon background
    local IconBg = CreateInstance("Frame", {
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(0, 14, 0, 19),
        BackgroundColor3 = type == "success" and Theme.Success or type == "error" and Theme.Error or type == "warning" and Theme.Warning or Theme.Info,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Parent = NotifFrame
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = IconBg
    })
    
    local Icon = CreateInstance("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = type == "success" and "✓" or type == "error" and "✕" or type == "warning" and "⚠" or "ℹ",
        TextColor3 = type == "success" and Theme.Success or type == "error" and Theme.Error or type == "warning" and Theme.Warning or Theme.Info,
        Font = Theme.FontBold,
        TextSize = 18,
        Parent = IconBg
    })
    
    local TitleLabel = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -80, 0, 20),
        Position = UDim2.new(0, 58, 0, 10),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        Font = Theme.FontBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = NotifFrame
    })
    
    local MessageLabel = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -80, 0, 35),
        Position = UDim2.new(0, 58, 0, 30),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Theme.TextDark,
        Font = Theme.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = NotifFrame
    })
    
    local CloseBtn = CreateInstance("TextButton", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -28, 0, 8),
        BackgroundColor3 = Theme.BackgroundTertiary,
        Text = "×",
        TextColor3 = Theme.TextDark,
        Font = Theme.FontBold,
        TextSize = 16,
        Parent = NotifFrame
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = CloseBtn
    })
    
    ActiveNotifications += 1
    
    -- Entrance animation
    NotifFrame.Size = UDim2.new(1, 0, 0, 0)
    Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, 75)}, 0.3)
    
    local function Close()
        Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
        task.wait(0.3)
        NotifFrame:Destroy()
        ActiveNotifications -= 1
    end
    
    -- Hover effects
    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = Theme.Error, TextColor3 = Theme.Text}, 0.2)
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = Theme.BackgroundTertiary, TextColor3 = Theme.TextDark}, 0.2)
    end)
    
    CloseBtn.MouseButton1Click:Connect(Close)
    
    task.delay(duration, Close)
end

-- Main Window Creation
function UILibrary:CreateWindow(title, gameName)
    local Window = {}
    
    -- Clean up old UI
    local existing = PlayerGui:FindFirstChild("FrigidUI_" .. title:gsub(" ", ""))
    if existing then existing:Destroy() end
    
    local ScreenGui = CreateInstance("ScreenGui", {
        Name = "FrigidUI_" .. title:gsub(" ", ""),
        Parent = (gethui and gethui()) or PlayerGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Main Window Frame with Gradient
    local MainFrame = CreateInstance("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 600, 0, 420),
        Position = UDim2.new(0.5, -300, 0.5, -210),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Active = true,
        ClipsDescendants = true,
        Parent = ScreenGui
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, Theme.CornerRadius),
        Parent = MainFrame
    })
    
    -- Gradient Background
    local Gradient = CreateInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Background),
            ColorSequenceKeypoint.new(1, Theme.BackgroundSecondary)
        }),
        Rotation = 45,
        Parent = MainFrame
    })
    
    CreateInstance("UIScale", {
        Scale = 1,
        Parent = MainFrame
    })
    
    -- Enhanced Shadow with Blur Effect
    local Shadow = CreateInstance("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, 60, 1, 60),
        Position = UDim2.new(0, -30, 0, -30),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Theme.Shadow,
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = -1,
        Parent = MainFrame
    })
    
    -- Title Bar with Glass Effect
    local TitleBar = CreateInstance("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Theme.BackgroundSecondary,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, Theme.CornerRadius),
        Parent = TitleBar
    })
    
    -- Title Bar Gradient
    local TitleBarGradient = CreateInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.BackgroundSecondary),
            ColorSequenceKeypoint.new(1, Theme.BackgroundTertiary)
        }),
        Rotation = 90,
        Parent = TitleBar
    })
    
    -- Fix title bar corner
    local TitleBarFix = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 15),
        Position = UDim2.new(0, 0, 1, -15),
        BackgroundColor3 = Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Parent = TitleBar
    })
    
    -- Title with Icon
    local TitleIcon = CreateInstance("TextLabel", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 12, 0.5, -15),
        BackgroundTransparency = 1,
        Text = "◆",
        TextColor3 = Theme.Accent,
        Font = Theme.FontBold,
        TextSize = 18,
        Parent = TitleBar
    })
    
    local TitleLabel = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -150, 1, 0),
        Position = UDim2.new(0, 45, 0, 0),
        BackgroundTransparency = 1,
        Text = title .. (gameName and " <font size='11' color='rgb(160,160,170)'>  |  " .. gameName .. "</font>" or ""),
        TextColor3 = Theme.Text,
        Font = Theme.FontBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        RichText = true,
        Parent = TitleBar
    })
    
    -- Window Controls with Hover Effects
    local MinimizeBtn = CreateInstance("TextButton", {
        Name = "Minimize",
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -75, 0.5, -16),
        BackgroundColor3 = Theme.BackgroundTertiary,
        Text = "−",
        TextColor3 = Theme.TextDark,
        Font = Theme.FontBold,
        TextSize = 16,
        AutoButtonColor = false,
        Parent = TitleBar
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = MinimizeBtn
    })
    
    local CloseBtn = CreateInstance("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -38, 0.5, -16),
        BackgroundColor3 = Theme.BackgroundTertiary,
        Text = "×",
        TextColor3 = Theme.Error,
        Font = Theme.FontBold,
        TextSize = 18,
        AutoButtonColor = false,
        Parent = TitleBar
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = CloseBtn
    })
    
    -- Button Hover Effects
    MinimizeBtn.MouseEnter:Connect(function()
        Tween(MinimizeBtn, {BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Text}, 0.2)
    end)
    MinimizeBtn.MouseLeave:Connect(function()
        Tween(MinimizeBtn, {BackgroundColor3 = Theme.BackgroundTertiary, TextColor3 = Theme.TextDark}, 0.2)
    end)
    
    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = Theme.Error, TextColor3 = Theme.Text}, 0.2)
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = Theme.BackgroundTertiary, TextColor3 = Theme.Error}, 0.2)
    end)
    
    -- Tab Container with Glass Effect
    local TabContainer = CreateInstance("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 130, 1, -50),
        Position = UDim2.new(0, 8, 0, 50),
        BackgroundColor3 = Theme.BackgroundSecondary,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, Theme.CornerRadius),
        Parent = TabContainer
    })
    
    -- Tab Container Stroke
    CreateInstance("UIStroke", {
        Color = Theme.Border,
        Thickness = 1,
        Transparency = 0.5,
        Parent = TabContainer
    })
    
    local TabLayout = CreateInstance("UIListLayout", {
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabContainer
    })
    
    local TabPadding = CreateInstance("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        Parent = TabContainer
    })
    
    -- Content Area with Glass Effect
    local ContentArea = CreateInstance("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -148, 1, -60),
        Position = UDim2.new(0, 142, 0, 55),
        BackgroundColor3 = Theme.BackgroundSecondary,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, Theme.CornerRadius),
        Parent = ContentArea
    })
    
    -- Content Area Stroke
    CreateInstance("UIStroke", {
        Color = Theme.Border,
        Thickness = 1,
        Transparency = 0.5,
        Parent = ContentArea
    })
    
    -- Content Scroll
    local ContentScroll = CreateInstance("ScrollingFrame", {
        Name = "Scroll",
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = ContentArea
    })
    
    local ContentLayout = CreateInstance("UIListLayout", {
        Padding = UDim.new(0, 8),
        Parent = ContentScroll
    })
    
    CreateInstance("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        Parent = ContentScroll
    })
    
    -- Window functionality
    local minimized = false
    local dragConnection
    
    MinimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(MainFrame, {Size = UDim2.new(0, 550, 0, 45)}, 0.3)
            MinimizeBtn.Text = "+"
            ContentArea.Visible = false
            TabContainer.Visible = false
        else
            Tween(MainFrame, {Size = UDim2.new(0, 550, 0, 400)}, 0.3)
            MinimizeBtn.Text = "−"
            ContentArea.Visible = true
            TabContainer.Visible = true
        end
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
        task.wait(0.2)
        ScreenGui:Destroy()
    end)
    
    MakeDraggable(MainFrame, TitleBar)
    
    -- Toggle UI keybind
    local uiVisible = true
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
            uiVisible = not uiVisible
            MainFrame.Visible = uiVisible
        end
    end)
    
    Window.ScreenGui = ScreenGui
    Window.ContentScroll = ContentScroll
    Window.Tabs = {}
    Window.ActiveTab = nil
    
    -- Tab Creation with Modern Styling
    function Window:AddTab(name, icon)
        local Tab = {}
        
        local TabBtn = CreateInstance("TextButton", {
            Name = name,
            Size = UDim2.new(0.9, 0, 0, 38),
            BackgroundColor3 = Theme.BackgroundTertiary,
            BackgroundTransparency = 0.3,
            Text = (icon and icon .. "  " or "") .. name,
            TextColor3 = Theme.TextDark,
            Font = Theme.FontSemibold,
            TextSize = 13,
            LayoutOrder = #Window.Tabs,
            AutoButtonColor = false,
            Parent = TabContainer
        })
        
        CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, Theme.ElementCornerRadius),
            Parent = TabBtn
        })
        
        -- Active Indicator Bar
        local ActiveIndicator = CreateInstance("Frame", {
            Name = "Indicator",
            Size = UDim2.new(0, 3, 0.7, 0),
            Position = UDim2.new(0, 0, 0.15, 0),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Visible = false,
            Parent = TabBtn
        })
        
        CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 2),
            Parent = ActiveIndicator
        })
        
        local TabContent = CreateInstance("ScrollingFrame", {
            Name = name .. "Content",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = ContentArea
        })
        
        local TabListLayout = CreateInstance("UIListLayout", {
            Padding = UDim.new(0, 10),
            Parent = TabContent
        })
        
        CreateInstance("UIPadding", {
            PaddingTop = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
            Parent = TabContent
        })
        
        table.insert(Window.Tabs, Tab)
        
        -- Tab Hover Effects
        TabBtn.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabBtn, {BackgroundTransparency = 0.1, TextColor3 = Theme.Text}, 0.2)
            end
        end)
        
        TabBtn.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabBtn, {BackgroundTransparency = 0.3, TextColor3 = Theme.TextDark}, 0.2)
            end
        end)
        
        if not Window.ActiveTab then
            Window.ActiveTab = Tab
            TabContent.Visible = true
            TabBtn.BackgroundColor3 = Theme.Accent
            TabBtn.BackgroundTransparency = 0
            TabBtn.TextColor3 = Theme.Text
            ActiveIndicator.Visible = true
        end
        
        TabBtn.MouseButton1Click:Connect(function()
            if Window.ActiveTab == Tab then return end
            
            -- Deactivate current
            for _, t in ipairs(Window.Tabs) do
                t.Content.Visible = false
                t.Button.BackgroundColor3 = Theme.BackgroundTertiary
                t.Button.BackgroundTransparency = 0.3
                t.Button.TextColor3 = Theme.TextDark
                t.Button.Indicator.Visible = false
            end
            
            -- Activate new with animation
            Window.ActiveTab = Tab
            TabContent.Visible = true
            Tween(TabBtn, {BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0, TextColor3 = Theme.Text}, 0.2)
            ActiveIndicator.Visible = true
        end)
        
        Tab.Button = TabBtn
        Tab.Content = TabContent
        
        -- Section Creation with Modern Styling
        function Tab:AddSection(name)
            local Section = {}
            
            local SectionFrame = CreateInstance("Frame", {
                Name = name,
                Size = UDim2.new(1, 0, 0, 45),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.Background,
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
                Parent = TabContent
            })
            
            CreateInstance("UICorner", {
                CornerRadius = UDim.new(0, Theme.ElementCornerRadius),
                Parent = SectionFrame
            })
            
            -- Section Border
            CreateInstance("UIStroke", {
                Color = Theme.Border,
                Thickness = 1,
                Transparency = 0.3,
                Parent = SectionFrame
            })
            
            -- Section Header with Icon
            local SectionHeader = CreateInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 35),
                BackgroundTransparency = 1,
                Parent = SectionFrame
            })
            
            local SectionIcon = CreateInstance("TextLabel", {
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(0, 12, 0.5, -10),
                BackgroundTransparency = 1,
                Text = "▸",
                TextColor3 = Theme.Accent,
                Font = Theme.FontBold,
                TextSize = 14,
                Parent = SectionHeader
            })
            
            local SectionTitle = CreateInstance("TextLabel", {
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 32, 0, 0),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = Theme.Text,
                Font = Theme.FontBold,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SectionHeader
            })
            
            local SectionContent = CreateInstance("Frame", {
                Name = "Content",
                Size = UDim2.new(1, -24, 0, 0),
                Position = UDim2.new(0, 12, 0, 38),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = SectionFrame
            })
            
            local SectionLayout = CreateInstance("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = SectionContent
            })
            
            Section.Content = SectionContent
            
            -- Button
            function Section:AddButton(text, callback)
                local Btn = CreateInstance("TextButton", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundColor3 = Theme.BackgroundTertiary,
                    Text = text,
                    TextColor3 = Theme.Text,
                    Font = Theme.FontSemibold,
                    TextSize = 13,
                    Parent = SectionContent
                })
                
                CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, Theme.ElementCornerRadius),
                    Parent = Btn
                })
                
                Btn.MouseEnter:Connect(function()
                    Tween(Btn, {BackgroundColor3 = Theme.Accent}, 0.2)
                end)
                
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, {BackgroundColor3 = Theme.BackgroundTertiary}, 0.2)
                end)
                
                Btn.MouseButton1Click:Connect(function()
                    pcall(callback)
                end)
                
                return Btn
            end
            
            -- Toggle with Modern Design
            function Section:AddToggle(text, default, callback)
                default = default or false
                
                local ToggleFrame = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 34),
                    BackgroundColor3 = Theme.BackgroundTertiary,
                    BackgroundTransparency = 0.5,
                    BorderSizePixel = 0,
                    Parent = SectionContent
                })
                
                CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, Theme.ElementCornerRadius),
                    Parent = ToggleFrame
                })
                
                local Label = CreateInstance("TextLabel", {
                    Size = UDim2.new(1, -70, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.Text,
                    Font = Theme.Font,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ToggleFrame
                })
                
                -- Toggle Track
                local ToggleTrack = CreateInstance("Frame", {
                    Size = UDim2.new(0, 44, 0, 22),
                    Position = UDim2.new(1, -56, 0.5, -11),
                    BackgroundColor3 = default and Theme.Accent or Theme.Background,
                    BackgroundTransparency = default and 0 or 0.5,
                    BorderSizePixel = 0,
                    Parent = ToggleFrame
                })
                
                CreateInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = ToggleTrack
                })
                
                -- Glow effect when enabled
                local Glow = CreateInstance("ImageLabel", {
                    Size = UDim2.new(1, 10, 1, 10),
                    Position = UDim2.new(0, -5, 0, -5),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://2797132742",
                    ImageColor3 = Theme.Accent,
                    ImageTransparency = default and 0.3 or 1,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(20, 20, 80, 80),
                    Parent = ToggleTrack
                })
                
                -- Toggle Circle (Knob)
                local Circle = CreateInstance("Frame", {
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
                    BackgroundColor3 = Theme.Text,
                    BorderSizePixel = 0,
                    Parent = ToggleTrack
                })
                
                CreateInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = Circle
                })
                
                -- Inner shadow for depth
                local CircleShadow = CreateInstance("ImageLabel", {
                    Size = UDim2.new(1, 4, 1, 4),
                    Position = UDim2.new(0, -2, 0, -2),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://6015897843",
                    ImageColor3 = Color3.fromRGB(0, 0, 0),
                    ImageTransparency = 0.7,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(49, 49, 450, 450),
                    Parent = Circle
                })
                
                local enabled = default
                
                local function UpdateToggle()
                    enabled = not enabled
                    Tween(ToggleTrack, {BackgroundColor3 = enabled and Theme.Accent or Theme.Background, BackgroundTransparency = enabled and 0 or 0.5}, 0.25)
                    Tween(Circle, {Position = enabled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.25)
                    Tween(Glow, {ImageTransparency = enabled and 0.3 or 1}, 0.25)
                    pcall(callback, enabled)
                end
                
                -- Hover effect
                ToggleFrame.MouseEnter:Connect(function()
                    if not enabled then
                        Tween(ToggleTrack, {BackgroundTransparency = 0.3}, 0.2)
                    end
                end)
                
                ToggleFrame.MouseLeave:Connect(function()
                    if not enabled then
                        Tween(ToggleTrack, {BackgroundTransparency = 0.5}, 0.2)
                    end
                end)
                
                ToggleFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        UpdateToggle()
                    end
                end)
                
                if default then
                    pcall(callback, default)
                end
                
                return {
                    Set = function(value)
                        if enabled ~= value then
                            enabled = value
                            Tween(ToggleTrack, {BackgroundColor3 = enabled and Theme.Accent or Theme.Background, BackgroundTransparency = enabled and 0 or 0.5}, 0.25)
                            Tween(Circle, {Position = enabled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.25)
                            Tween(Glow, {ImageTransparency = enabled and 0.3 or 1}, 0.25)
                            pcall(callback, enabled)
                        end
                    end,
                    Get = function() return enabled end
                }
            end
            
            -- Slider with Modern Thumb Design
            function Section:AddSlider(text, config, callback)
                config = config or {}
                local min = config.min or 0
                local max = config.max or 100
                local default = config.default or min
                local suffix = config.suffix or ""
                
                local SliderFrame = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 52),
                    BackgroundColor3 = Theme.BackgroundTertiary,
                    BackgroundTransparency = 0.5,
                    BorderSizePixel = 0,
                    Parent = SectionContent
                })
                
                CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, Theme.ElementCornerRadius),
                    Parent = SliderFrame
                })
                
                local Label = CreateInstance("TextLabel", {
                    Size = UDim2.new(0.6, 0, 0, 20),
                    Position = UDim2.new(0, 12, 0, 6),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.Text,
                    Font = Theme.Font,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SliderFrame
                })
                
                local ValueLabel = CreateInstance("TextLabel", {
                    Size = UDim2.new(0.3, 0, 0, 20),
                    Position = UDim2.new(0.7, -10, 0, 6),
                    BackgroundTransparency = 1,
                    Text = tostring(default) .. suffix,
                    TextColor3 = Theme.Accent,
                    Font = Theme.FontSemibold,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = SliderFrame
                })
                
                local SliderBg = CreateInstance("Frame", {
                    Size = UDim2.new(1, -24, 0, 8),
                    Position = UDim2.new(0, 12, 0, 34),
                    BackgroundColor3 = Theme.Background,
                    BackgroundTransparency = 0.5,
                    BorderSizePixel = 0,
                    Parent = SliderFrame
                })
                
                CreateInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SliderBg
                })
                
                local Fill = CreateInstance("Frame", {
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                    Parent = SliderBg
                })
                
                CreateInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = Fill
                })
                
                -- Slider Thumb
                local Thumb = CreateInstance("Frame", {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8),
                    BackgroundColor3 = Theme.Text,
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    Parent = SliderBg
                })
                
                CreateInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = Thumb
                })
                
                -- Thumb shadow
                local ThumbShadow = CreateInstance("ImageLabel", {
                    Size = UDim2.new(1, 6, 1, 6),
                    Position = UDim2.new(0, -3, 0, -3),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://6015897843",
                    ImageColor3 = Color3.fromRGB(0, 0, 0),
                    ImageTransparency = 0.6,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(49, 49, 450, 450),
                    Parent = Thumb
                })
                
                local Dragging = false
                
                local function UpdateSlider(input)
                    local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                    local value = math.floor(min + (pos * (max - min)))
                    
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    Thumb.Position = UDim2.new(pos, -8, 0.5, -8)
                    ValueLabel.Text = tostring(value) .. suffix
                    pcall(callback, value)
                end
                
                SliderBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = true
                        UpdateSlider(input)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = false
                    end
                end)
                
                -- Hover effects
                SliderFrame.MouseEnter:Connect(function()
                    Tween(SliderFrame, {BackgroundTransparency = 0.3}, 0.2)
                end)
                
                SliderFrame.MouseLeave:Connect(function()
                    Tween(SliderFrame, {BackgroundTransparency = 0.5}, 0.2)
                end)
                
                return {
                    Set = function(value)
                        value = math.clamp(value, min, max)
                        local pos = (value - min) / (max - min)
                        Fill.Size = UDim2.new(pos, 0, 1, 0)
                        Thumb.Position = UDim2.new(pos, -8, 0.5, -8)
                        ValueLabel.Text = tostring(value) .. suffix
                        pcall(callback, value)
                    end,
                    Get = function() return tonumber(ValueLabel.Text:gsub(suffix, "")) end
                }
            end
            
            -- Dropdown
            function Section:AddDropdown(text, options, default, callback)
                options = options or {}
                default = default or options[1]
                
                local DropdownFrame = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundColor3 = Theme.BackgroundTertiary,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Parent = SectionContent
                })
                
                CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, Theme.ElementCornerRadius),
                    Parent = DropdownFrame
                })
                
                local SelectedLabel = CreateInstance("TextLabel", {
                    Size = UDim2.new(1, -40, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text .. ": " .. (default or "Select..."),
                    TextColor3 = Theme.Text,
                    Font = Theme.Font,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DropdownFrame
                })
                
                local Arrow = CreateInstance("TextLabel", {
                    Size = UDim2.new(0, 30, 1, 0),
                    Position = UDim2.new(1, -30, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = Theme.TextDark,
                    Font = Theme.FontSemibold,
                    TextSize = 12,
                    Parent = DropdownFrame
                })
                
                local OptionContainer = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, #options * 28),
                    Position = UDim2.new(0, 0, 0, 32),
                    BackgroundColor3 = Theme.BackgroundSecondary,
                    BorderSizePixel = 0,
                    Parent = DropdownFrame
                })
                
                local OptionLayout = CreateInstance("UIListLayout", {
                    Padding = UDim.new(0, 2),
                    Parent = OptionContainer
                })
                
                local expanded = false
                
                for _, option in ipairs(options) do
                    local OptionBtn = CreateInstance("TextButton", {
                        Size = UDim2.new(1, 0, 0, 26),
                        BackgroundColor3 = Theme.BackgroundTertiary,
                        Text = option,
                        TextColor3 = Theme.TextDark,
                        Font = Theme.Font,
                        TextSize = 12,
                        Parent = OptionContainer
                    })
                    
                    OptionBtn.MouseEnter:Connect(function()
                        Tween(OptionBtn, {BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Text}, 0.2)
                    end)
                    
                    OptionBtn.MouseLeave:Connect(function()
                        Tween(OptionBtn, {BackgroundColor3 = Theme.BackgroundTertiary, TextColor3 = Theme.TextDark}, 0.2)
                    end)
                    
                    OptionBtn.MouseButton1Click:Connect(function()
                        SelectedLabel.Text = text .. ": " .. option
                        expanded = false
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 32)}, 0.2)
                        Arrow.Text = "▼"
                        pcall(callback, option)
                    end)
                end
                
                DropdownFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        expanded = not expanded
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, expanded and 32 + OptionContainer.Size.Y.Offset or 32)}, 0.2)
                        Arrow.Text = expanded and "▲" or "▼"
                    end
                end)
                
                return {
                    Set = function(value)
                        if table.find(options, value) then
                            SelectedLabel.Text = text .. ": " .. value
                            pcall(callback, value)
                        end
                    end,
                    Refresh = function(newOptions)
                        options = newOptions
                        for _, child in ipairs(OptionContainer:GetChildren()) do
                            if child:IsA("TextButton") then child:Destroy() end
                        end
                        -- Rebuild options...
                    end
                }
            end
            
            -- Keybind
            function Section:AddKeybind(text, default, callback)
                local KeybindFrame = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundColor3 = Theme.BackgroundTertiary,
                    BorderSizePixel = 0,
                    Parent = SectionContent
                })
                
                CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, Theme.ElementCornerRadius),
                    Parent = KeybindFrame
                })
                
                local Label = CreateInstance("TextLabel", {
                    Size = UDim2.new(0.6, 0, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.Text,
                    Font = Theme.Font,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = KeybindFrame
                })
                
                local KeyBtn = CreateInstance("TextButton", {
                    Size = UDim2.new(0, 80, 0, 24),
                    Position = UDim2.new(1, -90, 0.5, -12),
                    BackgroundColor3 = Theme.Background,
                    Text = default and default.Name or "None",
                    TextColor3 = Theme.TextDark,
                    Font = Theme.FontSemibold,
                    TextSize = 12,
                    Parent = KeybindFrame
                })
                
                CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = KeyBtn
                })
                
                local listening = false
                local currentKey = default
                
                KeyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    KeyBtn.Text = "..."
                    KeyBtn.TextColor3 = Theme.Accent
                end)
                
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if listening and not gameProcessed then
                        if input.KeyCode ~= Enum.KeyCode.Unknown then
                            currentKey = input.KeyCode
                            KeyBtn.Text = input.KeyCode.Name
                            KeyBtn.TextColor3 = Theme.TextDark
                            listening = false
                            pcall(callback, input.KeyCode)
                        end
                    elseif input.KeyCode == currentKey and not listening and not gameProcessed then
                        pcall(callback, currentKey)
                    end
                end)
                
                return {
                    Set = function(key)
                        currentKey = key
                        KeyBtn.Text = key.Name
                    end,
                    Get = function() return currentKey end
                }
            end
            
            -- TextBox
            function Section:AddTextBox(text, placeholder, callback)
                local BoxFrame = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 60),
                    BackgroundColor3 = Theme.BackgroundTertiary,
                    BorderSizePixel = 0,
                    Parent = SectionContent
                })
                
                CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, Theme.ElementCornerRadius),
                    Parent = BoxFrame
                })
                
                local Label = CreateInstance("TextLabel", {
                    Size = UDim2.new(1, -20, 0, 20),
                    Position = UDim2.new(0, 10, 0, 5),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.Text,
                    Font = Theme.Font,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = BoxFrame
                })
                
                local TextBox = CreateInstance("TextBox", {
                    Size = UDim2.new(1, -20, 0, 26),
                    Position = UDim2.new(0, 10, 0, 28),
                    BackgroundColor3 = Theme.Background,
                    Text = "",
                    PlaceholderText = placeholder or "Enter text...",
                    TextColor3 = Theme.Text,
                    PlaceholderColor3 = Theme.TextDark,
                    Font = Theme.Font,
                    TextSize = 13,
                    ClearTextOnFocus = false,
                    Parent = BoxFrame
                })
                
                CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = TextBox
                })
                
                TextBox.FocusLost:Connect(function(enterPressed)
                    if enterPressed then
                        pcall(callback, TextBox.Text)
                    end
                end)
                
                return {
                    Set = function(text) TextBox.Text = text end,
                    Get = function() return TextBox.Text end,
                    Focus = function() TextBox:CaptureFocus() end
                }
            end
            
            -- Label
            function Section:AddLabel(text)
                local Label = CreateInstance("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 25),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.TextDark,
                    Font = Theme.Font,
                    TextSize = 12,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = SectionContent
                })
                
                return {
                    Set = function(newText) Label.Text = newText end,
                    Get = function() return Label.Text end
                }
            end
            
            return Section  
        end
        
        return Tab
    end
    
    return Window
end

-- Export
return UILibrary
