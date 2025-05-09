# vim: set ft=make :

# alias for install-jetbrains-toolbox
[group('Apps')]
jetbrains-toolbox:
    @ujust install-jetbrains-toolbox

# Install JetBrains Toolbox | https://www.jetbrains.com/toolbox-app/
[group('Apps')]
install-jetbrains-toolbox:
    #!/usr/bin/env -S bash
    brew tap ublue-os/tap 2>/dev/null || true
    brew trust ublue-os/tap 2>/dev/null || true
    brew install --cask ublue-os/tap/jetbrains-toolbox-linux