local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- 👇 Pon aquí tu webhook de Discord exactamente como sale
local webhookUrl = "https://discord.com/api/webhooks/1410719582418895029/0N7OAYVMDhORyBnDu1fVthIqAPtV5DdS3pSomJFf038PDQvicCnGwSzS6Wxz311_dcLT"

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 420, 0, 200)
frame.Position = UDim2.new(0.5, -210, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local textbox = Instance.new("TextBox")
textbox.Size = UDim2.new(1, -40, 0, 60)
textbox.Position = UDim2.new(0, 20, 0, 25)
textbox.PlaceholderText = "Escribe tu mensaje aquí..."
textbox.ClearTextOnFocus = false
textbox.TextWrapped = true
textbox.BackgroundColor3 = Color3.fromRGB(240,240,240)
textbox.TextColor3 = Color3.fromRGB(0,0,0)
textbox.TextScaled = true
textbox.Parent = frame
Instance.new("UICorner", textbox).CornerRadius = UDim.new(0, 8)

local sendBtn = Instance.new("TextButton")
sendBtn.Size = UDim2.new(0.5, -15, 0, 36)
sendBtn.Position = UDim2.new(0, 20, 0, 110)
sendBtn.Text = "Enviar"
sendBtn.Font = Enum.Font.GothamBold
sendBtn.TextColor3 = Color3.fromRGB(255,255,255)
sendBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
sendBtn.Parent = frame
Instance.new("UICorner", sendBtn).CornerRadius = UDim.new(0, 6)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -40, 0, 28)
status.Position = UDim2.new(0, 20, 0, 155)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(220,220,220)
status.Text = "Estado: esperando..."
status.Parent = frame

-- Función de envío
local function sendMessage(msg)
    local request = http_request or (syn and syn.request)
    if not request then
        status.Text = "❌ Tu executor no soporta requests"
        return
    end

    local data = HttpService:JSONEncode({ ["content"] = msg })

    local res = request({
        Url = webhookUrl,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = data
    })

    if res and res.StatusCode == 204 then
        status.Text = "✅ Enviado correctamente"
    else
        status.Text = "❌ Error: " .. (res and res.StatusCode or "desconocido")
        warn(res)
    end
end

-- Botón
sendBtn.MouseButton1Click:Connect(function()
    local texto = textbox.Text
    if texto == "" then
        status.Text = "⚠️ Escribe un mensaje primero"
        return
    end
    sendMessage(texto)
end)
