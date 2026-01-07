if status is-interactive
   if command -q go
        set -l go_bin
        if set -q GOBIN
            set go_bin $GOBIN
        else
            set go_bin (go env GOPATH)/bin
        end

        if test -d $go_bin
            contains -- $go_bin $fish_user_paths || set -Ua fish_user_paths $go_bin
        end
    end
end
