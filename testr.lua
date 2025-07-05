--[[
     _              _             _ _
    | |  _  _ _ __ (_)_ _  ___ __(_) |_ _  _
    | |_| || | '  \| | ' \/ _ (_-< |  _| || |
    |____\_,_|_|_|_|_|_||_\___/__/_|\__|\_, |
                                        |__/
	Source:
        https://raw.githubusercontent.com/icuck/GenesisStudioLibraries/main/Elerium%20Interface%20Library.lua

	Version:
        0.0.1

	Date:
        October 19th, 2020

	Author:
        OminousVibes @ v3rmillion.net / OminousVibes#1234 @ discord.gg

    Credits:
        (None Yet)

]]

-- [ Initialize ] --
-- Destroy Previous UI's --
if _G.ByteRise_Loaded and _G.ByteRise then
    _G.ByteRise:Destroy()
end

-- Set Globals --
_G.ByteRise_Loaded = true

-- [ Yield ] --
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- // CONSTANTS \\ --
-- [ Services ] --
local Services = setmetatable({}, {__index = function(Self, Index)
    local NewService = game:GetService(Index)
    if NewService then
        Self[Index] = NewService
    end
    return NewService
end})

-- [ LocalPlayer ] --
local LocalPlayer = Services.Players.LocalPlayer

-- // Library \\ --
local ByteRise = {}
_G.ByteRise = ByteRise

ByteRise.ScreenGui = Instance.new("ScreenGui")
ByteRise.ScreenGui.Name = "ByteRise"
ByteRise.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ByteRise.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- // Variables \\ --
-- [ Colors ] --
local Objects = {}

-- [ Other ] --
local Binds = {}

-- // Functions \\ --
local Utility = {}

--[[
Utility.new(Class: string, Properties: Dictionary, Children: Array)
    Creates a new object with the Properties
]]
function Utility.new(Class, Properties, Children)
    local NewInstance = Instance.new(Class)
    for i,v in pairs(Properties or {}) do
        if i ~= "Parent" then
            NewInstance[i] = v
        end
    end
    for i,v in ipairs(Children or {}) do
        if typeof(v) == "Instance" then
            v.Parent = NewInstance
        end
    end

    NewInstance.Parent = Properties.Parent
    return NewInstance
end

--[[
Utility.Tween(Object: Instance, TweenInformation: TweenInfo, Goal: Dictionary)
    Creates a tween
]]
function Utility.Tween(Object, TweenInformation, Goal)
    -- [ Tween ] --
    local Tween = Services.TweenService:Create(Object, TweenInformation, Goal)

    -- [ Info ] --
    local Info = {}

    -- Yield --
	function Info:Yield()
		Tween:Play()
		Tween.Completed:Wait(10)
	end

	return setmetatable(Info, {__index = function(Self, Index)
		local Value = Tween[Index]
		return typeof(Value) ~= "function" and Value or function(self, ...)
			return Tween[Index](Tween, ...)
		end
	end})
end

--[[
Utility:Wait()
    Yields for a short period of time.
]]
function Utility.Wait(Seconds)
    if Seconds then
        local StartTime = time()
        repeat
            Services.RunService.Heartbeat:Wait(0.1)
        until time() - StartTime > Seconds
    else
        return Services.RunService.Heartbeat:Wait(0.1)
    end
end

--[[
Utility.BindKey(Key: KeyCode, Callback: Function, ID: string)
    Binds a key
]]
function Utility.BindKey(Key, Callback, ID)
    local BindID = ID or Services.HttpService:GenerateGUID(true)
    Services.ContextActionService:BindAction(BindID, Callback, false, Key)
    return BindID
end

--[[
Utility:DraggingEnabled()
    Allows Dragging for the Frame Provided
]]
function Utility.CreateDrag(Frame, Parent, Settings)
    -- Main --
    local DragPro = {
        DragEnabled = true;
        Dragging = false;
        Settings = Settings or {
            TweenDuration = 0.1,
            TweenStyle = Enum.EasingStyle.Quad
        }
    }

    -- Info --
    local DragInfo = {
        Parent = Parent or Frame;
        DragInput = nil;
        MousePosition = nil;
        FramePosition = nil;
    }

    -- Script --
    local Connections = {}

    function DragPro:Initialize()
        table.insert(Connections,
            Frame.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    DragPro.Dragging = true
                    DragInfo.MousePosition = Input.Position
                    DragInfo.FramePosition = DragInfo.Parent.Position

                    repeat
                        Input.Changed:Wait()
                    until Input.UserInputState == Enum.UserInputState.End
                    DragPro.Dragging = false
                end
            end)
        )

        table.insert(Connections,
            Frame.InputChanged:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    DragInfo.DragInput = Input
                end
            end)
        )

        table.insert(Connections,
            Services.UserInputService.InputChanged:Connect(function(Input)
                if DragPro.Dragging == true and Input == DragInfo.DragInput then
                    local PositionChange = Input.Position - DragInfo.MousePosition
                    Utility.Tween(DragInfo.Parent, TweenInfo.new(DragPro.Settings.TweenDuration, DragPro.Settings.TweenStyle), {Position = UDim2.new(DragInfo.FramePosition.X.Scale, DragInfo.FramePosition.X.Offset + PositionChange.X, DragInfo.FramePosition.Y.Scale, DragInfo.FramePosition.Y.Offset + PositionChange.Y)}):Play()
                end
            end)
        )
    end

    -- Functions --
    function DragPro:Destroy()
        for i,v in ipairs(Connections) do
            v:Disconnect()
        end
    end

    DragPro:Initialize()

    -- Return --
    return DragPro
