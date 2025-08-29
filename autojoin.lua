-- Discord AutoJoiner para "Steal a Brainrot"
-- Ejecutar desde dentro del juego

-- ========== CONFIGURACIÓN ==========
local CONFIG = {
    DISCORD_TOKEN = "NjU1Nzg5ODkzODIxMTM2OTI2.kKbSgjrR4L1ofTnBerPovgIJu7k", -- Tu token personal de Discord
    CHANNEL_ID = "1410719491255701564", -- ID del canal donde aparecen los Job IDs
    GAME_ID = 109983668079237, -- ID de "Steal a Brainrot" (verificar si es correcto)
    CHECK_INTERVAL = 3, -- Segundos entre cada verificación
    RETRY_DELAY = 10, -- Segundos de espera cuando servidor lleno
    MAX_RETRIES = 5 -- Máximo número de reintentos
}

-- ========== SERVICIOS ==========
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

-- ========== VARIABLES GLOBALES ==========
local LocalPlayer = Players.LocalPlayer
local AutoJoinerEnabled = false
local LastCheckedMessageId = ""
local IsProcessing = false
local RetryCount = 0
local GUI = {}

-- ========== FUNCIONES AUXILIARES ==========

local function Log(message)
    print("[AutoJoiner] " .. tostring(message))
end

local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "🎯 " .. tostring(title);
            Text = tostring(text);
            Duration = duration or 4;
        })
    end)
end

-- ========== FUNCIONES DISCORD API ==========

local function MakeDiscordRequest(endpoint)
    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = "https://discord.com/api/v10" .. endpoint,
            Method = "GET",
            Headers = {
                ["Authorization"] = CONFIG.DISCORD_TOKEN,
                ["Content-Type"] = "application/json",
                ["User-Agent"] = "DiscordBot (https://discord.js.org, 1.0.0)"
            }
        })
    end)
    
    if success and response.Success then
        local data = HttpService:JSONDecode(response.Body)
        return data
    else
        Log("Error en petición Discord: " .. tostring(response))
        return nil
    end
end

local function GetLatestMessage()
    return MakeDiscordRequest("/channels/" .. CONFIG.CHANNEL_ID .. "/messages?limit=1")
end

-- ========== EXTRACTOR DE JOB ID ==========

local function ExtractJobIdFromText(text)
    if not text or text == "" then return nil end
    
    -- Patrones para detectar Job IDs
    local patterns = {
        "Job ID %(PC%):%s*([%w%-]+)",
        "Job ID %(Mobile%):%s*([%w%-]+)", 
        "JobId:%s*([%w%-]+)",
        "job%-id:%s*([%w%-]+)",
        "ID:%s*([%w%-]+)",
        "([%w]+-[%w]+-[%w]+-[%w]+-[%w%-]+)" -- Patrón UUID genérico
    }
    
    for _, pattern in pairs(patterns) do
        local jobId = string.match(text, pattern)
        if jobId and string.len(jobId) >= 20 then
            Log("Job ID encontrado: " .. jobId)
            return jobId
        end
    end
    
    return nil
end

local function ExtractJobIdFromMessage(message)
    local fullText = ""
    
    -- Contenido principal
    if message.content then
        fullText = fullText .. message.content .. " "
    end
    
    -- Embeds (si existen)
    if message.embeds then
        for _, embed in pairs(message.embeds) do
            if embed.description then
                fullText = fullText .. embed.description .. " "
            end
            if embed.fields then
                for _, field in pairs(embed.fields) do
                    if field.value then
                        fullText = fullText .. field.value .. " "
                    end
                end
            end
        end
    end
    
    return ExtractJobIdFromText(fullText)
end

-- ========== VERIFICACIÓN DE SERVIDOR ==========

local function CheckServerStatus(jobId)
    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = "https://games.roblox.com/v1/games/" .. CONFIG.GAME_ID .. "/servers/Public?sortOrder=Asc&limit=100",
            Method = "GET"
        })
    end)
    
    if success and response.Success then
        local data = HttpService:JSONDecode(response.Body)
        if data.data then
            for _, server in pairs(data.data) do
                if server.id == jobId then
                    return {
                        id = server.id,
                        playing = server.playing or 0,
                        maxPlayers = server.maxPlayers or 12,
                        isFull = (server.playing or 0) >= (server.maxPlayers or 12)
                    }
                end
            end
        end
    end
    
    -- Si no encontramos el servidor, asumimos que está disponible
    return {
        id = jobId,
        playing = 0,
        maxPlayers = 12,
        isFull = false
    }
