--[[
    Genim UI - Config Module
    Handles Keybinds, Themes, and Settings
]]

local ConfigModule = {}

function ConfigModule:AddConfigTab(Window)
    local ConfigTab = Window:CreateTab("Ajustes", 10734898801) -- Icon for settings
    Window.SettingsTab = ConfigTab -- Link for TopBar button

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
            -- We can use Notify directly if we have access to Genim
            -- In a real scenario, Genim would be global or passed.
        end
    })

    return ConfigTab
end

return ConfigModule
