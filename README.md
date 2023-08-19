# lume 🌟

![lume demonstration](YOUR_IMAGE_URL_HERE)

Structured logs are for machines. `lume` is for humans. While machines consume and process structured logs efficiently, humans prefer aesthetics, clarity, and colors. `lume` takes structured JSON logs and transforms them into vibrant, human-readable logs, perfect for local development.

With `lume`, each log line gets transformed:

- **Colorful Levels**: Depending on the log level (`INFO`, `ERROR`, `WARN`, `TRACE`), `lume` colorizes the log prefix for instant recognition.
  - `[ INFO ]` is in green
  - `[ ERROR ]` is in red
  - `[ WARN ]` is in yellow
  - `[ TRACE ]` is in blue

- **Timestamps**: Human-friendly timestamps to quickly grasp when the event occurred.

- **Structured Data**: `lume` simplifies complex JSON structures, presenting additional data in a key-value format, easy to read and understand.

## Installation

With [fisher](https://github.com/jorgebucaran/fisher):

```fish
fisher install srizzling/lume
```

Of course! Here's the updated usage section for lume with the new arguments:

markdown

# Lume

**A human-friendly structured log viewer.**

![Lume Example Image](YOUR_IMAGE_LINK_HERE)

Structured logs are designed for machines, especially logging systems. `lume` is for humans, making these logs, especially in local development, more readable.

## Installation

```bash
fisher install srizzling/lume
```

## Usage

Pipe your structured logs into lume and watch it make the logs more readable:

```bash
echo '{"lvl": "INFO", "msg": "Hello World", "timestamp": "2023-08-19T12:00:00Z"}' | lume
```

### Options:

    -h, --help: Show the help message and exit.
    -H, --hide-additional: Hide additional fields in the log.
    -f, --jq-filter=FILTER: Provide a jq filter to extract specific fields. Example: -f '.details'.
    -D, --dot-notation: Transform nested fields to dot notation.

### Examples:

To hide additional fields:

```bash
echo '{"lvl": "INFO", "msg": "Hello World", "details": {"location": "earth"}}' | lume -H
```

To use a jq filter and dot notation:

```bash
echo '{"lvl": "INFO", "msg": "Hello World", "details": {"location": "earth"}}
```

## Configuration

| Environment Variable | Default | Description                                                  |
|----------------------|---------|--------------------------------------------------------------|
| `LUME_LINE_COUNT`    | `10`    | Maximum number of lines to accumulate before issuing a warning |

## Caveats

1. **Buffering**: Some shells or pipelines buffer the output, which might introduce a delay in the logs being displayed.
2. **Incomplete JSON**: `lume` accumulates lines until it gets a valid JSON object. If the log stream contains invalid JSON or logs that are not JSON at all, `lume` will issue a warning after a certain number of lines (configurable).
3. **Performance**: For very high-frequency log streams, there might be some lag due to the overhead of processing each log individually.

**Note**: While `lume` is exceptional for human-readable logs during local development, it's not designed for large quantities of logs. It does not scale and should not be used for processing vast log data.

## License

MIT License

Copyright (c) 2023 Sriram Venkatesh

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
