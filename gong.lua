--!strict
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
 
-- Check for executor's request function
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request
 
local AstralLib = {}
 
-- // THEME CONFIGURATION
local Theme = {
    Background = Color3.fromRGB(12, 12, 14),
    Card = Color3.fromRGB(18, 18, 22),
    IconBg = Color3.fromRGB(25, 25, 30),
    Border = Color3.fromRGB(35, 35, 40),
    Accent = Color3.fromRGB(0, 122, 255), -- Blue
    Purple = Color3.fromRGB(190, 0, 255),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSec = Color3.fromRGB(160, 160, 165),
    Knob = Color3.fromRGB(255, 255, 255),
    Success = Color3.fromRGB(50, 255, 100), -- Green for ticks
    Danger = Color3.fromRGB(255, 50, 50)
}
 
if CoreGui:FindFirstChild("Astral_UI_V10") then
    CoreGui.Astral_UI_V10:Destroy()
end
 
-- // INTERNAL HELPERS
local function Corner(radius: number, parent: Instance)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end
 
local function Stroke(color: Color3, thickness: number, parent: Instance)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end
 
-- // DRAGGING HANDLER
local function MakeDraggable(UIElement: GuiObject)
    local dragging = false
    local dragInput
    local dragStart
    local startPos
 
    UIElement.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = UIElement.Position
 
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
 
    UIElement.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
 
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            UIElement.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
 
