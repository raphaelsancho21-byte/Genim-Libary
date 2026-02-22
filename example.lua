local Genim = loadstring(game:HttpGet("https://raw.githubusercontent.com/raphaelsancho21-byte/Genim-Libary/refs/heads/main/Genim.lua"))()

-- Criando a Janela Principal
local Window = Genim:CreateWindow({
    Name = "Genim Showcase",
    Theme = "Default", -- Temas: "Default", "Ocean", "Amethyst", "Emerald", "Light"
    LoadingTitle = "Genim Interface",
    LoadingSubtitle = "by Genim Team",
    Keybind = Enum.KeyCode.K, -- Tecla para esconder/mostrar
    KeySystem = true, -- Ativa o sistema de Key
    KeySettings = {
        Title = "Sistema de Verificação",
        Subtitle = "Pegue a key no nosso Discord",
        Link = "https://120347.oneapp.dev/",
        Key = "GENIM-2026" -- A chave secreta
    }
})

-- ==========================================
-- TAB: COMPONENTES BÁSICOS
-- ==========================================
local BasicTab = Window:CreateTab("Componentes", 15132379512)

local Section2 = BasicTab:CreateSection("Alavancas (Toggles)")

BasicTab:CreateToggle({
    Name = "Auto-Farm Exemplo",
    CurrentValue = false,
    Callback = function(Value)
        print("Toggle alterado para:", Value)
    end
})

BasicTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = true,
    Callback = function(Value)
        print("Anti-AFK:", Value)
    end
})

-- ==========================================
-- TAB: INPUTS E SLIDERS
-- ==========================================
local InputTab = Window:CreateTab("Avançado", 10734898357)

InputTab:CreateSection("Sliders Numéricos")

InputTab:CreateSlider({
    Name = "Velocidade (WalkSpeed)",
    Min = 16,
    Max = 200,
    CurrentValue = 16,
    Callback = function(Value)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end
})

InputTab:CreateSlider({
    Name = "Pulo (JumpPower)",
    Min = 50,
    Max = 500,
    CurrentValue = 50,
    Callback = function(Value)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end
})

InputTab:CreateSection("Caixas de Texto")

InputTab:CreateInput({
    Name = "Nickname do Script",
    Placeholder = "Digite algo...",
    Callback = function(Text, EnterPressed)
        if EnterPressed then
            print("Texto inserido:", Text)
            Genim:Notify({
                Title = "Input Confirmado",
                Content = "Você digitou: " .. Text,
                Duration = 3
            })
        end
    end
})

-- ==========================================
-- TAB: SELEÇÃO (DROPDOWNS)
-- ==========================================
local ConfigTab = Window:CreateTab("Configuração", 10734898801)

ConfigTab:CreateSection("Listas de Seleção")

ConfigTab:CreateDropdown({
    Name = "Escolher Mapa",
    Options = {"Floresta", "Deserto", "Vila", "Cidade Futurista", "Espaço"},
    CurrentOption = "Floresta",
    Callback = function(Option)
        print("Mapa selecionado:", Option)
    end
})

ConfigTab:CreateDropdown({
    Name = "Modo de Jogo",
    Options = {"Sobrevivência", "Criativo", "Hardcore"},
    CurrentOption = "Sobrevivência",
    Callback = function(Option)
        print("Modo alterado para:", Option)
    end
})

ConfigTab:CreateSection("Outros")

ConfigTab:CreateButton({
    Name = "Destruir Interface",
    Callback = function()
        -- Exemplo de como você poderia fechar a interface
        print("Botão de fechar pressionado.")
    end
})