end

-- ========== TELEPORTE ==========

local function TeleportToServer(jobId)
    if IsProcessing then return end
    IsProcessing = true
    
    Log("Intentando teletransporte a Job ID: " .. jobId)
    Notify("AutoJoiner", "Teletransportando...", 3)
    
    local success, errorMsg = pcall(function()
        TeleportService:TeleportToPlaceInstance(CONFIG.GAME_ID, jobId, LocalPlayer)
    end)
    
    if not success then
        Log("Error en teletransporte: " .. tostring(errorMsg))
        Notify("Error", "Fallo al teletransportar: " .. tostring(errorMsg), 5)
        IsProcessing = false
    end
    
    wait(2) -- Evitar spam
    IsProcessing = false
end

-- ========== FUNCIÓN PRINCIPAL ==========

local function ProcessDiscordMessages()
    if not AutoJoinerEnabled or IsProcessing then return end
    
    local messages = GetLatestMessage()
    if not messages or #messages == 0 then return end
    
    local latestMessage = messages[1]
    
    -- Verificar si es mensaje nuevo
    if latestMessage.id == LastCheckedMessageId then return end
    LastCheckedMessageId = latestMessage.id
    
    -- Extraer Job ID
    local jobId = ExtractJobIdFromMessage(latestMessage)
    if not jobId then
        Log("No se encontró Job ID en el mensaje")
        return
    end
    
    -- Verificar estado del servidor
    local serverInfo = CheckServerStatus(jobId)
    Log("Estado del servidor - Jugadores: " .. serverInfo.playing .. "/" .. serverInfo.maxPlayers)
    
    if serverInfo.isFull then
        RetryCount = RetryCount + 1
        if RetryCount <= CONFIG.MAX_RETRIES then
            Notify("Servidor Lleno", "Reintentando en " .. CONFIG.RETRY_DELAY .. "s (" .. RetryCount .. "/" .. CONFIG.MAX_RETRIES .. ")", CONFIG.RETRY_DELAY)
            wait(CONFIG.RETRY_DELAY)
            return ProcessDiscordMessages() -- Reintentar
        else
            Notify("Error", "Máximo de reintentos alcanzado", 5)
            RetryCount = 0
        end
    else
        RetryCount = 0 -- Resetear contador
        Notify("Servidor Disponible", serverInfo.playing .. "/" .. serverInfo.maxPlayers .. " jugadores", 3)
        TeleportToServer(jobId)
    end
end

-- ========== GUI ==========

