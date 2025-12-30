#!/usr/bin/env bash
set -euo pipefail

# Close System Settings to prevent it from overriding changes
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true

# =============================================================================
# Keyboard & Input
# =============================================================================

# Fast key repeat (essential for vim)
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable press-and-hold for keys (enable key repeat everywhere)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Disable auto-correct and smart substitutions (code-hostile features)
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable Spotlight shortcuts (for Raycast)
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "{ enabled = 0; }"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 65 "{ enabled = 0; }"

# =============================================================================
# Trackpad & Mouse
# =============================================================================

# Trackpad speed
defaults write -g com.apple.trackpad.scaling -float 3.0

# Tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1
defaults write -g com.apple.mouse.tapBehavior -int 1

# Three finger drag
defaults write com.apple.AppleMultitouchTrackpad Dragging -bool true
defaults write com.apple.AppleMultitouchTrackpad DragLock -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Dragging -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad DragLock -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

# =============================================================================
# Finder
# =============================================================================

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show path bar and status bar
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

# Show full path in title bar
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Search current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable warning when changing file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store on network and USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Default to list view
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# New Finder window opens home folder
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# =============================================================================
# Desktop & Dock
# =============================================================================

# Desktop: disable click-to-show, hide icons
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
defaults write com.apple.WindowManager StandardHideDesktopIcons -bool true

# Dock position and behavior
defaults write com.apple.dock orientation -string "right"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.3
defaults write com.apple.dock mineffect -string "scale"
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock launchanim -bool false
defaults write com.apple.dock show-process-indicators -bool true
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock tilesize -int 48

# Double-click title bar to maximize
defaults write -g AppleActionOnDoubleClick -string "Maximize"

# Stage Manager (disabled)
defaults write com.apple.WindowManager GloballyEnabled -bool false
defaults write com.apple.WindowManager EnableStageManagerClickToShowDesktop -bool true
defaults write com.apple.WindowManager StageManagerShowRecentApps -bool false

# =============================================================================
# Screenshots
# =============================================================================

# Create Screenshots folder
mkdir -p "${HOME}/Screenshots"

# Save screenshots to ~/Screenshots
defaults write com.apple.screencapture location -string "${HOME}/Screenshots"

# Save as PNG
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Include date in filename
defaults write com.apple.screencapture include-date -bool true

# =============================================================================
# Security & Privacy
# =============================================================================

# Enable firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on 2>/dev/null || true

# Enable stealth mode (don't respond to pings)
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on 2>/dev/null || true

# Require password immediately after sleep/screensaver
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# =============================================================================
# Safari (if used)
# =============================================================================

# Show full URL in address bar
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# Enable Develop menu
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true

# Disable AutoFill
defaults write com.apple.Safari AutoFillPasswords -bool false
defaults write com.apple.Safari AutoFillCreditCardData -bool false

# =============================================================================
# TextEdit
# =============================================================================

# Use plain text by default
defaults write com.apple.TextEdit RichText -int 0

# Open and save files as UTF-8
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

# =============================================================================
# Activity Monitor
# =============================================================================

# Show all processes
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Sort by CPU usage
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

# =============================================================================
# Misc
# =============================================================================

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Save to disk (not iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Disable "Are you sure you want to open this application?"
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Disable Resume system-wide
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

# Disable automatic termination of inactive apps
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

# =============================================================================
# Restart affected services
# =============================================================================

killall SystemUIServer 2>/dev/null || true
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