end

-- // Main Module \\ --
-- [ ByteRise ] --
local ByteRise = {
    ScreenGui = Utility.new("ScreenGui", {
        DisplayOrder = 5,
        Name = "ByteRise",
        Parent = Services.RunService:IsStudio() and LocalPlayer:FindFirstChildOfClass("PlayerGui") or Services.CoreGui,
        IgnoreGuiInset = true,
        ResetOnSpawn = false
    });
    Settings = {
        Name = "Template";
        Debug = false;
    };
    ColorScheme = {
        Primary = Color3.fromRGB(66, 134, 245);
        Text = Color3.new(255, 255, 255);
    };
}
_G.ByteRise = ByteRise.ScreenGui
for i,v in pairs({Name = "Template", Debug = false}) do
    if ByteRise.Settings[i] == nil then
        ByteRise.Settings[i] = v
    end
end

-- Intro --
function ByteRise.LoadingScreen()
    coroutine.wrap(function()
        local LoadingScreen = Utility.new("Frame", {
            Name = "LoadingScreen",
            Parent = ByteRise.ScreenGui,
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 5
        }, {
            Utility.new("VideoFrame", {
                Name = "LoadingVideo",
                Visible = false,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.new(0, 750, 0, 425),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                ZIndex = 10,
                Looped = true,
                Playing = true,
                TimePosition = 0,
                Video = "rbxassetid://5608337069"
            })
        })
        Utility.Tween(LoadingScreen, TweenInfo.new(1), {BackgroundTransparency = 0}):Yield()

        -- Loading --    
        if not LoadingScreen.LoadingVideo.IsLoaded then
            LoadingScreen.LoadingVideo.Loaded:Wait(10)
        end
        LoadingScreen.LoadingVideo.Visible = true

        -- Wait for all assets to load --
        Utility.Wait(2.5)
        Services.ContentProvider:PreloadAsync({ByteRise.ScreenGui})
        Utility.Wait(0.25)

        -- Destroy Screen --
        LoadingScreen.LoadingVideo.Visible = false
        Utility.Tween(LoadingScreen, TweenInfo.new(1), {BackgroundTransparency = 1}):Yield()
        LoadingScreen:Destroy()
    end)()
    Utility.Wait(1)
end

