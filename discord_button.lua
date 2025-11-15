-- discord_button.lua
-- Adds a "Discord" button to the "Functions" tab (or creates a small Functions frame) that attempts to open a Discord invite link in the user's browser or copies it to clipboard if direct open is unavailable.

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local player = Players.LocalPlayer
if not player then return end
local playerGui = player:WaitForChild("PlayerGui")

local url = "https://discord.com/invite/Ev8XAQar"

-- Try to find an existing "Functions" frame inside any ScreenGui in PlayerGui
local functionsFrame
for _, gui in pairs(playerGui:GetChildren()) do
    if gui:IsA("ScreenGui") then
        local f = gui:FindFirstChild("Functions")
        if f and f:IsA("Frame") then
            functionsFrame = f
            break
        end
    end
end

-- If not found, create a minimal ScreenGui with a Functions frame
if not functionsFrame then
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ScriptFunctionsGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Name = "Functions"
    frame.Size = UDim2.new(0, 200, 0, 80)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    functionsFrame = frame
end

-- Remove any existing DiscordButton to avoid duplicates
local existing = functionsFrame:FindFirstChild("DiscordButton")
if existing then existing:Destroy() end

local btn = Instance.new("TextButton")
btn.Name = "DiscordButton"
btn.Text = "Discord"
btn.Size = UDim2.new(0, 180, 0, 36)
btn.Position = UDim2.new(0, 10, 0, 10)
btn.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.BorderSizePixel = 0
btn.Parent = functionsFrame

local function openUrl(link)
    -- 1) Try GuiService:OpenBrowserWindow (exists in some environments)
    if GuiService and typeof(GuiService.OpenBrowserWindow) == "function" then
        local ok = pcall(function() GuiService:OpenBrowserWindow(link) end)
        if ok then return end
    end

    -- 2) Try StarterGui:SetCore("OpenBrowser", link) (may exist in some contexts)
    if StarterGui and StarterGui.SetCore then
        local ok = pcall(function() StarterGui:SetCore("OpenBrowser", link) end)
        if ok then return end
    end

    -- 3) Try copying to clipboard if setclipboard is available (exploit environments)
    if setclipboard then
        pcall(function() setclipboard(link) end)
        pcall(function()
            if StarterGui and StarterGui.SetCore then
                StarterGui:SetCore("SendNotification", {Title = "Discord", Text = "Ссылка скопирована в буфер: "..link, Duration = 5})
            end
        end)
        return
    end

    -- 4) Fallback: show a notification with the link
    pcall(function()
        if StarterGui and StarterGui.SetCore then
            StarterGui:SetCore("SendNotification", {Title = "Discord", Text = "Откройте ссылку в браузере: "..link, Duration = 10})
        end
    end)
end

btn.MouseButton1Click:Connect(function()
    openUrl(url)
end