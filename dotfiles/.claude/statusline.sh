#!/bin/bash
input=$(cat)

# Parse JSON fields using grep/sed (no jq dependency)
current_dir=$(echo "$input" | grep -o '"current_dir":"[^"]*"' | head -1 | sed 's/"current_dir":"//;s/"//')
used=$(echo "$input" | grep -o '"used_percentage":[0-9.]*' | grep -o '[0-9.]*$')
ctx_size=$(echo "$input" | grep -o '"context_window_size":[0-9]*' | grep -o '[0-9]*$')

# Derive display name from current_dir
dir_name=$(basename "$current_dir")

# Git branch info
git_info=""
if [ -n "$current_dir" ]; then
    branch=$(git -C "$current_dir" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        git_info=" $(printf '\033[0;35m')($branch)$(printf '\033[0m')"
    fi
fi


# Model name (extract tier from JSON input)
model_info=""
model_raw=$(echo "$input" | grep -o '"id":"[^"]*"' | head -1 | sed 's/"id":"//;s/"//')
if [ -z "$model_raw" ] && [ -n "$CLAUDE_MODEL" ]; then
    model_raw="$CLAUDE_MODEL"
fi
if [ -n "$model_raw" ]; then
    model_tier=$(echo "$model_raw" | grep -oiE 'opus|sonnet|haiku' | head -1)
    if [ -n "$model_tier" ]; then
        model_tier_cap=$(echo "$model_tier" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')
        model_info=" $(printf '\033[38;5;240m')${model_tier_cap}$(printf '\033[0m')"
    fi
fi

# Context window usage bar
ctx_info=""
if [ -n "$used" ]; then
    used_int=$(printf "%.0f" "$used")
    if [ "$used_int" -le 50 ]; then
        ctx_color=$(printf '\033[32m')
    elif [ "$used_int" -le 80 ]; then
        ctx_color=$(printf '\033[33m')
    else
        ctx_color=$(printf '\033[31m')
    fi
    filled=$(( used_int / 10 ))
    empty=$(( 10 - filled ))
    bar=""
    for i in $(seq 1 $filled); do bar="${bar}█"; done
    for i in $(seq 1 $empty);  do bar="${bar}░"; done
    # Compute used/total tokens for display
    if [ -n "$ctx_size" ] && [ "$ctx_size" -gt 0 ]; then
        used_tokens=$(( ctx_size * used_int / 100 ))
        token_label="${used_int}%"
    else
        token_label="${used_int}%"
    fi
    ctx_info=" $(printf '\033[38;5;240m')|$(printf '\033[0m') ${ctx_color}${bar} ${token_label}$(printf '\033[0m')"
else
    if [ -n "$ctx_size" ] && [ "$ctx_size" -gt 0 ]; then
        token_label="0%"
    else
        token_label="0%"
    fi
    ctx_info=" $(printf '\033[38;5;240m')|$(printf '\033[0m') $(printf '\033[32m')░░░░░░░░░░ ${token_label}$(printf '\033[0m')"
fi

# Security scan of changed files
sec_info=""
sec_details=""
if [ -n "$current_dir" ]; then
    sec_pattern=$(jq -r '.patterns | join("|")' ~/.claude/config/security_patterns.json 2>/dev/null)
    changed_files=$(
        git -C "$current_dir" --no-optional-locks diff --name-only HEAD 2>/dev/null
        git -C "$current_dir" --no-optional-locks diff --cached --name-only 2>/dev/null
        git -C "$current_dir" --no-optional-locks ls-files --others --exclude-standard 2>/dev/null
    )
    changed_files=$(echo "$changed_files" | sort -u | grep -v '^$' | grep -E '\.(ts|tsx|js|jsx|py|go|rs|java|c|cpp|cs|rb|php|sh|bash|zsh|env|json|yaml|yml|toml|tf|sql)$')

    issue_count=0
    file_lines=""
    max_line_len=0
    if [ -n "$changed_files" ] && [ -n "$sec_pattern" ]; then
        while IFS= read -r file; do
            filepath="$current_dir/$file"
            [ -f "$filepath" ] || continue
            hits=$(grep -nE "$sec_pattern" "$filepath" 2>/dev/null)
            [ -z "$hits" ] && continue
            shortname=$(basename "$file")
            hit_count=$(echo "$hits" | wc -l | tr -d ' ')
            line_nums=$(echo "$hits" | cut -d: -f1 | head -5 | tr '\n' ',' | sed 's/,$//')
            [ "$hit_count" -gt 5 ] && line_nums="${line_nums},…"
            issue_count=$(( issue_count + hit_count ))
            entry="${shortname}[${line_nums}]"
            entry_len=${#entry}
            [ "$entry_len" -gt "$max_line_len" ] && max_line_len=$entry_len
            file_lines+="$(printf '\033[38;5;245m')${entry}$(printf '\033[0m')"$'\n'
        done <<< "$changed_files"
    fi
    divider=$(printf '─%.0s' $(seq 1 "$max_line_len"))

    if [ "$issue_count" -eq 0 ]; then
        sec_info=""
    elif [ "$issue_count" -le 3 ]; then
        sec_color='\033[33m'
        sec_info="$(printf '\033[33m')⛨ ${issue_count} security issues$(printf '\033[0m')"$'\n'"$(printf '\033[38;5;240m')${divider}$(printf '\033[0m')"$'\n'"${file_lines%$'\n'}"
    else
        sec_color='\033[31m'
        sec_info="$(printf '\033[31m')⛨ ${issue_count} security issues$(printf '\033[0m')"$'\n'"$(printf '\033[38;5;240m')${divider}$(printf '\033[0m')"$'\n'"${file_lines%$'\n'}"
    fi
    sec_details=""
fi

# AWS CodeArtifact login status
aws_info=""
auth_file="$HOME/.aws/.codeartifact_auth"
if [ -f "$auth_file" ]; then
    login_at=$(cat "$auth_file" 2>/dev/null | tr -d '[:space:]')
    now=$(date +%s)
    expires_at=$(( login_at + 43200 ))  # 12 hours = 43200 seconds
    if [ -n "$login_at" ] && [ "$expires_at" -gt "$now" ] 2>/dev/null; then
        remaining=$(( expires_at - now ))
        hours=$(( remaining / 3600 ))
        mins=$(( (remaining % 3600) / 60 ))
        if [ "$remaining" -le 3600 ]; then
            # Less than 1 hour — warn in yellow
            aws_info=" $(printf '\033[38;5;240m')|$(printf '\033[0m') $(printf '\033[33m')⛁ AWS ${hours}h${mins}m$(printf '\033[0m')"
        else
            aws_info=" $(printf '\033[38;5;240m')|$(printf '\033[0m') $(printf '\033[36m')⛁ AWS ✓"
        fi
    else
        # File exists but token expired
        aws_info=" $(printf '\033[38;5;240m')|$(printf '\033[0m') $(printf '\033[31m')⛁ AWS ✕$(printf '\033[0m')"
    fi
else
    aws_info=" $(printf '\033[38;5;240m')|$(printf '\033[0m') $(printf '\033[31m')⛁ AWS ✕$(printf '\033[0m')"
fi

printf "\n$(printf '\033[1;32m')➜$(printf '\033[0m') $(printf '\033[0;36m')%s$(printf '\033[0m')%s\n⠀\n%s%s%s\n⠀\n%s\n" "$dir_name" "$git_info" "$model_info" "$ctx_info" "$aws_info" "$sec_info"
