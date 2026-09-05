local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local ImGuiLib = {}

function ImGuiLib:CreateWindow(config)
    local title = config.Title or "ImGui Menu"
    local size = config.Size or Vector2.new(350, 420)
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CustomImGui_Lib"
    ScreenGui.ResetOnSpawn = false
    
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui) 
    elseif gethui then ScreenGui.Parent = gethui() 
    else ScreenGui.Parent = CoreGui end
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, size.X, 0, size.Y)
    MainFrame.Position = UDim2.new(0, 100, 0, 100)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 1
    MainFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 22)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -70, 1, 0)
    TitleText.Position = UDim2.new(0, 8, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = title
    TitleText.TextColor3 = Color3.fromRGB(240, 240, 240)
    TitleText.Font = Enum.Font.Code
    TitleText.TextSize = 13
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 22, 1, 0)
    CloseButton.Position = UDim2.new(1, -22, 0, 0)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "[X]"
    CloseButton.TextColor3 = Color3.fromRGB(200, 80, 80)
    CloseButton.Font = Enum.Font.Code
    CloseButton.TextSize = 12
    CloseButton.Parent = TitleBar
    CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 22, 1, 0)
    MinimizeButton.Position = UDim2.new(1, -44, 0, 0)
    MinimizeButton.BackgroundTransparency = 1
    MinimizeButton.Text = "[-]"
    MinimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    MinimizeButton.Font = Enum.Font.Code
    MinimizeButton.TextSize = 12
    MinimizeButton.Parent = TitleBar
    
    local IsMinimized = false
    local IsTweening = false
    local currentOpacity = 0  -- 0 = fully opaque, 1 = fully transparent

    -- Opacity slider: right-click title bar and drag horizontally to adjust
    local OpacityDragging = false
    local OpacityDragStartX = 0
    local OpacityDragStartVal = 0

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            OpacityDragging = true
            OpacityDragStartX = input.Position.X
            OpacityDragStartVal = currentOpacity
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if OpacityDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = (input.Position.X - OpacityDragStartX) / 200
            currentOpacity = math.clamp(OpacityDragStartVal + delta, 0, 0.9)
            MainFrame.BackgroundTransparency = currentOpacity
            TitleBar.BackgroundTransparency = currentOpacity
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            OpacityDragging = false
        end
    end)

    -- ClipFrame sits below the title bar and hard-clips everything inside it.
    -- This stops scrolled content from bleeding over the title bar while
    -- keeping ContentScroll.ClipsDescendants = false so dropdowns still work.
    local ClipFrame = Instance.new("Frame")
    ClipFrame.Name = "ClipFrame"
    ClipFrame.Size = UDim2.new(1, 0, 1, -22)
    ClipFrame.Position = UDim2.new(0, 0, 0, 22)
    ClipFrame.BackgroundTransparency = 1
    ClipFrame.BorderSizePixel = 0
    ClipFrame.ClipsDescendants = true
    ClipFrame.Parent = MainFrame

    local ContentScroll = Instance.new("ScrollingFrame")
    ContentScroll.Size = UDim2.new(1, -10, 1, -6)
    ContentScroll.Position = UDim2.new(0, 5, 0, 4)
    ContentScroll.BackgroundTransparency = 1
    ContentScroll.BorderSizePixel = 0
    ContentScroll.ScrollBarThickness = 4
    ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70)
    ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentScroll.ClipsDescendants = false
    ContentScroll.Parent = ClipFrame

    -- Smooth minimize: tween height instead of snapping
    local function setMinimized(minimized)
        if IsTweening then return end
        IsTweening = true
        IsMinimized = minimized
        MinimizeButton.Text = minimized and "[+]" or "[-]"

        if minimized then
            ContentScroll.CanvasPosition = Vector2.new(0, 0)
            local tween = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, size.X, 0, 22)
            })
            tween:Play()
            tween.Completed:Connect(function()
                ClipFrame.Visible = false
                IsTweening = false
            end)
        else
            ClipFrame.Visible = true
            local tween = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, size.X, 0, size.Y)
            })
            tween:Play()
            tween.Completed:Connect(function()
                IsTweening = false
            end)
        end
    end

    MinimizeButton.MouseButton1Click:Connect(function()
        setMinimized(not IsMinimized)
    end)
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 5)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = ContentScroll
    
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentScroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
    end)

    local WindowObj = {}
    
    function WindowObj:CreateHeader(headerConfig)
        local headerName = headerConfig.Name or "Category"
        
        local HeaderFrame = Instance.new("Frame")
        HeaderFrame.Size = UDim2.new(1, 0, 0, 22)
        HeaderFrame.BackgroundColor3 = Color3.fromRGB(35, 45, 55)
        HeaderFrame.BorderSizePixel = 1
        HeaderFrame.BorderColor3 = Color3.fromRGB(50, 65, 80)
        HeaderFrame.Parent = ContentScroll
        
        local HeaderText = Instance.new("TextLabel")
        HeaderText.Size = UDim2.new(1, 0, 1, 0)
        HeaderText.Position = UDim2.new(0, 6, 0, 0)
        HeaderText.BackgroundTransparency = 1
        HeaderText.Text = "[+] " .. headerName
        HeaderText.TextColor3 = Color3.fromRGB(200, 220, 255)
        HeaderText.Font = Enum.Font.Code
        HeaderText.TextSize = 12
        HeaderText.TextXAlignment = Enum.TextXAlignment.Left
        HeaderText.Parent = HeaderFrame
        
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, 0, 0, 0)
        Container.BackgroundTransparency = 1
        Container.AutomaticSize = Enum.AutomaticSize.Y
        Container.Visible = false
        Container.ZIndex = 2
        Container.Parent = ContentScroll
        
        local ContainerLayout = Instance.new("UIListLayout")
        ContainerLayout.Padding = UDim.new(0, 5)
        ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContainerLayout.Parent = Container
        
        local Expanded = false
        HeaderFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Expanded = not Expanded
                Container.Visible = Expanded
                HeaderText.Text = (Expanded and "[-] " or "[+] ") .. headerName
            end
        end)
        
        local HeaderObj = {}

        function HeaderObj:CreateButton(bConfig)
            local buttonName = bConfig.Name or "Button"
            local callback = bConfig.Callback or function() end
            
            local ButtonFrame = Instance.new("Frame")
            ButtonFrame.Size = UDim2.new(1, 0, 0, 22)
            ButtonFrame.BackgroundTransparency = 1
            ButtonFrame.Parent = Container
            
            local ActualButton = Instance.new("TextButton")
            ActualButton.Size = UDim2.new(1, -15, 0, 18)
            ActualButton.Position = UDim2.new(0, 5, 0, 2)
            ActualButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            ActualButton.BorderSizePixel = 1
            ActualButton.BorderColor3 = Color3.fromRGB(70, 70, 70)
            ActualButton.Text = buttonName
            ActualButton.TextColor3 = Color3.fromRGB(230, 230, 230)
            ActualButton.Font = Enum.Font.Code
            ActualButton.TextSize = 11
            ActualButton.Parent = ButtonFrame

            ActualButton.MouseEnter:Connect(function() ActualButton.TextColor3 = Color3.fromRGB(30, 150, 255) end)
            ActualButton.MouseLeave:Connect(function() ActualButton.TextColor3 = Color3.fromRGB(230, 230, 230) end)
            
            ActualButton.MouseButton1Click:Connect(function()
                task.spawn(callback)
            end)
        end
        
        function HeaderObj:CreateToggle(tConfig)
            local state = tConfig.Default or false
            local callback = tConfig.Callback or function() end
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 20)
            ToggleFrame.BackgroundTransparency = 1
            ToggleFrame.Parent = Container
            local Indicator = Instance.new("Frame")
            Indicator.Size = UDim2.new(0, 12, 0, 12)
            Indicator.Position = UDim2.new(0, 5, 0, 4)
            Indicator.BackgroundColor3 = state and Color3.fromRGB(30, 120, 215) or Color3.fromRGB(45, 45, 45)
            Indicator.BorderSizePixel = 1
            Indicator.BorderColor3 = Color3.fromRGB(70, 70, 70)
            Indicator.Parent = ToggleFrame
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -25, 1, 0)
            Label.Position = UDim2.new(0, 24, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = tConfig.Name
            Label.TextColor3 = Color3.fromRGB(220, 220, 220)
            Label.Font = Enum.Font.Code
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleFrame
            ToggleFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    state = not state
                    Indicator.BackgroundColor3 = state and Color3.fromRGB(30, 120, 215) or Color3.fromRGB(45, 45, 45)
                    callback(state)
                end
            end)
        end
        
        function HeaderObj:CreateSlider(sConfig)
            local min = sConfig.Min or 0
            local max = sConfig.Max or 100
            local current = sConfig.Default or min
            local callback = sConfig.Callback or function() end
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, 0, 0, 34)
            SliderFrame.BackgroundTransparency = 1
            SliderFrame.Parent = Container
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -10, 0, 14)
            Label.Position = UDim2.new(0, 5, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = sConfig.Name .. " [" .. tostring(current) .. "]"
            Label.TextColor3 = Color3.fromRGB(220, 220, 220)
            Label.Font = Enum.Font.Code
            Label.TextSize = 11
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame
            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(1, -15, 0, 10)
            Track.Position = UDim2.new(0, 5, 0, 16)
            Track.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Track.BorderSizePixel = 1
            Track.BorderColor3 = Color3.fromRGB(70, 70, 70)
            Track.Parent = SliderFrame
            local Fill = Instance.new("Frame")
            local percent = (current - min) / (max - min)
            Fill.Size = UDim2.new(percent, 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(30, 120, 215)
            Fill.BorderSizePixel = 0
            Fill.Parent = Track
            local function updateSlider(input)
                local xOffset = math.clamp(input.Position.X - Track.AbsolutePosition.X, 0, Track.AbsoluteSize.X)
                local newPercent = xOffset / Track.AbsoluteSize.X
                local newValue = math.floor(min + (newPercent * (max - min)))
                Fill.Size = UDim2.new(newPercent, 0, 1, 0)
                Label.Text = sConfig.Name .. " [" .. tostring(newValue) .. "]"
                callback(newValue)
            end
            local dragging = false
            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true updateSlider(input) end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
        end

        function HeaderObj:CreateDropdown(dConfig)
            local options = dConfig.Options or {}
            local currentSelection = dConfig.Default or options[1] or "None"
            local callback = dConfig.Callback or function() end
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Size = UDim2.new(1, 0, 0, 36)
            DropdownFrame.BackgroundTransparency = 1
            DropdownFrame.Parent = Container
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -10, 0, 14)
            Label.Position = UDim2.new(0, 5, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = dConfig.Name
            Label.TextColor3 = Color3.fromRGB(220, 220, 220)
            Label.Font = Enum.Font.Code
            Label.TextSize = 11
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = DropdownFrame
            local SelectBox = Instance.new("TextButton")
            SelectBox.Size = UDim2.new(1, -15, 0, 18)
            SelectBox.Position = UDim2.new(0, 5, 0, 15)
            SelectBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            SelectBox.BorderSizePixel = 1
            SelectBox.BorderColor3 = Color3.fromRGB(65, 65, 65)
            SelectBox.Text = "  " .. currentSelection .. "  ▼"
            SelectBox.TextColor3 = Color3.fromRGB(240, 240, 240)
            SelectBox.Font = Enum.Font.Code
            SelectBox.TextSize = 11
            SelectBox.TextXAlignment = Enum.TextXAlignment.Left
            SelectBox.ZIndex = 4
            SelectBox.Parent = DropdownFrame
            local OptionsList = Instance.new("ScrollingFrame")
            OptionsList.Size = UDim2.new(1, 0, 0, 0)
            OptionsList.Position = UDim2.new(0, 0, 1, 1)
            OptionsList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            OptionsList.BorderSizePixel = 1
            OptionsList.BorderColor3 = Color3.fromRGB(65, 65, 65)
            OptionsList.ScrollBarThickness = 4
            OptionsList.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70)
            OptionsList.CanvasSize = UDim2.new(0, 0, 0, #options * 18)
            OptionsList.Visible = false
            OptionsList.ZIndex = 5
            OptionsList.Parent = SelectBox
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Parent = OptionsList
            local isOpen = false
            local function toggleDropdown()
                isOpen = not isOpen
                OptionsList.Visible = isOpen
                local targetHeight = math.clamp(#options * 18, 0, 100)
                OptionsList.Size = isOpen and UDim2.new(1, 0, 0, targetHeight) or UDim2.new(1, 0, 0, 0)
            end
            SelectBox.MouseButton1Click:Connect(toggleDropdown)
            for _, optName in ipairs(options) do
                local OptButton = Instance.new("TextButton")
                OptButton.Size = UDim2.new(1, 0, 0, 18)
                OptButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                OptButton.BorderSizePixel = 0
                OptButton.Text = "  " .. optName
                OptButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                OptButton.Font = Enum.Font.Code
                OptButton.TextSize = 11
                OptButton.TextXAlignment = Enum.TextXAlignment.Left
                OptButton.ZIndex = 6
                OptButton.Parent = OptionsList
                OptButton.MouseEnter:Connect(function() OptButton.BackgroundColor3 = Color3.fromRGB(30, 120, 215) end)
                OptButton.MouseLeave:Connect(function() OptButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35) end)
                OptButton.MouseButton1Click:Connect(function()
                    currentSelection = optName
                    SelectBox.Text = "  " .. currentSelection .. "  ▼"
                    toggleDropdown()
                    callback(currentSelection)
                end)
            end
        end

        function HeaderObj:CreatePlayerDropdown(pdConfig)
            local callback = pdConfig.Callback or function() end
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Size = UDim2.new(1, 0, 0, 36)
            DropdownFrame.BackgroundTransparency = 1
            DropdownFrame.Parent = Container
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -10, 0, 14)
            Label.Position = UDim2.new(0, 5, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = pdConfig.Name or "Select Player"
            Label.TextColor3 = Color3.fromRGB(220, 220, 220)
            Label.Font = Enum.Font.Code
            Label.TextSize = 11
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = DropdownFrame
            local SelectBox = Instance.new("TextButton")
            SelectBox.Size = UDim2.new(1, -15, 0, 18)
            SelectBox.Position = UDim2.new(0, 5, 0, 15)
            SelectBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            SelectBox.BorderSizePixel = 1
            SelectBox.BorderColor3 = Color3.fromRGB(65, 65, 65)
            SelectBox.Text = "  Select a player...  ▼"
            SelectBox.TextColor3 = Color3.fromRGB(240, 240, 240)
            SelectBox.Font = Enum.Font.Code
            SelectBox.TextSize = 11
            SelectBox.TextXAlignment = Enum.TextXAlignment.Left
            SelectBox.ZIndex = 4
            SelectBox.Parent = DropdownFrame
            local OptionsList = Instance.new("ScrollingFrame")
            OptionsList.Size = UDim2.new(1, 0, 0, 0)
            OptionsList.Position = UDim2.new(0, 0, 1, 1)
            OptionsList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            OptionsList.BorderSizePixel = 1
            OptionsList.BorderColor3 = Color3.fromRGB(65, 65, 65)
            OptionsList.ScrollBarThickness = 4
            OptionsList.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70)
            OptionsList.Visible = false
            OptionsList.ZIndex = 5
            OptionsList.Parent = SelectBox
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Parent = OptionsList
            local isOpen = false
            local function rebuildPlayerList()
                for _, child in ipairs(OptionsList:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                local listCount = 0
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= Players.LocalPlayer then
                        listCount = listCount + 1
                        local OptButton = Instance.new("TextButton")
                        OptButton.Size = UDim2.new(1, 0, 0, 18)
                        OptButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                        OptButton.BorderSizePixel = 0
                        OptButton.Text = "  " .. p.Name
                        OptButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                        OptButton.Font = Enum.Font.Code
                        OptButton.TextSize = 11
                        OptButton.TextXAlignment = Enum.TextXAlignment.Left
                        OptButton.ZIndex = 6
                        OptButton.Parent = OptionsList
                        OptButton.MouseEnter:Connect(function() OptButton.BackgroundColor3 = Color3.fromRGB(30, 120, 215) end)
                        OptButton.MouseLeave:Connect(function() OptButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35) end)
                        OptButton.MouseButton1Click:Connect(function()
                            SelectBox.Text = "  " .. p.Name .. "  ▼"
                            isOpen = false
                            OptionsList.Visible = false
                            OptionsList.Size = UDim2.new(1, 0, 0, 0)
                            callback(p.Name)
                        end)
                    end
                end
                OptionsList.CanvasSize = UDim2.new(0, 0, 0, listCount * 18)
                if isOpen then
                    OptionsList.Size = UDim2.new(1, 0, 0, math.clamp(listCount * 18, 0, 100))
                end
            end
            SelectBox.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                OptionsList.Visible = isOpen
                if isOpen then rebuildPlayerList() else OptionsList.Size = UDim2.new(1, 0, 0, 0) end
            end)
            Players.PlayerAdded:Connect(function() task.wait(0.5) if isOpen then rebuildPlayerList() end end)
            Players.PlayerRemoving:Connect(function(p) 
                if SelectBox.Text == "  " .. p.Name .. "  ▼" then SelectBox.Text = "  Select a player...  ▼" end
                task.wait(0.5) if isOpen then rebuildPlayerList() end 
            end)
        end

        function HeaderObj:CreateTextBox(tbConfig)
            local callback = tbConfig.Callback or function() end
            local TBFrame = Instance.new("Frame")
            TBFrame.Size = UDim2.new(1, 0, 0, 36)
            TBFrame.BackgroundTransparency = 1
            TBFrame.Parent = Container
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -10, 0, 14)
            Label.Position = UDim2.new(0, 5, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = tbConfig.Name
            Label.TextColor3 = Color3.fromRGB(220, 220, 220)
            Label.Font = Enum.Font.Code
            Label.TextSize = 11
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = TBFrame
            local Box = Instance.new("TextBox")
            Box.Size = UDim2.new(1, -15, 0, 18)
            Box.Position = UDim2.new(0, 5, 0, 15)
            Box.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            Box.BorderSizePixel = 1
            Box.BorderColor3 = Color3.fromRGB(65, 65, 65)
            Box.Text = ""
            Box.PlaceholderText = tbConfig.Placeholder or "Type..."
            Box.TextColor3 = Color3.fromRGB(255, 255, 255)
            Box.Font = Enum.Font.Code
            Box.TextSize = 12
            Box.TextXAlignment = Enum.TextXAlignment.Left
            Box.ClearTextOnFocus = false
            Box.Parent = TBFrame
            Box.FocusLost:Connect(function() callback(Box.Text) end)
        end

        function HeaderObj:CreateKeybind(kConfig)
            local currentKey = kConfig.Default or Enum.KeyCode.E
            local mode = kConfig.Mode or "Toggle"
            local callback = kConfig.Callback or function() end
            local listening = false
            local isToggled = false
            
            local BindFrame = Instance.new("Frame")
            BindFrame.Size = UDim2.new(1, 0, 0, 22)
            BindFrame.BackgroundTransparency = 1
            BindFrame.Parent = Container
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -80, 1, 0)
            Label.Position = UDim2.new(0, 5, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = kConfig.Name
            Label.TextColor3 = Color3.fromRGB(220, 220, 220)
            Label.Font = Enum.Font.Code
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = BindFrame
            
            local BindBtn = Instance.new("TextButton")
            BindBtn.Size = UDim2.new(0, 70, 0, 18)
            BindBtn.Position = UDim2.new(1, -80, 0, 2)
            BindBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            BindBtn.BorderSizePixel = 1
            BindBtn.BorderColor3 = Color3.fromRGB(70, 70, 70)
            BindBtn.Text = "[" .. currentKey.Name .. "]"
            BindBtn.TextColor3 = Color3.fromRGB(30, 150, 255)
            BindBtn.Font = Enum.Font.Code
            BindBtn.TextSize = 11
            BindBtn.Parent = BindFrame
            
            BindBtn.MouseButton1Click:Connect(function()
                listening = true
                BindBtn.Text = "[...]"
                BindBtn.TextColor3 = Color3.fromRGB(230, 200, 50)
            end)
            
            UserInputService.InputBegan:Connect(function(input, gpe)
                if gpe then return end
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    currentKey = input.KeyCode
                    BindBtn.Text = "[" .. currentKey.Name .. "]"
                    BindBtn.TextColor3 = Color3.fromRGB(30, 150, 255)
                elseif not listening and input.KeyCode == currentKey then
                    if mode == "Toggle" then
                        isToggled = not isToggled
                        callback(isToggled)
                    elseif mode == "Hold" then
                        callback(true)
                    end
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input, gpe)
                if gpe then return end
                if not listening and mode == "Hold" and input.KeyCode == currentKey then
                    callback(false)
                end
            end)
        end

        function HeaderObj:CreateParagraph(pConfig)
            local contentText = pConfig.Text or "Status log output."
            
            local ParaFrame = Instance.new("Frame")
            ParaFrame.Size = UDim2.new(1, -15, 0, 0)
            ParaFrame.Position = UDim2.new(0, 5, 0, 0)
            ParaFrame.BackgroundTransparency = 1
            ParaFrame.AutomaticSize = Enum.AutomaticSize.Y
            ParaFrame.Parent = Container
            
            local TextLabel = Instance.new("TextLabel")
            TextLabel.Size = UDim2.new(1, 0, 1, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.Text = contentText
            TextLabel.TextColor3 = pConfig.Color or Color3.fromRGB(170, 180, 190)
            TextLabel.Font = Enum.Font.Code
            TextLabel.TextSize = 11
            TextLabel.TextWrapped = true
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.Parent = ParaFrame
            
            local ParaObj = {}
            function ParaObj:SetText(newText)
                TextLabel.Text = newText
            end
            return ParaObj
        end


        function HeaderObj:CreateLabel(lConfig)
            local LabelFrame = Instance.new("Frame")
            LabelFrame.Size = UDim2.new(1, 0, 0, 18)
            LabelFrame.BackgroundTransparency = 1
            LabelFrame.Parent = Container

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Size = UDim2.new(1, -10, 1, 0)
            TextLabel.Position = UDim2.new(0, 5, 0, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.Text = lConfig.Text or ""
            TextLabel.TextColor3 = lConfig.Color or Color3.fromRGB(180, 180, 180)
            TextLabel.Font = Enum.Font.Code
            TextLabel.TextSize = 11
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.Parent = LabelFrame

            local LabelObj = {}
            function LabelObj:SetText(newText)
                TextLabel.Text = newText
            end
            function LabelObj:SetColor(newColor)
                TextLabel.TextColor3 = newColor
            end
            return LabelObj
        end

        return HeaderObj
    end
    
    return WindowObj
end


local _notifCounter = 0

function ImGuiLib:Notify(config)
    local title    = config.Title or "Notification"
    local message  = config.Message or ""
    local duration = config.Duration or 3
    local nColor   = config.Color or Color3.fromRGB(30, 120, 215)

    -- Find or create the notification holder
    local holder = CoreGui:FindFirstChild("ImGui_NotifHolder")
    if not holder then
        holder = Instance.new("ScreenGui")
        holder.Name = "ImGui_NotifHolder"
        holder.ResetOnSpawn = false
        holder.DisplayOrder = 999
        if syn and syn.protect_gui then syn.protect_gui(holder)
        elseif gethui then holder.Parent = gethui()
        else holder.Parent = CoreGui end

        local layout = Instance.new("UIListLayout")
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        layout.Padding = UDim.new(0, 6)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.Parent = holder

        local padding = Instance.new("UIPadding")
        padding.PaddingBottom = UDim.new(0, 12)
        padding.PaddingRight = UDim.new(0, 12)
        padding.Parent = holder
    end

    -- Each notification gets a unique order so they stack newest-on-top
    _notifCounter = _notifCounter + 1

    -- Outer wrapper: UIListLayout positions this; ClipsDescendants lets us slide the inner frame
    local Wrapper = Instance.new("Frame")
    Wrapper.Size = UDim2.new(0, 220, 0, 48)
    Wrapper.BackgroundTransparency = 1
    Wrapper.BorderSizePixel = 0
    Wrapper.ClipsDescendants = true
    Wrapper.LayoutOrder = _notifCounter
    Wrapper.Parent = holder

    -- Inner frame slides in/out horizontally inside the wrapper
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(1, 0, 1, 0)
    NotifFrame.Position = UDim2.new(1, 0, 0, 0)  -- starts off-screen to the right
    NotifFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.BackgroundTransparency = 0.1
    NotifFrame.ClipsDescendants = true
    NotifFrame.Parent = Wrapper

    -- Accent bar on the left
    local Accent = Instance.new("Frame")
    Accent.Size = UDim2.new(0, 3, 1, 0)
    Accent.BackgroundColor3 = nColor
    Accent.BorderSizePixel = 0
    Accent.Parent = NotifFrame

    -- Title
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -12, 0, 18)
    TitleLabel.Position = UDim2.new(0, 10, 0, 4)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 11
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = NotifFrame

    -- Message
    local MsgLabel = Instance.new("TextLabel")
    MsgLabel.Size = UDim2.new(1, -12, 0, 18)
    MsgLabel.Position = UDim2.new(0, 10, 0, 24)
    MsgLabel.BackgroundTransparency = 1
    MsgLabel.Text = message
    MsgLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    MsgLabel.Font = Enum.Font.Code
    MsgLabel.TextSize = 11
    MsgLabel.TextXAlignment = Enum.TextXAlignment.Left
    MsgLabel.Parent = NotifFrame

    -- Progress bar at the bottom
    local ProgressBg = Instance.new("Frame")
    ProgressBg.Size = UDim2.new(1, 0, 0, 2)
    ProgressBg.Position = UDim2.new(0, 0, 1, -2)
    ProgressBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ProgressBg.BorderSizePixel = 0
    ProgressBg.Parent = NotifFrame

    local ProgressFill = Instance.new("Frame")
    ProgressFill.Size = UDim2.new(1, 0, 1, 0)
    ProgressFill.BackgroundColor3 = nColor
    ProgressFill.BorderSizePixel = 0
    ProgressFill.Parent = ProgressBg

    -- Slide inner frame in (UIListLayout handles vertical stacking via Wrapper)
    TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()

    -- Progress bar drain
    TweenService:Create(ProgressFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0)
    }):Play()

    -- Slide out then destroy wrapper (removes from stack cleanly)
    task.delay(duration, function()
        TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 0, 0, 0)
        }):Play()
        task.wait(0.3)
        Wrapper:Destroy()
    end)
end

return ImGuiLib
