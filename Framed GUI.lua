-- Define variables / constants

local Startup = tick()

local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ServerMode = game:GetService("Workspace").Values.ServerMode
local Targets = game:GetService("Workspace").Values.Targets
local MissNextShot = false
local HitChance = 100

local HunterIcon
local UndercoverIcon
local TargetIcon

if not isfolder("FramedAssets") then
    makefolder("FramedAssets")

    warn("Assets missing, downloading...")

    print("Downloading HunterIcon.png 1/3")
    HunterIcon = game:HttpGet("https://github.com/centerepic/Framed-GUI/raw/main/HunterIcon.png")
    writefile("FramedAssets\\HunterIcon.png",HunterIcon)

    print("Downloading UndercoverIcon.png 2/3")
    UndercoverIcon = game:HttpGet("https://github.com/centerepic/Framed-GUI/raw/main/UndercoverIcon.png")
    writefile("FramedAssets\\UndercoverIcon.png",UndercoverIcon)

    print("Downloading TargetIcon.png 3/3")
    TargetIcon = game:HttpGet("https://github.com/centerepic/Framed-GUI/raw/main/TargetIcon.png")
    writefile("FramedAssets\\TargetIcon.png",TargetIcon)

    print("Assets loaded!")
else
    HunterIcon = readfile("FramedAssets\\HunterIcon.png")
    UndercoverIcon = readfile("FramedAssets\\UndercoverIcon.png")
    TargetIcon = readfile("FramedAssets\\TargetIcon.png")
    print("Assets loaded!")
end

-- Load in modules

local ESP = loadstring(game:HttpGet("https://kiriot22.com/releases/ESP.lua"))()
-- // Load Aiming Module
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/centerepic/LifeSentanceScript/main/Aiming_Module.lua"))()

ESP:Toggle(true)

Aiming.TeamCheck(false)

local function printTable(t)
    for k, v in pairs(t) do
      print(k, v)
    end
end

local function GameInProgress()
    return ServerMode.Value == "In Progress"
end

function Aiming.Check()
    -- // Check A
    if not (Aiming.Enabled == true and Aiming.Selected ~= LocalPlayer and Aiming.SelectedPart ~= nil) then
        return false
    end

    if GameInProgress() then
        return false
    end

    -- //
    return true
end

ServerMode.Changed:Connect(function()
    if Toggles.ESPToggle.Value == false then
        ESP:Toggle(false)
    end
    if Toggles.ESPToggle.Value == true then
        ESP:Toggle(GameInProgress())
    end
end)

local function GetUserFromId(Id)
    return Players:GetPlayerByUserId(Id)
end

local function Miss()
    return (math.random(0,100) >= HitChance)
end

local function GetTargets(Player)
    local Decoded = game:GetService('HttpService'):JSONDecode(Targets.Value)
    local Targets = Decoded[tostring(Player.UserId)]
    local PlayerTable = {}
    if Targets then
        for _,b in pairs(Targets) do
            table.insert(PlayerTable,GetUserFromId(b))
		end
    end
    return PlayerTable
end

local function MyTargets()
    return GetTargets(LocalPlayer)
end

local function GetLighterColor(Color)
    local H, S, V = Color3.toHSV(Color);
    return Color3.fromHSV(H, S, V * 5);
end

local function table_count(tt, item)
    local count
    count = 0
    for ii,xx in next, tt do
      if item == xx then count = count + 1 end
    end
    return count
end

