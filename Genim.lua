--[[
    Genim UI Library
    Inspired by Gemini Aesthetic
    
    A standalone, premium UI library for Roblox.
]]

local Genim = {}
Genim.Version = "v1.27.1"
Genim.NotifyHolder = nil

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Constants & Theme
Genim.Themes = {
    Dark = {
        MainColor = Color3.fromRGB(15, 17, 26),
        AccentColor = Color3.fromRGB(26, 115, 232),
        SecondaryAccent = Color3.fromRGB(147, 51, 234),
        TextColor = Color3.fromRGB(255, 255, 255),
        SecondaryTextColor = Color3.fromRGB(160, 160, 160),
        StrokeColor = Color3.fromRGB(35, 40, 55),
        DarkerColor = Color3.fromRGB(10, 12, 18)
    },
    Light = {
        MainColor = Color3.fromRGB(245, 246, 250),
        AccentColor = Color3.fromRGB(37, 99, 235),
        SecondaryAccent = Color3.fromRGB(79, 70, 229),
        TextColor = Color3.fromRGB(15, 23, 42),
        SecondaryTextColor = Color3.fromRGB(100, 116, 139),
        StrokeColor = Color3.fromRGB(220, 225, 235),
        DarkerColor = Color3.fromRGB(235, 238, 245)
    },
    Amethyst = {
        MainColor = Color3.fromRGB(13, 11, 22),
        AccentColor = Color3.fromRGB(168, 85, 247),
        SecondaryAccent = Color3.fromRGB(236, 72, 153),
        TextColor = Color3.fromRGB(255, 255, 255),
        SecondaryTextColor = Color3.fromRGB(148, 163, 184),
        StrokeColor = Color3.fromRGB(30, 27, 46),
        DarkerColor = Color3.fromRGB(9, 8, 15)
    },
    Emerald = {
        MainColor = Color3.fromRGB(6, 18, 16),
        AccentColor = Color3.fromRGB(16, 185, 129),
        SecondaryAccent = Color3.fromRGB(5, 150, 105),
        TextColor = Color3.fromRGB(255, 255, 255),
        SecondaryTextColor = Color3.fromRGB(110, 140, 130),
        StrokeColor = Color3.fromRGB(20, 35, 30),
        DarkerColor = Color3.fromRGB(4, 12, 11)
    },
    Ruby = {
        MainColor = Color3.fromRGB(18, 6, 6),
        AccentColor = Color3.fromRGB(239, 68, 68),
        SecondaryAccent = Color3.fromRGB(185, 28, 28),
        TextColor = Color3.fromRGB(255, 255, 255),
        SecondaryTextColor = Color3.fromRGB(140, 100, 100),
        StrokeColor = Color3.fromRGB(35, 20, 20),
        DarkerColor = Color3.fromRGB(12, 4, 4)
    },
    Glass = {
        MainColor = Color3.fromRGB(15, 17, 26),
        AccentColor = Color3.fromRGB(255, 255, 255),
        SecondaryAccent = Color3.fromRGB(200, 200, 200),
        TextColor = Color3.fromRGB(255, 255, 255),
        SecondaryTextColor = Color3.fromRGB(180, 180, 180),
        StrokeColor = Color3.fromRGB(255, 255, 255),
        DarkerColor = Color3.fromRGB(10, 12, 18)
    }
}

Genim.Theme = Genim.Themes.Dark

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

