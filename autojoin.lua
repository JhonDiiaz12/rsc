-- AutoJoin con GUI centrada
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- PlaceId del juego (cámbialo al tuyo si es otro)
local placeId = 109983668079237 

-- Crear GUI
local screenGui = Instance.new("ScreenGui")
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame principal (centrado en pantalla)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 180)
frame.Position = UDim2.new(0.5, -175, 0.5, -90) -- 👈 Centrado
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Bordes redondeados
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "🔑 Ingresa el JobId del servidor"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = frame

-- Caja de texto
local textbox = Instance.new("TextBox")
textbox.Size = UDim2.new(0.9, 0, 0, 40)
textbox.Position = UDim2.new(0.05, 0, 0.45, -20)
textbox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
textbox.Font = Enum.Font.Gotham
textbox.TextSize = 16
textbox.PlaceholderText = "Ej: b6e3ecbc-24e3-43c6-84a4-4fe693ab0fb4"
textbox.Parent = frame

local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 8)
boxCorner.Parent = textbox

-- Botón
local button = Instance.new("TextButton")
button.Size = UDim2.new(0.5, 0, 0, 35)
button.Position = UDim2.new(0.25, 0, 0.8, 0)
button.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
button.Text = "Unirse"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.GothamBold
button.TextSize = 18
button.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = button

-- Acción al presionar el botón
button.MouseButton1Click:Connect(function()
    local jobId = textbox.Text
    if jobId and jobId ~= "" then
        frame.Visible = false
        TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
    else
        title.Text = "❌ JobId inválido"
        title.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end)
