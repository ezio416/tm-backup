// c 2024-07-04
// m 2024-07-10

const string backupFolder = ForSlash(IO::FromStorageFolder(""));
const string guiFile      = ForSlash(IO::FromDataFolder("Gui.ini"));
const string logFile      = ForSlash(IO::FromDataFolder("Openplanet.log"));
const string oldLogFile   = ForSlash(IO::FromDataFolder("Openplanet-old.log"));
const string opFolder     = ForSlash(IO::FromDataFolder(""));
bool         running      = false;
const string settingsFile = ForSlash(IO::FromDataFolder("Settings.ini"));

void OnSettingsSave(Settings::Section& section) {
    if (!S_Enabled)
        return;

    startnew(BackupAsync);
}

void BackupAsync() {
    while (running)
        yield();

    running = true;

    const string[]@ backupFiles = IO::IndexFolder(backupFolder, false);

    const string now = Time::FormatStringUTC("%Y_%m_%d_%H_%M_%SZ_", Time::Stamp);

    if (S_Gui)
        BackupIfChanged(backupFiles, "Gui.ini", guiFile, now);

    if (S_Log)
        BackupIfChanged(backupFiles, "Openplanet.log", logFile, now);

    if (S_OldLog)
        BackupIfChanged(backupFiles, "Openplanet-old.log", oldLogFile, now);

    if (S_Settings)
        BackupIfChanged(backupFiles, "Settings.ini", settingsFile, now);

    sleep(1000);  // in case settings are saved twice in the same second (unlikely), this ensures new backup files are always created

    running = false;
}

void BackupIfChanged(const string[]@ backupFiles, const string &in name, const string &in file, const string &in now) {
    const string contents = FileRead(file);

    string latestFile;

    for (int i = backupFiles.Length - 1; i >= 0; i--) {
        if (backupFiles[i].EndsWith(name)) {
            latestFile = backupFiles[i].Replace(backupFolder, "");
            break;
        }
    }

    if (latestFile.Length == 0 || contents != FileRead(backupFolder + latestFile)) {
        trace(name);
        FileAppend(backupFolder + now + name, contents);
    }
}
