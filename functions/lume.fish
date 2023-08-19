function lume
    set -l hide_additional false
    set -l jq_filter ""
    set -l dot_notation false

    argparse "h/help" "H/hide-additional" "f/jq-filter=" "D/dot-notation" -- $argv

    if set -q _flag_help
        echo "Usage: lume [OPTIONS]"
        echo ""
        echo "A human-friendly structured log viewer."
        echo ""
        echo "Options:"
        echo "  -h, --help                Show this help message and exit."
        echo "  -H, --hide-additional     Hide additional fields in the log."
        echo "  -f, --jq-filter=FILTER    Provide a jq filter to extract specific fields."
        echo "  -D, --dot-notation        Transform nested fields to dot notation."
        echo ""
        echo "Examples:"
        echo "  lume -H"
        echo "  lume -f '.details' -D"
        return
    end

    if set -q _flag_hide_additional; set hide_additional true; end
    if set -q _flag_jq_filter; set jq_filter $_flag_jq_filter; end
    if set -q _flag_dot_notation; set dot_notation true; end

    set -l line_count 0
    set max_line_count (or (env LUME_LINE_COUNT) 10)
    while read -l line
        math line_count++

        set log_level (echo $line | jq -r ".lvl? // .level? // empty")
        set message (echo $line | jq -r ".msg? // .message? // empty")
        set timestamp (echo $line | jq -r ".timestamp? // .time? // empty")
        set human_timestamp (date --date=$timestamp +"%b %d %H:%M:%S")

        switch $log_level
            case "INFO" "info"
                set log_level_color (set_color green)
            case "WARN" "warning" "WARNING"
                set log_level_color (set_color yellow)
            case "ERROR" "error" "ERR"
                set log_level_color (set_color red)
            case "TRACE" "trace"
                set log_level_color (set_color blue)
            case "*"
                set log_level_color (set_color white)
        end

        set additional_fields ""
        if not $hide_additional
            set json_fields (echo $line | jq -c "del(.lvl, .level, .msg, .message, .timestamp, .time)")

            if test "$jq_filter" != ""
                set json_fields (echo $json_fields | jq -c $jq_filter)
            end

            if $dot_notation
                set json_fields (echo $json_fields | jq -c -r 'to_entries[] | "\(.key): \(.value)"')
            end

            set additional_fields " - $json_fields"
        end

        echo "$log_level_color[$log_level](set_color normal) - $human_timestamp - $message$additional_fields"

        if test $line_count -ge $max_line_count
            echo (set_color yellow)"[ WARN from lume ] Accumulated $line_count lines without a recognizable log level. Consider adjusting LUME_LINE_COUNT if seeing this frequently."(set_color normal)
            set line_count 0
        end
    end
end
