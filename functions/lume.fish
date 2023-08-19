function lume
    set _flag_hide_additional_fields 0
    set _flag_flat_fields 0
    set _flag_filter_string ""

    # Define flags and arguments with argparse
    argparse "H/hide_additional_fields" "f/flat_fields" "d/filter_string=" -- $argv

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
        set human_timestamp (date -d $timestamp +'%b %d %H:%M:%S' 2>/dev/null; or echo "Invalid Timestamp")

        set additional_fields ""

        # Prepare the additional fields if they are not to be hidden
        if not $_flag_hide_additional_fields
            set additional_fields (echo $line | jq 'del(.lvl, .level, .msg, .message, .timestamp, .time)')
            # Flatten the additional fields if the flat_fields flag is set
            if $_flag_flat_fields
                set additional_fields (echo $additional_fields | jq -r 'recurse | to_entries[] | "\(.key): \(.value)"')
            end
        end

        # Apply filtering if a filter string is provided
        if test -n "$_flag_filter_string"
            set additional_fields (echo $additional_fields | jq "$_flag_filter_string")
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
        echo " ] - $human_timestamp - $message - $additional_fields"

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
    echo "  -H, --hide_additional_fields  Hide the additional fields in the log output"
    echo "  -f, --flat_fields             Display additional fields in a flattened manner"
    echo "  -d, --filter_string=STRING    Filter which fields to display using a jq filter string"
end