function AstralLib:CreateWindow(titleText, versionText)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Astral_UI_V10"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
 
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 795, 0, 532)
    MainFrame.Position = UDim2.new(0.5, -397, 0.5, -266)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    Corner(10, MainFrame)
    Stroke(Theme.Border, 1, MainFrame)
 
    -- // INDEPENDENT EXTERNAL BUTTONS
    local MinimizeBtn = Instance.new("ImageButton")
    MinimizeBtn.Name = "MinimizeButton"
    MinimizeBtn.Size = UDim2.new(0, 75, 0, 75)
    MinimizeBtn.Position = UDim2.new(0, 130, 0.5, -37)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MinimizeBtn.Image = "rbxassetid://106987676739927"
    MinimizeBtn.Active = true
    MinimizeBtn.Parent = ScreenGui
    Corner(100, MinimizeBtn)
    Stroke(Theme.Accent, 2, MinimizeBtn)
    
    local MinScale = Instance.new("UIScale", MinimizeBtn)
    MakeDraggable(MinimizeBtn)
 
    local StopTweenBtn = Instance.new("TextButton")
    StopTweenBtn.Name = "StopTweenButton"
    StopTweenBtn.Size = UDim2.new(0, 75, 0, 75)
    StopTweenBtn.Position = UDim2.new(0, 50, 0.5, -37)
    StopTweenBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    StopTweenBtn.Text = "STOP\nTWEEN"
    StopTweenBtn.TextColor3 = Color3.new(1, 1, 1)
    StopTweenBtn.Font = Enum.Font.GothamBold
    StopTweenBtn.TextSize = 13
    StopTweenBtn.TextWrapped = true
    StopTweenBtn.Active = true
    StopTweenBtn.Parent = ScreenGui
    Corner(100, StopTweenBtn)
    Stroke(Theme.Accent, 2, StopTweenBtn)
    
    local StopScale = Instance.new("UIScale", StopTweenBtn)
    MakeDraggable(StopTweenBtn)
 
    -- // CLICK ANIMATIONS & LOGIC
    local clickStartPos = Vector2.zero
 
    MinimizeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            clickStartPos = Vector2.new(input.Position.X, input.Position.Y)
            TweenService:Create(MinScale, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 0.85}):Play()
        end
    end)
 
    MinimizeBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(MinScale, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
            local endPos = Vector2.new(input.Position.X, input.Position.Y)
            local delta = (endPos - clickStartPos).Magnitude
            if delta < 10 then
                MainFrame.Visible = not MainFrame.Visible
            end
        end
    end)
 
    StopTweenBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(StopScale, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 0.85}):Play()
        end
    end)
 
    StopTweenBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(StopScale, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
        end
    end)
 
    local ResizeHandle = Instance.new("TextButton")
    ResizeHandle.Size = UDim2.new(0, 20, 0, 20)
    ResizeHandle.Position = UDim2.new(1, -20, 1, -20)
    ResizeHandle.BackgroundTransparency = 1
    ResizeHandle.Text = ""
    ResizeHandle.ZIndex = 100
    ResizeHandle.Parent = MainFrame
 
    local resizing = false
    local resizeStartPos: Vector3
    local resizeStartSize: Vector2
 
    ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resizeStartPos = input.Position
            resizeStartSize = MainFrame.AbsoluteSize
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                end
            end)
        end
    end)
 
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if resizing then
                local delta = input.Position - resizeStartPos
                local newWidth = math.clamp(resizeStartSize.X + delta.X, 795, 1150)
                local newHeight = math.clamp(resizeStartSize.Y + delta.Y, 532, 733)
                MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
            end
        end
    end)
 
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = MainFrame
 
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 110, 1, 0)
    Title.Position = UDim2.new(0, 50, 0, 0)
    Title.BackgroundTransparency = 1
    Title.RichText = true
    Title.Text = [[Astral <font color="#007AFF">Hub</font>]]
    Title.TextColor3 = Theme.TextPrimary
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 19
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar
 
    local SidebarToggle = Instance.new("ImageButton")
    SidebarToggle.Size = UDim2.new(0, 24, 0, 24)
    SidebarToggle.Position = UDim2.new(0, 15, 0.5, -12)
    SidebarToggle.BackgroundTransparency = 1
    SidebarToggle.Image = "rbxassetid://96304569438872"
    SidebarToggle.ImageColor3 = Theme.TextPrimary
    SidebarToggle.Parent = TopBar
 
    local function CreateBadge(text, bgColor, textColor, parent)
        local Badge = Instance.new("Frame")
        Badge.BackgroundColor3 = bgColor
        Badge.AutomaticSize = Enum.AutomaticSize.XY
        Badge.Parent = parent
        Corner(6, Badge)
        local Padding = Instance.new("UIPadding", Badge)
        Padding.PaddingLeft = UDim.new(0, 10)
        Padding.PaddingRight = UDim.new(0, 10)
        Padding.PaddingTop = UDim.new(0, 5)
        Padding.PaddingBottom = UDim.new(0, 5)
        local Label = Instance.new("TextLabel")
        Label.Text = text
        Label.Font = Enum.Font.GothamBold
        Label.TextColor3 = textColor
        Label.TextSize = 12
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(0, 0, 0, 14)
        Label.AutomaticSize = Enum.AutomaticSize.X
        Label.Parent = Badge
        return Badge
    end
 
    local ActiveBadge = CreateBadge("BETA", Theme.Accent, Theme.TextPrimary, TopBar)
    ActiveBadge.Position = UDim2.new(0, 155, 0.5, -12)
 
    local Arrows = Instance.new("TextLabel")
    Arrows.Size = UDim2.new(0, 350, 1, 0)
    Arrows.Position = UDim2.new(0, 240, 0, 0)
    Arrows.BackgroundTransparency = 1
    Arrows.RichText = true
    Arrows.Text = [[<font color="#FFFFFF">>></font> <font color="#007AFF">>></font> <font color="#FFFFFF">>></font> <font color="#007AFF">>></font> <font color="#FFFFFF">>></font> <font color="#007AFF">>></font> <font color="#FFFFFF">>></font> <font color="#007AFF">>></font>]]
    Arrows.TextColor3 = Theme.TextPrimary
    Arrows.Font = Enum.Font.GothamBold
    Arrows.TextSize = 16
    Arrows.TextXAlignment = Enum.TextXAlignment.Left
    Arrows.Parent = TopBar
 
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -40, 0.5, -15)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "—"
    MinBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 14
    MinBtn.Parent = TopBar
 
    MinBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        pcall(function()
            StarterGui:SetCore("SendNotification", {Title = "Astral Hub", Text = "UI Minimized. Use the logo button to restore.", Duration = 3})
        end)
    end)
 
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)
 
    local dragging, dragInput, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
 
    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(1, 0, 0, 1)
    Line.Position = UDim2.new(0, 0, 0, 50)
    Line.BackgroundColor3 = Theme.Border
    Line.BorderSizePixel = 0
    Line.Parent = MainFrame
 
    local VLine = Instance.new("Frame")
    VLine.Size = UDim2.new(0, 1, 1, -50)
    VLine.Position = UDim2.new(0, 180, 0, 50)
    VLine.BackgroundColor3 = Theme.Border
    VLine.BorderSizePixel = 0
    VLine.Parent = MainFrame
 
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, 175, 1, -50)
    Sidebar.Position = UDim2.new(0, 0, 0, 50)
    Sidebar.BackgroundTransparency = 1
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 0
    Sidebar.Parent = MainFrame
 
    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Padding = UDim.new(0, 6)
    SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.Parent = Sidebar
    Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 15)
 
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -180, 1, -50)
    ContentContainer.Position = UDim2.new(0, 180, 0, 50)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame
 
    local Window = { CurrentTab = nil, AllTabs = {}, SidebarExpanded = true }
 
    SidebarToggle.MouseButton1Click:Connect(function()
        Window.SidebarExpanded = not Window.SidebarExpanded
        local targetSidebarWidth = Window.SidebarExpanded and 175 or 60
        local targetContentPos = Window.SidebarExpanded and 180 or 65
        local targetContentSize = Window.SidebarExpanded and -180 or -65
        
        TweenService:Create(Sidebar, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(0, targetSidebarWidth, 1, -50)}):Play()
        TweenService:Create(VLine, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(0, targetContentPos, 0, 50)}):Play()
        TweenService:Create(ContentContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(0, targetContentPos, 0, 50), Size = UDim2.new(1, targetContentSize, 1, -50)}):Play()
        TweenService:Create(SidebarToggle, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Rotation = Window.SidebarExpanded and 0 or 180}):Play()
 
        for _, tab in ipairs(Window.AllTabs) do
            TweenService:Create(tab.Btn, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(0, Window.SidebarExpanded and 155 or 45, 0, 40)}):Play()
            TweenService:Create(tab.Text, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {TextTransparency = Window.SidebarExpanded and 0 or 1}):Play()
        end
    end)
 
    function Window:MakeTabSection(name)
        local Sec = Instance.new("TextLabel")
        Sec.Size = UDim2.new(1, -20, 0, 30)
        Sec.BackgroundTransparency = 1
        Sec.Text = string.upper(name)
        Sec.TextColor3 = Color3.fromRGB(180, 180, 180)
        Sec.Font = Enum.Font.GothamBold
        Sec.TextSize = 12
        Sec.TextXAlignment = Enum.TextXAlignment.Left
        Sec.LayoutOrder = #Sidebar:GetChildren()
        Sec.Parent = Sidebar
        Instance.new("UIPadding", Sec).PaddingLeft = UDim.new(0, 10)
        
        task.spawn(function()
            while task.wait(0.1) do
                Sec.Visible = Window.SidebarExpanded
            end
        end)
    end
 
    function Window:MakeTab(tabName, iconId)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 155, 0, 40)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.LayoutOrder = #Sidebar:GetChildren()
        TabBtn.Parent = Sidebar
 
        local TabBg = Instance.new("Frame")
        TabBg.Size = UDim2.new(1, 0, 1, 0)
        TabBg.BackgroundColor3 = Color3.fromRGB(32, 32, 35)
        TabBg.Parent = TabBtn
        Corner(8, TabBg)
        local TabStroke = Stroke(Color3.fromRGB(50, 50, 55), 1, TabBg)
 
        local TabGradient = Instance.new("UIGradient")
        TabGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.25, 0),
            NumberSequenceKeypoint.new(0.55, 1),
            NumberSequenceKeypoint.new(1, 1)
        })
        TabGradient.Enabled = false
        TabGradient.Parent = TabBg
 
        local textOffsetX = 15
        if iconId then
            local Icon = Instance.new("ImageLabel")
            Icon.Name = "TabIcon"
            Icon.Size = UDim2.new(0, 18, 0, 18)
            Icon.Position = UDim2.new(0, 12, 0.5, -9)
            Icon.BackgroundTransparency = 1
            Icon.Image = iconId
            Icon.ImageColor3 = Color3.fromRGB(180, 180, 180)
            Icon.Parent = TabBg
            textOffsetX = 40
        end
 
        local TabText = Instance.new("TextLabel")
        TabText.Size = UDim2.new(1, -textOffsetX, 1, 0)
        TabText.Position = UDim2.new(0, textOffsetX, 0, 0)
        TabText.BackgroundTransparency = 1
        TabText.Text = tabName
        TabText.TextColor3 = Color3.fromRGB(180, 180, 180)
        TabText.Font = Enum.Font.GothamSemibold
        TabText.TextSize = 13
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.ClipsDescendants = true
        TabText.Parent = TabBg
 
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.ScrollBarThickness = 3
        TabContent.ScrollBarImageColor3 = Theme.Accent
        TabContent.Visible = false
        TabContent.Parent = ContentContainer
 
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Padding = UDim.new(0, 10)
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Parent = TabContent
 
        local ContentPadding = Instance.new("UIPadding")
        ContentPadding.PaddingLeft = UDim.new(0, 20); ContentPadding.PaddingRight = UDim.new(0, 20)
        ContentPadding.PaddingTop = UDim.new(0, 15); ContentPadding.PaddingBottom = UDim.new(0, 20)
        ContentPadding.Parent = TabContent
 
        local ColumnsContainer = Instance.new("Frame")
        ColumnsContainer.Name = "ColumnsContainer"
        ColumnsContainer.Size = UDim2.new(1, 0, 0, 0)
        ColumnsContainer.BackgroundTransparency = 1
        ColumnsContainer.AutomaticSize = Enum.AutomaticSize.Y
        ColumnsContainer.LayoutOrder = 999
        ColumnsContainer.Parent = TabContent
 
        local LeftColumn = Instance.new("Frame")
        LeftColumn.Name = "LeftColumn"
        LeftColumn.Size = UDim2.new(0.5, -7, 0, 0)
        LeftColumn.AutomaticSize = Enum.AutomaticSize.Y
        LeftColumn.BackgroundTransparency = 1
        LeftColumn.Parent = ColumnsContainer
 
        local RightColumn = Instance.new("Frame")
        RightColumn.Name = "RightColumn"
        RightColumn.Size = UDim2.new(0.5, -7, 0, 0)
        RightColumn.Position = UDim2.new(0.5, 7, 0, 0)
        RightColumn.AutomaticSize = Enum.AutomaticSize.Y
        RightColumn.BackgroundTransparency = 1
        RightColumn.Parent = ColumnsContainer
 
        local LList = Instance.new("UIListLayout", LeftColumn)
        LList.Padding = UDim.new(0, 15); LList.SortOrder = Enum.SortOrder.LayoutOrder
        local RList = Instance.new("UIListLayout", RightColumn)
        RList.Padding = UDim.new(0, 15); RList.SortOrder = Enum.SortOrder.LayoutOrder
 
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 30)
        end)
 
        table.insert(Window.AllTabs, {Btn = TabBtn, Bg = TabBg, Text = TabText, Content = TabContent, Gradient = TabGradient, Stroke = TabStroke})
 
        local function SelectTab()
            for _, t in ipairs(Window.AllTabs) do
                t.Content.Visible = false
                t.Gradient.Enabled = false
                t.Stroke.Enabled = true
                TweenService:Create(t.Bg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(32, 32, 35)}):Play()
                TweenService:Create(t.Text, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
                local icon = t.Bg:FindFirstChild("TabIcon")
                if icon then TweenService:Create(icon, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(180, 180, 180)}):Play() end
            end
            TabContent.Visible = true
            TabGradient.Enabled = true
            TabStroke.Enabled = false
            TweenService:Create(TabBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 80, 160)}):Play()
            TweenService:Create(TabText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            local activeIcon = TabBg:FindFirstChild("TabIcon")
            if activeIcon then TweenService:Create(activeIcon, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play() end
        end
 
        TabBtn.MouseButton1Click:Connect(SelectTab)
        if not Window.CurrentTab then Window.CurrentTab = TabContent; SelectTab() end
 
        local Elements = {}
        local elementOrder = 0
 
        function Elements:AddContentSection(name)
            elementOrder = elementOrder + 1
            local Sec = Instance.new("TextLabel")
            Sec.Size = UDim2.new(1, 0, 0, 35)
            Sec.BackgroundTransparency = 1
            Sec.Text = name
            Sec.TextColor3 = Color3.fromRGB(220, 220, 220)
            Sec.Font = Enum.Font.GothamBold
            Sec.TextSize = 16
            Sec.TextXAlignment = Enum.TextXAlignment.Left
            Sec.LayoutOrder = elementOrder
            Sec.Parent = TabContent
            local SecLine = Instance.new("Frame")
            SecLine.Size = UDim2.new(1, 0, 0, 1)
            SecLine.Position = UDim2.new(0, 0, 1, -5)
            SecLine.BackgroundColor3 = Theme.Border
            SecLine.BorderSizePixel = 0
            SecLine.Parent = Sec
        end
 
        function Elements:AddParagraph(title: string, content: string)
            elementOrder = elementOrder + 1
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -5, 0, 0)
            frame.AutomaticSize = Enum.AutomaticSize.Y
            frame.BackgroundColor3 = Theme.Card
            frame.LayoutOrder = elementOrder
            frame.Parent = TabContent
            Corner(10, frame)
            Stroke(Theme.Border, 1, frame)
            local pad = Instance.new("UIPadding", frame)
            pad.PaddingLeft = UDim.new(0, 15); pad.PaddingRight = UDim.new(0, 15)
            pad.PaddingTop = UDim.new(0, 12); pad.PaddingBottom = UDim.new(0, 12)
            local t = Instance.new("TextLabel")
            t.Text = title
            t.Font = Enum.Font.GothamBold
            t.TextColor3 = Theme.TextPrimary
            t.TextSize = 18
            t.Size = UDim2.new(1, 0, 0, 22)
            t.BackgroundTransparency = 1
            t.TextXAlignment = Enum.TextXAlignment.Left
            t.Parent = frame
            local c = Instance.new("TextLabel")
            c.Text = content
            c.Font = Enum.Font.Gotham
            c.TextColor3 = Theme.TextSec
            c.TextSize = 13
            c.Size = UDim2.new(1, 0, 0, 0)
            c.Position = UDim2.new(0, 0, 0, 28)
            c.AutomaticSize = Enum.AutomaticSize.Y
            c.BackgroundTransparency = 1
            c.TextXAlignment = Enum.TextXAlignment.Left
            c.TextWrapped = true
            c.Parent = frame
        end
 
        function Elements:AddPreview(title: string, content: string)
            elementOrder = elementOrder + 1
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -5, 0, 140)
            frame.BackgroundColor3 = Theme.Card
            frame.LayoutOrder = elementOrder
            frame.Parent = TabContent
            Corner(10, frame)
            Stroke(Theme.Border, 1, frame)
            local graphics = Instance.new("Frame")
            graphics.Size = UDim2.new(1, 0, 0, 80)
            graphics.BackgroundTransparency = 1
            graphics.Parent = frame
            local pill = Instance.new("Frame")
            pill.Size = UDim2.new(0, 80, 0, 30)
            pill.Position = UDim2.new(0, 30, 0.5, -15)
            pill.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            pill.Parent = graphics
            Corner(15, pill)
            local arc = Instance.new("ImageLabel")
            arc.Size = UDim2.new(0, 140, 0, 70)
            arc.Position = UDim2.new(0, 130, 0.5, -5)
            arc.BackgroundTransparency = 1
            arc.Image = "rbxassetid://12523411499"
            arc.ImageColor3 = Color3.fromRGB(180, 180, 180)
            arc.Parent = graphics
            local t = Instance.new("TextLabel")
            t.Text = title
            t.Font = Enum.Font.GothamBold
            t.TextColor3 = Theme.TextPrimary
            t.TextSize = 18
            t.Position = UDim2.new(0, 15, 0, 85)
            t.Size = UDim2.new(1, -30, 0, 22)
            t.BackgroundTransparency = 1
            t.TextXAlignment = Enum.TextXAlignment.Left
            t.Parent = frame
            local c = Instance.new("TextLabel")
            c.Text = content
            c.Font = Enum.Font.Gotham
            c.TextColor3 = Theme.TextSec
            c.TextSize = 13
            c.Position = UDim2.new(0, 15, 0, 107)
            c.Size = UDim2.new(1, -30, 0, 18)
            c.BackgroundTransparency = 1
            c.TextXAlignment = Enum.TextXAlignment.Left
            c.Parent = frame
        end
 
        function Elements:AddStatusCard(title: string, status: string, imageId: string, statusColor: Color3, side: string?)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 80)
            frame.BackgroundColor3 = Theme.Card
            frame.Parent = (side == "Right" and RightColumn) or LeftColumn
            Corner(10, frame)
            Stroke(Theme.Border, 1, frame)
 
            local ibg = Instance.new("Frame")
            ibg.Size = UDim2.fromOffset(60, 60)
            ibg.Position = UDim2.new(0, 12, 0.5, 0)
            ibg.AnchorPoint = Vector2.new(0, 0.5)
            ibg.BackgroundColor3 = Theme.IconBg
            ibg.Parent = frame
            Corner(10, ibg)
 
            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.fromScale(0.95, 0.95)
            icon.Position = UDim2.fromScale(0.5, 0.5)
            icon.AnchorPoint = Vector2.new(0.5, 0.5)
            icon.Image = imageId
            icon.BackgroundTransparency = 1
            icon.Parent = ibg
 
            local label = Instance.new("TextLabel")
            label.Text = title
            label.Font = Enum.Font.GothamBold
            label.TextSize = 15
            label.TextColor3 = Theme.TextPrimary
            label.Position = UDim2.new(0, 82, 0.5, -10)
            label.AnchorPoint = Vector2.new(0, 0.5)
            label.Size = UDim2.new(1, -92, 0, 20)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.BackgroundTransparency = 1
            label.Parent = frame
 
            local statusContainer = Instance.new("Frame")
            statusContainer.Size = UDim2.new(1, -92, 0, 15)
            statusContainer.Position = UDim2.new(0, 82, 0.5, 10)
            statusContainer.AnchorPoint = Vector2.new(0, 0.5)
            statusContainer.BackgroundTransparency = 1
            statusContainer.Parent = frame
 
            local statusLabel = Instance.new("TextLabel")
            statusLabel.Text = "Status: "
            statusLabel.Font = Enum.Font.GothamMedium
            statusLabel.TextSize = 11
            statusLabel.TextColor3 = Theme.TextSec
            statusLabel.Size = UDim2.new(0, 42, 1, 0)
            statusLabel.TextXAlignment = Enum.TextXAlignment.Left
            statusLabel.BackgroundTransparency = 1
            statusLabel.Parent = statusContainer
 
            local dot = Instance.new("Frame")
            dot.Size = UDim2.fromOffset(8, 8)
            dot.Position = UDim2.new(0, 44, 0.5, 0)
            dot.AnchorPoint = Vector2.new(0, 0.5)
            dot.BackgroundColor3 = statusColor
            dot.Parent = statusContainer
            Corner(8, dot)
 
            local statusText = Instance.new("TextLabel")
            statusText.Text = status
            statusText.Font = Enum.Font.GothamMedium
            statusText.TextSize = 11
            statusText.TextColor3 = Theme.TextSec
            statusText.Position = UDim2.new(0, 58, 0, 0)
            statusText.Size = UDim2.new(1, -58, 1, 0)
            statusText.TextXAlignment = Enum.TextXAlignment.Left
            statusText.BackgroundTransparency = 1
            statusText.Parent = statusContainer
        end
 
        function Elements:AddLabel(title: string, content: string, iconId: string, side: string?)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 80)
            frame.BackgroundColor3 = Theme.Card
            frame.Parent = (side == "Right" and RightColumn) or LeftColumn
            Corner(10, frame)
            Stroke(Theme.Border, 1, frame)
            local ibg = Instance.new("Frame")
            ibg.Size = UDim2.fromOffset(60, 60)
            ibg.Position = UDim2.new(0, 12, 0.5, 0)
            ibg.AnchorPoint = Vector2.new(0, 0.5)
            ibg.BackgroundColor3 = Theme.IconBg
            ibg.Parent = frame
            Corner(10, ibg)
            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.fromScale(0.7, 0.7)
            icon.Position = UDim2.fromScale(0.5, 0.5)
            icon.AnchorPoint = Vector2.new(0.5, 0.5)
            icon.Image = iconId
            icon.BackgroundTransparency = 1
            icon.Parent = ibg
            local label = Instance.new("TextLabel")
            label.Text = title
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            label.TextColor3 = Theme.TextPrimary
            label.Position = UDim2.new(0, 82, 0.5, -10)
            label.AnchorPoint = Vector2.new(0, 0.5)
            label.Size = UDim2.new(1, -92, 0, 20)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.BackgroundTransparency = 1
            label.Parent = frame
            local subLabel = Instance.new("TextLabel")
            subLabel.Text = content
            subLabel.Font = Enum.Font.GothamMedium
            subLabel.TextSize = 11
            subLabel.TextColor3 = Theme.TextSec
            subLabel.Position = UDim2.new(0, 82, 0.5, 10)
            subLabel.AnchorPoint = Vector2.new(0, 0.5)
            subLabel.Size = UDim2.new(1, -92, 0, 20)
            subLabel.TextXAlignment = Enum.TextXAlignment.Left
            subLabel.BackgroundTransparency = 1
            subLabel.Parent = frame
        end
 
        function Elements:AddBanner(titleText, descText, bannerId, inviteCode)
            elementOrder = elementOrder + 1
            local InviteCode = inviteCode or "bbHJmq6YCs"
            local BannerID = bannerId or "rbxassetid://127861212431489"
            local ServerIconID = "rbxassetid://106987676739927"
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -5, 0, 175)
            frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
            frame.BorderSizePixel = 0
            frame.LayoutOrder = elementOrder
            frame.Parent = TabContent
            Corner(10, frame)
            local mainStroke = Stroke(Color3.fromRGB(40, 40, 45), 1, frame)
            local banner = Instance.new("ImageLabel")
            banner.Size = UDim2.new(1, 0, 0, 95)
            banner.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            banner.Image = BannerID
            banner.ScaleType = Enum.ScaleType.Crop
            banner.Parent = frame
            Corner(10, banner)
            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.new(0, 64, 0, 64)
            icon.Position = UDim2.new(0, 20, 0, 65)
            icon.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
            icon.Image = ServerIconID
            icon.ZIndex = 5
            icon.Parent = frame
            Corner(14, icon)
            local iconStroke = Stroke(Color3.fromRGB(18, 18, 22), 4, icon)
            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, -110, 0, 22)
            title.Position = UDim2.new(0, 95, 0, 105)
            title.BackgroundTransparency = 1
            title.Text = titleText
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            title.Font = Enum.Font.GothamBold
            title.TextSize = 18
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.Parent = frame
            local desc = Instance.new("TextLabel")
            desc.Size = UDim2.new(1, -110, 0, 18)
            desc.Position = UDim2.new(0, 95, 0, 125)
            desc.BackgroundTransparency = 1
            desc.Text = descText
            desc.TextColor3 = Color3.fromRGB(140, 140, 145)
            desc.Font = Enum.Font.Gotham
            desc.TextSize = 12
            desc.TextXAlignment = Enum.TextXAlignment.Left
            desc.Parent = frame
            local stats = Instance.new("Frame")
            stats.Size = UDim2.new(1, -110, 0, 20)
            stats.Position = UDim2.new(0, 95, 0, 145)
            stats.BackgroundTransparency = 1
            stats.Parent = frame
            local onlineDot = Instance.new("Frame")
            onlineDot.Size = UDim2.new(0, 10, 0, 10)
            onlineDot.Position = UDim2.new(0, 0, 0.5, -5)
            onlineDot.BackgroundColor3 = Color3.fromRGB(35, 165, 90)
            onlineDot.Parent = stats
            Corner(10, onlineDot)
            local onlineCount = Instance.new("TextLabel")
            onlineCount.Size = UDim2.new(0, 70, 1, 0)
            onlineCount.Position = UDim2.new(0, 15, 0, 0)
            onlineCount.BackgroundTransparency = 1
            onlineCount.Text = "0 Online"
            onlineCount.TextColor3 = Color3.fromRGB(160, 160, 165)
            onlineCount.Font = Enum.Font.GothamMedium
            onlineCount.TextSize = 11
            onlineCount.TextXAlignment = Enum.TextXAlignment.Left
            onlineCount.Parent = stats
            local memberDot = Instance.new("ImageLabel")
            memberDot.Size = UDim2.new(0, 11, 0, 11)
            memberDot.Position = UDim2.new(0, 85, 0.5, -5)
            memberDot.BackgroundTransparency = 1
            memberDot.Image = "rbxassetid://88495550982825"
            memberDot.Parent = stats
            local memberCount = Instance.new("TextLabel")
            memberCount.Size = UDim2.new(0, 100, 1, 0)
            memberCount.Position = UDim2.new(0, 100, 0, 0)
            memberCount.BackgroundTransparency = 1
            memberCount.Text = "0 Members"
            memberCount.TextColor3 = Color3.fromRGB(160, 160, 165)
            memberCount.Font = Enum.Font.GothamMedium
            memberCount.TextSize = 11
            memberCount.TextXAlignment = Enum.TextXAlignment.Left
            memberCount.Parent = stats
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 105, 0, 36)
            btn.Position = UDim2.new(1, -120, 1, -50)
            btn.BackgroundColor3 = Color3.fromRGB(35, 165, 90)
            btn.Text = "Join"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 15
            btn.AutoButtonColor = true
            btn.Parent = frame
            Corner(6, btn)
            task.spawn(function()
                if httpRequest then
                    local res = httpRequest({ Url = "https://discord.com/api/v9/invites/" .. InviteCode .. "?with_counts=true", Method = "GET" })
                    if res.StatusCode == 200 then
                        local data = HttpService:JSONDecode(res.Body)
                        onlineCount.Text = (data.approximate_presence_count or 0) .. " Online"
                        memberCount.Text = (data.approximate_member_count or 0) .. " Members"
                        if data.guild and data.guild.description and data.guild.description ~= "" then desc.Text = data.guild.description end
                    end
                end
            end)
            btn.MouseButton1Click:Connect(function()
                if setclipboard then setclipboard("https://discord.gg/" .. InviteCode) end
                btn.Text = "Copied!"
                btn.BackgroundColor3 = Color3.fromRGB(65, 65, 70)
                pcall(function() StarterGui:SetCore("OpenUrl", "https://discord.gg/" .. InviteCode) end)
                task.wait(2)
                btn.Text = "Join"
                btn.BackgroundColor3 = Color3.fromRGB(35, 165, 90)
            end)
        end
 
        function Elements:AddToggle(title: string, iconId: string, side: string?, callback: (boolean) -> ())
            local isToggled = false
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 80)
            frame.BackgroundColor3 = Theme.Card
            frame.Parent = (side == "Right" and RightColumn) or LeftColumn
            Corner(10, frame)
            Stroke(Theme.Border, 1, frame)
            local ibg = Instance.new("Frame")
            ibg.Size = UDim2.fromOffset(60, 60)
            ibg.Position = UDim2.new(0, 12, 0.5, 0)
            ibg.AnchorPoint = Vector2.new(0, 0.5)
            ibg.BackgroundColor3 = Theme.IconBg
            ibg.Parent = frame
            Corner(10, ibg)
            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.fromScale(0.7, 0.7)
            icon.Position = UDim2.fromScale(0.5, 0.5)
            icon.AnchorPoint = Vector2.new(0.5, 0.5)
            icon.BackgroundTransparency = 1
            icon.Image = iconId
            icon.Parent = ibg
            local label = Instance.new("TextLabel")
            label.Text = title
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            label.TextColor3 = Theme.TextPrimary
            label.Position = UDim2.new(0, 82, 0.5, 0)
            label.AnchorPoint = Vector2.new(0, 0.5)
            label.Size = UDim2.new(1, -140, 0, 20)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.BackgroundTransparency = 1
            label.Parent = frame
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 48, 0, 26)
            btn.Position = UDim2.new(1, -12, 0.5, 0)
            btn.AnchorPoint = Vector2.new(1, 0.5)
            btn.BackgroundColor3 = Theme.Border
            btn.Text = ""
            btn.Parent = frame
            Corner(6, btn)
            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 20, 0, 20)
            knob.Position = UDim2.new(0, 3, 0.5, 0)
            knob.AnchorPoint = Vector2.new(0, 0.5)
            knob.BackgroundColor3 = Theme.Knob
            knob.Parent = btn
            Corner(4, knob)
            btn.MouseButton1Click:Connect(function()
                isToggled = not isToggled
                TweenService:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Position = isToggled and UDim2.new(1, -23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}):Play()
                TweenService:Create(btn, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {BackgroundColor3 = isToggled and Theme.Accent or Theme.Border}):Play()
                callback(isToggled)
            end)
        end
 
        -- // UPDATED TICK COMPONENT (WITH ICON SUPPORT)
        function Elements:AddTick(title: string, iconId: string, default: boolean, side: string?, callback: (boolean) -> ())
            local isToggled = default or false
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 65)
            frame.BackgroundColor3 = Theme.Card
            frame.Parent = (side == "Right" and RightColumn) or LeftColumn
            Corner(10, frame)
            Stroke(Theme.Border, 1, frame)
 
            local ibg = Instance.new("Frame")
            ibg.Size = UDim2.fromOffset(45, 45)
            ibg.Position = UDim2.new(0, 10, 0.5, 0)
            ibg.AnchorPoint = Vector2.new(0, 0.5)
            ibg.BackgroundColor3 = Theme.IconBg
            ibg.Parent = frame
            Corner(8, ibg)
 
            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.fromScale(0.65, 0.65)
            icon.Position = UDim2.fromScale(0.5, 0.5)
            icon.AnchorPoint = Vector2.new(0.5, 0.5)
            icon.BackgroundTransparency = 1
            icon.Image = iconId
            icon.Parent = ibg
 
            local label = Instance.new("TextLabel")
            label.Text = title
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            label.TextColor3 = Theme.TextPrimary
            label.Position = UDim2.new(0, 65, 0.5, 0)
            label.AnchorPoint = Vector2.new(0, 0.5)
            label.Size = UDim2.new(1, -110, 0, 20)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.BackgroundTransparency = 1
            label.Parent = frame
 
            local box = Instance.new("TextButton")
            box.Size = UDim2.fromOffset(30, 30)
            box.Position = UDim2.new(1, -15, 0.5, 0)
            box.AnchorPoint = Vector2.new(1, 0.5)
            box.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            box.Text = ""
            box.Parent = frame
            Corner(6, box)
            Stroke(Theme.Accent, 2, box)
 
            local check = Instance.new("ImageLabel")
            check.Size = UDim2.fromScale(0.75, 0.75)
            check.Position = UDim2.fromScale(0.5, 0.5)
            check.AnchorPoint = Vector2.new(0.5, 0.5)
            check.BackgroundTransparency = 1
            check.Image = "rbxassetid://6353957304"
            check.ImageColor3 = Theme.Success
            check.ImageTransparency = isToggled and 0 or 1
            check.Parent = box
 
            box.MouseButton1Click:Connect(function()
                isToggled = not isToggled
                TweenService:Create(check, TweenInfo.new(0.2), {ImageTransparency = isToggled and 0 or 1}):Play()
                callback(isToggled)
            end)
        end
 
        -- // UPDATED COMBIN TICK COMPONENT (WITH ICON SUPPORT)
        function Elements:AddCombinTick(title: string, ticks: {{Text: string, Icon: string, Default: boolean, Callback: (boolean) -> ()}}, side: string?)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 0)
            frame.AutomaticSize = Enum.AutomaticSize.Y
            frame.BackgroundColor3 = Theme.Card
            frame.Parent = (side == "Right" and RightColumn) or LeftColumn
            Corner(10, frame)
            Stroke(Theme.Border, 1, frame)
 
            local pad = Instance.new("UIPadding", frame)
            pad.PaddingLeft = UDim.new(0, 15); pad.PaddingRight = UDim.new(0, 15)
            pad.PaddingTop = UDim.new(0, 15); pad.PaddingBottom = UDim.new(0, 15)
 
            local t = Instance.new("TextLabel")
            t.Text = title
            t.Font = Enum.Font.GothamBold
            t.TextColor3 = Theme.TextPrimary
            t.TextSize = 16
            t.Size = UDim2.new(1, 0, 0, 25)
            t.BackgroundTransparency = 1
            t.TextXAlignment = Enum.TextXAlignment.Left
            t.Parent = frame
 
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, 0)
            container.Position = UDim2.new(0, 0, 0, 35)
            container.AutomaticSize = Enum.AutomaticSize.Y
            container.BackgroundTransparency = 1
            container.Parent = frame
 
            local grid = Instance.new("UIListLayout")
            grid.Padding = UDim.new(0, 8)
            grid.SortOrder = Enum.SortOrder.LayoutOrder
            grid.Parent = container
 
            for _, tickData in ipairs(ticks) do
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 35)
                row.BackgroundTransparency = 1
                row.Parent = container
 
                local subIcon = Instance.new("ImageLabel")
                subIcon.Size = UDim2.fromOffset(20, 20)
                subIcon.Position = UDim2.new(0, 0, 0.5, 0)
                subIcon.AnchorPoint = Vector2.new(0, 0.5)
                subIcon.BackgroundTransparency = 1
                subIcon.Image = tickData.Icon
                subIcon.ImageColor3 = Theme.TextSec
                subIcon.Parent = row
 
                local label = Instance.new("TextLabel")
                label.Text = tickData.Text
                label.Font = Enum.Font.GothamMedium
                label.TextSize = 13
                label.TextColor3 = Theme.TextSec
                label.Size = UDim2.new(1, -65, 1, 0)
                label.Position = UDim2.new(0, 28, 0, 0)
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.BackgroundTransparency = 1
                label.Parent = row
 
                local box = Instance.new("TextButton")
                box.Size = UDim2.fromOffset(24, 24)
                box.Position = UDim2.new(1, 0, 0.5, 0)
                box.AnchorPoint = Vector2.new(1, 0.5)
                box.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
                box.Text = ""
                box.Parent = row
                Corner(5, box)
                Stroke(Theme.Accent, 1.5, box)
 
                local check = Instance.new("ImageLabel")
                check.Size = UDim2.fromScale(0.7, 0.7)
                check.Position = UDim2.fromScale(0.5, 0.5)
                check.AnchorPoint = Vector2.new(0.5, 0.5)
                check.BackgroundTransparency = 1
                check.Image = "rbxassetid://6353957304"
                check.ImageColor3 = Theme.Success
                check.ImageTransparency = tickData.Default and 0 or 1
                check.Parent = box
 
                local active = tickData.Default
                box.MouseButton1Click:Connect(function()
                    active = not active
                    TweenService:Create(check, TweenInfo.new(0.2), {ImageTransparency = active and 0 or 1}):Play()
                    tickData.Callback(active)
                end)
            end
        end
 
        -- // UPDATED KEYBIND COMPONENT (WITH ICON SUPPORT)
        function Elements:AddKeybind(title: string, iconId: string, default: Enum.KeyCode?, side: string?, callback: (Enum.KeyCode) -> ())
            local currentKey = default or Enum.KeyCode.LeftControl
            local listening = false
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 65)
            frame.BackgroundColor3 = Theme.Card
            frame.Parent = (side == "Right" and RightColumn) or LeftColumn
            Corner(10, frame)
            Stroke(Theme.Border, 1, frame)
 
            local ibg = Instance.new("Frame")
            ibg.Size = UDim2.fromOffset(45, 45)
            ibg.Position = UDim2.new(0, 10, 0.5, 0)
            ibg.AnchorPoint = Vector2.new(0, 0.5)
            ibg.BackgroundColor3 = Theme.IconBg
            ibg.Parent = frame
            Corner(8, ibg)
 
            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.fromScale(0.65, 0.65)
            icon.Position = UDim2.fromScale(0.5, 0.5)
            icon.AnchorPoint = Vector2.new(0.5, 0.5)
            icon.BackgroundTransparency = 1
            icon.Image = iconId
            icon.Parent = ibg
 
            local label = Instance.new("TextLabel")
            label.Text = title
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            label.TextColor3 = Theme.TextPrimary
            label.Position = UDim2.new(0, 65, 0.5, 0)
            label.AnchorPoint = Vector2.new(0, 0.5)
            label.Size = UDim2.new(1, -160, 0, 20)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.BackgroundTransparency = 1
            label.Parent = frame
 
            local bindBox = Instance.new("TextButton")
            bindBox.Size = UDim2.fromOffset(85, 30)
            bindBox.Position = UDim2.new(1, -15, 0.5, 0)
            bindBox.AnchorPoint = Vector2.new(1, 0.5)
            bindBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            bindBox.Text = currentKey.Name
            bindBox.Font = Enum.Font.GothamBold
            bindBox.TextColor3 = Theme.TextPrimary
            bindBox.TextSize = 11
            bindBox.Parent = frame
            Corner(6, bindBox)
            Stroke(Theme.Border, 1, bindBox)
 
            bindBox.MouseButton1Click:Connect(function()
                listening = true
                bindBox.Text = "..."
            end)
 
            UserInputService.InputBegan:Connect(function(input)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode
                    bindBox.Text = currentKey.Name
                    listening = false
                    callback(currentKey)
                end
            end)
        end
 
        function Elements:AddButton(title: string, sub: string, iconId: string, side: string?, callback: () -> ())
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 80)
            frame.BackgroundColor3 = Theme.Card
            frame.Parent = (side == "Right" and RightColumn) or LeftColumn
            Corner(10, frame)
            Stroke(Theme.Border, 1, frame)
            local Scale = Instance.new("UIScale", frame)
            local ibg = Instance.new("Frame")
            ibg.Size = UDim2.fromOffset(60, 60)
            ibg.Position = UDim2.new(0, 12, 0.5, 0)
            ibg.AnchorPoint = Vector2.new(0, 0.5)
            ibg.BackgroundColor3 = Theme.IconBg
            ibg.Parent = frame
            Corner(10, ibg)
            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.fromScale(0.7, 0.7)
            icon.Position = UDim2.fromScale(0.5, 0.5)
            icon.AnchorPoint = Vector2.new(0.5, 0.5)
            icon.Image = iconId
            icon.BackgroundTransparency = 1
            icon.Parent = ibg
            local label = Instance.new("TextLabel")
            label.Text = title
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            label.TextColor3 = Theme.TextPrimary
            label.Position = UDim2.new(0, 82, 0.5, -10)
            label.AnchorPoint = Vector2.new(0, 0.5)
            label.Size = UDim2.new(1, -92, 0, 20)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.BackgroundTransparency = 1
            label.Parent = frame
            local subLabel = Instance.new("TextLabel")
            subLabel.Text = sub
            subLabel.Font = Enum.Font.GothamMedium
            subLabel.TextSize = 11
            subLabel.TextColor3 = Theme.TextSec
            subLabel.Position = UDim2.new(0, 82, 0.5, 10)
            subLabel.AnchorPoint = Vector2.new(0, 0.5)
            subLabel.Size = UDim2.new(1, -92, 0, 20)
            subLabel.TextXAlignment = Enum.TextXAlignment.Left
            subLabel.BackgroundTransparency = 1
            subLabel.Parent = frame
            local t = Instance.new("TextButton")
            t.Size = UDim2.fromScale(1, 1)
            t.BackgroundTransparency = 1
            t.Text = ""
            t.Parent = frame
            t.MouseButton1Down:Connect(function() TweenService:Create(Scale, TweenInfo.new(0.1), {Scale = 0.95}):Play() end)
            t.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then TweenService:Create(Scale, TweenInfo.new(0.1), {Scale = 1}):Play() end end)
            t.MouseButton1Click:Connect(callback)
        end
 
        function Elements:AddInputButton(title: string, iconId: string, buttonText: string, side: string?, callback: (string) -> ())
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 100)
            frame.BackgroundColor3 = Theme.Card
            frame.Parent = (side == "Right" and RightColumn) or LeftColumn
            Corner(10, frame)
            Stroke(Theme.Border, 1, frame)
 
            local ibg = Instance.new("Frame")
            ibg.Size = UDim2.fromOffset(45, 45)
            ibg.Position = UDim2.new(0, 12, 0, 12)
            ibg.BackgroundColor3 = Theme.IconBg
            ibg.Parent = frame
            Corner(8, ibg)
 
            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.fromScale(0.7, 0.7)
            icon.Position = UDim2.fromScale(0.5, 0.5)
            icon.AnchorPoint = Vector2.new(0.5, 0.5)
            icon.Image = iconId
            icon.BackgroundTransparency = 1
            icon.Parent = ibg
 
            local label = Instance.new("TextLabel")
            label.Text = title
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            label.TextColor3 = Theme.TextPrimary
            label.Position = UDim2.new(0, 65, 0, 22)
            label.AnchorPoint = Vector2.new(0, 0.5)
            label.Size = UDim2.new(1, -75, 0, 20)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.BackgroundTransparency = 1
            label.Parent = frame
 
            local inputFrame = Instance.new("Frame")
            inputFrame.Size = UDim2.new(1, -135, 0, 32)
            inputFrame.Position = UDim2.new(0, 12, 1, -12)
            inputFrame.AnchorPoint = Vector2.new(0, 1)
            inputFrame.BackgroundColor3 = Theme.Background
            inputFrame.Parent = frame
            Corner(6, inputFrame)
            Stroke(Theme.Border, 1, inputFrame)
 
            local box = Instance.new("TextBox")
            box.Size = UDim2.new(1, -10, 1, 0)
            box.Position = UDim2.fromOffset(5, 0)
            box.BackgroundTransparency = 1
            box.Text = ""
            box.PlaceholderText = "Paste key here..."
            box.TextColor3 = Theme.TextPrimary
            box.Font = Enum.Font.GothamMedium
            box.TextSize = 12
            box.TextXAlignment = Enum.TextXAlignment.Left
            box.Parent = inputFrame
 
            local submit = Instance.new("TextButton")
            submit.Size = UDim2.new(0, 100, 0, 32)
            submit.Position = UDim2.new(1, -12, 1, -12)
            submit.AnchorPoint = Vector2.new(1, 1)
            submit.BackgroundColor3 = Theme.Accent
            submit.Text = buttonText
            submit.Font = Enum.Font.GothamBold
            submit.TextColor3 = Color3.new(1, 1, 1)
            submit.TextSize = 13
            submit.Parent = frame
            Corner(6, submit)
 
            local statusLabel = Instance.new("TextLabel")
            statusLabel.Size = UDim2.new(1, -135, 0, 15)
            statusLabel.Position = UDim2.new(0, 12, 1, -48)
            statusLabel.AnchorPoint = Vector2.new(0, 1)
            statusLabel.BackgroundTransparency = 1
            statusLabel.Text = ""
            statusLabel.TextColor3 = Theme.TextSec
            statusLabel.Font = Enum.Font.GothamMedium
            statusLabel.TextSize = 10
            statusLabel.TextXAlignment = Enum.TextXAlignment.Left
            statusLabel.Parent = frame
 
            submit.MouseButton1Click:Connect(function()
                callback(box.Text)
                statusLabel.Text = "Processing..."
                task.delay(1.5, function()
                    statusLabel.Text = "Status: Updated"
                end)
            end)
        end
 
        -- // UPDATED COMBIN BUTTON (WITH ICON SUPPORT)
        function Elements:AddCombinButton(title: string, buttons: {{Text: string, Icon: string?, Callback: () -> ()}}, side: string?)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 0)
            frame.AutomaticSize = Enum.AutomaticSize.Y
            frame.BackgroundColor3 = Theme.Card
            frame.Parent = (side == "Right" and RightColumn) or LeftColumn
            Corner(10, frame)
            Stroke(Theme.Border, 1, frame)
 
            local pad = Instance.new("UIPadding", frame)
            pad.PaddingLeft = UDim.new(0, 15); pad.PaddingRight = UDim.new(0, 15)
            pad.PaddingTop = UDim.new(0, 15); pad.PaddingBottom = UDim.new(0, 15)
 
            local t = Instance.new("TextLabel")
            t.Text = title
            t.Font = Enum.Font.GothamBold
            t.TextColor3 = Theme.TextPrimary
            t.TextSize = 16
            t.Size = UDim2.new(1, 0, 0, 25)
            t.BackgroundTransparency = 1
            t.TextXAlignment = Enum.TextXAlignment.Left
            t.Parent = frame
 
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, 0)
            container.Position = UDim2.new(0, 0, 0, 35)
            container.AutomaticSize = Enum.AutomaticSize.Y
            container.BackgroundTransparency = 1
            container.Parent = frame
 
            local grid = Instance.new("UIGridLayout")
            grid.CellSize = UDim2.new(0.5, -6, 0, 34)
            grid.CellPadding = UDim2.new(0, 12, 0, 10)
            grid.SortOrder = Enum.SortOrder.LayoutOrder
            grid.Parent = container
 
            for i, btnData in ipairs(buttons) do
                local b = Instance.new("TextButton")
                b.BackgroundColor3 = Theme.Accent
                b.Text = ""
                b.Parent = container
                Corner(6, b)
 
                local bIcon = Instance.new("ImageLabel")
                bIcon.Size = UDim2.fromOffset(16, 16)
                bIcon.Position = UDim2.new(0, 8, 0.5, 0)
                bIcon.AnchorPoint = Vector2.new(0, 0.5)
                bIcon.BackgroundTransparency = 1
                bIcon.Image = btnData.Icon or "rbxassetid://10747373176"
                bIcon.ImageColor3 = Color3.new(1, 1, 1)
                bIcon.Parent = b
 
                local bText = Instance.new("TextLabel")
                bText.Size = UDim2.new(1, -30, 1, 0)
                bText.Position = UDim2.new(0, 26, 0, 0)
                bText.BackgroundTransparency = 1
                bText.Text = string.lower(btnData.Text)
                bText.Font = Enum.Font.GothamBold
                bText.TextColor3 = Color3.new(1, 1, 1)
                bText.TextSize = 12
                bText.TextXAlignment = Enum.TextXAlignment.Left
                bText.Parent = b
 
                local bScale = Instance.new("UIScale", b)
                b.MouseButton1Down:Connect(function() TweenService:Create(bScale, TweenInfo.new(0.1), {Scale = 0.95}):Play() end)
                b.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then TweenService:Create(bScale, TweenInfo.new(0.1), {Scale = 1}):Play() end end)
                b.MouseButton1Click:Connect(btnData.Callback)
            end
        end
 
        function Elements:AddTextBox(title: string, iconId: string, side: string?, callback: (string) -> ())
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 80)
            frame.BackgroundColor3 = Theme.Card
            frame.Parent = (side == "Right" and RightColumn) or LeftColumn
            Corner(10, frame)
            Stroke(Theme.Border, 1, frame)
            local ibg = Instance.new("Frame")
            ibg.Size = UDim2.fromOffset(60, 60)
            ibg.Position = UDim2.new(0, 12, 0.5, 0)
            ibg.AnchorPoint = Vector2.new(0, 0.5)
            ibg.BackgroundColor3 = Theme.IconBg
            ibg.Parent = frame
            Corner(10, ibg)
            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.fromScale(0.7, 0.7)
            icon.Position = UDim2.fromScale(0.5, 0.5)
            icon.AnchorPoint = Vector2.new(0.5, 0.5)
            icon.Image = iconId
            icon.BackgroundTransparency = 1
            icon.Parent = ibg
            local label = Instance.new("TextLabel")
            label.Text = title
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            label.TextColor3 = Theme.TextPrimary
            label.Position = UDim2.new(0, 82, 0.5, -12)
            label.AnchorPoint = Vector2.new(0, 0.5)
            label.Size = UDim2.new(1, -92, 0, 20)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.BackgroundTransparency = 1
            label.Parent = frame
            local inputFrame = Instance.new("Frame")
            inputFrame.Size = UDim2.new(1, -95, 0, 26)
            inputFrame.Position = UDim2.new(0, 82, 0.5, 12)
            inputFrame.AnchorPoint = Vector2.new(0, 0.5)
            inputFrame.BackgroundColor3 = Theme.Background
            inputFrame.Parent = frame
            Corner(4, inputFrame)
            Stroke(Theme.Border, 1, inputFrame)
            local box = Instance.new("TextBox")
            box.Size = UDim2.new(1, -10, 1, 0)
            box.Position = UDim2.fromOffset(5, 0)
            box.BackgroundTransparency = 1
            box.Text = ""
            box.PlaceholderText = "Type here..."
            box.TextColor3 = Theme.TextPrimary
            box.Font = Enum.Font.GothamMedium
            box.TextSize = 11
            box.TextXAlignment = Enum.TextXAlignment.Left
            box.Parent = inputFrame
            box.FocusLost:Connect(function(enter) if enter then callback(box.Text) end end)
        end
 
        function Elements:AddSlider(title: string, iconId: string, min: number, max: number, default: number, side: string?, callback: (number) -> ())
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 80)
            frame.BackgroundColor3 = Theme.Card
            frame.Parent = (side == "Right" and RightColumn) or LeftColumn
            Corner(10, frame)
            Stroke(Theme.Border, 1, frame)
 
            local ibg = Instance.new("Frame")
            ibg.Size = UDim2.fromOffset(60, 60)
            ibg.Position = UDim2.new(0, 12, 0.5, 0)
            ibg.AnchorPoint = Vector2.new(0, 0.5)
            ibg.BackgroundColor3 = Theme.IconBg
            ibg.Parent = frame
            Corner(10, ibg)
 
            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.fromScale(0.5, 0.5)
            icon.Position = UDim2.fromScale(0.5, 0.5)
            icon.AnchorPoint = Vector2.new(0.5, 0.5)
            icon.Image = iconId or "rbxassetid://6026663699"
            icon.BackgroundTransparency = 1
            icon.Parent = ibg
 
            local label = Instance.new("TextLabel")
            label.Text = title
            label.Font = Enum.Font.GothamBold
            label.TextSize = 13
            label.TextColor3 = Theme.TextPrimary
            label.Position = UDim2.new(0, 82, 0, 22)
            label.AnchorPoint = Vector2.new(0, 0.5)
            label.Size = UDim2.new(1, -140, 0, 20)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.BackgroundTransparency = 1
            label.Parent = frame
 
            local valBox = Instance.new("TextBox")
            valBox.Size = UDim2.fromOffset(55, 22)
            valBox.Position = UDim2.new(1, -12, 0, 22)
            valBox.AnchorPoint = Vector2.new(1, 0.5)
            valBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            valBox.Text = tostring(default)
            valBox.TextColor3 = Theme.TextPrimary
            valBox.Font = Enum.Font.GothamBold
            valBox.TextSize = 12
            valBox.ClearTextOnFocus = false
            valBox.Parent = frame
            Corner(4, valBox)
            Stroke(Theme.Border, 1, valBox)
 
            local SliderBG = Instance.new("Frame")
            SliderBG.Size = UDim2.new(1, -95, 0, 10)
            SliderBG.Position = UDim2.new(0, 82, 0.5, 12)
            SliderBG.AnchorPoint = Vector2.new(0, 0.5)
            SliderBG.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            SliderBG.Parent = frame
            Corner(2, SliderBG)
 
            local Progress = Instance.new("Frame")
            Progress.Size = UDim2.fromScale((default - min) / (max - min), 1)
            Progress.BackgroundColor3 = Theme.Accent
            Progress.Parent = SliderBG
            Corner(2, Progress)
 
            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 10, 0, 20)
            knob.Position = UDim2.fromScale((default - min) / (max - min), 0.5)
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.BackgroundColor3 = Theme.Knob
            knob.Parent = SliderBG
            Corner(2, knob)
            Stroke(Color3.new(0,0,0), 1, knob)
 
            local function update(inputPos)
                local pos = math.clamp((inputPos.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pos)
                valBox.Text = tostring(val)
                Progress.Size = UDim2.fromScale(pos, 1)
                knob.Position = UDim2.fromScale(pos, 0.5)
                callback(val)
            end
 
            valBox.FocusLost:Connect(function()
                local val = tonumber(valBox.Text)
                if val then
                    val = math.clamp(val, min, max)
                    local pos = (val - min) / (max - min)
                    valBox.Text = tostring(val)
                    TweenService:Create(Progress, TweenInfo.new(0.2), {Size = UDim2.fromScale(pos, 1)}):Play()
                    TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.fromScale(pos, 0.5)}):Play()
                    callback(val)
                else
                    valBox.Text = tostring(default)
                end
            end)
 
            local dragging = false
            SliderBG.InputBegan:Connect(function(input) 
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
                    dragging = true 
                    update(input.Position) 
                end 
            end)
            UserInputService.InputChanged:Connect(function(input) 
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then 
                    update(input.Position) 
                end 
            end)
            UserInputService.InputEnded:Connect(function(input) 
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
                    dragging = false 
                end 
            end)
        end
 
        function Elements:AddSelector(title: string, iconId: string, options: {string}, config: {MaxSelect: number, Default: {string}?}, side: string?, callback: ({string}) -> ())
            local maxSelect = config.MaxSelect or 1
            local selected = config.Default or {}
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 80)
            frame.BackgroundColor3 = Theme.Card
            frame.Parent = (side == "Right" and RightColumn) or LeftColumn
            Corner(10, frame)
            Stroke(Theme.Border, 1, frame)
            local ibg = Instance.new("Frame")
            ibg.Size = UDim2.fromOffset(60, 60)
            ibg.Position = UDim2.new(0, 12, 0.5, 0)
            ibg.AnchorPoint = Vector2.new(0, 0.5)
            ibg.BackgroundColor3 = Theme.IconBg
            ibg.Parent = frame
            Corner(10, ibg)
            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.fromScale(0.7, 0.7)
            icon.Position = UDim2.fromScale(0.5, 0.5)
            icon.AnchorPoint = Vector2.new(0.5, 0.5)
            icon.Image = iconId
            icon.BackgroundTransparency = 1
            icon.Parent = ibg
            local label = Instance.new("TextLabel")
            label.Text = title
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            label.TextColor3 = Theme.TextPrimary
            label.Position = UDim2.new(0, 82, 0.5, -10)
            label.AnchorPoint = Vector2.new(0, 0.5)
            label.Size = UDim2.new(1, -92, 0, 20)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.BackgroundTransparency = 1
            label.Parent = frame
            local subLabel = Instance.new("TextLabel")
            
            local function GetSelectionText()
                if #selected == 0 then return "None Selected" end
                if #selected == 1 then return selected[1] end
                return selected[1] .. " + " .. (#selected - 1) .. " more..."
            end
 
            subLabel.Text = GetSelectionText()
            subLabel.Font = Enum.Font.GothamMedium
            subLabel.TextSize = 11
            subLabel.TextColor3 = Theme.Accent
            subLabel.Position = UDim2.new(0, 82, 0.5, 10)
            subLabel.AnchorPoint = Vector2.new(0, 0.5)
            subLabel.Size = UDim2.new(1, -92, 0, 20)
            subLabel.TextXAlignment = Enum.TextXAlignment.Left
            subLabel.BackgroundTransparency = 1
            subLabel.Parent = frame
 
            local Overlay = Instance.new("TextButton")
            Overlay.Size = UDim2.fromScale(1, 1)
            Overlay.BackgroundTransparency = 1
            Overlay.Text = ""
            Overlay.Visible = false
            Overlay.ZIndex = 500
            Overlay.Parent = MainFrame
            local Panel = Instance.new("Frame")
            Panel.Size = UDim2.new(0, 240, 1, 0)
            Panel.Position = UDim2.new(1, 0, 0, 0)
            Panel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            Panel.BorderSizePixel = 0
            Panel.ZIndex = 501
            Panel.ClipsDescendants = true
            Panel.Active = true
            Panel.Parent = MainFrame
            Stroke(Theme.Border, 1, Panel)
            local SearchFrame = Instance.new("Frame")
            SearchFrame.Size = UDim2.new(1, -20, 0, 35)
            SearchFrame.Position = UDim2.new(0, 10, 0, 15)
            SearchFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            SearchFrame.ZIndex = 502
            SearchFrame.Parent = Panel
            Corner(6, SearchFrame)
            local SearchIcon = Instance.new("ImageLabel")
            SearchIcon.Size = UDim2.fromOffset(16, 16)
            SearchIcon.Position = UDim2.new(0, 10, 0.5, 0)
            SearchIcon.AnchorPoint = Vector2.new(0, 0.5)
            SearchIcon.Image = "rbxassetid://6031154871"
            SearchIcon.BackgroundTransparency = 1
            SearchIcon.ImageColor3 = Theme.TextSec
            SearchIcon.ZIndex = 503
            SearchIcon.Parent = SearchFrame
            local SearchBox = Instance.new("TextBox")
            SearchBox.Size = UDim2.new(1, -40, 1, 0)
            SearchBox.Position = UDim2.new(0, 35, 0, 0)
            SearchBox.BackgroundTransparency = 1
            SearchBox.Text = ""
            SearchBox.PlaceholderText = "Search Here..."
            SearchBox.TextColor3 = Theme.TextPrimary
            SearchBox.PlaceholderColor3 = Theme.TextSec
            SearchBox.Font = Enum.Font.GothamMedium
            SearchBox.TextSize = 12
            SearchBox.TextXAlignment = Enum.TextXAlignment.Left
            SearchBox.ZIndex = 503
            SearchBox.Parent = SearchFrame
            local List = Instance.new("ScrollingFrame")
            List.Size = UDim2.new(1, 0, 1, -65)
            List.Position = UDim2.new(0, 0, 0, 65)
            List.BackgroundTransparency = 1
            List.ScrollBarThickness = 2
            List.ScrollBarImageColor3 = Theme.Accent
            List.ZIndex = 502
            List.Parent = Panel
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.SortOrder = Enum.SortOrder.Name
            ListLayout.Parent = List
            local function UpdateList()
                for _, child in ipairs(List:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
                for _, opt in ipairs(options) do
                    if SearchBox.Text == "" or string.find(string.lower(opt), string.lower(SearchBox.Text)) then
                        local isSelected = table.find(selected, opt)
                        local btn = Instance.new("TextButton")
                        btn.Name = opt
                        btn.Size = UDim2.new(1, 0, 0, 40)
                        btn.BackgroundColor3 = isSelected and Color3.fromRGB(25, 25, 25) or Color3.fromRGB(15, 15, 15)
                        btn.BorderSizePixel = 0
                        btn.Text = ""
                        btn.AutoButtonColor = false
                        btn.ZIndex = 504
                        btn.Parent = List
                        local indicator = Instance.new("Frame")
                        indicator.Size = UDim2.new(0, 3, 0, 22)
                        indicator.Position = UDim2.new(0, 5, 0.5, 0)
                        indicator.AnchorPoint = Vector2.new(0, 0.5)
                        indicator.BackgroundColor3 = Theme.Accent
                        indicator.Visible = isSelected ~= nil
                        indicator.ZIndex = 505
                        indicator.Parent = btn
                        Corner(2, indicator)
                        local optLabel = Instance.new("TextLabel")
                        optLabel.Size = UDim2.new(1, -30, 1, 0)
                        optLabel.Position = UDim2.new(0, 20, 0, 0)
                        optLabel.BackgroundTransparency = 1
                        optLabel.Text = opt
                        optLabel.TextColor3 = isSelected and Theme.TextPrimary or Theme.TextSec
                        optLabel.Font = Enum.Font.GothamMedium
                        optLabel.TextSize = 13
                        optLabel.TextXAlignment = Enum.TextXAlignment.Left
                        optLabel.ZIndex = 505
                        optLabel.Parent = btn
                        btn.MouseButton1Click:Connect(function()
                            local idx = table.find(selected, opt)
                            if idx then table.remove(selected, idx) else
                                if #selected < maxSelect then table.insert(selected, opt) elseif maxSelect == 1 then selected = {opt} end
                            end
                            subLabel.Text = GetSelectionText()
                            UpdateList()
                            callback(selected)
                        end)
                    end
                end
                task.defer(function() List.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y) end)
            end
            SearchBox:GetPropertyChangedSignal("Text"):Connect(UpdateList)
            local function TogglePanel(state)
                if state then Overlay.Visible = true UpdateList() TweenService:Create(Panel, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -240, 0, 0)}):Play()
                else TweenService:Create(Panel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 0, 0, 0)}):Play() task.delay(0.3, function() Overlay.Visible = false end) end
            end
            local trigger = Instance.new("TextButton")
            trigger.Size = UDim2.fromScale(1, 1)
            trigger.BackgroundTransparency = 1
            trigger.Text = ""
            trigger.Parent = frame
            trigger.MouseButton1Click:Connect(function() TogglePanel(true) end)
            Overlay.MouseButton1Click:Connect(function() TogglePanel(false) end)
        end
 
        function Elements:AddColorPicker(title: string, sub: string, default: Color3, side: string?, callback: (Color3) -> ())
            local h, s, v = Color3.toHSV(default)
            local originalColor = default
            local currentColor = default
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 80)
            frame.BackgroundColor3 = Theme.Card
            frame.Parent = (side == "Right" and RightColumn) or LeftColumn
            Corner(10, frame)
            Stroke(Theme.Border, 1, frame)
            local ibg = Instance.new("Frame")
            ibg.Size = UDim2.fromOffset(60, 60)
            ibg.Position = UDim2.new(0, 12, 0.5, 0)
            ibg.AnchorPoint = Vector2.new(0, 0.5)
            ibg.BackgroundColor3 = Theme.IconBg
            ibg.Parent = frame
            Corner(10, ibg)
            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.fromScale(0.7, 0.7)
            icon.Position = UDim2.fromScale(0.5, 0.5)
            icon.AnchorPoint = Vector2.new(0.5, 0.5)
            icon.Image = "rbxassetid://114291598644525"
            icon.BackgroundTransparency = 1
            icon.Parent = ibg
            local label = Instance.new("TextLabel")
            label.Text = title
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            label.TextColor3 = Theme.TextPrimary
            label.Position = UDim2.new(0, 82, 0.5, -10)
            label.AnchorPoint = Vector2.new(0, 0.5)
            label.Size = UDim2.new(1, -140, 0, 20)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.BackgroundTransparency = 1
            label.Parent = frame
            local subLabel = Instance.new("TextLabel")
            subLabel.Text = sub
            subLabel.Font = Enum.Font.GothamMedium
            subLabel.TextSize = 11
            subLabel.TextColor3 = Theme.TextSec
            subLabel.Position = UDim2.new(0, 82, 0.5, 10)
            subLabel.AnchorPoint = Vector2.new(0, 0.5)
            subLabel.Size = UDim2.new(1, -140, 0, 20)
            subLabel.TextXAlignment = Enum.TextXAlignment.Left
            subLabel.BackgroundTransparency = 1
            subLabel.Parent = frame
            local ColorSquare = Instance.new("TextButton")
            ColorSquare.Size = UDim2.fromOffset(55, 35)
            ColorSquare.Position = UDim2.new(1, -15, 0.5, 0)
            ColorSquare.AnchorPoint = Vector2.new(1, 0.5)
            ColorSquare.BackgroundColor3 = default
            ColorSquare.Text = ""
            ColorSquare.Parent = frame
            Corner(5, ColorSquare)
            Stroke(Theme.Border, 1, ColorSquare)
            local Overlay = Instance.new("TextButton")
            Overlay.Size = UDim2.fromScale(1, 1)
            Overlay.BackgroundTransparency = 1
            Overlay.Text = ""
            Overlay.Visible = false
            Overlay.ZIndex = 500
            Overlay.Parent = MainFrame
            local Panel = Instance.new("Frame")
            Panel.Size = UDim2.new(0, 240, 1, 0)
            Panel.Position = UDim2.new(1, 0, 0, 0)
            Panel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            Panel.BorderSizePixel = 0
            Panel.ZIndex = 501
            Panel.ClipsDescendants = true
            Panel.Active = true
            Panel.Parent = MainFrame
            Stroke(Theme.Border, 1, Panel)
            local Title = Instance.new("TextLabel")
            Title.Text = "Color Picker"
            Title.Font = Enum.Font.GothamBold
            Title.TextSize = 16
            Title.TextColor3 = Theme.TextPrimary
            Title.Position = UDim2.new(0, 15, 0, 15)
            Title.Size = UDim2.new(0, 100, 0, 20)
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.ZIndex = 502
            Title.Parent = Panel
            local HexInput = Instance.new("TextBox")
            HexInput.Size = UDim2.new(1, -30, 0, 30)
            HexInput.Position = UDim2.new(0, 15, 0, 45)
            HexInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            HexInput.Text = "#" .. default:ToHex():upper()
            HexInput.Font = Enum.Font.Code
            HexInput.TextSize = 12
            HexInput.TextColor3 = Theme.TextPrimary
            HexInput.ZIndex = 502
            HexInput.Parent = Panel
            Corner(6, HexInput)
            Stroke(Theme.Border, 1, HexInput)
            local SVMap = Instance.new("ImageLabel")
            SVMap.Size = UDim2.new(1, -30, 0, 150)
            SVMap.Position = UDim2.new(0, 15, 0, 85)
            SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            SVMap.Image = "rbxassetid://4155801252"
            SVMap.ZIndex = 502
            SVMap.Active = true
            SVMap.Parent = Panel
            Corner(8, SVMap)
            local SVCursor = Instance.new("Frame")
            SVCursor.Size = UDim2.fromOffset(10, 10)
            SVCursor.Position = UDim2.fromScale(s, 1 - v)
            SVCursor.AnchorPoint = Vector2.new(0.5, 0.5)
            SVCursor.BackgroundColor3 = Color3.new(1, 1, 1)
            SVCursor.ZIndex = 503
            SVCursor.Parent = SVMap
            Corner(10, SVCursor)
            Stroke(Color3.new(0, 0, 0), 1, SVCursor)
            local HueSlider = Instance.new("ImageLabel")
            HueSlider.Size = UDim2.new(1, -30, 0, 20)
            HueSlider.Position = UDim2.new(0, 15, 0, 245)
            HueSlider.BackgroundColor3 = Color3.new(1, 1, 1)
            HueSlider.ZIndex = 502
            HueSlider.Active = true
            HueSlider.Parent = Panel
            Corner(6, HueSlider)
            local HueGradient = Instance.new("UIGradient")
            HueGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                ColorSequenceKeypoint.new(0.16, Color3.fromHSV(0.16, 1, 1)),
                ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
                ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
                ColorSequenceKeypoint.new(0.66, Color3.fromHSV(0.66, 1, 1)),
                ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
            })
            HueGradient.Parent = HueSlider
            local HueCursor = Instance.new("Frame")
            HueCursor.Size = UDim2.new(0, 4, 1, 0)
            HueCursor.Position = UDim2.fromScale(h, 0)
            HueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
            HueCursor.ZIndex = 503
            HueCursor.Parent = HueSlider
            Corner(2, HueCursor)
            local PreviewContainer = Instance.new("Frame")
            PreviewContainer.Size = UDim2.new(1, -30, 0, 40)
            PreviewContainer.Position = UDim2.new(0, 15, 0, 275)
            PreviewContainer.BackgroundTransparency = 1
            PreviewContainer.ZIndex = 502
            PreviewContainer.Active = true
            PreviewContainer.Parent = Panel
            local NewColorPreview = Instance.new("Frame")
            NewColorPreview.Size = UDim2.new(0.5, -5, 1, 0)
            NewColorPreview.BackgroundColor3 = default
            NewColorPreview.ZIndex = 503
            NewColorPreview.Parent = PreviewContainer
            Corner(6, NewColorPreview)
            Stroke(Theme.Border, 1, NewColorPreview)
            local OldColorPreview = Instance.new("Frame")
            OldColorPreview.Size = UDim2.new(0.5, -5, 1, 0)
            OldColorPreview.Position = UDim2.new(0.5, 5, 0, 0)
            OldColorPreview.BackgroundColor3 = default
            OldColorPreview.ZIndex = 503
            OldColorPreview.Parent = PreviewContainer
            Corner(6, OldColorPreview)
            Stroke(Theme.Border, 1, OldColorPreview)
            local ApplyBtn = Instance.new("TextButton")
            ApplyBtn.Size = UDim2.new(1, -30, 0, 35)
            ApplyBtn.Position = UDim2.new(0, 15, 0, 325)
            ApplyBtn.BackgroundColor3 = Theme.Accent
            ApplyBtn.Text = "Apply"
            ApplyBtn.Font = Enum.Font.GothamBold
            ApplyBtn.TextColor3 = Color3.new(1, 1, 1)
            ApplyBtn.TextSize = 14
            ApplyBtn.ZIndex = 502
            ApplyBtn.Parent = Panel
            Corner(6, ApplyBtn)
            local function UpdateColor(skipHex: boolean?)
                currentColor = Color3.fromHSV(h, s, v)
                NewColorPreview.BackgroundColor3 = currentColor
                SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                if not skipHex then HexInput.Text = "#" .. currentColor:ToHex():upper() end
                SVCursor.Position = UDim2.fromScale(s, 1 - v)
                HueCursor.Position = UDim2.fromScale(h, 0)
            end
            HexInput.FocusLost:Connect(function()
                local success, result = pcall(Color3.fromHex, HexInput.Text)
                if success then local nh, ns, nv = Color3.toHSV(result) h, s, v = nh, ns, nv UpdateColor(true) else HexInput.Text = "#" .. currentColor:ToHex():upper() end
            end)
            local draggingSV = false
            SVMap.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSV = true end end)
            local draggingHue = false
            HueSlider.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingHue = true end end)
            UserInputService.InputChanged:Connect(function(input)
                if draggingSV and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local pos = Vector2.new(math.clamp((input.Position.X - SVMap.AbsolutePosition.X) / SVMap.AbsoluteSize.X, 0, 1), math.clamp((input.Position.Y - SVMap.AbsolutePosition.Y) / SVMap.AbsoluteSize.Y, 0, 1))
                    s = pos.X v = 1 - pos.Y UpdateColor()
                elseif draggingHue and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    h = math.clamp((input.Position.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1) UpdateColor()
                end
            end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSV = false draggingHue = false end end)
            local function TogglePanel(state)
                if state then originalColor = currentColor OldColorPreview.BackgroundColor3 = originalColor Overlay.Visible = true TweenService:Create(Panel, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -240, 0, 0)}):Play()
                else TweenService:Create(Panel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 0, 0, 0)}):Play() task.delay(0.3, function() Overlay.Visible = false end) end
            end
            ApplyBtn.MouseButton1Click:Connect(function() ColorSquare.BackgroundColor3 = currentColor callback(currentColor) TogglePanel(false) end)
            ColorSquare.MouseButton1Click:Connect(function() TogglePanel(true) end)
        end
 
    return Elements
    end
    return Window
end
 
return AstralLib
