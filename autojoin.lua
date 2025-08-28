local TeleportService = game:GetService("TeleportService")
local player = game.Players.LocalPlayer

-- El PlaceId fijo del juego
local placeId = 109983668079237 

-- GUI
local screenGui = Instance.new("ScreenGui", player.PlayerGui)

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 150)
frame.Position = UDim2.new(0.5, -150, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "🔑 Ingresa el JobId"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

local textbox = Instance.new("TextBox", frame)
textbox.Size = UDim2.new(0.9, 0, 0, 30)
textbox.Position = UDim2.new(0.05, 0, 0.5, -15)
textbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
textbox.Font = Enum.Font.SourceSans
textbox.TextSize = 18
textbox.PlaceholderText = "Ej: b6e3ecbc-24e3-43c6-84a4-4fe693ab0fb4"

local button = Instance.new("TextButton", frame)
button.Size = UDim2.new(0.5, 0, 0, 30)
button.Position = UDim2.new(0.25, 0, 0.8, 0)
button.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
button.Text = "Unirse"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.SourceSansBold
button.TextSize = 18

-- Cuando el jugador hace clic en "Unirse"
button.MouseButton1Click:Connect(function()
    local jobId = textbox.Text
    if jobId and jobId ~= "" then
        frame.Visible = false
        TeleportService:TeleportToPlaceInstance(placeId, jobId, player) -- 👈 Teleport directo
    else
        title.Text = "❌ JobId inválido"
        title.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