local function CreateAutoJoinerGUI()
    -- Limpiar GUI existente
    if GUI.ScreenGui then
        GUI.ScreenGui:Destroy()
    end
    
    -- Crear elementos
    GUI.ScreenGui = Instance.new("ScreenGui")
    GUI.MainFrame = Instance.new("Frame")
    GUI.Title = Instance.new("TextLabel")
    GUI.ToggleButton = Instance.new("TextButton")
    GUI.StatusLabel = Instance.new("TextLabel")
    GUI.CloseButton = Instance.new("TextButton")
    GUI.InfoLabel = Instance.new("TextLabel")
    
    -- Configurar ScreenGui
    GUI.ScreenGui.Name = "AutoJoinerGUI"
    GUI.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    GUI.ScreenGui.ResetOnSpawn = false
    
    -- Frame principal
    GUI.MainFrame.Name = "MainFrame"
    GUI.MainFrame.Parent = GUI.ScreenGui
    GUI.MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    GUI.MainFrame.BorderSizePixel = 0
    GUI.MainFrame.Position = UDim2.new(0.5, -175, 0.3, 0)
    GUI.MainFrame.Size = UDim2.new(0, 350, 0, 180)
    GUI.MainFrame.Active = true
    GUI.MainFrame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = GUI.MainFrame
    
    -- Título
    GUI.Title.Name = "Title"
    GUI.Title.Parent = GUI.MainFrame
    GUI.Title.BackgroundTransparency = 1
    GUI.Title.Position = UDim2.new(0, 0, 0, 10)
    GUI.Title.Size = UDim2.new(0.85, 0, 0, 30)
    GUI.Title.Font = Enum.Font.GothamBold
    GUI.Title.Text = "🎯 Discord AutoJoiner"
    GUI.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    GUI.Title.TextSize = 16
    GUI.Title.TextXAlignment = Enum.TextXAlignment.Left
    GUI.Title.TextYAlignment = Enum.TextYAlignment.Center
    
    -- Botón toggle
    GUI.ToggleButton.Name = "ToggleButton"
    GUI.ToggleButton.Parent = GUI.MainFrame
    GUI.ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
    GUI.ToggleButton.Position = UDim2.new(0.1, 0, 0.28, 0)
    GUI.ToggleButton.Size = UDim2.new(0.8, 0, 0, 35)
    GUI.ToggleButton.Font = Enum.Font.GothamBold
    GUI.ToggleButton.Text = "▶ ACTIVAR AUTOJOINER"
    GUI.ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    GUI.ToggleButton.TextSize = 14
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = GUI.ToggleButton
    
    -- Label de estado
    GUI.StatusLabel.Name = "StatusLabel"
    GUI.StatusLabel.Parent = GUI.MainFrame
    GUI.StatusLabel.BackgroundTransparency = 1
    GUI.StatusLabel.Position = UDim2.new(0, 20, 0.55, 0)
    GUI.StatusLabel.Size = UDim2.new(0.9, 0, 0, 25)
    GUI.StatusLabel.Font = Enum.Font.Gotham
    GUI.StatusLabel.Text = "🔴 Estado: Desactivado"
    GUI.StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    GUI.StatusLabel.TextSize = 12
    GUI.StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Info label
    GUI.InfoLabel.Name = "InfoLabel"
    GUI.InfoLabel.Parent = GUI.MainFrame
    GUI.InfoLabel.BackgroundTransparency = 1
    GUI.InfoLabel.Position = UDim2.new(0, 20, 0.72, 0)
    GUI.InfoLabel.Size = UDim2.new(0.9, 0, 0, 20)
    GUI.InfoLabel.Font = Enum.Font.Gotham
    GUI.InfoLabel.Text = "💡 Configura tu token y canal ID"
    GUI.InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    GUI.InfoLabel.TextSize = 10
    GUI.InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Botón cerrar
    GUI.CloseButton.Name = "CloseButton"
    GUI.CloseButton.Parent = GUI.MainFrame
    GUI.CloseButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
    GUI.CloseButton.Position = UDim2.new(0.9, 0, 0.05, 0)
    GUI.CloseButton.Size = UDim2.new(0, 25, 0, 25)
    GUI.CloseButton.Font = Enum.Font.GothamBold
    GUI.CloseButton.Text = "✕"
    GUI.CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    GUI.CloseButton.TextSize = 12
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = GUI.CloseButton
    
    -- Eventos
    GUI.ToggleButton.MouseButton1Click:Connect(function()
        AutoJoinerEnabled = not AutoJoinerEnabled
        
        if AutoJoinerEnabled then
            GUI.ToggleButton.Text = "⏸ DESACTIVAR AUTOJOINER"
            GUI.ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
            GUI.StatusLabel.Text = "🟢 Estado: Activado - Escaneando Discord..."
            GUI.StatusLabel.TextColor3 = Color3.fromRGB(40, 167, 69)
            GUI.InfoLabel.Text = "🔍 Verificando cada " .. CONFIG.CHECK_INTERVAL .. " segundos"
            Notify("AutoJoiner", "Activado - Escaneando canal de Discord", 3)
        else
            GUI.ToggleButton.Text = "▶ ACTIVAR AUTOJOINER"
            GUI.ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
            GUI.StatusLabel.Text = "🔴 Estado: Desactivado"
            GUI.StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            GUI.InfoLabel.Text = "💡 Configura tu token y canal ID"
            Notify("AutoJoiner", "Desactivado", 2)
        end
    end)
    
    GUI.CloseButton.MouseButton1Click:Connect(function()
        AutoJoinerEnabled = false
        GUI.ScreenGui:Destroy()
    end)
end

-- ========== LOOP PRINCIPAL ==========

local function StartAutoJoinerLoop()
    spawn(function()
        while true do
            if AutoJoinerEnabled then
                pcall(ProcessDiscordMessages)
            end
            wait(CONFIG.CHECK_INTERVAL)
        end
    end)
end

-- ========== INICIALIZACIÓN ==========

local function Initialize()
    Log("Discord AutoJoiner para Steal a Brainrot cargado!")
    Log("Recuerda configurar DISCORD_TOKEN y CHANNEL_ID")
    
    Notify("AutoJoiner", "Script cargado correctamente!", 4)
    
    CreateAutoJoinerGUI()
    StartAutoJoinerLoop()
end

-- ========== EJECUTAR ==========
Initialize()
