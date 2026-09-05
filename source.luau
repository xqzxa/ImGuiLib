local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local ImGuiLib = {}

--=============================================================
-- THEME
-- Colors pulled from Dear ImGui's default dark style so the
-- recreated widgets read the same as the reference screenshots.
--=============================================================
local Theme = {
    WindowBg        = Color3.fromRGB(15, 15, 15),
    TitleBg         = Color3.fromRGB(10, 10, 10),
    TitleBgActive   = Color3.fromRGB(41, 74, 122),
    Border          = Color3.fromRGB(90, 90, 100),

    Text            = Color3.fromRGB(255, 255, 255),
    TextDim         = Color3.fromRGB(175, 180, 188),
    TextDisabled    = Color3.fromRGB(128, 128, 128),

    FrameBg         = Color3.fromRGB(41, 50, 66),
    FrameBgHover    = Color3.fromRGB(54, 68, 92),
    FrameBgActive   = Color3.fromRGB(66, 86, 120),

    Button          = Color3.fromRGB(59, 90, 148),
    ButtonHover     = Color3.fromRGB(66, 150, 250),
    ButtonActive    = Color3.fromRGB(15, 135, 250),

    HeaderHover     = Color3.fromRGB(41, 74, 122),
    HeaderActiveBg  = Color3.fromRGB(30, 54, 88),

    CheckMark       = Color3.fromRGB(66, 150, 250),
    SliderGrab      = Color3.fromRGB(61, 133, 224),

    ScrollGrab      = Color3.fromRGB(79, 79, 79),
    PopupBg         = Color3.fromRGB(20, 20, 20),

    Warning         = Color3.fromRGB(230, 180, 60),
    Danger          = Color3.fromRGB(196, 43, 28),
}

local FONT_TITLE = Enum.Font.SourceSansBold
local FONT_BODY  = Enum.Font.SourceSans
local FONT_BOLD  = Enum.Font.SourceSansSemibold

--=============================================================
-- HELPERS
--=============================================================
local function corner(inst, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 3)
    c.Parent = inst
    return c
end