function Genim:CreateWindow(Config)

    Config = Config or {}
    Config.Name = Config.Name or "Genim Library"
    Config.Theme = Config.Theme or "Dark"
    
    local KeySystem = Config.KeySystem or false
    local KeySettings = Config.KeySettings or {}
    local ValidKey = KeySettings.Key or ""
    
    if Genim.Themes[Config.Theme] then
        Genim.Theme = Genim.Themes[Config.Theme]
    end
    
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    
    local ScreenGui = Create("ScreenGui", {
        Name = "Genim_" .. HttpService:GenerateGUID(false):sub(1, 8),
        Parent = (RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui")) or CoreGui,
        ResetOnSpawn = false
    })
    
    -- Notification Container
    local NotifyHolder = Create("Frame", {
        Name = "NotifyHolder",
        Parent = ScreenGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -310, 1, -20),
        Size = UDim2.new(0, 300, 1, -20),
        AnchorPoint = Vector2.new(0, 1)
    })
    
    Create("UIListLayout", {
        Parent = NotifyHolder,
        Padding = UDim.new(0, 10),
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    Genim.NotifyHolder = NotifyHolder
    
    -- Main Container
    local MainFrame = Create("CanvasGroup", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Genim.Theme.MainColor,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 0),
        ClipsDescendants = true,
        Visible = false,
        Transparency = 0.05
    })

    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = MainFrame
    })
    
    local MainStroke = Create("UIStroke", {
        Color = Color3.new(1, 1, 1),
        Thickness = 1,
        Parent = MainFrame,
        Transparency = 0.5
    })
    
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Genim.Theme.AccentColor),
            ColorSequenceKeypoint.new(1, Genim.Theme.SecondaryAccent)
        }),
        Parent = MainStroke
    })

    -- Breathing effect for the Luminous Stroke
    task.spawn(function()
        while task.wait(3) do
            if not MainStroke.Parent then break end
            Tween(MainStroke, 1.5, {Transparency = 0.2})
            task.wait(1.5)
            Tween(MainStroke, 1.5, {Transparency = 0.6})
        end
    end)

    -- TopBar
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Parent = MainFrame,
        BackgroundColor3 = Genim.Theme.DarkerColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 44)
    })

    Create("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = TopBar
    })

    -- Accent underline on TopBar
    local TopBarLine = Create("Frame", {
        Name = "AccentLine",
        Parent = TopBar,
        BackgroundColor3 = Genim.Theme.AccentColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1)
    })
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Genim.Theme.AccentColor),
            ColorSequenceKeypoint.new(1, Genim.Theme.SecondaryAccent)
        }),
        Parent = TopBarLine
    })

    local Title = Create("TextLabel", {
        Name = "Title",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 0),
        Size = UDim2.new(1, -70, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = Config.Name,
        TextColor3 = Genim.Theme.TextColor,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local CloseButton = Create("TextButton", {
        Name = "CloseButton",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -38, 0, 0),
        Size = UDim2.new(0, 38, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "✕",
        TextColor3 = Genim.Theme.SecondaryTextColor,
        TextSize = 13,
        AutoButtonColor = false
    })


    CloseButton.MouseEnter:Connect(function()
        Tween(CloseButton, 0.2, {TextColor3 = Color3.fromRGB(255, 100, 100)})
    end)

    CloseButton.MouseLeave:Connect(function()
        Tween(CloseButton, 0.2, {TextColor3 = Genim.Theme.SecondaryTextColor})
    end)

    CloseButton.MouseButton1Click:Connect(function()
        Ripple(CloseButton)
        Window:CreateDialog({
            Title = "Fechar Interface?",
            Content = "Você tem certeza que deseja fechar o script? Isso irá encerrar todas as funções.",
            Buttons = {
                {
                    Name = "Sim",
                    Primary = true,
                    Callback = function()
                        Tween(MainFrame, 0.4, {Size = UDim2.new(0, 0, 0, 0)})
                        task.wait(0.4)
                        ScreenGui:Destroy()
                    end
                },
                {
                    Name = "Não",
                    Primary = false,
                    Callback = function() end
                }
            }
        })
    end)
    
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
        Position = UDim2.new(0, 0, 0, 44),
        Size = UDim2.new(0, 155, 1, -44)
    })

    Create("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = SideBar
    })

    -- Sidebar label
    Create("TextLabel", {
        Parent = SideBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(1, -12, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = "NAVEGAÇÃO",
        TextColor3 = Genim.Theme.AccentColor,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local SideBarList = Create("ScrollingFrame", {
        Name = "List",
        Parent = SideBar,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 8, 0, 28),
        Size = UDim2.new(1, -16, 1, -36),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Genim.Theme.AccentColor,
        ScrollBarImageTransparency = 0.4,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ElasticBehavior = Enum.ElasticBehavior.Always,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
    })
    
    local SideBarLayout = Create("UIListLayout", {
        Parent = SideBarList,
        Padding = UDim.new(0, 4),
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
        Position = UDim2.new(0, 155, 0, 44),
        Size = UDim2.new(1, -155, 1, -44),
        ClipsDescendants = true
    })

    local VersionLabel = Create("TextLabel", {
        Name = "Version",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 1, -18),
        Size = UDim2.new(0, 120, 0, 14),
        Font = Enum.Font.GothamMedium,
        Text = Genim.Version,
        TextColor3 = Genim.Theme.AccentColor,
        TextTransparency = 0.4,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 110
    })
    
    function Window:CreateDialog(Props)
        Props = Props or {}
        Props.Title = Props.Title or "Dialog"
        Props.Content = Props.Content or "Are you sure?"
        Props.Buttons = Props.Buttons or {
            {Name = "Confirm", Primary = true, Callback = function() end},
            {Name = "Cancel", Primary = false, Callback = function() end}
        }

        local Overlay = Create("TextButton", {
            Name = "Overlay",
            Parent = MainFrame,
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            AutoButtonColor = false,
            ZIndex = 200
        })

        local DialogFrame = Create("CanvasGroup", {
            Name = "Dialog",
            Parent = Overlay,
            BackgroundColor3 = Genim.Theme.MainColor,
            BackgroundTransparency = 0.05,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 0, 0, 0),
            ClipsDescendants = true,
            ZIndex = 201
        })

        Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = DialogFrame })
        local DStroke = Create("UIStroke", {
            Color = Color3.new(1, 1, 1),
            Thickness = 1,
            Parent = DialogFrame,
            Transparency = 0.5
        })
        
        Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Genim.Theme.AccentColor),
                ColorSequenceKeypoint.new(1, Genim.Theme.SecondaryAccent)
            }),
            Parent = DStroke
        })

        local DTitle = Create("TextLabel", {
            Parent = DialogFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 15),
            Size = UDim2.new(1, -30, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = Props.Title,
            TextColor3 = Genim.Theme.TextColor,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 202
        })

        local DContent = Create("TextLabel", {
            Parent = DialogFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 45),
            Size = UDim2.new(1, -30, 0, 40),
            Font = Enum.Font.GothamMedium,
            Text = Props.Content,
            TextColor3 = Genim.Theme.SecondaryTextColor,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            ZIndex = 202
        })

        local ButtonContainer = Create("Frame", {
            Parent = DialogFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 1, -45),
            Size = UDim2.new(1, -30, 0, 30),
            ZIndex = 202
        })

        local Layout = Create("UIListLayout", {
            Parent = ButtonContainer,
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        local function CloseDialog()
            Tween(DialogFrame, 0.3, {Size = UDim2.new(0, 0, 0, 0)})
            Tween(Overlay, 0.3, {BackgroundTransparency = 1})
            task.wait(0.3)
            Overlay:Destroy()
        end

        for i, btn in pairs(Props.Buttons) do
            local BFrame = Create("Frame", {
                Name = btn.Name .. "Button",
                Parent = ButtonContainer,
                BackgroundColor3 = btn.Primary and Genim.Theme.AccentColor or Genim.Theme.DarkerColor,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 80, 1, 0),
                LayoutOrder = i,
                ZIndex = 203
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = BFrame })
            if not btn.Primary then
                Create("UIStroke", { Color = Genim.Theme.StrokeColor, Thickness = 1, Parent = BFrame })
            end

            local BText = Create("TextButton", {
                Parent = BFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = btn.Name,
                TextColor3 = btn.Primary and Color3.new(1, 1, 1) or Genim.Theme.TextColor,
                TextSize = 12,
                AutoButtonColor = false,
                ZIndex = 204
            })

            BText.MouseButton1Click:Connect(function()
                Ripple(BFrame)
                task.spawn(btn.Callback)
                CloseDialog()
            end)
        end

        -- Animate In
        Tween(Overlay, 0.3, {BackgroundTransparency = 0.5})
        Tween(DialogFrame, 0.4, {Size = UDim2.new(0, 300, 0, 140)})
    end

    -- Window properties already initialized
    
    function Window:CreateTab(Name, Icon)
        local TabButton = Create("TextButton", {
            Name = Name .. "Tab",
            Parent = SideBarList,
            BackgroundColor3 = Genim.Theme.AccentColor,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 36),
            AutoButtonColor = false,
            Font = Enum.Font.GothamSemibold,
            Text = "  " .. Name,
            TextColor3 = Genim.Theme.SecondaryTextColor,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = TabButton
        })

        -- Active left-bar indicator
        local TabIndicator = Create("Frame", {
            Name = "Indicator",
            Parent = TabButton,
            BackgroundColor3 = Genim.Theme.AccentColor,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0.2, 0),
            Size = UDim2.new(0, 3, 0.6, 0),
            Visible = false
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = TabIndicator })
        
        local TabContent = Create("CanvasGroup", {
            Name = Name .. "Content",
            Parent = Container,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            GroupTransparency = 0
        })

        local TabScroll = Create("ScrollingFrame", {
            Name = "Scroll",
            Parent = TabContent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Genim.Theme.AccentColor,
            ScrollBarImageTransparency = 0.4,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ElasticBehavior = Enum.ElasticBehavior.Always,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
        })
        
        local TabList = Create("UIListLayout", {
            Parent = TabScroll,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        })

        -- Robust Manual Update with Extra Padding
        TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabScroll.CanvasSize = UDim2.new(0, 0, 0, TabList.AbsoluteContentSize.Y + 50)
        end)
        
        Create("UIPadding", {
            Parent = TabScroll,
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10)
        })

        local Tab = {
            Elements = {}
        }
        
        function Tab:CreateSection(Name)
            local SectionFrame = Create("Frame", {
                Name = Name .. "Section",
                Parent = TabScroll,
                BackgroundColor3 = Genim.Theme.AccentColor,
                BackgroundTransparency = 0.88,
                BorderSizePixel = 0,
                Size = UDim2.new(0.92, 0, 0, 28)
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 7),
                Parent = SectionFrame
            })

            Create("Frame", {
                Parent = SectionFrame,
                BackgroundColor3 = Genim.Theme.AccentColor,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0.2, 0),
                Size = UDim2.new(0, 3, 0.6, 0)
            })
            
            Create("TextLabel", {
                Name = "Title",
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 0),
                Size = UDim2.new(1, -14, 1, 0),
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
                Parent = TabScroll,
                BackgroundColor3 = Genim.Theme.DarkerColor,
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
                Size = UDim2.new(0.92, 0, 0, 40)
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
                Parent = TabScroll,
                BackgroundColor3 = Genim.Theme.DarkerColor,
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
                Size = UDim2.new(0.92, 0, 0, 40)
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

            local function Update(Save)
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
                Update(true)
            end)


            if Toggled then Update(false) end

            return {
                Set = function(_, NewValue)
                    Toggled = NewValue
                    Update(true)
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
                Parent = TabScroll,
                BackgroundColor3 = Genim.Theme.DarkerColor,
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
                Size = UDim2.new(0.92, 0, 0, 52)
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

            local function Update(Input, Save)
                local Percentage
                if typeof(Input) == "number" then
                    Percentage = Input
                else
                    Percentage = math.clamp((Input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                end
                
                Value = math.floor(Props.Min + (Props.Max - Props.Min) * Percentage)
                
                ValueLabel.Text = tostring(Value)
                Tween(SliderFill, 0.1, {Size = UDim2.new(Percentage, 0, 1, 0)})
                
                Props.Callback(Value)
            end

            local Dragging = false
            SliderFrame.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    Update(Input, true)
                end
            end)

            UserInputService.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(Input)
                if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                    Update(Input, true)
                end
            end)

            if Value ~= Props.CurrentValue then
                task.spawn(function()
                    task.wait()
                    Update((Value - Props.Min) / (Props.Max - Props.Min), false)
                end)
            end

            return {
                Set = function(_, NewValue)
                    Value = math.clamp(NewValue, Props.Min, Props.Max)
                    Update((Value - Props.Min) / (Props.Max - Props.Min), true)
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
                Parent = TabScroll,
                BackgroundColor3 = Genim.Theme.DarkerColor,
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
                Size = UDim2.new(0.92, 0, 0, 40)
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
                Parent = TabScroll,
                BackgroundColor3 = Genim.Theme.DarkerColor,
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
                Size = UDim2.new(0.92, 0, 0, 40),
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
                Image = "rbxassetid://15132379512",
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
                Tween(Arrow, 0.2, {Rotation = Opened and 270 or 90})
                
                local ContentSize = 40
                if Opened then
                    for _, option in pairs(Props.Options) do
                        ContentSize = ContentSize + 28
                    end
                    ContentSize = ContentSize + 5
                end
                
                Tween(DropdownFrame, 0.3, {Size = UDim2.new(0.92, 0, 0, ContentSize)})
            end

            local function Update(Value, Save)
                Selected = Value
                SelectedLabel.Text = Selected
                
                for _, child in pairs(ItemsContainer:GetChildren()) do
                    if child:IsA("TextButton") then
                        child.TextColor3 = (child.Name == Selected and Genim.Theme.TextColor or Genim.Theme.SecondaryTextColor)
                    end
                end
                
                Props.Callback(Selected)
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
                    Update(Value, true)
                    Toggle(false)
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

            if Selected ~= Props.CurrentOption then
                task.spawn(function()
                    task.wait()
                    Update(Selected, false)
                end)
            end

            return {
                Set = function(_, NewValue)
                    Update(NewValue, true)
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
                local OldContent = Window.CurrentTab.Content
                local OldBtn = Window.CurrentTab.Button
                Tween(OldBtn, 0.25, {BackgroundTransparency = 1, TextColor3 = Genim.Theme.SecondaryTextColor})
                local OldInd = OldBtn:FindFirstChild("Indicator")
                if OldInd then OldInd.Visible = false end
                task.spawn(function()
                    Tween(OldContent, 0.2, {Position = UDim2.new(0, 0, 0, 12), GroupTransparency = 1})
                    task.wait(0.2)
                    OldContent.Visible = false
                    OldContent.Position = UDim2.new(0, 0, 0, 0)
                end)
            end
            
            TabContent.Visible = true
            TabContent.Position = UDim2.new(0, 0, 0, 12)
            TabContent.GroupTransparency = 1
            Tween(TabContent, 0.35, {Position = UDim2.new(0, 0, 0, 0), GroupTransparency = 0})
            Tween(TabButton, 0.25, {BackgroundTransparency = 0.85, TextColor3 = Genim.Theme.TextColor})
            TabIndicator.Visible = true
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
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            Tween(MainFrame, 0.5, {Size = UDim2.new(0, 560, 0, 380)})
            -- Intro sequence for aesthetics
            task.spawn(function()
                MainFrame.GroupTransparency = 1
                Tween(MainFrame, 0.4, {GroupTransparency = 0})
            end)
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
                Size = UDim2.new(0, 560, 0, 380),
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
            
            if Config.StartupNotification then
                Genim:Notify(Config.NotificationConfig or {
                    Title = "Genim Library",
                    Content = "Interface carregada com sucesso!",
                    Duration = 5
                })
            end
        end)
    end

    if KeySystem then
        local KeyFrame = Create("Frame", {
            Name = "KeyFrame",
            Parent = ScreenGui,
            BackgroundColor3 = Genim.Theme.MainColor,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 320, 0, 180),
            ClipsDescendants = true
        })
        
        Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = KeyFrame })
        Create("UIStroke", { Color = Genim.Theme.StrokeColor, Thickness = 1.2, Parent = KeyFrame })

        local KClose = Create("TextButton", {
            Name = "CloseButton",
            Parent = KeyFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -30, 0, 5),
            Size = UDim2.new(0, 25, 0, 25),
            Font = Enum.Font.GothamBold,
            Text = "X",
            TextColor3 = Genim.Theme.SecondaryTextColor,
            TextSize = 14,
            AutoButtonColor = false
        })

        KClose.MouseEnter:Connect(function()
            Tween(KClose, 0.2, {TextColor3 = Color3.fromRGB(255, 100, 100)})
        end)

        KClose.MouseLeave:Connect(function()
            Tween(KClose, 0.2, {TextColor3 = Genim.Theme.SecondaryTextColor})
        end)

        KClose.MouseButton1Click:Connect(function()
            Ripple(KClose)
            Tween(KeyFrame, 0.4, {Size = UDim2.new(0, 0, 0, 0)})
            task.wait(0.4)
            ScreenGui:Destroy()
        end)

        local KTitle = Create("TextLabel", {
            Parent = KeyFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 20),
            Size = UDim2.new(1, 0, 0, 25),
            Font = Enum.Font.GothamBold,
            Text = KeySettings.Title or "Verification Required",
            TextColor3 = Genim.Theme.TextColor,
            TextSize = 18
        })

        local KSubtitle = Create("TextLabel", {
            Parent = KeyFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 45),
            Size = UDim2.new(1, 0, 0, 20),
            Font = Enum.Font.GothamMedium,
            Text = KeySettings.Subtitle or "Join Discord to get the Key",
            TextColor3 = Genim.Theme.SecondaryTextColor,
            TextSize = 12
        })

        local KInput = Create("TextBox", {
            Parent = KeyFrame,
            BackgroundColor3 = Genim.Theme.DarkerColor,
            BorderSizePixel = 0,
            Position = UDim2.new(0.1, 0, 0.5, -15),
            Size = UDim2.new(0.8, 0, 0, 35),
            Font = Enum.Font.GothamMedium,
            PlaceholderText = "Enter key here...",
            Text = "",
            TextColor3 = Genim.Theme.TextColor,
            TextSize = 14
        })
        
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = KInput })
        Create("UIStroke", { Color = Genim.Theme.StrokeColor, Thickness = 1, Parent = KInput })

        local VerifyBtn = Create("TextButton", {
            Parent = KeyFrame,
            BackgroundColor3 = Genim.Theme.AccentColor,
            BorderSizePixel = 0,
            Position = UDim2.new(0.1, 0, 0.8, -10),
            Size = UDim2.new(0.38, 0, 0, 30),
            Font = Enum.Font.GothamBold,
            Text = "Verify",
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 14,
            AutoButtonColor = false
        })
        
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = VerifyBtn })

        local GetKeyBtn = Create("TextButton", {
            Parent = KeyFrame,
            BackgroundColor3 = Genim.Theme.DarkerColor,
            BorderSizePixel = 0,
            Position = UDim2.new(0.52, 0, 0.8, -10),
            Size = UDim2.new(0.38, 0, 0, 30),
            Font = Enum.Font.GothamBold,
            Text = "Get Key",
            TextColor3 = Genim.Theme.TextColor,
            TextSize = 14,
            AutoButtonColor = false
        })
        
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = GetKeyBtn })
        Create("UIStroke", { Color = Genim.Theme.StrokeColor, Thickness = 1, Parent = GetKeyBtn })

        MakeDraggable(KeyFrame, KeyFrame)

        VerifyBtn.MouseButton1Click:Connect(function()
            Ripple(VerifyBtn)
            if KInput.Text == ValidKey then
                Tween(KeyFrame, 0.5, {Size = UDim2.new(0, 0, 0, 0)})
                task.wait(0.5)
                KeyFrame:Destroy()
                StartLoading()
            else
                KInput.Text = ""
                KInput.PlaceholderText = "Invalid Key! Try again."
                task.wait(1.5)
                KInput.PlaceholderText = "Enter key here..."
            end
        end)

        GetKeyBtn.MouseButton1Click:Connect(function()
            Ripple(GetKeyBtn)
            if setclipboard then
                setclipboard(KeySettings.Link or "https://discord.gg/example")
                GetKeyBtn.Text = "Copied!"
                task.wait(1)
                GetKeyBtn.Text = "Get Key"
            else
                print("Key Link: " .. (KeySettings.Link or "https://discord.gg/example"))
                GetKeyBtn.Text = "Check Console"
                task.wait(1)
                GetKeyBtn.Text = "Get Key"
            end
        end)
    else
        StartLoading()
    end

    return Window
