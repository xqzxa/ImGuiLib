# ImGuiLib
Ui liberay for roblox, made with claude ai.

## Installation
```luau
-- Boot
local ImGuiLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/nondevelopers/ImGuiLib/main/source.luau"))()

-- Create Window
local Window = ImGuiLib:CreateWindow({
    Title = "UI Library Template",
    Size = Vector2.new(340, 430)
})

-- Create Section Header
local Section = Window:CreateHeader({ Name = "Section Header" })

-- Create Toggle
-- (now returns an object with :Set(bool) / :Get() so you can drive the
-- checkbox from code, not just read its callback)
local Toggle = Section:CreateToggle({
    Name = "Toggle",
    Default = false,
    Callback = function(state)
        print(state)
    end
})
-- Toggle:Set(true)
-- print(Toggle:Get())

-- Create Slider
-- (Decimals is new — leave it out for whole numbers, or set it to show
-- a float value like the "float" slider in Dear ImGui's demo window)
local Slider = Section:CreateSlider({
    Name = "Slider",
    Min = 0,
    Max = 100,
    Default = 50,
    Decimals = 0,
    Callback = function(val)
        print(val)
    end
})
-- Slider:Set(75)

local FloatSlider = Section:CreateSlider({
    Name = "float",
    Min = 0,
    Max = 1,
    Default = 0,
    Decimals = 3,
    Callback = function(val)
        print(val)
    end
})

-- Create Dropdown
-- (now returns an object with :Set(option) to change the selection from code)
local Dropdown = Section:CreateDropdown({
    Name = "Dropdown",
    Options = {"Option 1", "Option 2", "Option 3"},
    Default = "Option 1",
    Callback = function(selection)
        print(selection)
    end
})
-- Dropdown:Set("Option 2")

-- Create TextBox
-- (now returns an object with :Get() / :Set(text), and accepts an
-- optional Default to pre-fill the box)
local TextBox = Section:CreateTextBox({
    Name = "TextBox",
    Placeholder = "Type here...",
    Default = "",
    Callback = function(inputStr)
        print(inputStr)
    end
})
-- print(TextBox:Get())
-- TextBox:Set("preset value")

-- Create Keybind
-- (Supports two configurations for the Mode argument: "Toggle" or "Hold")
-- (now returns an object with :Get() to read the currently bound key)
local Keybind = Section:CreateKeybind({
    Name = "Keybind",
    Default = Enum.KeyCode.E,
    Mode = "Toggle",
    Callback = function(state)
        print("Keybind active:", state)
    end
})
-- print(Keybind:Get())

-- Create Paragraph
local Paragraph = Section:CreateParagraph({
    Text = "This is a Paragraph element.",
    Color = Color3.fromRGB(170, 180, 190)
})

-- Create Button
-- (now returns an object with :SetText(text) to relabel it later)
local Button = Section:CreateButton({
    Name = "Button Name Here",
    Callback = function()
        print("Button clicked!")
        -- Put your script features or actions here
    end
})
-- Button:SetText("Clicked!")

-- Create Label
local Label = Section:CreateLabel({
    Text = "This is a Label element.",
    Color = Color3.fromRGB(180, 180, 180) -- optional
})
-- Update the label text and color at any time:
Label:SetText("Updated text!")
Label:SetColor(Color3.fromRGB(255, 80, 80))

-- Notify
-- (Color controls the accent bar and progress bar color)
ImGuiLib:Notify({
    Title = "Notification Title",
    Message = "This is the notification message.",
    Duration = 3,                            -- optional, default 3
    Color = Color3.fromRGB(30, 120, 215)     -- optional
})
```