local function stroke(inst, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = inst
    return s
end

local function newFrame(props)
    local f = Instance.new("Frame")
    for k, v in pairs(props) do
        if k ~= "Parent" then
            f[k] = v
        end
    end
    if props.Parent then
        f.Parent = props.Parent
    end
    return f
end

local function newLabel(props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font = props.Font or FONT_BODY
    l.TextColor3 = props.TextColor3 or Theme.Text
    l.TextSize = props.TextSize or 13
    l.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
    l.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
    for k, v in pairs(props) do
        if k ~= "Parent" and k ~= "Font" and k ~= "TextColor3" and k ~= "TextSize"
            and k ~= "TextXAlignment" and k ~= "TextYAlignment" then
            l[k] = v
        end
    end
    if props.Parent then
        l.Parent = props.Parent
    end
    return l
end

local function fmtNumber(value, decimals)
    if decimals and decimals > 0 then
        return string.format("%." .. decimals .. "f", value)
    end
    return tostring(math.floor(value))
end

--=============================================================
-- WINDOW
--=============================================================
function ImGuiLib:CreateWindow(config)
    config = config or {}
    local title = config.Title or "ImGui Menu"
    local size = config.Size or Vector2.new(350, 420)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CustomImGui_Lib"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = CoreGui
    end

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, size.X, 0, size.Y)
    MainFrame.Position = UDim2.new(0, 100, 0, 100)
    MainFrame.BackgroundColor3 = Theme.WindowBg
    MainFrame.BorderSizePixel = 1
    MainFrame.BorderColor3 = Theme.Border
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    -- Title bar -------------------------------------------------
    local TitleBar = newFrame({
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = Theme.TitleBgActive,
        BorderSizePixel = 0,
        Parent = MainFrame,
    })

    local CollapseButton = Instance.new("TextButton")
    CollapseButton.Name = "CollapseButton"
    CollapseButton.Size = UDim2.new(0, 18, 0, 18)
    CollapseButton.Position = UDim2.new(0, 4, 0, 3)
    CollapseButton.BackgroundTransparency = 1
    CollapseButton.AutoButtonColor = false
    CollapseButton.Text = "\226\150\190" -- ▾
    CollapseButton.TextColor3 = Theme.Text
    CollapseButton.Font = FONT_BODY
    CollapseButton.TextSize = 12
    CollapseButton.Parent = TitleBar
    corner(CollapseButton, 3)

    CollapseButton.MouseEnter:Connect(function()
        CollapseButton.BackgroundTransparency = 0.4
        CollapseButton.BackgroundColor3 = Theme.FrameBgHover
    end)
    CollapseButton.MouseLeave:Connect(function()
        CollapseButton.BackgroundTransparency = 1
    end)

    local TitleText = newLabel({
        Size = UDim2.new(1, -48, 1, 0),
        Position = UDim2.new(0, 24, 0, 0),
        Text = title,
        Font = FONT_TITLE,
        TextSize = 14,
        Parent = TitleBar,
    })

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 18, 0, 18)
    CloseButton.Position = UDim2.new(1, -22, 0, 3)
    CloseButton.BackgroundTransparency = 1
    CloseButton.AutoButtonColor = false
    CloseButton.Text = "\226\156\149" -- ✕
    CloseButton.TextColor3 = Theme.Text
    CloseButton.Font = FONT_BODY
    CloseButton.TextSize = 12
    CloseButton.Parent = TitleBar
    corner(CloseButton, 3)

    CloseButton.MouseEnter:Connect(function()
        CloseButton.BackgroundTransparency = 0
        CloseButton.BackgroundColor3 = Theme.Danger
    end)
    CloseButton.MouseLeave:Connect(function()
        CloseButton.BackgroundTransparency = 1
    end)
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local IsMinimized = false
    local IsTweening = false
    local currentOpacity = 0 -- 0 = fully opaque, 1 = fully transparent

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
    local ClipFrame = newFrame({
        Name = "ClipFrame",
        Size = UDim2.new(1, 0, 1, -24),
        Position = UDim2.new(0, 0, 0, 24),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = MainFrame,
    })

    local ContentScroll = Instance.new("ScrollingFrame")
    ContentScroll.Size = UDim2.new(1, -10, 1, -8)
    ContentScroll.Position = UDim2.new(0, 5, 0, 4)
    ContentScroll.BackgroundTransparency = 1
    ContentScroll.BorderSizePixel = 0
    ContentScroll.ScrollBarThickness = 4
    ContentScroll.ScrollBarImageColor3 = Theme.ScrollGrab
    ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentScroll.ClipsDescendants = false
    ContentScroll.Parent = ClipFrame

    -- Smooth minimize: tween height instead of snapping
    local function setMinimized(minimized)
        if IsTweening then return end
        IsTweening = true
        IsMinimized = minimized
        CollapseButton.Text = minimized and "\226\150\184" or "\226\150\190" -- ▸ / ▾

        if minimized then
            ContentScroll.CanvasPosition = Vector2.new(0, 0)
            local tween = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, size.X, 0, 24)
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

    CollapseButton.MouseButton1Click:Connect(function()
        setMinimized(not IsMinimized)
    end)

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 2)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = ContentScroll

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentScroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
    end)

    local WindowObj = {}

    --=========================================================
    -- COLLAPSING HEADER (sidebar category)
    --=========================================================
    function WindowObj:CreateHeader(headerConfig)
        headerConfig = headerConfig or {}
        local headerName = headerConfig.Name or "Category"

        local HeaderFrame = Instance.new("TextButton")
        HeaderFrame.Name = "Header_" .. headerName
        HeaderFrame.Size = UDim2.new(1, 0, 0, 22)
        HeaderFrame.BackgroundColor3 = Theme.HeaderHover
        HeaderFrame.BackgroundTransparency = 1
        HeaderFrame.AutoButtonColor = false
        HeaderFrame.Text = ""
        HeaderFrame.BorderSizePixel = 0
        HeaderFrame.Parent = ContentScroll
        corner(HeaderFrame, 3)

        local Arrow = newLabel({
            Size = UDim2.new(0, 16, 1, 0),
            Position = UDim2.new(0, 4, 0, 0),
            Text = "\226\150\184", -- ▸
            Font = FONT_BODY,
            TextSize = 11,
            Parent = HeaderFrame,
        })

        local HeaderText = newLabel({
            Size = UDim2.new(1, -24, 1, 0),
            Position = UDim2.new(0, 20, 0, 0),
            Text = headerName,
            Font = FONT_BOLD,
            TextSize = 13,
            Parent = HeaderFrame,
        })

        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, 0, 0, 0)
        Container.BackgroundTransparency = 1
        Container.AutomaticSize = Enum.AutomaticSize.Y
        Container.Visible = false
        Container.ZIndex = 2
        Container.Parent = ContentScroll

        local ContainerPadding = Instance.new("UIPadding")
        ContainerPadding.PaddingLeft = UDim.new(0, 4)
        ContainerPadding.Parent = Container

        local ContainerLayout = Instance.new("UIListLayout")
        ContainerLayout.Padding = UDim.new(0, 5)
        ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContainerLayout.Parent = Container

        local Expanded = false
        HeaderFrame.MouseEnter:Connect(function()
            HeaderFrame.BackgroundTransparency = 0.5
        end)
        HeaderFrame.MouseLeave:Connect(function()
            HeaderFrame.BackgroundTransparency = 1
        end)
        HeaderFrame.MouseButton1Click:Connect(function()
            Expanded = not Expanded
            Container.Visible = Expanded
            Arrow.Text = Expanded and "\226\150\190" or "\226\150\184" -- ▾ / ▸
        end)

        local HeaderObj = {}

        --=====================================================
        -- BUTTON
        --=====================================================
        function HeaderObj:CreateButton(bConfig)
            bConfig = bConfig or {}
            local buttonName = bConfig.Name or "Button"
            local callback = bConfig.Callback or function() end

            local ButtonFrame = newFrame({
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                Parent = Container,
            })

            local ActualButton = Instance.new("TextButton")
            ActualButton.Size = UDim2.new(1, -15, 0, 20)
            ActualButton.Position = UDim2.new(0, 5, 0, 2)
            ActualButton.BackgroundColor3 = Theme.Button
            ActualButton.AutoButtonColor = false
            ActualButton.BorderSizePixel = 0
            ActualButton.Text = buttonName
            ActualButton.TextColor3 = Theme.Text
            ActualButton.Font = FONT_BODY
            ActualButton.TextSize = 13
            ActualButton.Parent = ButtonFrame
            corner(ActualButton, 3)

            ActualButton.MouseEnter:Connect(function() ActualButton.BackgroundColor3 = Theme.ButtonHover end)
            ActualButton.MouseLeave:Connect(function() ActualButton.BackgroundColor3 = Theme.Button end)
            ActualButton.MouseButton1Down:Connect(function() ActualButton.BackgroundColor3 = Theme.ButtonActive end)
            ActualButton.MouseButton1Up:Connect(function() ActualButton.BackgroundColor3 = Theme.ButtonHover end)

            ActualButton.MouseButton1Click:Connect(function()
                task.spawn(callback)
            end)

            local ButtonObj = {}
            function ButtonObj:SetText(newText)
                ActualButton.Text = newText
            end
            return ButtonObj
        end

        --=====================================================
        -- TOGGLE / CHECKBOX
        --=====================================================
        function HeaderObj:CreateToggle(tConfig)
            tConfig = tConfig or {}
            local state = tConfig.Default or false
            local callback = tConfig.Callback or function() end

            local ToggleFrame = Instance.new("TextButton")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 20)
            ToggleFrame.BackgroundTransparency = 1
            ToggleFrame.AutoButtonColor = false
            ToggleFrame.Text = ""
            ToggleFrame.Parent = Container

            local Box = newFrame({
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 5, 0, 2),
                BackgroundColor3 = Theme.FrameBg,
                BorderSizePixel = 0,
                Parent = ToggleFrame,
            })
            corner(Box, 3)
            stroke(Box, Theme.Border, 1)

            local Check = newLabel({
                Size = UDim2.new(1, 0, 1, 0),
                Text = "\226\156\147", -- ✓
                TextColor3 = Theme.CheckMark,
                TextXAlignment = Enum.TextXAlignment.Center,
                TextSize = 13,
                Font = FONT_TITLE,
                Visible = state,
                Parent = Box,
            })

            local Label = newLabel({
                Size = UDim2.new(1, -28, 1, 0),
                Position = UDim2.new(0, 26, 0, 0),
                Text = tConfig.Name or "Toggle",
                TextSize = 13,
                Parent = ToggleFrame,
            })

            local function applyState()
                Check.Visible = state
            end

            ToggleFrame.MouseEnter:Connect(function() stroke(Box, Theme.ButtonHover, 1) end)
            ToggleFrame.MouseButton1Click:Connect(function()
                state = not state
                applyState()
                callback(state)
            end)

            local ToggleObj = {}
            function ToggleObj:Set(newState)
                state = newState and true or false
                applyState()
            end
            function ToggleObj:Get()
                return state
            end
            return ToggleObj
        end

        --=====================================================
        -- SLIDER
        --=====================================================
        function HeaderObj:CreateSlider(sConfig)
            sConfig = sConfig or {}
            local min = sConfig.Min or 0
            local max = sConfig.Max or 100
            local decimals = sConfig.Decimals or 0
            local current = sConfig.Default or min
            local callback = sConfig.Callback or function() end

            local SliderFrame = newFrame({
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundTransparency = 1,
                Parent = Container,
            })

            local Track = newFrame({
                Size = UDim2.new(0.55, -8, 0, 18),
                Position = UDim2.new(0, 5, 0, 2),
                BackgroundColor3 = Theme.FrameBg,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Parent = SliderFrame,
            })
            corner(Track, 3)
            stroke(Track, Theme.Border, 1)

            local Fill = newFrame({
                Size = UDim2.new(math.clamp((current - min) / (max - min), 0, 1), 0, 1, 0),
                BackgroundColor3 = Theme.SliderGrab,
                BorderSizePixel = 0,
                Parent = Track,
            })

            local ValueText = newLabel({
                Size = UDim2.new(1, 0, 1, 0),
                Text = fmtNumber(current, decimals),
                TextXAlignment = Enum.TextXAlignment.Center,
                TextSize = 12,
                ZIndex = 2,
                Parent = Track,
            })

            local NameLabel = newLabel({
                Size = UDim2.new(0.45, -10, 1, 0),
                Position = UDim2.new(0.55, 5, 0, 0),
                Text = sConfig.Name or "Slider",
                TextSize = 13,
                Parent = SliderFrame,
            })

            local function updateSlider(input)
                local xOffset = math.clamp(input.Position.X - Track.AbsolutePosition.X, 0, Track.AbsoluteSize.X)
                local newPercent = Track.AbsoluteSize.X > 0 and (xOffset / Track.AbsoluteSize.X) or 0
                local rawValue = min + (newPercent * (max - min))
                local newValue = decimals > 0 and (math.floor(rawValue * (10 ^ decimals) + 0.5) / (10 ^ decimals)) or math.floor(rawValue)
                Fill.Size = UDim2.new(newPercent, 0, 1, 0)
                ValueText.Text = fmtNumber(newValue, decimals)
                callback(newValue)
            end

            local dragging = false
            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateSlider(input)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            local SliderObj = {}
            function SliderObj:Set(newValue)
                newValue = math.clamp(newValue, min, max)
                local percent = (newValue - min) / (max - min)
                Fill.Size = UDim2.new(percent, 0, 1, 0)
                ValueText.Text = fmtNumber(newValue, decimals)
            end
            return SliderObj
        end

        --=====================================================
        -- DROPDOWN (Combo)
        --=====================================================
        function HeaderObj:CreateDropdown(dConfig)
            dConfig = dConfig or {}
            local options = dConfig.Options or {}
            local currentSelection = dConfig.Default or options[1] or "None"
            local callback = dConfig.Callback or function() end

            local DropdownFrame = newFrame({
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundTransparency = 1,
                ZIndex = 3,
                Parent = Container,
            })

            newLabel({
                Size = UDim2.new(1, -10, 0, 14),
                Position = UDim2.new(0, 5, 0, 0),
                Text = dConfig.Name or "Dropdown",
                TextSize = 12,
                TextColor3 = Theme.TextDim,
                ZIndex = 3,
                Parent = DropdownFrame,
            })

            local SelectBox = Instance.new("TextButton")
            SelectBox.Size = UDim2.new(1, -10, 0, 20)
            SelectBox.Position = UDim2.new(0, 5, 0, 16)
            SelectBox.BackgroundColor3 = Theme.FrameBg
            SelectBox.AutoButtonColor = false
            SelectBox.BorderSizePixel = 0
            SelectBox.Text = "  " .. currentSelection
            SelectBox.TextColor3 = Theme.Text
            SelectBox.Font = FONT_BODY
            SelectBox.TextSize = 13
            SelectBox.TextXAlignment = Enum.TextXAlignment.Left
            SelectBox.ZIndex = 4
            SelectBox.Parent = DropdownFrame
            corner(SelectBox, 3)
            stroke(SelectBox, Theme.Border, 1)

            newLabel({
                Size = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(1, -20, 0, 0),
                Text = "\226\150\190", -- ▾
                TextXAlignment = Enum.TextXAlignment.Center,
                TextSize = 10,
                ZIndex = 5,
                Parent = SelectBox,
            })

            local OptionsList = Instance.new("ScrollingFrame")
            OptionsList.Size = UDim2.new(1, 0, 0, 0)
            OptionsList.Position = UDim2.new(0, 0, 1, 2)
            OptionsList.BackgroundColor3 = Theme.PopupBg
            OptionsList.BorderSizePixel = 0
            OptionsList.ScrollBarThickness = 4
            OptionsList.ScrollBarImageColor3 = Theme.ScrollGrab
            OptionsList.CanvasSize = UDim2.new(0, 0, 0, #options * 20)
            OptionsList.Visible = false
            OptionsList.ZIndex = 5
            OptionsList.Parent = SelectBox
            corner(OptionsList, 3)
            stroke(OptionsList, Theme.Border, 1)

            local ListLayout = Instance.new("UIListLayout")
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ListLayout.Parent = OptionsList

            local isOpen = false
            local function toggleDropdown()
                isOpen = not isOpen
                OptionsList.Visible = isOpen
                local targetHeight = math.clamp(#options * 20, 0, 120)
                OptionsList.Size = isOpen and UDim2.new(1, 0, 0, targetHeight) or UDim2.new(1, 0, 0, 0)
            end
            SelectBox.MouseButton1Click:Connect(toggleDropdown)

            for _, optName in ipairs(options) do
                local OptButton = Instance.new("TextButton")
                OptButton.Size = UDim2.new(1, 0, 0, 20)
                OptButton.BackgroundColor3 = Theme.PopupBg
                OptButton.AutoButtonColor = false
                OptButton.BorderSizePixel = 0
                OptButton.Text = "  " .. optName
                OptButton.TextColor3 = Theme.Text
                OptButton.Font = FONT_BODY
                OptButton.TextSize = 13
                OptButton.TextXAlignment = Enum.TextXAlignment.Left
                OptButton.ZIndex = 6
                OptButton.Parent = OptionsList

                OptButton.MouseEnter:Connect(function() OptButton.BackgroundColor3 = Theme.HeaderHover end)
                OptButton.MouseLeave:Connect(function() OptButton.BackgroundColor3 = Theme.PopupBg end)
                OptButton.MouseButton1Click:Connect(function()
                    currentSelection = optName
                    SelectBox.Text = "  " .. currentSelection
                    toggleDropdown()
                    callback(currentSelection)
                end)
            end

            local DropdownObj = {}
            function DropdownObj:Set(newSelection)
                currentSelection = newSelection
                SelectBox.Text = "  " .. currentSelection
            end
            return DropdownObj
        end

        --=====================================================
        -- PLAYER DROPDOWN
        --=====================================================
        function HeaderObj:CreatePlayerDropdown(pdConfig)
            pdConfig = pdConfig or {}
            local callback = pdConfig.Callback or function() end

            local DropdownFrame = newFrame({
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundTransparency = 1,
                ZIndex = 3,
                Parent = Container,
            })

            newLabel({
                Size = UDim2.new(1, -10, 0, 14),
                Position = UDim2.new(0, 5, 0, 0),
                Text = pdConfig.Name or "Select Player",
                TextSize = 12,
                TextColor3 = Theme.TextDim,
                ZIndex = 3,
                Parent = DropdownFrame,
            })

            local SelectBox = Instance.new("TextButton")
            SelectBox.Size = UDim2.new(1, -10, 0, 20)
            SelectBox.Position = UDim2.new(0, 5, 0, 16)
            SelectBox.BackgroundColor3 = Theme.FrameBg
            SelectBox.AutoButtonColor = false
            SelectBox.BorderSizePixel = 0
            SelectBox.Text = "  Select a player..."
            SelectBox.TextColor3 = Theme.Text
            SelectBox.Font = FONT_BODY
            SelectBox.TextSize = 13
            SelectBox.TextXAlignment = Enum.TextXAlignment.Left
            SelectBox.ZIndex = 4
            SelectBox.Parent = DropdownFrame
            corner(SelectBox, 3)
            stroke(SelectBox, Theme.Border, 1)

            newLabel({
                Size = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(1, -20, 0, 0),
                Text = "\226\150\190",
                TextXAlignment = Enum.TextXAlignment.Center,
                TextSize = 10,
                ZIndex = 5,
                Parent = SelectBox,
            })

            local OptionsList = Instance.new("ScrollingFrame")
            OptionsList.Size = UDim2.new(1, 0, 0, 0)
            OptionsList.Position = UDim2.new(0, 0, 1, 2)
            OptionsList.BackgroundColor3 = Theme.PopupBg
            OptionsList.BorderSizePixel = 0
            OptionsList.ScrollBarThickness = 4
            OptionsList.ScrollBarImageColor3 = Theme.ScrollGrab
            OptionsList.Visible = false
            OptionsList.ZIndex = 5
            OptionsList.Parent = SelectBox
            corner(OptionsList, 3)
            stroke(OptionsList, Theme.Border, 1)

            local ListLayout = Instance.new("UIListLayout")
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
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
                        OptButton.Size = UDim2.new(1, 0, 0, 20)
                        OptButton.BackgroundColor3 = Theme.PopupBg
                        OptButton.AutoButtonColor = false
                        OptButton.BorderSizePixel = 0
                        OptButton.Text = "  " .. p.Name
                        OptButton.TextColor3 = Theme.Text
                        OptButton.Font = FONT_BODY
                        OptButton.TextSize = 13
                        OptButton.TextXAlignment = Enum.TextXAlignment.Left
                        OptButton.ZIndex = 6
                        OptButton.Parent = OptionsList

                        OptButton.MouseEnter:Connect(function() OptButton.BackgroundColor3 = Theme.HeaderHover end)
                        OptButton.MouseLeave:Connect(function() OptButton.BackgroundColor3 = Theme.PopupBg end)
                        OptButton.MouseButton1Click:Connect(function()
                            SelectBox.Text = "  " .. p.Name
                            isOpen = false
                            OptionsList.Visible = false
                            OptionsList.Size = UDim2.new(1, 0, 0, 0)
                            callback(p.Name)
                        end)
                    end
                end
                OptionsList.CanvasSize = UDim2.new(0, 0, 0, listCount * 20)
                if isOpen then
                    OptionsList.Size = UDim2.new(1, 0, 0, math.clamp(listCount * 20, 0, 120))
                end
            end

            SelectBox.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                OptionsList.Visible = isOpen
                if isOpen then
                    rebuildPlayerList()
                else
                    OptionsList.Size = UDim2.new(1, 0, 0, 0)
                end
            end)
            Players.PlayerAdded:Connect(function()
                task.wait(0.5)
                if isOpen then rebuildPlayerList() end
            end)
            Players.PlayerRemoving:Connect(function(p)
                if SelectBox.Text == "  " .. p.Name then
                    SelectBox.Text = "  Select a player..."
                end
                task.wait(0.5)
                if isOpen then rebuildPlayerList() end
            end)
        end

        --=====================================================
        -- TEXTBOX
        --=====================================================
        function HeaderObj:CreateTextBox(tbConfig)
            tbConfig = tbConfig or {}
            local callback = tbConfig.Callback or function() end

            local TBFrame = newFrame({
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundTransparency = 1,
                Parent = Container,
            })

            newLabel({
                Size = UDim2.new(1, -10, 0, 14),
                Position = UDim2.new(0, 5, 0, 0),
                Text = tbConfig.Name or "Input",
                TextSize = 12,
                TextColor3 = Theme.TextDim,
                Parent = TBFrame,
            })

            local Box = Instance.new("TextBox")
            Box.Size = UDim2.new(1, -10, 0, 20)
            Box.Position = UDim2.new(0, 5, 0, 16)
            Box.BackgroundColor3 = Theme.FrameBg
            Box.BorderSizePixel = 0
            Box.Text = tbConfig.Default or ""
            Box.PlaceholderText = tbConfig.Placeholder or "Type..."
            Box.PlaceholderColor3 = Theme.TextDisabled
            Box.TextColor3 = Theme.Text
            Box.Font = FONT_BODY
            Box.TextSize = 13
            Box.TextXAlignment = Enum.TextXAlignment.Left
            Box.ClearTextOnFocus = false
            Box.Parent = TBFrame
            corner(Box, 3)
            local box_stroke = stroke(Box, Theme.Border, 1)

            local Padding = Instance.new("UIPadding")
            Padding.PaddingLeft = UDim.new(0, 6)
            Padding.Parent = Box

            Box.Focused:Connect(function() box_stroke.Color = Theme.ButtonHover end)
            Box.FocusLost:Connect(function()
                box_stroke.Color = Theme.Border
                callback(Box.Text)
            end)

            local TextBoxObj = {}
            function TextBoxObj:Get()
                return Box.Text
            end
            function TextBoxObj:Set(newText)
                Box.Text = newText
            end
            return TextBoxObj
        end

        --=====================================================
        -- KEYBIND
        --=====================================================
        function HeaderObj:CreateKeybind(kConfig)
            kConfig = kConfig or {}
            local currentKey = kConfig.Default or Enum.KeyCode.E
            local mode = kConfig.Mode or "Toggle"
            local callback = kConfig.Callback or function() end
            local listening = false
            local isToggled = false

            local BindFrame = newFrame({
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                Parent = Container,
            })

            newLabel({
                Size = UDim2.new(1, -80, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                Text = kConfig.Name or "Keybind",
                TextSize = 13,
                Parent = BindFrame,
            })

            local BindBtn = Instance.new("TextButton")
            BindBtn.Size = UDim2.new(0, 70, 0, 20)
            BindBtn.Position = UDim2.new(1, -75, 0, 2)
            BindBtn.BackgroundColor3 = Theme.FrameBg
            BindBtn.AutoButtonColor = false
            BindBtn.BorderSizePixel = 0
            BindBtn.Text = "[" .. currentKey.Name .. "]"
            BindBtn.TextColor3 = Theme.ButtonHover
            BindBtn.Font = FONT_BODY
            BindBtn.TextSize = 12
            BindBtn.Parent = BindFrame
            corner(BindBtn, 3)
            stroke(BindBtn, Theme.Border, 1)

            BindBtn.MouseButton1Click:Connect(function()
                listening = true
                BindBtn.Text = "[...]"
                BindBtn.TextColor3 = Theme.Warning
            end)

            UserInputService.InputBegan:Connect(function(input, gpe)
                if gpe then return end
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    currentKey = input.KeyCode
                    BindBtn.Text = "[" .. currentKey.Name .. "]"
                    BindBtn.TextColor3 = Theme.ButtonHover
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

            local KeybindObj = {}
            function KeybindObj:Get()
                return currentKey
            end
            return KeybindObj
        end

        --=====================================================
        -- PARAGRAPH
        --=====================================================
        function HeaderObj:CreateParagraph(pConfig)
            pConfig = pConfig or {}
            local contentText = pConfig.Text or "Status log output."

            local ParaFrame = newFrame({
                Size = UDim2.new(1, -15, 0, 0),
                Position = UDim2.new(0, 5, 0, 0),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = Container,
            })

            local TextLabel = newLabel({
                Size = UDim2.new(1, 0, 1, 0),
                Text = contentText,
                TextColor3 = pConfig.Color or Theme.TextDim,
                TextSize = 12,
                TextWrapped = true,
                Parent = ParaFrame,
            })

            local ParaObj = {}
            function ParaObj:SetText(newText)
                TextLabel.Text = newText
            end
            return ParaObj
        end

        --=====================================================
        -- LABEL
        --=====================================================
        function HeaderObj:CreateLabel(lConfig)
            lConfig = lConfig or {}

            local LabelFrame = newFrame({
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Parent = Container,
            })

            local TextLabel = newLabel({
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                Text = lConfig.Text or "",
                TextColor3 = lConfig.Color or Theme.TextDim,
                TextSize = 12,
                Parent = LabelFrame,
            })

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

--=============================================================
-- NOTIFICATIONS
--=============================================================
local _notifCounter = 0

function ImGuiLib:Notify(config)
    config = config or {}
    local title    = config.Title or "Notification"
    local message  = config.Message or ""
    local duration = config.Duration or 3
    local nColor   = config.Color or Theme.CheckMark

    -- Find or create the notification holder
    local holder = CoreGui:FindFirstChild("ImGui_NotifHolder")
    if not holder then
        holder = Instance.new("ScreenGui")
        holder.Name = "ImGui_NotifHolder"
        holder.ResetOnSpawn = false
        holder.DisplayOrder = 999
        if syn and syn.protect_gui then
            syn.protect_gui(holder)
            holder.Parent = CoreGui
        elseif gethui then
            holder.Parent = gethui()
        else
            holder.Parent = CoreGui
        end

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
    NotifFrame.Position = UDim2.new(1, 0, 0, 0) -- starts off-screen to the right
    NotifFrame.BackgroundColor3 = Theme.PopupBg
    NotifFrame.BorderSizePixel = 0
    NotifFrame.ClipsDescendants = true
    NotifFrame.Parent = Wrapper
    corner(NotifFrame, 4)
    stroke(NotifFrame, Theme.Border, 1)

    -- Accent bar on the left
    local Accent = Instance.new("Frame")
    Accent.Size = UDim2.new(0, 3, 1, 0)
    Accent.BackgroundColor3 = nColor
    Accent.BorderSizePixel = 0
    Accent.Parent = NotifFrame

    -- Title
    newLabel({
        Size = UDim2.new(1, -12, 0, 18),
        Position = UDim2.new(0, 10, 0, 4),
        Text = title,
        Font = FONT_TITLE,
        TextSize = 13,
        Parent = NotifFrame,
    })

    -- Message
    newLabel({
        Size = UDim2.new(1, -12, 0, 18),
        Position = UDim2.new(0, 10, 0, 24),
        Text = message,
        TextColor3 = Theme.TextDim,
        TextSize = 12,
        Parent = NotifFrame,
    })

    -- Progress bar at the bottom
    local ProgressBg = Instance.new("Frame")
    ProgressBg.Size = UDim2.new(1, 0, 0, 2)
    ProgressBg.Position = UDim2.new(0, 0, 1, -2)
    ProgressBg.BackgroundColor3 = Theme.FrameBg
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