end




function Genim:Notify(Config)
    Config = Config or {}
    Config.Title = Config.Title or "Notification"
    Config.Content = Config.Content or "Content"
    Config.Duration = Config.Duration or 5
    
    if not Genim.NotifyHolder then return end
    
    local NotifyFrame = Create("CanvasGroup", {
        Name = "Notification",
        Parent = Genim.NotifyHolder,
        BackgroundColor3 = Genim.Theme.MainColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
        GroupTransparency = 1
    })
    
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = NotifyFrame })
    
    local NotifyStroke = Create("UIStroke", {
        Color = Color3.new(1, 1, 1),
        Thickness = 1,
        Parent = NotifyFrame,
        Transparency = 0.6
    })
    
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Genim.Theme.AccentColor),
            ColorSequenceKeypoint.new(1, Genim.Theme.SecondaryAccent)
        }),
        Parent = NotifyStroke
    })
    
    local Title = Create("TextLabel", {
        Parent = NotifyFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(1, -24, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = Config.Title,
        TextColor3 = Genim.Theme.TextColor,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local Content = Create("TextLabel", {
        Parent = NotifyFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 28),
        Size = UDim2.new(1, -24, 0, 0),
        Font = Enum.Font.GothamMedium,
        Text = Config.Content,
        TextColor3 = Genim.Theme.SecondaryTextColor,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true
    })

    -- Auto-Size based on content
    local textHeight = game:GetService("TextService"):GetTextSize(Config.Content, 12, Enum.Font.GothamMedium, Vector2.new(276, 1000)).Y
    local totalHeight = 40 + textHeight
    
    -- Animation In
    Tween(NotifyFrame, 0.4, {Size = UDim2.new(1, 0, 0, totalHeight), GroupTransparency = 0})
    
    task.delay(Config.Duration, function()
        -- Animation Out
        Tween(NotifyFrame, 0.4, {Size = UDim2.new(1, 0, 0, 0), GroupTransparency = 1})
        task.wait(0.4)
        NotifyFrame:Destroy()
    end)
end

return Genim
