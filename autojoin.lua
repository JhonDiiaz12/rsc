-- 🧠 Brainrot Auto-Joiner v2.0
-- GitHub: tu-usuario/brainrot-auto-joiner
-- Descripción: Monitor automático para servidores de Brainrot con alta ganancia

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

-- ⚙️ CONFIGURACIÓN
local CONFIG = {
    VERSION = "2.0",
    MIN_MONEY = 15000000, -- 15M mínimo
    CHECK_INTERVAL = 10, -- Segundos entre verificaciones
    GAME_ID = 10928359319, -- Chilli Hub Game ID
    DISCORD_API = "https://discord.com/api/v10",
    DEFAULT_CHANNEL_ID = "1410719491255701564" -- Canal de Brainrot Notify
}

-- 🌐 Variables Globales
local BrainrotMonitor = {
    token = "",
    channelId = "",
    lastMessageId = "",
    isRunning = false,
    gui = nil,
    connection = nil
}

-- 🎨 Crear Interfaz de Usuario
function BrainrotMonitor:CreateGUI()
    -- Limpiar GUI anterior si existe
    if self.gui then
        self.gui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BrainrotAutoJoiner"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game.CoreGui
    
    -- Frame principal con diseño moderno
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 420, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -210, 0.5, -175)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Sombra y esquinas
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Barra de título
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 60)
    titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    -- Título principal
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 20, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🧠 Brainrot Auto-Joiner v" .. CONFIG.VERSION
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Botón cerrar
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 15)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeButton
    
    -- Contenido principal
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -40, 1, -100)
    contentFrame.Position = UDim2.new(0, 20, 0, 80)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- Campo Discord Token
    local tokenLabel = Instance.new("TextLabel")
    tokenLabel.Size = UDim2.new(1, 0, 0, 25)
    tokenLabel.BackgroundTransparency = 1
    tokenLabel.Text = "🔑 Discord User Token:"
    tokenLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    tokenLabel.TextSize = 14
    tokenLabel.Font = Enum.Font.Gotham
    tokenLabel.TextXAlignment = Enum.TextXAlignment.Left
    tokenLabel.Parent = contentFrame
    
    local tokenBox = Instance.new("TextBox")
    tokenBox.Size = UDim2.new(1, 0, 0, 40)
    tokenBox.Position = UDim2.new(0, 0, 0, 30)
    tokenBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    tokenBox.BorderSizePixel = 0
    tokenBox.PlaceholderText = "Tu token de usuario de Discord (no bot token)..."
    tokenBox.Text = ""
    tokenBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    tokenBox.TextSize = 12
    tokenBox.Font = Enum.Font.Gotham
    tokenBox.TextWrapped = true
    tokenBox.Parent = contentFrame
    
    local tokenCorner = Instance.new("UICorner")
    tokenCorner.CornerRadius = UDim.new(0, 6)
    tokenCorner.Parent = tokenBox
    
    -- Campo Channel ID
    local channelLabel = Instance.new("TextLabel")
    channelLabel.Size = UDim2.new(1, 0, 0, 25)
    channelLabel.Position = UDim2.new(0, 0, 0, 85)
    channelLabel.BackgroundTransparency = 1
    channelLabel.Text = "📺 Channel ID:"
    channelLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    channelLabel.TextSize = 14
    channelLabel.Font = Enum.Font.Gotham
    channelLabel.TextXAlignment = Enum.TextXAlignment.Left
    channelLabel.Parent = contentFrame
    
    local channelBox = Instance.new("TextBox")
    channelBox.Size = UDim2.new(1, 0, 0, 40)
    channelBox.Position = UDim2.new(0, 0, 0, 115)
    channelBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    channelBox.BorderSizePixel = 0
    channelBox.PlaceholderText = "Channel ID (ya configurado por defecto)"
    channelBox.Text = CONFIG.DEFAULT_CHANNEL_ID
    channelBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    channelBox.TextSize = 12
    channelBox.Font = Enum.Font.Gotham
    channelBox.Parent = contentFrame
    
    local channelCorner = Instance.new("UICorner")
    channelCorner.CornerRadius = UDim.new(0, 6)
    channelCorner.Parent = channelBox
    
    -- Botón principal
    local actionButton = Instance.new("TextButton")
    actionButton.Size = UDim2.new(0, 200, 0, 45)
    actionButton.Position = UDim2.new(0.5, -100, 0, 170)
    actionButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    actionButton.Text = "🚀 Iniciar Monitor"
    actionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    actionButton.TextSize = 16
    actionButton.Font = Enum.Font.GothamBold
    actionButton.Parent = contentFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = actionButton
    
    -- Estado del sistema
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 30)
    statusLabel.Position = UDim2.new(0, 0, 0, 230)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "⚪ Listo para configurar..."
    statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    statusLabel.TextSize = 12
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = contentFrame
    
    self.gui = screenGui
    
    -- Eventos de la interfaz
    closeButton.MouseButton1Click:Connect(function()
        self:StopMonitoring()
        screenGui:Destroy()
    end)
    
    actionButton.MouseButton1Click:Connect(function()
        if not self.isRunning then
            self:StartMonitoring(tokenBox.Text, channelBox.Text, actionButton, statusLabel)
        else
            self:StopMonitoring()
            actionButton.Text = "🚀 Iniciar Monitor"
            actionButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            statusLabel.Text = "⚪ Monitor detenido"
            statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end)
    
    -- Hacer el frame arrastrable
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- 🔔 Mostrar notificaciones
function BrainrotMonitor:ShowNotification(title, message, duration)
    duration = duration or 3
    
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = message,
            Duration = duration
        })
    end)
