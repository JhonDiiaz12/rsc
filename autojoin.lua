-- AutoJoiner con GUI que envía datos a un webhook de Discord
local HttpService = game:GetService("HttpService")

-- Reemplaza con tu Webhook
local webhookUrl = "https://discord.com/api/webhooks/TU_WEBHOOK_ID/TU_WEBHOOK_TOKEN"

-- GUI
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 320, 0, 160)
Frame.Position = UDim2.new(0.5, -160, 0.5, -80)
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "🔗 Enviar a Discord"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255, 255, 255)

local TextBox = Instance.new("TextBox", Frame)
TextBox.Size = UDim2.new(1, -40, 0, 40)
TextBox.Position = UDim2.new(0, 20, 0, 50)
TextBox.PlaceholderText = "Escribe aquí..."
TextBox.Font = Enum.Font.Gotham
TextBox.TextSize = 16
TextBox.TextColor3 = Color3.fromRGB(0, 0, 0)
TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextBox.ClearTextOnFocus = false
Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 8)

local Button = Instance.new("TextButton", Frame)
Button.Size = UDim2.new(0.5, -30, 0, 35)
Button.Position = UDim2.new(0.5, -70, 0, 110)
Button.Text = "Enviar"
Button.Font = Enum.Font.GothamBold
Button.TextSize = 16
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)

Button.MouseButton1Click:Connect(function()
    local texto = TextBox.Text
    if texto ~= "" then
        local payload = HttpService:JSONEncode({content = "📩 Dato recibido: " .. texto})
        local success, err = pcall(function()
            HttpService:PostAsync(webhookUrl, payload, Enum.HttpContentType.ApplicationJson)
        end)
        if success then
            Button.Text = "✅ Enviado"
            wait(2)
            Button.Text = "Enviar"
        else
            Button.Text = "❌ Error"
            warn(err)
        end
    end
end)
