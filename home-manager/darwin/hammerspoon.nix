# Hammerspoon configuration for macOS
# Detects ultrawide monitor and hot-swaps Aerospace config profiles
{ config, lib, pkgs, ... }: {
  home.file.".hammerspoon/init.lua".text = ''
    -- Aerospace monitor-aware config switcher
    -- Detects ultrawide (Odyssey) and swaps gap profiles

    local aerospaceConfig = os.getenv("HOME") .. "/.aerospace.toml"
    local laptopTemplate = os.getenv("HOME") .. "/.config/aerospace/laptop.toml"
    local ultrawideTemplate = os.getenv("HOME") .. "/.config/aerospace/ultrawide.toml"

    local function copyFile(src, dst)
      local input = io.open(src, "r")
      if not input then
        print("[aerospace] Failed to open source: " .. src)
        return false
      end
      local content = input:read("*a")
      input:close()
      local output = io.open(dst, "w")
      if not output then
        print("[aerospace] Failed to open destination: " .. dst)
        return false
      end
      output:write(content)
      output:close()
      print("[aerospace] Copied " .. src .. " -> " .. dst)
      return true
    end

    local function hasUltrawide()
      for _, screen in ipairs(hs.screen.allScreens()) do
        local name = screen:name()
        print("[aerospace] Found screen: " .. (name or "nil"))
        if name and string.find(name, "Odyssey") then
          return true
        end
      end
      return false
    end

    local function switchAerospaceConfig()
      local ultrawide = hasUltrawide()
      local template = ultrawide and ultrawideTemplate or laptopTemplate
      local label = ultrawide and "ultrawide" or "laptop"
      print("[aerospace] Switching to " .. label .. " config")

      if copyFile(template, aerospaceConfig) then
        local output, status = hs.execute("aerospace reload-config", true)
        print("[aerospace] reload-config: " .. (output or "") .. " (status: " .. tostring(status) .. ")")
        hs.notify.new({ title = "Aerospace", informativeText = "Switched to " .. label .. " layout" }):send()
      else
        hs.notify.new({ title = "Aerospace", informativeText = "Failed to switch config" }):send()
      end
    end

    -- Watch for screen changes (connect/disconnect)
    local screenWatcher = hs.screen.watcher.new(switchAerospaceConfig)
    screenWatcher:start()

    -- Run once at startup to set correct config
    switchAerospaceConfig()

    -- Reload Hammerspoon config hotkey: Cmd+Ctrl+R
    hs.hotkey.bind({ "cmd", "ctrl" }, "r", function()
      hs.reload()
    end)

    hs.notify.new({ title = "Hammerspoon", informativeText = "Config loaded" }):send()
  '';
}
