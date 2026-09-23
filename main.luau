--!nonstrict
-- main.luau: Background service for Saved Desktop Widgets

-- Load initial settings from the manifest defaults
local saveWidgets = noctalia.getConfig("saveWidgets")
local loadWidgets = noctalia.getConfig("loadWidgets")

-- Initialize the saved widgets table (in a full plugin, you might load/save this to a JSON file via noctalia.readFile)
local monitorWidgets = noctalia.state.get("monitorWidgets") or {}

-- 1. Sync state with the settings.luau panel
noctalia.state.watch("saveWidgets", function(value)
  saveWidgets = value
end)

noctalia.state.watch("loadWidgets", function(value)
  loadWidgets = value
end)

noctalia.state.watch("monitorWidgets", function(value)
  monitorWidgets = value
end)

-- 2. Listen for shell events (e.g., Wallpaper Picker broadcasts)
function onIpc(event, payload)
  -- Assuming the wallpaper picker broadcasts a "wallpaper-changed" IPC event with the path
  if event == "wallpaper-changed" then
    local wallpaperPath = payload

    if loadWidgets then
      if monitorWidgets[wallpaperPath] then
        -- Layout exists for this wallpaper: Apply it
        -- Note: Replace this conceptual function with Noctalia's actual widget-setting API
        -- noctalia.setDesktopWidgets(monitorWidgets[wallpaperPath])
        noctalia.notify("Saved Desktop Widgets", "Loaded layout for " .. wallpaperPath)
      else
        noctalia.notify("Saved Desktop Widgets", "No saved layout for this wallpaper.")
      end
    end

  -- Assuming the shell broadcasts when a user moves/adds a widget
  elseif event == "widgets-updated" then
    if saveWidgets then
      -- Note: Replace this conceptual function with Noctalia's actual state-fetching API
      -- local currentWallpaper = noctalia.wallpaperPath()
      -- local currentLayout = noctalia.getDesktopWidgets()
      -- monitorWidgets[currentWallpaper] = currentLayout

      noctalia.state.set("monitorWidgets", monitorWidgets)
    end
  end
end

-- Required dummy update loop for services to stay alive
function update()
  noctalia.setUpdateInterval(5000)
end
