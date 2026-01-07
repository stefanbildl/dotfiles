if status is-interactive
    if not set -q ZELLIJ
        and not set -q SSH_TTY
        and not set -q SSH_CONNECTION
        eval (zellij setup --generate-auto-start fish | string collect)
    end
end