local function BetterRound(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function BeatWait()
    RunService.Heartbeat:Wait()
end

local function GetClosest()
    local Character = LocalPlayer.Character
    local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    if not (Character or HumanoidRootPart) then return end

    local TargetDistance = math.huge
    local Target

    for i,v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local TargetHRP = v.Character.HumanoidRootPart
            local mag = (HumanoidRootPart.Position - TargetHRP.Position).magnitude
            if mag < TargetDistance then
                TargetDistance = mag
                Target = v.Character
            end
        end
    end

    return Target
end

local function Targettify(Character,Tag,Color)
    local parts = Character:GetChildren()
  
    for _, part in pairs(parts) do
        if part:IsA("Part") and (part.Name ~= "MobileHitbox" and part.Name ~=  "MobileHead") then
            local hasAdornment = false
            if part:FindFirstChild("ESP") then
                hasAdornment = true
            end
            if not hasAdornment then
                local a = Instance.new("BoxHandleAdornment")
                a.Name = "ESP"
                a.Parent = part
                a.Adornee = part
                a.AlwaysOnTop = true
                a.ZIndex = 10
                a.Size = part.Size
                a.Transparency = 0.5
                a.Color = Color or game.Players:GetPlayerFromCharacter(Character).TeamColor
            end
        end
    end
end

local UndercoverESP
local TargetESP = {}
local HunterESP = {}

local function Mark(Player,Role,Color)
    return ESP:Add(Player.Character,{
        Name = Role or Player.Name,
        Color = Color,
        Player = Player,
        Temporary = true,
        PrimaryPart = Player.Character:FindFirstChild("HumanoidRootPart") or Player.Character:FindFirstChild("Torso"),
        IsEnabled = Role
    })
end

LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
    if child.Name == LocalPlayer.Name .. "TargetScreen" then
        print("Found")
        wait(0.1)

        local TargetFace = tostring(child:WaitForChild("FaceFrame"):WaitForChild("SingleTarget").Image)

        for i,v in pairs(game.Players:GetPlayers()) do
            if v.Character and v.Character:FindFirstChild("Head") and v.Character.Head:FindFirstChild("face") then
                if TargetFace == v.Character.Head.face.Texture then
                    Targettify(v.Character)
                end
            end
        end

    end
end)

local repo = 'https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/'
local t = tostring(tick())

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/centerepic/RefineryCaves/main/library.lua?t='..t))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua?t='..t))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua?t='..t))()

local Window 
Window = Library:CreateWindow({
    Title = "sasware v1 | OpenWare",
    Center = true, 
    AutoShow = true,
})

local Tabs = {
    CombatTab = Window:AddTab('Combat'),
    VisualsTab = Window:AddTab('Visuals'),
    CreditsTab = Window:AddTab('Credits'),
    UISettings = Window:AddTab('UI Settings')
}

local AimingGroup = Tabs.CombatTab:AddLeftGroupbox('Aiming')

-- AimingGroup:AddToggle('SilentAimToggle', {
--     Text = 'Silent Aim',
--     Default = false,
--     Tooltip = 'Enables/Disables silent aim.'
-- })

AimingGroup:AddSlider('FOVSlider', {
    Text = 'Aimlock FOV',
    Default = 60,
    Min = 15,
    Max = 360,
    Rounding = 0,
    Compact = false
})

AimingGroup:AddDropdown('AimpartDropDown', {
    Values = {'Head','Torso','All'},
    Default = nil,
    Multi = false,
    Text = 'Aim Part',
    Tooltip = 'Parts of a character to aim at.',
})

Options.AimpartDropDown:OnChanged(function()
    if Options.AimpartDropDown.Value ~= nil then

        if Options.AimpartDropDown.Value ~= 'All' then
            Aiming.TargetPart = {Options.AimpartDropDown.Value}
        else
            Aiming.TargetPart = {'Head','Torso','Left Arm','Right Arm','Left Leg','Right Leg'}
        end
        
    end
end)

Options.FOVSlider:OnChanged(function()
    Aiming.FOV = Options.FOVSlider.Value
end)

AimingGroup:AddSlider('AccuracySlider', {
    Text = 'Hitchance',
    Default = 100,
    Min = 10,
    Max = 100,
    Rounding = 0,
    Compact = false
})

Options.AccuracySlider:OnChanged(function()
    HitChance = Options.AccuracySlider.Value
end)

AimingGroup:AddToggle('AimlockToggle', {
    Text = 'Aimlock',
    Default = false,
    Tooltip = 'Enables/Disables aimlock.'
})

