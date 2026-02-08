void HoverTooltip(const string&in msg) {
    if (!UI::IsItemHovered()) {
        return;
    }

    UI::BeginTooltip();
    UI::Text(msg);
    UI::EndTooltip();
}

void Log(const string&in msg) {
    if (S_Debug) {
        trace(msg);
    }
}
