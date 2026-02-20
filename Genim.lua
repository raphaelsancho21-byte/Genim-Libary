--[[
    Genim UI Library
    Inspired by Gemini Aesthetic
    
    A standalone, premium UI library for Roblox.
]]

local Genim = {}
Genim.Version = "v1.2.5"

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Constants & Theme
Genim.Themes = {
    Default = {
        MainColor = Color3.fromRGB(5, 11, 24),
        AccentColor = Color3.fromRGB(26, 115, 232),
        SecondaryAccent = Color3.fromRGB(147, 51, 234),
        TextColor = Color3.fromRGB(248, 250, 252),
        SecondaryTextColor = Color3.fromRGB(148, 163, 184),
        StrokeColor = Color3.fromRGB(30, 41, 59),
        DarkerColor = Color3.fromRGB(2, 6, 15)
    },
    Ocean = {
        MainColor = Color3.fromRGB(10, 25, 47),
        AccentColor = Color3.fromRGB(0, 206, 209),
        SecondaryAccent = Color3.fromRGB(0, 150, 255),
        TextColor = Color3.fromRGB(230, 241, 255),
        SecondaryTextColor = Color3.fromRGB(136, 146, 176),
        StrokeColor = Color3.fromRGB(23, 42, 69),
        DarkerColor = Color3.fromRGB(2, 12, 27)
    },
    Amethyst = {
        MainColor = Color3.fromRGB(15, 10, 25),
        AccentColor = Color3.fromRGB(168, 85, 247),
        SecondaryAccent = Color3.fromRGB(236, 72, 153),
        TextColor = Color3.fromRGB(250, 245, 255),
        SecondaryTextColor = Color3.fromRGB(168, 162, 158),
        StrokeColor = Color3.fromRGB(46, 16, 101),
        DarkerColor = Color3.fromRGB(12, 6, 23)
    },
    Emerald = {
        MainColor = Color3.fromRGB(6, 20, 15),
        AccentColor = Color3.fromRGB(34, 197, 94),
        SecondaryAccent = Color3.fromRGB(16, 185, 129),
        TextColor = Color3.fromRGB(240, 253, 244),
        SecondaryTextColor = Color3.fromRGB(100, 116, 139),
        StrokeColor = Color3.fromRGB(20, 83, 45),
        DarkerColor = Color3.fromRGB(2, 15, 10)
    },
    Light = {
        MainColor = Color3.fromRGB(248, 250, 252),
        AccentColor = Color3.fromRGB(37, 99, 235),
        SecondaryAccent = Color3.fromRGB(79, 70, 229),
        TextColor = Color3.fromRGB(15, 23, 42),
        SecondaryTextColor = Color3.fromRGB(100, 116, 139),
        StrokeColor = Color3.fromRGB(226, 232, 240),
        DarkerColor = Color3.fromRGB(241, 245, 249)
    }
}

Genim.Theme = Genim.Themes.Default

-- Utility Functions
local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    inst.Parent = props.Parent
    return inst
end

local function Tween(inst, speed, props)
    local info = TweenInfo.new(speed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local t = TweenService:Create(inst, info, props)
    t:Play()
    return t
end

local function Ripple(obj)
    task.spawn(function()
        local mouse = Players.LocalPlayer:GetMouse()
        local ripple = Create("Frame", {
            Name = "Ripple",
            Parent = obj,
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = 0.8,
            BorderSizePixel = 0,
            Position = UDim2.new(0, mouse.X - obj.AbsolutePosition.X, 0, mouse.Y - obj.AbsolutePosition.Y),
            Size = UDim2.new(0, 0, 0, 0),
            ZIndex = 10
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ripple })
        
        local size = math.max(obj.AbsoluteSize.X, obj.AbsoluteSize.Y) * 1.5
        Tween(ripple, 0.4, {Size = UDim2.new(0, size, 0, size), Position = ripple.Position - UDim2.new(0, size/2, 0, size/2), BackgroundTransparency = 1})
        task.wait(0.4)
        ripple:Destroy()
    end)
end

local function MakeDraggable(TopBar, MainFrame)

	local Dragging, DragInput, DragStart, StartPos

	local function Update(Input)
		local Delta = Input.Position - DragStart
		MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
	end

	TopBar.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = Input.Position
			StartPos = MainFrame.Position

			Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)

	TopBar.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
			DragInput = Input
		end
	end)

	UserInputService.InputChanged:Connect(function(Input)
		if Input == DragInput and Dragging then
			Update(Input)
		end
	end)