end

-- 🌐 Hacer peticiones a Discord API (Self-Bot)
function BrainrotMonitor:MakeDiscordRequest(endpoint)
    local success, result = pcall(function()
        local headers = {
            ["Authorization"] = self.token, -- Token de usuario, no "Bot " prefix
            ["Content-Type"] = "application/json",
            ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
        }
        
        return HttpService:GetAsync(CONFIG.DISCORD_API .. endpoint, false, headers)
    end)
    
    if success then
        local data = HttpService:JSONDecode(result)
        return data
    else
        warn("❌ Error en petición Discord: " .. tostring(result))
        return nil
    end
end

-- 💰 Parsear valor monetario del mensaje
function BrainrotMonitor:ParseMoneyValue(text)
    text = text:upper()
    
    -- Buscar patrones como $660K/s, $15M/s, etc.
    local patterns = {
        "%$(%d+%.?%d*)([KMB])",
        "(%d+%.?%d*)([KMB])/S",
        "MONEY PER SEC%s*%$?(%d+%.?%d*)([KMB])"
    }
    
    for _, pattern in ipairs(patterns) do
        local value, suffix = text:match(pattern)
        if value and suffix then
            value = tonumber(value)
            if suffix == "K" then
                return value * 1000
            elseif suffix == "M" then
                return value * 1000000
            elseif suffix == "B" then
                return value * 1000000000
            end
        end
    end
    
    return 0
end

-- 🆔 Extraer Job ID del mensaje
function BrainrotMonitor:ExtractJobId(content)
    local patterns = {
        "Job ID %(Mobile%)%s*([a-f0-9%-]+)",
        "Job ID %(PC%)%s*([a-f0-9%-]+)",
        "([a-f0-9]{8}%-[a-f0-9]{4}%-[a-f0-9]{4}%-[a-f0-9]{4}%-[a-f0-9]{12})"
    }
    
    for _, pattern in ipairs(patterns) do
        local jobId = content:match(pattern)
        if jobId then
            return jobId
        end
    end
    
    return nil
end

