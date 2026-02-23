--[[
    Genim UI - Config Module
    Handles Keybinds, Themes, and Settings
]]

local ConfigModule = {}

function ConfigModule:Init(Window)
    print("[Genim] Inicializando Aba de Configurações...")
    local ConfigTab = Window:CreateTab("Ajustes", 15132379512)
    Window.SettingsTab = ConfigTab -- Vincula ao botão da TopBar

    ConfigTab:CreateSection("Interface & Atalhos")

    ConfigTab:CreateDropdown({
        Name = "Trocar Tema",
        Options = {"Dark", "Light", "Amethyst", "Emerald", "Ruby", "Glass"},
        CurrentOption = Window.OriginalConfig.Theme or "Dark",
        Callback = function(Value)
            Window:CreateDialog({
                Title = "Reiniciar Interface?",
                Content = "Trocar o tema exige reiniciar a interface. Todos os scripts ativos na UI serão resetados.",
                Buttons = {
                    {
                        Name = "Reiniciar",
                        Primary = true,
                        Callback = function()
                            Window:Restart(Value)
                        end
                    },
                    {
                        Name = "Cancelar",
                        Primary = false,
                        Callback = function() end
                    }
                }
            })
        end
    })

    ConfigTab:CreateDropdown({
        Name = "Tecla de Atalho (Show/Hide)",
        Options = {"K", "H", "P", "L", "Delete", "Insert"},
        CurrentOption = "K",
        Callback = function(Value)
            local Key = Enum.KeyCode[Value]
            if Key then
                Window.Keybind = Key
                print("Keybind atualizado para:", Value)
            end
        end
    })

    ConfigTab:CreateSection("Informações")

    ConfigTab:CreateButton({
        Name = "Copiar Discord",
        Callback = function()
            setclipboard("https://discord.gg/genim")
            Genim:Notify({
                Title = "Discord",
                Content = "Link copiado para a área de transferência!",
                Duration = 3
            })
        end
    })

    return ConfigTab
end

-- Registro automático como Plugin (Persistente)
if Genim and Genim.AddPlugin then
    Genim:AddPlugin(function(Window)
        ConfigModule:Init(Window)
    end)
end

return ConfigModule
