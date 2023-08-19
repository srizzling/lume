function lume
    # Initialize flags with default values
    set _flag_hide_additional 0
    set _flag_jq_filter ""
    set _flag_dot_notation 0

    # Define flags and arguments with argparse
    argparse "h/help" "H/hide_additional" "f/jq_filter=" "D/dot_notation" -- $argv || lume_help

    # If the help flag is set, display help and exit
    if set -q _flag_help
        lume_help
        return
    end

    # Determine maximum line count from environment variable or default to 10
    if set -q LUME_LINE_COUNT
        set max_line_count $LUME_LINE_COUNT
    else
        set max_line_count 10
    end
    set line_count 0

    # Process each incoming log line
    while read -l line
        # Extract main fields from the log line
        set log_level (echo $line | jq -r '.lvl // .level // "UNKNOWN"')
        set message (echo $line | jq -r '.msg // .message // "No Message"')
        set timestamp (echo $line | jq -r '.timestamp // .time // ""')
        set human_timestamp (date -d $timestamp +"%A %d %B %Y %H:%M:%S" 2>/dev/null; or echo "Invalid Timestamp")

        set additional_fields ""

        # Prepare the additional fields if they are not to be hidden
        if test $_flag_hide_additional -eq 0
            if test -n "$_flag_jq_filter"
                set additional_fields (echo $line | jq -rc "$_flag_jq_filter")
            else
                set additional_fields (echo $line | jq -rc 'del(.lvl, .level, .msg, .message, .timestamp, .time)')
            end

            # Flatten the additional fields if the dot_notation flag is set
            if test $_flag_dot_notation -eq 1
                set additional_fields (echo $additional_fields | jq -r 'recurse | to_entries[] | "\(.key): \(.value)"')
            end
        end

        # Begin printing the processed log line
        echo -n "[ "

        # Colorize log level based on its value
        switch $log_level
            case "INFO" "info"
                set_color green
                echo -n "INFO"
            case "ERROR" "error"
                set_color red
                echo -n "ERROR"
            case "WARN" "warn"
                set_color yellow
                echo -n "WARN"
            case "TRACE" "trace"
                set_color blue
                echo -n "TRACE"
            case '*'
                set_color normal
                echo -n "UNKNOWN"
        end

        # Reset color and print the rest of the log line
        set_color normal

        # Print the message, and if there are additional fields, append them separated by " - "
        echo " ] - $human_timestamp - $message" (if test -n "$additional_fields"; echo -n " - $additional_fields"; end)

        # Count processed lines and give a warning if the threshold is reached
        set line_count (math $line_count+1)
        if test $line_count -ge $max_line_count
            set_color yellow
            echo "[ WARN from lume ] Exceeded $max_line_count lines of processed logs. Accumulation might affect performance."
            set_color normal
            set line_count 0
        end
    end
end

function lume_help
    echo "Usage: lume [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help                Show this help message and exit."
    echo "  -H, --hide-additional     Hide additional fields in the log."
    echo "  -f, --jq-filter=FILTER    Provide a jq filter to extract specific fields. Example: -f '.details'."
    echo "  -D, --dot-notation        Transform nested fields to dot notation."
end