-- 🎮 Unirse al servidor
function BrainrotMonitor:JoinServer(jobId)
    self:ShowNotification("🎮 Conectando", "Intentando unirse al servidor...", 3)
    
    local success, error = pcall(function()
        -- Copiar Job ID al portapapeles
        if setclipboard then
            setclipboard(jobId)
            self:ShowNotification("📋 Copiado", "Job ID copiado al portapapeles", 2)
        end
        
        -- Teleport al servidor usando Job ID
        TeleportService:TeleportToPlaceInstance(CONFIG.GAME_ID, jobId, Players.LocalPlayer)
    end)
    
    if success then
        self:ShowNotification("✅ Éxito", "¡Uniéndose al servidor!", 5)
    else
        self:ShowNotification("❌ Error", "No se pudo unir: " .. tostring(error), 5)
        warn("Error al unirse: " .. tostring(error))
    end
end

-- 🔍 Monitorear canal de Discord
function BrainrotMonitor:CheckChannel(statusLabel)
    if not self.isRunning then return end
    
    statusLabel.Text = "🔍 Verificando canal..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    
    -- Obtener último mensaje del canal
    local messages = self:MakeDiscordRequest("/channels/" .. self.channelId .. "/messages?limit=1")
    
    if not messages or #messages == 0 then
        statusLabel.Text = "❌ Error al obtener mensajes"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    local latestMessage = messages[1]
    
    -- Verificar si es un mensaje nuevo
    if latestMessage.id == self.lastMessageId then
        statusLabel.Text = "⚪ Sin mensajes nuevos... (Último check: " .. os.date("%H:%M:%S") .. ")"
        statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        return
    end
    
    self.lastMessageId = latestMessage.id
    local content = latestMessage.content
    
    print("📱 Nuevo mensaje detectado:")
    print(content)
    
    -- Verificar si es un mensaje de Brainrot Notify
    if content:find("Brainrot Notify") or content:find("Money per sec") then
        statusLabel.Text = "📱 Mensaje de Brainrot detectado!"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        -- Parsear el valor monetario
        local moneyValue = self:ParseMoneyValue(content)
        
        print("💰 Dinero detectado: $" .. self:FormatMoney(moneyValue))
        
        -- Verificar si supera el mínimo requerido
        if moneyValue >= CONFIG.MIN_MONEY then
            statusLabel.Text = "🎯 ¡Servidor encontrado! Dinero: $" .. self:FormatMoney(moneyValue)
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            
            -- Extraer Job ID del mensaje
            local jobId = self:ExtractJobId(content)
            
            if jobId then
                self:ShowNotification("🎉 Servidor Encontrado!", "Dinero: $" .. self:FormatMoney(moneyValue) .. "\nUniéndose al servidor...", 8)
                
                -- Esperar un momento antes de unirse
                wait(2)
                self:JoinServer(jobId)
                
                -- Detener el monitoreo después de encontrar un servidor
                wait(5)
                self:StopMonitoring()
            else
                statusLabel.Text = "❌ No se pudo extraer Job ID del mensaje"
                statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                print("❌ Contenido del mensaje sin Job ID válido")
            end
        else
            statusLabel.Text = "💸 Dinero insuficiente: $" .. self:FormatMoney(moneyValue) .. " (Mín: $" .. self:FormatMoney(CONFIG.MIN_MONEY) .. ")"
            statusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
            print("💸 Dinero insuficiente, continuando monitoreo...")
        end
    else
        statusLabel.Text = "📄 Mensaje no relacionado con Brainrot"
        statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end

-- 💲 Formatear dinero para mostrar
function BrainrotMonitor:FormatMoney(amount)
    if amount >= 1000000000 then
        return string.format("%.1fB", amount / 1000000000)
    elseif amount >= 1000000 then
        return string.format("%.1fM", amount / 1000000)
    elseif amount >= 1000 then
        return string.format("%.1fK", amount / 1000)
    else
        return tostring(amount)
    end
end