end

-- Library Methods
-- Notifications Table
Genim.Notifications = {}

function Genim:Notify(Props)
    Props = Props or {}
    Props.Title = Props.Title or "Notification"
    Props.Content = Props.Content or "This is a notification message."
    Props.Duration = Props.Duration or 5
    Props.Image = Props.Image or "rbxassetid://15132379512"
    
    local NotificationGui = CoreGui:FindFirstChild("GenimNotifications")
    if not NotificationGui then
        NotificationGui = Create("ScreenGui", {
            Name = "GenimNotifications",
            Parent = (RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui")) or CoreGui
        })
        
        local Holder = Create("Frame", {
            Name = "Holder",
            Parent = NotificationGui,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -310, 1, -20),
            Size = UDim2.new(0, 300, 1, -20)
        })
        
        Create("UIListLayout", {
            Parent = Holder,
            Padding = UDim.new(0, 10),
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            SortOrder = Enum.SortOrder.LayoutOrder
        })
    end
    
    local Holder = NotificationGui.Holder
    
    local NoteBox = Create("Frame", {
        Name = "Note",
        Parent = Holder,
        BackgroundColor3 = Genim.Theme.MainColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0), -- Animated
        ClipsDescendants = true,
        LayoutOrder = #Holder:GetChildren()
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = NoteBox
    })
    
    Create("UIStroke", {
        Color = Genim.Theme.StrokeColor,
        Thickness = 1,
        Parent = NoteBox
    })

    local Title = Create("TextLabel", {
        Parent = NoteBox,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 40, 0, 8),
        Size = UDim2.new(1, -50, 0, 15),
        Font = Enum.Font.GothamBold,
        Text = Props.Title,
        TextColor3 = Genim.Theme.TextColor,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Genim.Theme.AccentColor),
            ColorSequenceKeypoint.new(1, Genim.Theme.SecondaryAccent)
        }),
        Parent = Title
    })

    local Content = Create("TextLabel", {
        Parent = NoteBox,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 40, 0, 25),
        Size = UDim2.new(1, -50, 0, 0),
        Font = Enum.Font.GothamMedium,
        Text = Props.Content,
        TextColor3 = Genim.Theme.SecondaryTextColor,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    })

    local Icon = Create("ImageLabel", {
        Parent = NoteBox,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(0, 22, 0, 22),
        Image = Props.Image,
        ImageColor3 = Genim.Theme.AccentColor
    })

    -- Animation
    Content.Size = UDim2.new(1, -50, 0, Content.TextBounds.Y)
    local TargetHeight = math.max(60, Content.TextBounds.Y + 35)
    
    Tween(NoteBox, 0.4, {Size = UDim2.new(1, 0, 0, TargetHeight)})
    
    task.delay(Props.Duration, function()
        Tween(NoteBox, 0.4, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1})
        task.wait(0.4)
        NoteBox:Destroy()
    end)
end

