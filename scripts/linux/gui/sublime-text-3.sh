#!/bin/bash

# # download and install sublime text for system user
# curl -o /tmp/sublime.tar.bz2 http://c758482.r82.cf2.rackcdn.com/sublime_text_3_build_3059_x64.tar.bz2
# tar xf /tmp/sublime.tar.bz2 -C /tmp
# rm /tmp/sublime.tar.bz2

# # modify all of the below commands, remove the su, and append the path
# chown -R $config_system_username:$config_system_username /tmp/sublime_text_3
# mkdir -p "${user_home_dir}/applications" "${user_home_dir}/.bin" "${user_home_dir}/.config/sublime-text-3/Packages/User" "${user_home_dir}/.config/sublime-text-3/Installed Packages/"
# mv /tmp/sublime_text_3 "${user_home_dir}/applications/sublime_text"
# ln -s "${user_home_dir}/applications/sublime_text/sublime_text" "${user_home_dir}/.bin/subl"

# # install sublime package control
# curl -o "${user_home_dir}/.config/sublime-text-3/Installed Packages/Package Control.sublime-package" "https://sublime.wbond.net/Package%20Control.sublime-package"

# # populate sublime preferences
# echo '{' > "${user_home_dir}/.config/sublime-text-3/Packages/User/Preferences.sublime-settings"
# echo '    "auto_complete_commit_on_tab": true,' >> "${user_home_dir}/.config/sublime-text-3/Packages/User/Preferences.sublime-settings"
# echo '    "caret_style": "phase",' >> "${user_home_dir}/.config/sublime-text-3/Packages/User/Preferences.sublime-settings"
# echo '    "color_scheme": "Packages/Color Scheme - Default/Sunburst.tmTheme",' >> "${user_home_dir}/.config/sublime-text-3/Packages/User/Preferences.sublime-settings"
# echo '    "font_face": "ForMateKonaVe",' >> "${user_home_dir}/.config/sublime-text-3/Packages/User/Preferences.sublime-settings"
# echo '    "font_size": 14,' >> "${user_home_dir}/.config/sublime-text-3/Packages/User/Preferences.sublime-settings"
# echo '    "highlight_line": true,' >> "${user_home_dir}/.config/sublime-text-3/Packages/User/Preferences.sublime-settings"
# echo '    "highlight_modified_tabs": true,' >> "${user_home_dir}/.config/sublime-text-3/Packages/User/Preferences.sublime-settings"
# echo '    "match_brackets_angle": true,' >> "${user_home_dir}/.config/sublime-text-3/Packages/User/Preferences.sublime-settings"
# echo '    "scroll_past_end": true,' >> "${user_home_dir}/.config/sublime-text-3/Packages/User/Preferences.sublime-settings"
# echo '    "scroll_speed": 2.0,' >> "${user_home_dir}/.config/sublime-text-3/Packages/User/Preferences.sublime-settings"
# echo '    "translate_tabs_to_spaces": true,' >> "${user_home_dir}/.config/sublime-text-3/Packages/User/Preferences.sublime-settings"
# echo '    "trim_trailing_white_space_on_save": true' >> "${user_home_dir}/.config/sublime-text-3/Packages/User/Preferences.sublime-settings"
# echo '}' >> "${user_home_dir}/.config/sublime-text-3/Packages/User/Preferences.sublime-settings"

# # configure hotkeys (some are plugin dependent and will simply not work)
# echo '[' > "${user_home_dir}/.config/sublime-text-3/Packages/User/Default (Linux).sublime-keymap"
# echo '    { "keys": ["ctrl+tab"], "command": "next_view" },' >> "${user_home_dir}/.config/sublime-text-3/Packages/User/Default (Linux).sublime-keymap"
# echo '    { "keys": ["ctrl+shift+tab"], "command": "prev_view" },' >> "${user_home_dir}/.config/sublime-text-3/Packages/User/Default (Linux).sublime-keymap"
# echo ']' >> "${user_home_dir}/.config/sublime-text-3/Packages/User/Default (Linux).sublime-keymap"
# # echo '[' > "${user_home_dir}/.config/sublime-text-3/Packages/User/Default (OSX).sublime-keymap"
# # echo '    { "keys": ["ctrl+tab"], "command": "next_view" },' >> "${user_home_dir}/.config/sublime-text-3/Packages/User/Default (OSX).sublime-keymap"
# # echo '    { "keys": ["ctrl+shift+tab"], "command": "prev_view" },' >> "${user_home_dir}/.config/sublime-text-3/Packages/User/Default (OSX).sublime-keymap"
# # echo ']' >> "${user_home_dir}/.config/sublime-text-3/Packages/User/Default (OSX).sublime-keymap"

# # populate markdown-preview config file
# echo '{' > "${user_home_dir}/.config/sublime-text-3/Packages/User/MarkdownPreview.sublime-settings"
# echo '    "build_action": "browser"' >> "${user_home_dir}/.config/sublime-text-3/Packages/User/MarkdownPreview.sublime-settings"
# echo '}' >> "${user_home_dir}/.config/sublime-text-3/Packages/User/MarkdownPreview.sublime-settings"

# # populate go-sublime package config
# echo '{' > "${user_home_dir}/.config/sublime-text-3/Packages/User/GoSublime.sublime-settings"
# echo '    "env": {' >> "${user_home_dir}/.config/sublime-text-3/Packages/User/GoSublime.sublime-settings"
# echo '        "GOPATH": "$HOME/.go"' >> "${user_home_dir}/.config/sublime-text-3/Packages/User/GoSublime.sublime-settings"
# echo '    }' >> "${user_home_dir}/.config/sublime-text-3/Packages/User/GoSublime.sublime-settings"
# echo '}' >> "${user_home_dir}/.config/sublime-text-3/Packages/User/GoSublime.sublime-settings"
