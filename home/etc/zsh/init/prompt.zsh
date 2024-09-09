#!/usr/bin/env zsh

# SIMPLE_PROMPT
#
# ~ λ

function generate_simple_prompt() {
    echo -ne "%F{blue}%~%f %B%(?.%F{green}.%F{red})λ%f%b "
}


# COMPLEX_PROMPT
#
# ┌─[zamlz@NAVI-CoplandOS]─/nixos::~/nix/
# ├─<nix.main>
# ├─{aws:test}
# └─(λ)─>
#
#    https://symbl.cc/en/unicode/blocks/box-drawing/
#    https://unix.stackexchange.com/questions/124407/what-color-codes-can-i-use-in-my-bash-ps1-prompt/124409#124409

function generate_complex_prompt() {
    local exit_code=$1

    echo -ne "\n\r%B%F{cyan}┌─"

    # Check if we are in an SSH connection
    if [ -n "$SSH_TTY" ]; then
        echo -ne "%F{white}|%b%F{yellow}ssh%F{white}%B|%F{cyan}─"
    fi

    # user @ hostname
    echo -ne "%F{white}[%b%F{blue}%n%F{white}@%F{magenta}%M%F{white}%B]%F{cyan}─"

    # distro :: current working directory
    export distro=$(grep --color=none ^ID= /etc/os-release \
        | sed -e 's/^ID=//g' \
        | tr -d '"')
    echo -ne "%F{white}/%b%F{cyan}${distro}"
    echo -ne "%F{white}::%F{blue}%~%B%F{white}/"
    
    # git_repo_name . git_repo_branch
    if [ -d "`git rev-parse --show-toplevel 2> /dev/null`/.git" ]; then

        GIT_NAME=$(basename -s .git `git config --get remote.origin.url` \
            2> /dev/null)
        GIT_NAME=$(echo $GIT_NAME | sed -e 's|^.*:||g')

        if [ -z "$GIT_NAME" ]; then
            GIT_NAME="[?]"
        fi

        GIT_BRANCH=$(git branch --list --no-color | grep --color=auto '\*' \
            | sed -e 's/^\* //g' | head -n1 | tr -d '\n')

        # (yes/no add ; no commited)
        #YA=$(git status --porcelain 2>/dev/null| grep -E "^M" | wc -l)
        #NA=$(git status --porcelain 2>/dev/null| grep -E "^ M" | wc -l)
        NC=$(git status --porcelain 2>/dev/null| grep -E "^(M| M | D)" | wc -l)

        # Use this info to construct our real status
        if [ $NC -eq 0 ]; then
            C='green'
        else
            C='red'
        fi
        echo -ne "\n%F{cyan}├─%F{white}<%b%F{$C}$GIT_NAME.$GIT_BRANCH%B%F{white}>"

    fi

    # Environment Variables
    if [ -n "${IN_NIX_SHELL}${AWS_PROFILE}${ENV_NAME}${PIPENV_ACTIVE}${VIRTUAL_ENV}" ]; then

        echo -ne "\n%B%F{cyan}├─%F{white}{%b%F{202}"
        SEPERATOR=""
        ALT_SEPERATOR="%F{white}, %F{202}"

        if [ -n "$IN_NIX_SHELL" ]; then
            echo -ne "${SEPERATOR}nix:$IN_NIX_SHELL"
            SEPERATOR=$ALT_SEPERATOR
        fi

        if [ -n "$AWS_PROFILE" ]; then
            echo -ne "${SEPERATOR}aws:$AWS_PROFILE"
            SEPERATOR=$ALT_SEPERATOR
        fi

        if [ -n "$ENV_NAME" ]; then
            echo -ne "${SEPERATOR}env:$ENV_NAME"
            SEPERATOR=$ALT_SEPERATOR
        fi

        if [ -n "$VIRTUAL_ENV" ]; then
            # Support both the old way of using venvs and new way
            if [ -n "$PIPENV_ACTIVE" ]; then
                PROGRAM="pipenv"
            else
                PROGRAM="venv"
            fi
            echo -ne "${SEPERATOR}${PROGRAM}:$(basename $VIRTUAL_ENV /.venv)"
            SEPERATOR=$ALT_SEPERATOR
        fi

        echo -ne "%B%F{white}}"
    fi

    # continue the curve on the next line of the prompt
    echo -ne "\n%B%F{cyan}└─"

    # λ : exit_code
    echo -ne "%B%F{white}("
    if [ ${exit_code} -eq 0 ]; then
        echo -ne "%B%F{green}λ"
    else
        echo -ne "%B%F{red}λ:${exit_code}"
    fi
    echo -ne "%B%F{white})"

    # end the prompt
    echo -ne "%B%F{cyan}─%B%F{cyan}> %{\e[0m%}"
}
