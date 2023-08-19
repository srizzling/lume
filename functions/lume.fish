function lume
    # Arguments setup
    set -l _flag_hide_additional 0
    set -l _flag_jq_filter ""
    set -l _flag_dot_notation 0

    argparse "h/help H/hide-additional f/jq-filter= D/dot-notation" -- $argv

    # Check if help flag is provided
    if set -q _flag_help
        echo "Usage: lume [OPTIONS]"
        echo
        echo "Options:"
        echo "  -h, --help: Show the help message and exit."
        echo "  -H, --hide-additional: Hide additional fields in the log."
        echo "  -f, --jq-filter=FILTER: Provide a jq filter to extract specific fields. Example: -f '.details'."
        echo "  -D, --dot-notation: Transform nested fields to dot notation."
        return 0
    end

    while read -l line
        # Extracting primary fields (level, timestamp, and message)
        set -l level (echo $line | jq -r '.lvl // .level // ""')
        set -l message (echo $line | jq -r '.msg // .message // ""')
        set -l timestamp (echo $line | jq -r '.timestamp // .time // ""')

        # Formatting the timestamp
        set -l human_timestamp (date -d $timestamp +"%A %d %B %Y %T")

        # Handle log level coloring
        switch $level
            case "INFO" "info"
                set_color green
                echo -n "[ INFO ]"
            case "ERROR" "error"
                set_color red
                echo -n "[ ERROR ]"
            case "WARN" "warn"
                set_color yellow
                echo -n "[ WARN ]"
            case "TRACE" "trace"
                set_color blue
                echo -n "[ TRACE ]"
            case '*'
                set_color normal
                echo -n "[ UNKNOWN ]"
        end
        set_color normal

        # Apply jq filter if provided
        if test -n "$_flag_jq_filter"
            set line (echo $line | jq $_flag_jq_filter)
        end

        # Transform nested fields to dot notation if -D is set
        if test $_flag_dot_notation -eq 1
            set line (echo $line | jq -c 'recurse | objects | to_entries | .[] | "\(.key)=\(.value)"' | tr '\n' ',')
        end

        # Hide additional fields if -H is set
        if test $_flag_hide_additional -eq 1
            echo " - $human_timestamp - $message"
        else
            set -l additional_fields (echo $line | jq -c 'del(.lvl, .level, .msg, .message, .timestamp, .time)')
            echo " - $human_timestamp - $message - $additional_fields"
        end
    end
end