Toggles.AimlockToggle:OnChanged(function(Value)
    Aiming.Enabled = Value
end)

local CombatOtherGroup = Tabs.CombatTab:AddRightGroupbox('Main')

CombatOtherGroup:AddToggle('AlwaysBackstabToggle', {
    Text = 'Always backstab',
    Default = false,
    Tooltip = 'Makes all knife hits backstabs.'
})

CombatOtherGroup:AddButton('Remove Face [BLATANT]', function()
    LocalPlayer.Character.Head.Face:Destroy()
end)

local MainGroup = Tabs.VisualsTab:AddLeftGroupbox('Main')

MainGroup:AddToggle('ESPToggle', {
    Text = 'ESP',
    Default = false,
    Tooltip = 'Enables/Disables ESP.'
})

Toggles.ESPToggle:OnChanged(function()
    ESP:Toggle(GameInProgress())
end)

MainGroup:AddToggle('HunterESPToggle', {
    Text = 'Hunter ESP',
    Default = false,
    Tooltip = 'Enables/Disables hunter ESP.'
})

Toggles.HunterESPToggle:OnChanged(function(Value)
    ESP.Hunter = Value
end)

MainGroup:AddToggle('TargetESPToggle', {
    Text = 'Target ESP',
    Default = false,
    Tooltip = 'Enables/Disables target ESP.'
})

Toggles.TargetESPToggle:OnChanged(function(Value)
    ESP.Target = Value
end)

MainGroup:AddToggle('UndercoverESPToggle', {
    Text = 'Undercover ESP',
    Default = false,
    Tooltip = 'Enables/Disables undercover ESP.'
})

MainGroup:AddToggle('ModDetection', {
    Text = 'Warn on mod join',
    Default = true,
    Tooltip = 'Notifies you when a moderator joins the game.',
})

Toggles.UndercoverESPToggle:OnChanged(function(Value)
    ESP.Undercover = Value
end)

local CreditsGroup = Tabs.CreditsTab:AddLeftGroupbox('Credits')

CreditsGroup:AddButton('Stefanuk12 [Aiming Lib]',function()
    print('hi')
end)
CreditsGroup:AddButton('Kiriot [ESP Lib]',function()
    print('hi')
end)
CreditsGroup:AddButton('Wally [UI Lib]',function()
    print('hi')
end)

ServerMode.Changed:Connect(function()
    if not GameInProgress() then
        if UndercoverESP then
            UndercoverESP:Remove()
        end
        for i,v in pairs(HunterESP) do
            v:Remove()
        end
        HunterESP = {}
        for i,v in pairs(TargetESP) do
            v:Remove()
        end
        TargetESP = {}
    end
end)

local function ESPConnect(Player)

    local CurrentCoro

    Player.CharacterAdded:Connect(function(Character)
        if GameInProgress() then
            if CurrentCoro then
                coroutine.close(CurrentCoro)
            end
            CurrentCoro = coroutine.create(function()
                task.wait(2)
                -- for i,v in pairs(TargetESP) do
                --     print(i)
                --     if not table.find(MyTargets(),Player) then
                --         v:Remove()
                --     end
                -- end
                for i,v in pairs(HunterESP) do
                    if not table.find(GetTargets(i),LocalPlayer) then
                        v:Remove()
                    end
                end
                if Player.Role.Value ~= "" and game:GetService('HttpService'):JSONDecode(Player.Role.Value).Name == "Undercover" then
                    if not UndercoverESP then
                        UndercoverESP = Mark(Player,"Undercover",Color3.new(0.415686, 0.858823, 0.054901))
                    end
                else
                    if table.find(GetTargets(Player),LocalPlayer) then
                        if not HunterESP[Player] then
                            HunterESP[Player] = Mark(Player,"Hunter",Color3.new(1, 0.482352, 0))
                        end
                    end
                    if table.find(MyTargets(),Player) then
                        if not TargetESP[Player] then
                            TargetESP[Player] = Mark(Player,"Target",Color3.new(0.384313, 0, 1))
                        end
                    end
                end
                while wait(1) do
                    if Player.Role.Value ~= "" and game:GetService('HttpService'):JSONDecode(Player.Role.Value).Name == "Undercover" then
                        if not UndercoverESP then
                            UndercoverESP = Mark(Player,"Undercover",Color3.new(0.415686, 0.858823, 0.054901))
                        end
                    else
                        if table.find(GetTargets(Player),LocalPlayer) then
                            if not HunterESP[Player] then
                                HunterESP[Player] = Mark(Player,"Hunter",Color3.new(1, 0.482352, 0))
                            end
                        end
                        if table.find(MyTargets(),Player) then
                            if not TargetESP[Player] then
                                TargetESP[Player] = Mark(Player,"Target",Color3.new(0.384313, 0, 1))
                            end
                        end
                    end
                end
            end)
            coroutine.resume(CurrentCoro)
        end
    end)
