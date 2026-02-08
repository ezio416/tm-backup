const string backupFolder   = IO::FromStorageFolder("backups/");
const string guiFile        = IO::FromDataFolder("Gui.ini");
const string logFile        = IO::FromDataFolder("Openplanet.log");
const string oldLogFile     = IO::FromDataFolder("Openplanet-Old.log");
const string opFolder       = IO::FromDataFolder("");
bool         running        = false;
const string settingsFile   = IO::FromDataFolder("Settings.ini");
const string timestampsFile = IO::FromStorageFolder("timestamps.json");
Json::Value@ timestamps;

void OnSettingsSave(Settings::Section&) {
    if (!S_Enabled) {
        return;
    }

    @timestamps = LoadTimestamps();

    if (!IO::FolderExists(backupFolder)) {
        IO::CreateFolder(backupFolder);
    }

    startnew(BackupAsync);
}

void BackupAsync() {
    while (running) {
        yield();
    }

    running = true;

    const string now = Time::FormatStringUTC("%Y_%m_%d_%H_%M_%SZ_", Time::Stamp);

    if (S_Gui) {
        BackupIfChangedAsync("Gui.ini", guiFile, now);
    }

    if (S_Log) {
        BackupIfChangedAsync("Openplanet.log", logFile, now);
    }

    if (S_OldLog) {
        BackupIfChangedAsync("Openplanet-Old.log", oldLogFile, now);
    }

    if (S_Settings) {
        BackupIfChangedAsync("Settings.ini", settingsFile, now);
    }

    sleep(1000);  // in case settings are saved twice in the same second (unlikely), this ensures new backup files are always created

    running = false;
}

void BackupIfChangedAsync(const string&in name, const string&in file, const string&in now) {
    const int64 currentModifyTime = IO::FileModifiedTime(file);
    const int64 oldModifyTime = timestamps.HasKey(name) ? int64(timestamps[name]) : 0;

    Log("BackupIfChanged: " + name + " | currentModifyTime " + currentModifyTime + " | oldModifyTime: "
        + oldModifyTime + " (diff of " + (currentModifyTime - oldModifyTime) + "s)");

    if (false
        or !timestamps.HasKey(name)
        or currentModifyTime != oldModifyTime
    ) {
        trace(name);

        try {
            IO::Copy(file, backupFolder + now + name);
            yield();
        } catch {
            error("failed to back up (" + name + "):" + getExceptionInfo());
            return;
        }

        timestamps[name] = currentModifyTime;
        SaveTimestamps();
    }
}

Json::Value@ LoadTimestamps() {
    if (!IO::FileExists(timestampsFile)) {
        Log("timestamps file not found");
        return Json::Object();
    }

    Json::Value@ ts = Json::FromFile(timestampsFile);
    if (false
        or ts is null
        or ts.GetType() != Json::Type::Object
    ) {
        warn("LoadTimestamps: file empty or invalid");
        try {
            IO::Delete(timestampsFile);
        } catch {
            Log("failed to delete invalid timestamps file: " + getExceptionInfo());
        }
        return Json::Object();
    }

    return ts;
}

void SaveTimestamps() {
    try {
        Json::ToFile(timestampsFile, timestamps);
    } catch {
        error("SaveTimestamps: " + getExceptionInfo());
    }
}
