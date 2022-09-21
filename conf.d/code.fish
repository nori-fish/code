function _code_install --on-event code_install --on-event code_update
    if command --query code
        set --function current_version (dpkg -s code | grep '^Version:' | awk '{print $2}')
    end

    set --function latest_release_url ( \
        curl -fsI "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" \
            | grep '^Location:' \
            | awk '{print $2}' \
    )

    set --function latest_version (\
        string split '_' (\
            path change-extension "" (\
                path basename $latest_release_url\
            )\
        )\
        | tail -n-2\
        | head -n1\
    )

    if [ "$current_version" != "$latest_version" ]
        if [ "$current_version" ]
            echo "[code] Updating from v$current_version to v$latest_version..."
        else
            echo "[code] Installing v$latest_version"
        end

        set --local name "code_$latest_version.deb"
        set --local tmp_dir (mktemp -d /tmp/code.XXXXXXX)
        set --local file_path $tmp_dir/$name

        curl --progress-bar -fLo "$file_path" "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
        and pkexec dpkg --install $file_path
        and rm -rf $tmp_dir
    end
end

function _code_uninstall --on-event code_uninstall
    pkexec dpkg --remove code
end