end


Players.PlayerAdded:Connect(function(Player)
    if Player:IsInGroup(1146321) and Player:GetRoleInGroup(1146321):lower() ~= "fan" then
        if Toggles.ModDetection.Value == true then
            Library:Notify("Moderator/Contributor detected! Consider leaving soon.",5)
        end
    end
end)

for i,v in pairs(game.Players:GetPlayers()) do
    ESPConnect(v)
end

Players.PlayerAdded:Connect(function(player)
    ESPConnect(player)
end)

-- local u7 = require(script:WaitForChild("launchBullet"));
-- local u5 = require(game.ReplicatedStorage:WaitForChild("getRay"));
-- local u1 = require(game.ReplicatedStorage.gunStats);

local oldhmmnc

oldhmmnc = hookmetamethod(game, "__namecall", function(self, ...)
    local Args = {...}

    if Toggles.AlwaysBackstabToggle.Value == true and tostring(self) == "Shoot" and getnamecallmethod() == "FireServer" and tostring(Args[1].Tool) == "Knife" then
        Args[1].IsBackstab = true
        return oldhmmnc(self, table.unpack(Args))
    end

    if tostring(self) == "Shoot" and getnamecallmethod() == "FireServer" and (tostring(Args[1].Tool) ~= "Knife" and tostring(Args[1].Tool) ~= "Bowie Knife") then
       

        Args[1].Timestamp = workspace:GetServerTimeNow()

        setnamecallmethod("FireServer")

        --Args[1].Bullets[1] = u7(Args[1].Tool, true, (u5(LocalPlayer.Character.Humanoid, LocalPlayer.Character.HumanoidRootPart, CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, Aiming.SelectedPart.Position), Args[1].Tool, true, workspace:GetServerTimeNow(), 1)))

        for _,Bullet in pairs(Args[1].Bullets) do
            if Miss() then
                Bullet.Instance = nil
            end
        end

        return oldhmmnc(self, table.unpack(Args))
    end

    return oldhmmnc(self, ...)
end)

local Locking = false
local LockPart

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and Toggles.AimlockToggle.Value == true and Aiming.SelectedPart then
        Locking = true
        LockPart = Aiming.SelectedPart
        local LCON
        LCON = RunService.RenderStepped:Connect(function()
            if Locking and LockPart then
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position,LockPart.Position)
            else
                LCON:Disconnect()
            end
        end)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Locking = false
    end
end)

ThemeManager:SetLibrary(Library)

SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings() 

SaveManager:SetIgnoreIndexes({ 'MenuKeybind' }) 

ThemeManager:SetFolder('Framed_GUI')

SaveManager:SetFolder('Framed_GUI/main')

SaveManager:BuildConfigSection(Tabs.UISettings) 

ThemeManager:ApplyToTab(Tabs.UISettings)

Library:Notify("All features loaded in " .. tostring(BetterRound(tick() - Startup,3)) .. " seconds.",3)