-- [ Options ] --
local function CreateOptions(Frame)
    local Options = {}

    function Options.TextLabel(Title)
        local Container = Utility.new("Frame", {
            Name = "Switch",
            Parent = typeof(Frame) == "Instance" and Frame or Frame(),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 25),
        }, {
            Utility.new("TextLabel", {
                Name = "Title",
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.Gotham,
                Text = Title and tostring(Title) or "TextLabel",
                RichText = true,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                TextTransparency = 0.3,
                TextXAlignment = Enum.TextXAlignment.Left
            })
        })

        local Properties = {
            Text = Title and tostring(Title) or "TextLabel";
        }

        return setmetatable({}, {
            __index = function(Self, Index)
                return Properties[Index]
            end;
            __newindex = function(Self, Index, Value)
                if Index == "Text" then
                    Container.Title.Text = Value and tostring(Value) or "TextLabel"
                end
                Properties[Index] = Value
            end;
        })
    end

    function Options.Button(Title, ButtonText, Callback)
        local Properties = {
            Title = Title and tostring(Title) or "Button";
            Function = Callback or function(Status) end;
        }

        local Container = Utility.new("ImageButton", {
            Name = "Button",
            Parent = typeof(Frame) == "Instance" and Frame or Frame(),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 25),
        }, {
            Utility.new("TextLabel", {
                Name = "Title",
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.new(0.5, 0, 1, 0),
                Font = Enum.Font.Gotham,
                Text = Title and tostring(Title) or "Button",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                TextTransparency = 0.3,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            Utility.new("TextButton", {
                Name = "Button",
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Color3.fromRGB(50, 55, 60),
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(0.2, 25, 0, 20),
                Text = ButtonText and tostring(ButtonText) or "Button",
                Font = Enum.Font.Gotham,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 12,
                TextTransparency = 0.3
            }, {
                Utility.new("UICorner", {CornerRadius = UDim.new(0, 4)})
            })
        })

        Container.Button.MouseButton1Down:Connect(function()
            local Success, Error = pcall(Properties.Function)
            assert(ByteRise.Settings.Debug == false or Success, Error)
        end)

        return setmetatable({}, {
            __index = function(Self, Index)
                return Properties[Index]
            end;
            __newindex = function(Self, Index, Value)
                if Index == "Title" then
                    Container.Title.Text = Value and tostring(Value) or "Button"
                elseif Index == "ButtonText" then
                    Container.Button.Text = Value and tostring(Value) or "Button"
                end
                Properties[Index] = Value
            end
        })
    end

    function Options.Switch(Title, Callback)
        local Properties = {
            Title = Title and tostring(Title) or "Switch";
            Value = false;
            Function = Callback or function(Status) end;
        }

        local Container = Utility.new("ImageButton", {
            Name = "Switch",
            Parent = typeof(Frame) == "Instance" and Frame or Frame(),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 25),
        }, {
            Utility.new("TextLabel", {
                Name = "Title",
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Font = Enum.Font.Gotham,
                Text = Title and tostring(Title) or "Switch",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                TextTransparency = 0.3,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            Utility.new("Frame", {
                Name = "Switch",
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Color3.fromRGB(100, 100, 100),
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(0, 25, 0, 15),
            }, {
                Utility.new("UICorner", {CornerRadius = UDim.new(1, 0)}),
                Utility.new("Frame", {
                    Name = "Circle",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    Size = UDim2.new(0, 14, 0, 14)
                }, {Utility.new("UICorner", {CornerRadius = UDim.new(1, 0)})})
            })
        })

        local Tweens = {
            [true] = {
                Utility.Tween(Container.Switch, TweenInfo.new(0.5), {BackgroundColor3 = ByteRise.ColorScheme.Primary}),
                Utility.Tween(Container.Switch.Circle, TweenInfo.new(0.25), {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0)})
            };

            [false] = {
                Utility.Tween(Container.Switch, TweenInfo.new(0.5), {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}),
                Utility.Tween(Container.Switch.Circle, TweenInfo.new(0.25), {AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0)})
            };
        }

        Container.MouseButton1Down:Connect(function()
            Properties.Value = not  Properties.Value
            for i,v in ipairs(Tweens[Properties.Value]) do
                v:Play()
            end
            local Success, Error = pcall(Properties.Function, Properties.Value)
            assert(ByteRise.Settings.Debug == false or Success, Error)
        end)

        return setmetatable({}, {
            __index = function(Self, Index)
                return Properties[Index]
            end;
            __newindex = function(Self, Index, Value)
                if Index == "Title" then
                    Container.Title.Text = Value and tostring(Value) or "Switch"
                elseif Index == "Value" then
                    for i,v in ipairs(Tweens[Value]) do
                        v:Play()
                    end
                    local Success, Error = pcall(Properties.Function, Value)
                    assert(ByteRise.Settings.Debug == false or Success, Error)
                end
                Properties[Index] = Value
            end;
        })
    end

    function Options.Toggle(Title, Callback)
        local Properties = {
            Title = Title and tostring(Title) or "Switch";
            Value = false;
            Function = Callback or function(Status) end;
        }

        local Container = Utility.new("ImageButton", {
            Name = "Toggle",
            Parent = typeof(Frame) == "Instance" and Frame or Frame(),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 25)
        }, {
            Utility.new("TextLabel", {
                Name = "Title",
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Font = Enum.Font.Gotham,
                Text = Title and tostring(Title) or "Switch",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                TextTransparency = 0.3,
                TextXAlignment = Enum.TextXAlignment.Left
            }),

            Utility.new("ImageLabel", {
                Name = "Toggle",
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(0, 20, 0, 20),
                ZIndex = 2,
                Image = "rbxassetid://6031068420"
            }, {
                Utility.new("ImageLabel", {
                    Name = "Fill",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Image = "rbxassetid://6031068421",
                    ImageTransparency = 1
                })
            })
        })

        local Tweens = {
            [true] = {
                Utility.Tween(Container.Toggle.Fill, TweenInfo.new(0.2), {ImageTransparency = 0}),
                Utility.Tween(Container.Toggle, TweenInfo.new(0.5), {ImageColor3 = Color3.fromRGB(240, 240, 240)})
            };
            [false] = {
                Utility.Tween(Container.Toggle.Fill, TweenInfo.new(0.2), {ImageTransparency = 1}),
                Utility.Tween(Container.Toggle, TweenInfo.new(0.5), {ImageColor3 = Color3.fromRGB(255, 255, 255)})
            };
        }

        Container.MouseButton1Down:Connect(function()
            Properties.Value = not Properties.Value
            for i,v in ipairs(Tweens[Properties.Value]) do
                v:Play()
            end
            local Success, Error = pcall(Properties.Function, Properties.Value)
            assert(ByteRise.Settings.Debug == false or Success, Error)
        end)

        return setmetatable({}, {
            __index = function(Self, Index)
                return Properties[Index]
            end;
            __newindex = function(Self, Index, Value)
                if Index == "Title" then
                    Container.Title.Text = Value and tostring(Value) or "Switch"
                elseif Index == "Value" then
                    for i,v in ipairs(Tweens[Value]) do
                        v:Play()
                    end
                    local Success, Error = pcall(Properties.Function, Value)
                    assert(ByteRise.Settings.Debug == false or Success, Error)
                end
                Properties[Index] = Value
            end
        })
    end

    function Options.TextBox(Title, PlaceHolder, Callback)
        local Properties = {
            Title = Title and tostring(Title) or "TextBox";
            Value = "";
            PlaceHolder = PlaceHolder and tostring(PlaceHolder) or "Input";
            Function = Callback or function(Status) end;
        }

        local Container = Utility.new("ImageButton", {
            Name = "TextBox",
            Parent = typeof(Frame) == "Instance" and Frame or Frame(),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 25)
        }, {
            Utility.new("TextLabel", {
                Name = "Title",
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.new(0.5, 0, 1, 0),
                Font = Enum.Font.Gotham,
                Text = Title and tostring(Title) or "TextBox",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                TextTransparency = 0.3,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            Utility.new("ImageLabel", {
                Name = "TextBox",
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(0.2, 25, 0, 20),
                Image = "rbxassetid://3570695787",
                ImageColor3 = Color3.fromRGB(50, 55, 60),
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(100, 100, 100, 100),
                SliceScale = 0.04
            }, {
                Utility.new("TextBox", {
                    Name = "Input",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
                    PlaceholderText = PlaceHolder and tostring(PlaceHolder) or "Input",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12,
                    TextTransparency = 0.3,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, {Utility.new("UIPadding", {PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5)})})
            })
        })

        Container.MouseButton1Down:Connect(function()
            Container.TextBox.Input:CaptureFocus()
        end)

        Container.TextBox.Input:GetPropertyChangedSignal("Text"):Connect(function()
            local TextLength = Container.TextBox.Input.TextBounds.X
            local MaxSize = (Container.AbsoluteSize.X - Container.Title.TextBounds.X) - 40
            if Container.TextBox.Input.TextTruncate == Enum.TextTruncate.None then
                Utility.Tween(Container.TextBox, TweenInfo.new(0.1), {Size = UDim2.new(0.2, math.clamp(TextLength - (Container.AbsoluteSize.X * 0.2) + 15, 25, MaxSize), 0, 20)}):Play()
            end
            Container.TextBox.Input.TextTruncate = TextLength + 10 > MaxSize and Enum.TextTruncate.AtEnd or Enum.TextTruncate.None
            Properties.Value = Container.TextBox.Input.Text
        end)

        Container.TextBox.Input.FocusLost:Connect(function(EnterPressed, Input)
            if EnterPressed then
                coroutine.wrap(function()
                    local Success, Error = pcall(Properties.Function, Properties.Value)
                    assert(ByteRise.Settings.Debug == false or Success, Error)
                end)
                Container.TextBox.Input.Text = ""
            end
        end)

        return setmetatable({}, {
            __index = function(Self, Index)
                return Properties[Index]
            end;
            __newindex = function(Self, Index, Value)
                if Index == "Title" then
                    Container.Title.Text = Value and tostring(Value) or "TextBox"
                elseif Index == "Placeholder" then
                    Container.TextBox.Input.PlaceholderText = Value and tostring(Value) or "Input"
                elseif Index == "Value" then
                    Container.TextBox.Input.Text = Value and tostring(Value) or ""
                end
                Properties[Index] = Value
            end
        })
    end

    function Options.Dropdown(Title, List, Callback, Placeholder)

    end

    function Options.Slider(Title, Settings, Callback)
        Settings = Settings or {}
        local Properties = {
            Title = Title and tostring(Title) or "Slider";
            Value = nil;
            Settings = Settings;
            Function = Callback or function(Status) end;
        }
        for i,v in pairs({Precise = false, Default = 1, Min = 1, Max = 10}) do
            if Properties.Settings[i] == nil then
                Properties.Settings[i] = v
            end
        end
        Properties.Value = math.clamp(Properties.Settings.Default or Properties.Settings.Min, Properties.Settings.Min, Properties.Settings.Max)

        local Container = Utility.new("ImageButton", {
            Name = "Slider",
            Utility.new("TextBox", {
                Name = "Input",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.Gotham,
                PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
                PlaceholderText = PlaceHolder and tostring(PlaceHolder) or "Input",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 12,
                TextTransparency = 0.3,
                TextXAlignment = Enum.TextXAlignment.Left
            }, {Utility.new("UIPadding", {PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5)})})
        })
    })

    Container.MouseButton1Down:Connect(function()
        Container.TextBox.Input:CaptureFocus()
    end)

    Container.TextBox.Input:GetPropertyChangedSignal("Text"):Connect(function()
        local TextLength = Container.TextBox.Input.TextBounds.X
        local MaxSize = (Container.AbsoluteSize.X - Container.Title.TextBounds.X) - 40
        if Container.TextBox.Input.TextTruncate == Enum.TextTruncate.None then
            Utility.Tween(Container.TextBox, TweenInfo.new(0.1), {Size = UDim2.new(0.2, math.clamp(TextLength - (Container.AbsoluteSize.X * 0.2) + 15, 25, MaxSize), 0, 20)}):Play()
        end
        Container.TextBox.Input.TextTruncate = TextLength + 10 > MaxSize and Enum.TextTruncate.AtEnd or Enum.TextTruncate.None
        Properties.Value = Container.TextBox.Input.Text
    end)

    Container.TextBox.Input.FocusLost:Connect(function(EnterPressed, Input)
        if EnterPressed then
            coroutine.wrap(function()
                local Success, Error = pcall(Properties.Function, Properties.Value)
                assert(ByteRise.Settings.Debug == false or Success, Error)
            end)
            Container.TextBox.Input.Text = ""
        end
    end)

    return setmetatable({}, {
        __index = function(Self, Index)
            return Properties[Index]
        end;
        __newindex = function(Self, Index, Value)
            if Index == "Title" then
                Container.Title.Text = Value and tostring(Value) or "TextBox"
            elseif Index == "Placeholder" then
                Container.TextBox.Input.PlaceholderText = Value and tostring(Value) or "Input"
            elseif Index == "Value" then
                Container.TextBox.Input.Text = Value and tostring(Value) or ""
            end
            Properties[Index] = Value
        end
    })
