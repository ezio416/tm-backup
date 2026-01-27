[Setting hidden] bool S_Debug    = false;
[Setting hidden] bool S_Enabled  = true;
[Setting hidden] bool S_Gui      = true;
[Setting hidden] bool S_Log      = false;
[Setting hidden] bool S_OldLog   = false;
[Setting hidden] bool S_Settings = true;

[SettingsTab name="General" icon="Cogs"]
void Settings_General() {
    if (UI::Button("Reset to default")) {
        Meta::PluginSetting@[]@ settings = Meta::ExecutingPlugin().GetSettings();

        for (uint i = 0; i < settings.Length; i++) {
            settings[i].Reset();
        }
    }

    S_Enabled = UI::Checkbox("Enabled", S_Enabled);
    HoverTooltipSetting("Runs whenever Openplanet's settings are saved");

    UI::Separator();

    UI::TextWrapped("Toggle individual file backups here\nTimestamps on backed up files are in UTC\nFiles are only backed up if they differ from their latest backup");

    S_Gui = UI::Checkbox("GUI", S_Gui);
    HoverTooltipSetting(guiFile);

    S_Log = UI::Checkbox("Log", S_Log);
    HoverTooltipSetting(logFile);
    HoverTooltipSetting("Can quickly take up space on your storage drive", "FA0");

    S_OldLog = UI::Checkbox("Old log", S_OldLog);
    HoverTooltipSetting(oldLogFile);

    S_Settings = UI::Checkbox("Settings", S_Settings);
    HoverTooltipSetting(settingsFile);

    UI::Separator();

    if (UI::Button(Icons::ExternalLink + " Open Openplanet folder")) {
        OpenExplorerPath(opFolder);
    }
    HoverTooltip(opFolder);

    UI::SameLine();
    if (UI::Button(Icons::ExternalLink + " Open backup folder")) {
        OpenExplorerPath(backupFolder);
    }
    HoverTooltip(backupFolder);

    UI::Separator();

    S_Debug = UI::Checkbox("Debug logging", S_Debug);
    HoverTooltipSetting("Prints more to the log for debugging purposes");
}

void HoverTooltipSetting(const string&in msg, const string&in color = "666") {
    UI::SameLine();
    UI::Text("\\$" + color + Icons::QuestionCircle);
    if (!UI::IsItemHovered()) {
        return;
    }

    UI::SetNextWindowSize(int(Math::Min(UI::MeasureString(msg).x, 400.0f)), 0.0f);
    UI::BeginTooltip();
    UI::TextWrapped(msg);
    UI::EndTooltip();
}
