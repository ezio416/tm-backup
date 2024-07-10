// c 2024-07-04
// m 2024-07-04

void FileAppend(const string &in path, const string &in contents) {
    IO::File file(path, IO::FileMode::Append);
    file.Write(contents);
    file.Close();
}

string FileRead(const string &in path) {
    if (!IO::FileExists(path)) {
        warn("file not found: " + path);
        return "";
    }

    IO::File file(path, IO::FileMode::Read);
    const string contents = file.ReadToEnd();
    file.Close();

    return contents;
}

string ForSlash(const string &in path) {
    return path.Replace("\\", "/");
}

void HoverTooltip(const string &in msg) {
    if (!UI::IsItemHovered())
        return;

    UI::BeginTooltip();
        UI::Text(msg);
    UI::EndTooltip();
}
