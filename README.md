### Tools for working with common data sources

A collection of CLI utilities for pulling both files and structured data
from file sharing and collaboration services like Google Drive and
Dropbox.

You can use this to pull down google spreadsheets and convert them to
JSON structures, or to convert an excel spreadsheet on Dropbox to the
same.

You can use this to sync the contents of a local folder on your system
with the remote contents of a file share on Dropbox or Google Drive.

And much more.

### Getting Started

```bash
gem install datapimp
datapimp help
```

#### Available Commands

```
  COMMANDS:

    config               Shows the configuration options being used
    config set           manipulate configuration settings
    help                 Display global or [command] help documentation
    list spreadsheets    list the spreadsheets which can be used as datasources
    setup amazon         setup integration with amazon
    setup dropbox        setup integration with dropbox
    setup github         setup integration with github
    setup google         setup integration with google drive
    sync data            Synchronize the contents of a local data store with its remote source
    sync folder          Synchronize the contents of a local folder with a file sharing service

```