-- ▶️ Iniciar monitoreo
function BrainrotMonitor:StartMonitoring(token, channelId, button, statusLabel)
    -- Validar campos
    token = token:gsub("%s+", "")
    channelId = channelId:gsub("%s+", "")
    
    if token == "" or channelId == "" then
        self:ShowNotification("❌ Error", "Por favor completa todos los campos", 3)
        return
    end
    
    -- Validar formato del token de usuario
    if not token:match("^[A-Za-z0-9_%-%.]+$") and not token:match("^mfa%.") then
        self:ShowNotification("❌ Token Inválido", "El formato del token de usuario no es válido", 3)
        return
    end
    
    -- Validar Channel ID
    if not channelId:match("^%d+$") then
        self:ShowNotification("❌ Channel ID Inválido", "El Channel ID debe ser solo números", 3)
        return
    end
    
    self.token = token
    self.channelId = channelId
    self.isRunning = true
    self.lastMessageId = ""
    
    -- Actualizar interfaz
    button.Text = "🛑 Detener Monitor"
    button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    statusLabel.Text = "🚀 Iniciando monitor..."
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    
    self:ShowNotification("✅ Monitor Iniciado", "Buscando servidores con $" .. self:FormatMoney(CONFIG.MIN_MONEY) .. "+", 5)
    
    -- Iniciar bucle de monitoreo
    self.connection = game:GetService("RunService").Heartbeat:Connect(function()
        if not self.isRunning then
            if self.connection then
                self.connection:Disconnect()
                self.connection = nil
            end
            return
        end
        
        -- Verificar cada intervalo configurado
        if tick() % CONFIG.CHECK_INTERVAL < 0.1 then
            pcall(function()
                self:CheckChannel(statusLabel)
            end)
        end
    end)
    
    print("🧠 Monitor de Brainrot iniciado:")
    print("💰 Dinero mínimo: $" .. self:FormatMoney(CONFIG.MIN_MONEY))
    print("⏱️ Intervalo de verificación: " .. CONFIG.CHECK_INTERVAL .. "s")
    print("📺 Channel ID: " .. channelId)
end

-- ⏹️ Detener monitoreo
function BrainrotMonitor:StopMonitoring()
    self.isRunning = false
    
    if self.connection then
        self.connection:Disconnect()
        self.connection = nil
    end
    
    print("🛑 Monitor de Brainrot detenido")
    self:ShowNotification("🛑 Monitor Detenido", "Monitoreo pausado", 2)
end

-- 🚀 Inicialización principal
function BrainrotMonitor:Initialize()
    print("=" * 50)
    print("🧠 BRAINROT AUTO-JOINER v" .. CONFIG.VERSION)
    print("=" * 50)
    print("📱 Cargando interfaz...")
    
    -- Crear interfaz de usuario
    self:CreateGUI()
    
    -- Mostrar notificación de bienvenida
    self:ShowNotification("🧠 Brainrot Auto-Joiner", "¡Script cargado correctamente! v" .. CONFIG.VERSION, 5)
    
    print("✅ Script listo para usar")
    print("🔧 Configure su token y channel ID para comenzar")
end

-- 🎯 Auto-ejecutar al cargar
spawn(function()
    wait(1) -- Esperar a que el juego cargue completamente
    
    -- Cargar script original de Luarmor en segundo plano
    pcall(function()
        loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/5896f91b3735956f3d9d0727b84fcbe5.lua"))()
    end)
    
    wait(2)
    
    -- Inicializar el monitor de Brainrot
    BrainrotMonitor:Initialize()
end)

-- 💡 Comandos de consola para debugging
_G.BrainrotMonitor = BrainrotMonitor
_G.StopBrainrot = function() BrainrotMonitor:StopMonitoring() end
_G.StartBrainrot = function(token, channel) BrainrotMonitor:StartMonitoring(token, channel, nil, {Text = "", TextColor3 = Color3.new()}) end

return BrainrotMonitor
