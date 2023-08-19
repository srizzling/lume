function lume
    # Configuration: Maximum accumulated lines. You can customize this using the LUME_LINE_COUNT environment variable.
    set -l max_line_count (set -q LUME_LINE_COUNT; and echo $LUME_LINE_COUNT; or echo 10)
    set -l accumulated_lines ""
    set -l line_count 0

    while read -l line
        # Increment the line counter
        set line_count (math $line_count+1)

        # Try to append the new line to our accumulated lines and check if it forms a valid JSON
        set accumulated_lines "$accumulated_lines$line"

        # Test if the accumulated lines form a valid JSON
        if echo $accumulated_lines | jq empty 2>/dev/null
            set json $accumulated_lines

            # Extract common fields with fallback options
            set lvl (echo $json | jq -r '.lvl // .level // ""')
            set msg (echo $json | jq -r '.msg // .message // ""')
            set timestamp (echo $json | jq -r '.timestamp // .time // ""')

            # Make the timestamp human-friendly
            if test -n "$timestamp"
                set timestamp (date -d $timestamp +"%Y-%m-%d %H:%M:%S")
            end

            # Remove the already extracted fields from the JSON
            set other_fields (echo $json | jq 'del(.lvl, .level, .msg, .message, .timestamp, .time)')

            # Color formatting based on log level
            switch $lvl
                case 'INFO' 'info'
                    printf "\033[32m[ INFO ]\033[0m "
                case 'ERROR' 'error'
                    printf "\033[31m[ ERROR ]\033[0m "
                case 'WARN' 'warning'
                    printf "\033[33m[ WARN ]\033[0m "
                case 'TRACE' 'trace'
                    printf "\033[34m[ TRACE ]\033[0m "
                case '*'
                    printf "[ %s ] " $lvl
            end

            echo -n "$timestamp - $msg - "
            echo $other_fields | jq -r 'to_entries[] | "\(.key): \(.value)"' | string join ", "

            # Reset accumulated lines and line count
            set accumulated_lines ""
            set line_count 0

        else if test $line_count -ge $max_line_count
            # If accumulated lines reach max count without forming a valid JSON, print as a warning.
            printf "\033[33m[ WARN from lume ]\033[0m %s\n" $accumulated_lines
            set accumulated_lines ""
            set line_count 0
        end
    end
end