function Genim:CreateWindow(Config)

    Config = Config or {}
    Config.Name = Config.Name or "Genim Library"
    Config.Theme = Config.Theme or "Default"
    
    if Genim.Themes[Config.Theme] then
        Genim.Theme = Genim.Themes[Config.Theme]
    end
    
    local ScreenGui = Create("ScreenGui", {
        Name = "Genim_" .. HttpService:GenerateGUID(false):sub(1, 8),
        Parent = (RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui")) or CoreGui,
        ResetOnSpawn = false
    })
    
    -- Main Container
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Genim.Theme.MainColor,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 0),
        ClipsDescendants = true,
        Visible = false
    })

    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = MainFrame
    })
    
    Create("UIStroke", {
        Color = Genim.Theme.StrokeColor,
        Thickness = 1.2,
        Parent = MainFrame
    })

    -- TopBar
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Parent = MainFrame,
        BackgroundColor3 = Genim.Theme.DarkerColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40)
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = TopBar
    })
    
    -- Hide bottom corners of TopBar
    Create("Frame", {
        Name = "CornerFix",
        Parent = TopBar,
        BackgroundColor3 = Genim.Theme.DarkerColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0.5, 0),
        ZIndex = 0
    })

    local Title = Create("TextLabel", {
        Name = "Title",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -60, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = Config.Name,
        TextColor3 = Genim.Theme.TextColor,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Gemini Gradient for Title or Accent
    local Gradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Genim.Theme.AccentColor),
            ColorSequenceKeypoint.new(1, Genim.Theme.SecondaryAccent)
        }),
        Parent = Title
    })

    MakeDraggable(TopBar, MainFrame)
    
    -- Sidebar
    local SideBar = Create("Frame", {
        Name = "SideBar",
        Parent = MainFrame,
        BackgroundColor3 = Genim.Theme.DarkerColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(0, 140, 1, -40)
    })
    
    local SideBarList = Create("ScrollingFrame", {
        Name = "List",
        Parent = SideBar,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 5, 0, 10),
        Size = UDim2.new(1, -10, 1, -20),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Genim.Theme.AccentColor,
        ScrollBarImageTransparency = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ElasticBehavior = Enum.ElasticBehavior.Always,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
    })
    
    local SideBarLayout = Create("UIListLayout", {
        Parent = SideBarList,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    SideBarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SideBarList.CanvasSize = UDim2.new(0, 0, 0, SideBarLayout.AbsoluteContentSize.Y + 10)
    end)

    -- Container
    local Container = Create("Frame", {
        Name = "Container",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 140, 0, 40),
        Size = UDim2.new(1, -140, 1, -40),
        ClipsDescendants = true
    })

    local VersionLabel = Create("TextLabel", {
        Name = "Version",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 5, 1, -18),
        Size = UDim2.new(0, 100, 0, 15),
        Font = Enum.Font.GothamMedium,
        Text = Genim.Version,
        TextColor3 = Genim.Theme.SecondaryTextColor,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 110
    })
    
    local Window = {
        CurrentTab = nil,
        Tabs = {}
    }
    
    function Window:CreateTab(Name, Icon)
        local TabButton = Create("TextButton", {
            Name = Name .. "Tab",
            Parent = SideBarList,
            BackgroundColor3 = Genim.Theme.AccentColor,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 32),
            AutoButtonColor = false,
            Font = Enum.Font.GothamSemibold,
            Text = Name,
            TextColor3 = Genim.Theme.SecondaryTextColor,
            TextSize = 13
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = TabButton
        })
        
        local TabContent = Create("ScrollingFrame", {
            Name = Name .. "Content",
            Parent = Container,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Genim.Theme.AccentColor,
            ScrollBarImageTransparency = 0,
            Visible = false,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ElasticBehavior = Enum.ElasticBehavior.Always,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
        })
        
        local TabList = Create("UIListLayout", {
            Parent = TabContent,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        })

        -- Robust Manual Update with Extra Padding
        TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, TabList.AbsoluteContentSize.Y + 50)
        end)
        
        Create("UIPadding", {
            Parent = TabContent,
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10)
        })

        local Tab = {
            Elements = {}
        }
        
        function Tab:CreateSection(Name)
            local SectionFrame = Create("Frame", {
                Name = Name .. "Section",
                Parent = TabContent,
                BackgroundColor3 = Color3.fromRGB(15, 23, 42),
                BackgroundTransparency = 0.5,
                BorderSizePixel = 0,
                Size = UDim2.new(0.9, 0, 0, 24)
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = SectionFrame
            })
            
            local SectionTitle = Create("TextLabel", {
                Name = "Title",
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -10, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = Name:upper(),
                TextColor3 = Genim.Theme.AccentColor,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            return SectionFrame
        end

        function Tab:CreateButton(Props)
            Props = Props or {}
            Props.Name = Props.Name or "Button"
            Props.Callback = Props.Callback or function() end
            
            local ButtonFrame = Create("Frame", {
                Name = Props.Name .. "Button",
                Parent = TabContent,
                BackgroundColor3 = Genim.Theme.DarkerColor,
                BorderSizePixel = 0,
                Size = UDim2.new(0.9, 0, 0, 38)
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = ButtonFrame
            })
            
            Create("UIStroke", {
                Color = Genim.Theme.StrokeColor,
                Thickness = 1,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Parent = ButtonFrame
            })

            local Button = Create("TextButton", {
                Name = "Interact",
                Parent = ButtonFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamMedium,
                Text = Props.Name,
                TextColor3 = Genim.Theme.TextColor,
                TextSize = 13,
                AutoButtonColor = false
            })

            local Icon = Create("ImageLabel", {
                Name = "Icon",
                Parent = ButtonFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -30, 0.5, -9),
                Size = UDim2.new(0, 18, 0, 18),
                Image = "rbxassetid://15132379512", -- Simple click icon
                ImageColor3 = Genim.Theme.SecondaryTextColor
            })

            Button.MouseEnter:Connect(function()
                Tween(ButtonFrame, 0.2, {BackgroundColor3 = Genim.Theme.StrokeColor})
            end)
            
            Button.MouseLeave:Connect(function()
                Tween(ButtonFrame, 0.2, {BackgroundColor3 = Genim.Theme.DarkerColor})
            end)
            
            Button.MouseButton1Down:Connect(function()
                Ripple(ButtonFrame)
                Tween(ButtonFrame, 0.1, {Size = UDim2.new(0.88, 0, 0, 36)})
            end)

            
            Button.MouseButton1Up:Connect(function()
                Tween(ButtonFrame, 0.1, {Size = UDim2.new(0.9, 0, 0, 38)})
                Props.Callback()
            end)

            return {
                Set = function(_, NewName)
                    Button.Text = NewName
                end
            }
        end

        function Tab:CreateToggle(Props)
            Props = Props or {}
            Props.Name = Props.Name or "Toggle"
            Props.CurrentValue = Props.CurrentValue or false
            Props.Callback = Props.Callback or function() end
            
            local Toggled = Props.CurrentValue

            local ToggleFrame = Create("Frame", {
                Name = Props.Name .. "Toggle",
                Parent = TabContent,
                BackgroundColor3 = Genim.Theme.DarkerColor,
                BorderSizePixel = 0,
                Size = UDim2.new(0.9, 0, 0, 38)
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = ToggleFrame
            })
            
            Create("UIStroke", {
                Color = Genim.Theme.StrokeColor,
                Thickness = 1,
                Parent = ToggleFrame
            })

            local Title = Create("TextLabel", {
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -60, 1, 0),
                Font = Enum.Font.GothamMedium,
                Text = Props.Name,
                TextColor3 = Genim.Theme.TextColor,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local OuterToggle = Create("Frame", {
                Name = "Outer",
                Parent = ToggleFrame,
                BackgroundColor3 = Color3.fromRGB(30, 41, 59),
                Position = UDim2.new(1, -45, 0.5, -9),
                Size = UDim2.new(0, 32, 0, 18)
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = OuterToggle
            })

            local InnerToggle = Create("Frame", {
                Name = "Inner",
                Parent = OuterToggle,
                BackgroundColor3 = Genim.Theme.TextColor,
                Position = Toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
                Size = UDim2.new(0, 14, 0, 14)
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = InnerToggle
            })

            local Button = Create("TextButton", {
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = ""
            })

            local function Update()
                if Toggled then
                    Tween(OuterToggle, 0.2, {BackgroundColor3 = Genim.Theme.AccentColor})
                    Tween(InnerToggle, 0.2, {Position = UDim2.new(1, -16, 0.5, -7)})
                else
                    Tween(OuterToggle, 0.2, {BackgroundColor3 = Color3.fromRGB(30, 41, 59)})
                    Tween(InnerToggle, 0.2, {Position = UDim2.new(0, 2, 0.5, -7)})
                end
                Props.Callback(Toggled)
            end

            Button.MouseButton1Click:Connect(function()
                Ripple(ToggleFrame)
                Toggled = not Toggled
                Update()
            end)


            if Toggled then Update() end

            return {
                Set = function(_, NewValue)
                    Toggled = NewValue
                    Update()
                end
            }
        end

        function Tab:CreateSlider(Props)
            Props = Props or {}
            Props.Name = Props.Name or "Slider"
            Props.Min = Props.Min or 0
            Props.Max = Props.Max or 100
            Props.CurrentValue = Props.CurrentValue or 50
            Props.Callback = Props.Callback or function() end
            
            local Value = Props.CurrentValue

            local SliderFrame = Create("Frame", {
                Name = Props.Name .. "Slider",
                Parent = TabContent,
                BackgroundColor3 = Genim.Theme.DarkerColor,
                BorderSizePixel = 0,
                Size = UDim2.new(0.9, 0, 0, 48)
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = SliderFrame
            })
            
            Create("UIStroke", {
                Color = Genim.Theme.StrokeColor,
                Thickness = 1,
                Parent = SliderFrame
            })

            local Title = Create("TextLabel", {
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 8),
                Size = UDim2.new(1, -60, 0, 15),
                Font = Enum.Font.GothamMedium,
                Text = Props.Name,
                TextColor3 = Genim.Theme.TextColor,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local ValueLabel = Create("TextLabel", {
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -60, 0, 8),
                Size = UDim2.new(0, 50, 0, 15),
                Font = Enum.Font.GothamSemibold,
                Text = tostring(Value),
                TextColor3 = Genim.Theme.SecondaryTextColor,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right
            })

            local SliderTrack = Create("Frame", {
                Name = "Track",
                Parent = SliderFrame,
                BackgroundColor3 = Color3.fromRGB(30, 41, 59),
                Position = UDim2.new(0, 12, 1, -12),
                Size = UDim2.new(1, -24, 0, 4)
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = SliderTrack
            })

            local SliderFill = Create("Frame", {
                Name = "Fill",
                Parent = SliderTrack,
                BackgroundColor3 = Genim.Theme.AccentColor,
                Size = UDim2.new((Value - Props.Min) / (Props.Max - Props.Min), 0, 1, 0)
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = SliderFill
            })

            local SliderDot = Create("Frame", {
                Name = "Dot",
                Parent = SliderFill,
                BackgroundColor3 = Genim.Theme.TextColor,
                Position = UDim2.new(1, -6, 0.5, -6),
                Size = UDim2.new(0, 12, 0, 12)
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = SliderDot
            })
            
            Create("UIStroke", {
                Color = Genim.Theme.AccentColor,
                Thickness = 2,
                Parent = SliderDot
            })

            local function Update(Input)
                local Percentage = math.clamp((Input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                Value = math.floor(Props.Min + (Props.Max - Props.Min) * Percentage)
                
                ValueLabel.Text = tostring(Value)
                Tween(SliderFill, 0.1, {Size = UDim2.new(Percentage, 0, 1, 0)})
                Props.Callback(Value)
            end

            local Dragging = false
            SliderFrame.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    Update(Input)
                end
            end)

            UserInputService.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(Input)
                if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                    Update(Input)
                end
            end)

            return {
                Set = function(_, NewValue)
                    Value = math.clamp(NewValue, Props.Min, Props.Max)
                    ValueLabel.Text = tostring(Value)
                    local Percentage = (Value - Props.Min) / (Props.Max - Props.Min)
                    Tween(SliderFill, 0.2, {Size = UDim2.new(Percentage, 0, 1, 0)})
                    Props.Callback(Value)
                end
            }
        end

        function Tab:CreateInput(Props)
            Props = Props or {}
            Props.Name = Props.Name or "Input"
            Props.Placeholder = Props.Placeholder or "Type here..."
            Props.Callback = Props.Callback or function() end

            local InputFrame = Create("Frame", {
                Name = Props.Name .. "Input",
                Parent = TabContent,
                BackgroundColor3 = Genim.Theme.DarkerColor,
                BorderSizePixel = 0,
                Size = UDim2.new(0.9, 0, 0, 38)
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = InputFrame
            })
            
            Create("UIStroke", {
                Color = Genim.Theme.StrokeColor,
                Thickness = 1,
                Parent = InputFrame
            })

            local Title = Create("TextLabel", {
                Parent = InputFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(0.4, 0, 1, 0),
                Font = Enum.Font.GothamMedium,
                Text = Props.Name,
                TextColor3 = Genim.Theme.TextColor,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local InputBox = Create("TextBox", {
                Parent = InputFrame,
                BackgroundColor3 = Color3.fromRGB(15, 23, 42),
                Position = UDim2.new(1, -160, 0.5, -11),
                Size = UDim2.new(0, 150, 0, 22),
                Font = Enum.Font.GothamMedium,
                PlaceholderText = Props.Placeholder,
                Text = "",
                TextColor3 = Genim.Theme.TextColor,
                PlaceholderColor3 = Genim.Theme.SecondaryTextColor,
                TextSize = 12,
                ClearTextOnFocus = false
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = InputBox
            })
            
            Create("UIStroke", {
                Color = Genim.Theme.StrokeColor,
                Thickness = 1,
                Parent = InputBox
            })

            InputBox.FocusLost:Connect(function(EnterPressed)
                Props.Callback(InputBox.Text, EnterPressed)
            end)

            return {
                Set = function(_, NewValue)
                    InputBox.Text = NewValue
                    Props.Callback(NewValue)
                end
            }
        end

        function Tab:CreateDropdown(Props)
            Props = Props or {}
            Props.Name = Props.Name or "Dropdown"
            Props.Options = Props.Options or {"Option 1", "Option 2"}
            Props.CurrentOption = Props.CurrentOption or Props.Options[1]
            Props.Callback = Props.Callback or function() end
            
            local Selected = Props.CurrentOption
            local Opened = false

            local DropdownFrame = Create("Frame", {
                Name = Props.Name .. "Dropdown",
                Parent = TabContent,
                BackgroundColor3 = Genim.Theme.DarkerColor,
                BorderSizePixel = 0,
                Size = UDim2.new(0.9, 0, 0, 38),
                ClipsDescendants = true
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = DropdownFrame
            })
            
            Create("UIStroke", {
                Color = Genim.Theme.StrokeColor,
                Thickness = 1,
                Parent = DropdownFrame
            })

            local Title = Create("TextLabel", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -60, 0, 38),
                Font = Enum.Font.GothamMedium,
                Text = Props.Name,
                TextColor3 = Genim.Theme.TextColor,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local SelectedLabel = Create("TextLabel", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -160, 0, 0),
                Size = UDim2.new(0, 120, 0, 38),
                Font = Enum.Font.GothamSemibold,
                Text = Selected,
                TextColor3 = Genim.Theme.AccentColor,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right
            })

            local Arrow = Create("ImageLabel", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -30, 0, 10),
                Size = UDim2.new(0, 18, 0, 18),
                Image = "rbxassetid://15132379512", -- Same icon for now
                Rotation = 90,
                ImageColor3 = Genim.Theme.SecondaryTextColor
            })

            local ItemsContainer = Create("Frame", {
                Name = "Items",
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 38),
                Size = UDim2.new(1, 0, 0, 0)
            })
            
            Create("UIListLayout", {
                Parent = ItemsContainer,
                Padding = UDim.new(0, 2),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            
            Create("UIPadding", {
                Parent = ItemsContainer,
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 5)
            })

            local function Toggle(State)
                Opened = State
                local TargetSize = Opened and UDim2.new(0, 18, 0, 18) or UDim2.new(0, 18, 0, 18) -- Rotation handle
                Tween(Arrow, 0.2, {Rotation = Opened and 270 or 90})
                
                local ContentSize = 38
                if Opened then
                    for _, option in pairs(Props.Options) do
                        ContentSize = ContentSize + 28
                    end
                    ContentSize = ContentSize + 5
                end
                
                Tween(DropdownFrame, 0.3, {Size = UDim2.new(0.9, 0, 0, ContentSize)})
            end

            local function AddOption(Value)
                local btn = Create("TextButton", {
                    Name = Value,
                    Parent = ItemsContainer,
                    BackgroundColor3 = Color3.fromRGB(15, 23, 42),
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 26),
                    Font = Enum.Font.GothamMedium,
                    Text = Value,
                    TextColor3 = (Value == Selected and Genim.Theme.TextColor or Genim.Theme.SecondaryTextColor),
                    TextSize = 12,
                    AutoButtonColor = false
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = btn
                })
                
                btn.MouseButton1Click:Connect(function()
                    Selected = Value
                    SelectedLabel.Text = Selected
                    for _, child in pairs(ItemsContainer:GetChildren()) do
                        if child:IsA("TextButton") then
                            child.TextColor3 = (child.Name == Selected and Genim.Theme.TextColor or Genim.Theme.SecondaryTextColor)
                        end
                    end
                    Toggle(false)
                    Props.Callback(Selected)
                end)
            end

            for _, opt in pairs(Props.Options) do
                AddOption(opt)
            end

            local Button = Create("TextButton", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 38),
                Text = ""
            })

            Button.MouseButton1Click:Connect(function()
                Toggle(not Opened)
            end)

            return {
                Set = function(_, NewValue)
                    Selected = NewValue
                    SelectedLabel.Text = Selected
                    Props.Callback(Selected)
                end,
                Refresh = function(_, NewOptions, ClearOld)
                    if ClearOld then
                        for _, child in pairs(ItemsContainer:GetChildren()) do
                            if child:IsA("TextButton") then child:Destroy() end
                        end
                    end
                    Props.Options = NewOptions
                    for _, opt in pairs(NewOptions) do
                        AddOption(opt)
                    end
                end
            }
        end

        function Tab:Select()



            if Window.CurrentTab then
                Window.CurrentTab.Content.Visible = false
                Tween(Window.CurrentTab.Button, 0.3, {BackgroundTransparency = 1, TextColor3 = Genim.Theme.SecondaryTextColor})
            end
            
            TabContent.Visible = true
            Tween(TabButton, 0.3, {BackgroundTransparency = 0.8, TextColor3 = Genim.Theme.TextColor})
            Window.CurrentTab = {Button = TabButton, Content = TabContent}
        end
        
        TabButton.MouseButton1Click:Connect(function()
            Tab:Select()
        end)
        
        if not Window.CurrentTab then
            Tab:Select()
        end
        
        return Tab
    end
    
    -- Loading Screen Implementation
    local LoadingFrame = Create("Frame", {
        Name = "LoadingFrame",
        Parent = MainFrame,
        BackgroundColor3 = Genim.Theme.MainColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 100
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = LoadingFrame
    })

    local LoadingTitle = Create("TextLabel", {
        Parent = LoadingFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 120),
        Size = UDim2.new(1, 0, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = Config.LoadingTitle or Config.Name,
        TextColor3 = Genim.Theme.TextColor,
        TextSize = 24,
        ZIndex = 101,
        TextTransparency = 0
    })
    
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Genim.Theme.AccentColor),
            ColorSequenceKeypoint.new(1, Genim.Theme.SecondaryAccent)
        }),
        Parent = LoadingTitle
    })

    local LoadingSubtitle = Create("TextLabel", {
        Parent = LoadingFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 150),
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.GothamMedium,
        Text = Config.LoadingSubtitle or "Iniciando Genim...",
        TextColor3 = Genim.Theme.SecondaryTextColor,
        TextSize = 14,
        ZIndex = 101,
        TextTransparency = 0
    })

    local ProgressBack = Create("Frame", {
        Parent = LoadingFrame,
        BackgroundColor3 = Color3.fromRGB(30, 41, 59),
        Position = UDim2.new(0.5, -100, 0, 200),
        Size = UDim2.new(0, 200, 0, 4),
        ZIndex = 101
    })
    
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ProgressBack })

    local ProgressFill = Create("Frame", {
        Parent = ProgressBack,
        BackgroundColor3 = Genim.Theme.AccentColor,
        Size = UDim2.new(0, 0, 1, 0),
        ZIndex = 102
    })
    
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ProgressFill })
    
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Genim.Theme.AccentColor),
            ColorSequenceKeypoint.new(1, Genim.Theme.SecondaryAccent)
        }),
        Parent = ProgressFill
    })

    -- Toggle Logic
    local Toggled = true
    local Debounce = false
    
    function Window:Toggle(state)
        if LoadingFrame and LoadingFrame.Parent then return end -- Don't toggle while loading
        if Debounce then return end
        Debounce = true
        
        if state ~= nil then
            Toggled = state
        else
            Toggled = not Toggled
        end
        
        if Toggled then
            MainFrame.Visible = true
            Tween(MainFrame, 0.4, {Size = UDim2.new(0, 500, 0, 350)})
        else
            Tween(MainFrame, 0.4, {Size = UDim2.new(0, 0, 0, 0)})
            task.delay(0.4, function()
                if not Toggled then MainFrame.Visible = false end
            end)
        end
        
        task.wait(0.4)
        Debounce = false
    end

    -- Keybind Listener
    local Keybind = Config.Keybind or Enum.KeyCode.K
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Keybind then
            Window:Toggle()
        end
    end)

    -- Mobile Toggle Button
    local MobileToggle = Create("TextButton", {
        Name = "MobileToggle",
        Parent = ScreenGui,
        BackgroundColor3 = Genim.Theme.MainColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -40, 0, 5),
        Size = UDim2.new(0, 80, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = "GENIM",
        TextColor3 = Genim.Theme.TextColor,
        TextSize = 12,
        ZIndex = 500,
        AutoButtonColor = false
    })
    
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = MobileToggle })
    Create("UIStroke", { Color = Genim.Theme.AccentColor, Thickness = 1.2, Parent = MobileToggle })
    
    local MobileGradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Genim.Theme.AccentColor),
            ColorSequenceKeypoint.new(1, Genim.Theme.SecondaryAccent)
        }),
        Parent = MobileToggle
    })

    MobileToggle.MouseButton1Click:Connect(function()
        Ripple(MobileToggle)
        Window:Toggle()
    end)

    -- Animate Loading Function
    local function StartLoading()
        task.spawn(function()
            MainFrame.Visible = true
            Tween(MainFrame, 0.6, {
                Size = UDim2.new(0, 500, 0, 350),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            })
            task.wait(0.6)
            
            Tween(ProgressFill, 1.2, {Size = UDim2.new(1, 0, 1, 0)})
            task.wait(1.5)
            
            Tween(LoadingFrame, 0.5, {BackgroundTransparency = 1})
            Tween(LoadingTitle, 0.5, {TextTransparency = 1})
            Tween(LoadingSubtitle, 0.5, {TextTransparency = 1})
            Tween(ProgressBack, 0.5, {BackgroundTransparency = 1})
            Tween(ProgressFill, 0.5, {BackgroundTransparency = 1})
            
            task.wait(0.5)
            LoadingFrame:Destroy()
        end)
    end

    StartLoading()
    
    return Window
end



return Genim
