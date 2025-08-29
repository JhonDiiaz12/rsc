-- TEST ULTRA BÁSICO - Solo para verificar que el executor funciona

print("HOLA - EL SCRIPT SE ESTÁ EJECUTANDO")

-- Test 1: Notificación básica
game.StarterGui:SetCore("SendNotification", {
    Title = "TEST";
    Text = "El script funciona!";
    Duration = 5;
})

print("Notificación enviada")

-- Test 2: GUI ultra simple
local gui = Instance.new("ScreenGui")
gui.Parent = game.Players.LocalPlayer.PlayerGui

local frame = Instance.new("Frame")
frame.Parent = gui
frame.BackgroundColor3 = Color3.new(1, 0, 0) -- Rojo
frame.Position = UDim2.new(0, 0, 0, 0) -- Esquina superior izquierda
frame.Size = UDim2.new(0, 200, 0, 100)

local label = Instance.new("TextLabel")
label.Parent = frame
label.BackgroundTransparency = 1
label.Size = UDim2.new(1, 0, 1, 0)
label.Text = "FUNCIONA!"
label.TextColor3 = Color3.new(1, 1, 1)
label.TextScaled = true

print("GUI básica creada")

-- Test 3: Verificar servicios
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

print("Player actual:", Players.LocalPlayer.Name)

-- Test 4: Test HTTP básico
local success, result = pcall(function()
    return HttpService:RequestAsync({
        Url = "https://httpbin.org/get",
        Method = "GET"
    })
end)

if success then
    print("HTTP funciona correctamente")
else
    print("HTTP NO funciona:", result)
end

print("TODOS LOS TESTS COMPLETADOS")