end

function Options.Dropdown(Title, List, Callback, Placeholder)

end

function Options.Slider(Title, Settings, Callback)
    Settings = Settings or {}
    local Properties = {
        Title = Title and tostring(Title) or "Slider";
        Value = nil;
        Settings = Settings;
        Function = Callback or function(Status) end;
    }
    for i,v in pairs({Precise = false, Default = 1, Min = 1, Max = 10}) do
        if Properties.Settings[i] == nil then
            Properties.Settings[i] = v
        end
    end
    Properties.Value = math.clamp(Properties.Settings.Default or Properties.Settings.Min, Properties.Settings.Min, Properties.Settings.Max)

    local Container = Utility.new("ImageButton", {
        Name = "Slider",
        Parent = typeof(Frame) == "Instance" and Frame or Frame(),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 35)
    }, {
        Utility.new("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 2),
            Size = UDim2.new(1, -75, 0, 20),
            Font = Enum.Font.Gotham,
            Text = Title and tostring(Title) or "Slider",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextTransparency = 0.3,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
    
        Utility.new("TextBox", {
            Name = "Value",
            Active = true,
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 0, 0, 2),
            Size = UDim2.new(0, 75, 0, 20),
            Font = Enum.Font.Gotham,
            Text = tostring(Properties.Value),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextTransparency = 0.3,
            TextXAlignment = Enum.TextXAlignment.Right
        }),
    
        Utility.new("ImageLabel", {
            Name = "Bar",
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0, 25),
            Size = UDim2.new(1, 5, 0, 5),
            Image = "rbxassetid://5028857472",
            ImageColor3 = Color3.fromRGB(20, 20, 20),
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(2, 2, 298, 298)
        }, {
            Utility.new("ImageLabel", {
                Name = "Fill",
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 1, 0),
                Image = "rbxassetid://5028857472",
                ImageColor3 = ByteRise.ColorScheme.Primary,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(2, 2, 298, 298)
            }, {
                Utility.new("Frame", {
                    Name = "Circle",
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    ZIndex = 2,
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 10, 0, 10)
                }, {
                    Utility.new("UICorner", {CornerRadius = UDim.new(1, 0)}),
                    Utility.new("Frame", {
                        Name = "Ripple",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.75,
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = UDim2.new(0, 0, 0, 0)
                    }, {Utility.new("UICorner", {CornerRadius = UDim.new(1, 0)})})
                })
            })
        })
    })

    local Info = {
        Sliding = false;
        LastSelected = 0;
        LastUpdated = 0;
        Idled = false;
    }

    local function UpdateSlider(Value)
        if time() - Info.LastUpdated < 0.01 then
            return
        end
        Info.LastUpdated = time()

        Value = math.clamp(Value, Properties.Settings.Min, Properties.Settings.Max)
        if Properties.Settings.Precise then
            Value = math.floor(Value + 0.5)
        end
        Container.Value.Text = tostring(Value)
        Properties.Value = Value
        local Percentage = math.clamp((Value - Properties.Settings.Min) / (Properties.Settings.Max - Properties.Settings.Min), 0, 1)
        Utility.Tween(Container.Bar.Fill, TweenInfo.new(0.1), {Size = UDim2.new(Percentage, 0, 1, 0)}):Play()
                UpdateSlider(((Input.Position.X - Container.Bar.AbsolutePosition.X) / Container.Bar.AbsoluteSize.X) * Properties.Settings.Max)
                Info.LastSelected = time()
                local Success, Error = pcall(Properties.Function, Properties.Value)
                assert(ByteRise.Settings.Debug == false or Success, Error)
            end
        end)

        local CircleTweens = {
            Visible = Utility.Tween(Container.Bar.Fill.Circle, TweenInfo.new(0.25), {BackgroundTransparency = 0});
            Hidden = Utility.Tween(Container.Bar.Fill.Circle, TweenInfo.new(0.5), {BackgroundTransparency = 1});
        }
        local RippleTweens = {
            Visible = Utility.Tween(Container.Bar.Fill.Circle.Ripple, TweenInfo.new(0.25), {Size = UDim2.new(0, 26, 0, 26)});
            Hidden = Utility.Tween(Container.Bar.Fill.Circle.Ripple, TweenInfo.new(0.25), {Size = UDim2.new(0, 0, 0, 0)});
        }
        Container.MouseButton1Down:Connect(function()
            Info.Sliding = true
            UpdateSlider(((Services.UserInputService:GetMouseLocation().X - Container.Bar.AbsolutePosition.X) / Container.Bar.AbsoluteSize.X) * Properties.Settings.Max)
            Info.LastSelected = time()
            CircleTweens.Visible:Play()
            RippleTweens.Visible:Play()
            local Success, Error = pcall(Properties.Function, Properties.Value)
            assert(ByteRise.Settings.Debug == false or Success, Error)
        end)
        Container.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Info.Sliding = false
                Info.LastSelected = time()
                
                RippleTweens.Hidden:Play()
                Info.Idled = true
                repeat
                    Utility.Wait(0.1)
                    if Info.Idled == false then
                        return
                    end
                until time() - Info.LastSelected > 2.5
                CircleTweens.Hidden:Play()
                Info.Idled = false
            end
        end)

        Container.Value.FocusLost:Connect(function()
            local Text = Container.Value.Text
            if Text == "" then
                Container.Value.Text = tostring(Properties.Settings.Min)
            elseif tonumber(Text) == nil then
                Container.Value.Text = tostring(Properties.Settings.Min)
            end
            UpdateSlider(tonumber(Container.TextBox.Text) or Options.Min)
            local Success, Error = pcall(Properties.Function, Properties.Value)
            assert(ByteRise.Settings.Debug == false or Success, Error)
        end)

        Container.Value:GetPropertyChangedSignal("Text"):Connect(function()
            local Text = Container.Value.Text
            if not table.find({"", "-"}, Text) and not tonumber(Text) then
                Container.Value.Text = Text:sub(1, #Text - 1)
            elseif not table.find({"", "-"}, Text) then
                UpdateSlider(tonumber(Text))
            end
        end)

        UpdateSlider(Properties.Value)
        return setmetatable({}, {
            __index = function(Self, Index)
                return Properties[Index]
            end;
            __newindex = function(Self, Index, Value)
                if Index == "Title" then
                    Container.Title.Text = Value and tostring(Value) or "TextBox"
                elseif Index == "Value" then
                    UpdateSlider(tonumber(Value))
                end
                Properties[Index] = Value
            end
        })
    end

    return Options
end

function ByteRise.new(Name, Header, Icon)
    local Main = Utility.new(
        -- Class --
        "ImageButton",

        -- Properties --
        {
            Name = "Main",
            Parent = ByteRise.ScreenGui,
            Active = true,
            Modal = true,
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 700, 0, 475),
            ZIndex = 0,
            ClipsDescendants = true,
            Image = "rbxassetid://3570695787",
            ImageColor3 = Color3.fromRGB(50, 53, 59),
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(100, 100, 100, 100),
            SliceScale = 0.1
        },

        -- Children --
        {
            -- Contents
            Utility.new("Frame", {
                Name = "Contents",
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                Position = UDim2.new(0, 200, 0, 0),
                Size = UDim2.new(1, -200, 1, 0),
                ZIndex = 0
            }, {
                Utility.new("UIPageLayout", {
                    EasingStyle = Enum.EasingStyle.Quad,
                    TweenTime = 0.25,
                    FillDirection = Enum.FillDirection.Vertical,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    GamepadInputEnabled = false,
                    ScrollWheelInputEnabled = false,
                    TouchInputEnabled = false
                })
            }),

            -- SideBar
            Utility.new("ImageLabel", {
                Name = "SideBar",
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 200, 1, 0),
                Image = "rbxassetid://3570695787",
                ImageColor3 = Color3.fromRGB(47, 49, 54),
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(100, 100, 100, 100),
                SliceScale = 0.1
            }, {
                -- Info
                Utility.new("Frame", {
                    Name = "Info",
                    BackgroundTransparency = 1,
                    LayoutOrder = -5,
                    Size = UDim2.new(1, 0, 0, 75)
                }, {
                    Utility.new("ImageLabel", {
                        Name = "Logo",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 30, 0, 30),
                        Image = Icon and "rbxassetid://" .. tostring(Icon) or "rbxassetid://4370345701",
                        ScaleType = Enum.ScaleType.Fit
                    }),
                    Utility.new("TextLabel", {
                        Name = "Title",
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 35, 0, 15),
                        Size = UDim2.new(1, -35, 0, 25),
    end)

    -- Minimize Button
    local MinimizeButton = Utility.new("ImageButton", {
        Name = "Minimize",
        Parent = MainFrame,
        Size = UDim2.new(0, 18, 0, 26),
        Position = UDim2.new(0.90702, 0, 0.01883, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://11293980042",
        ImageColor3 = Color3.fromRGB(151, 151, 151)
    })
    MinimizeButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)

    -- Drag Functionality
    Utility.CreateDrag(MainFrame, MainFrame)

    -- Decorations
    local Decorations = Utility.new("Folder", {
        Name = "Decorations",
        Parent = MainFrame
    })

    Utility.new("ImageLabel", {
        Name = "Bottom-Left",
        Parent = Decorations,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 0, 1, -20),
        BackgroundTransparency = 1,
        Image = "rbxassetid://15437337394"
    })

    Utility.new("ImageLabel", {
        Name = "Bottom-Right",
        Parent = Decorations,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -20, 1, -20),
        BackgroundTransparency = 1,
        Image = "rbxassetid://15437337394"
    })

    Utility.new("ImageLabel", {
        Name = "Top-Left",
        Parent = Decorations,
        Size = UDim2.new(0, 20, 0, 20),
        BackgroundTransparency = 1,
        Image = "rbxassetid://15437337394"
    })

    Utility.new("ImageLabel", {
        Name = "Top-Right",
        Parent = Decorations,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -20, 0, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://15437337394"
    })

    Utility.new("Frame", {
        Name = "Bottom-Bar",
        Parent = Decorations,
        Size = UDim2.new(1, -40, 0, 1),
        Position = UDim2.new(0.5, 0, 0.17, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0
    })

    -- Tab Buttons
    local TabButtons = Utility.new("Frame", {
        Name = "Tab-Buttons",
        Parent = MainFrame,
        Size = UDim2.new(0, 192, 0, 265),
        Position = UDim2.new(0.01678, 0, 0.20476, 0),
        BackgroundTransparency = 1
    })

    local TabScroll = Utility.new("ScrollingFrame", {
        Name = "Tab-Scroll",
        Parent = TabButtons,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    }, {
        Utility.new("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder }),
        Utility.new("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 8) })
    })

    -- Tabs Holder
    local TabsHolder = Utility.new("Frame", {
        Name = "Tabs-Holder",
        Parent = MainFrame,
        Size = UDim2.new(0, 486, 0, 324),
        Position = UDim2.new(0.29943, 0, 0.17698, 0),
        BackgroundTransparency = 1,
    }, {
        Utility.new("UIPageLayout", { SortOrder = Enum.SortOrder.LayoutOrder })
    })

    local Window = {}
    local Tabs = {}

    function Window.Tab(title, info)
        local tabContent = Utility.new("ScrollingFrame", {
            Name = title,
            Parent = TabsHolder,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 0,
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })

        local tabButton = Utility.new("TextButton", {
            Name = "Tab-BTN",
            Parent = TabScroll,
            Size = UDim2.new(0, 175, 0, 56),
            Text = "",
            BackgroundTransparency = 1, -- Set via UIGradient
        }, {
            Utility.new("UICorner", { CornerRadius = UDim.new(0, 4) }),
            Utility.new("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(255, 255, 255) }),
            Utility.new("UIGradient", {
                Color = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 0, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(11, 11, 13))},
                Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.000, 0.4),NumberSequenceKeypoint.new(1.000, 0.8)}
            })
        })

        Utility.new("ImageLabel", {
            Name = "adjustments",
            Parent = tabButton,
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(0.05, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Image = "rbxassetid://75994289158851"
        })

        Utility.new("TextLabel", {
            Name = "Tab-Name",
            Parent = tabButton,
            Size = UDim2.new(0.6, 0, 0.5, 0),
            Position = UDim2.new(0.25, 0, 0.1, 0),
            BackgroundTransparency = 1,
            FontFace = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            Text = title or "Tab 1",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 20,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        Utility.new("TextLabel", {
            Name = "Tab-Sub",
            Parent = tabButton,
            Size = UDim2.new(0.6, 0, 0.5, 0),
            Position = UDim2.new(0.25, 0, 0.5, 0),
            BackgroundTransparency = 1,
            FontFace = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            Text = info or "Tab 1 Info",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        tabButton.MouseButton1Click:Connect(function()
            TabsHolder.UIPageLayout:JumpTo(tabContent)
        end)

        local tabObject = { Options = CreateOptions(tabContent) }
        table.insert(Tabs, tabObject)

        if #Tabs == 1 then
            TabsHolder.UIPageLayout:JumpTo(tabContent)
        end

        return tabObject
    end

    -- Footer
    local ClientInfo = Utility.new("Frame", {
        Name = "Client",
        Parent = MainFrame,
        Size = UDim2.new(0, 192, 0, 68),
        Position = UDim2.new(0.01678, 0, 0.82302, 0),
        BackgroundTransparency = 1
    })

    local Avatar = Utility.new("ImageLabel", {
        Name = "Avatar",
        Parent = ClientInfo,
        Size = UDim2.new(0, 48, 0, 48),
        Position = UDim2.new(0.04166, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://15437337394" -- Placeholder, will be set by script
    }, {
        Utility.new("UICorner", { CornerRadius = UDim.new(1, 0) })
    })

    local DisplayName = Utility.new("TextLabel", {
        Name = "Display-Name",
        Parent = ClientInfo,
        Size = UDim2.new(0.6, 0, 0.4, 0),
        Position = UDim2.new(0.3, 0, 0.1, 0),
        BackgroundTransparency = 1,
        FontFace = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        Text = LocalPlayer.DisplayName,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local UserName = Utility.new("TextLabel", {
        Name = "User-Name",
        Parent = ClientInfo,
        Size = UDim2.new(0.6, 0, 0.4, 0),
        Position = UDim2.new(0.3, 0, 0.5, 0),
        BackgroundTransparency = 1,
        FontFace = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        Text = "@" .. LocalPlayer.Name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local Version = Utility.new("TextLabel", {
        Name = "Version",
        Parent = MainFrame,
        Size = UDim2.new(0.1, 0, 0.05, 0),
        Position = UDim2.new(0.88, 0, 0.93, 0),
        BackgroundTransparency = 1,
        FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        Text = "Version 0.1",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right
    })

    local Ping = Utility.new("TextLabel", {
        Name = "Ping",
        Parent = MainFrame,
        Size = UDim2.new(0.1, 0, 0.05, 0),
        Position = UDim2.new(0.77, 0, 0.93, 0),
        BackgroundTransparency = 1,
        FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        Text = "Ping: 0ms",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right
    })

    -- Update Ping
    coroutine.wrap(function()
        while task.wait(1) do
            local ping = game:GetService("Stats"):GetTotalPing()
            Ping.Text = "Ping: " .. tostring(math.floor(ping)) .. "ms"
        end
    end)()

    -- Update Avatar
    local userId = LocalPlayer.UserId
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size48x48
    local content, isReady = Services.Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
    if isReady then
        Avatar.Image = content
    end

    return Window
end

return ByteRise
