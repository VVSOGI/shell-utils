# GitHub Label Synchronize

Bash script to synchronize issue labels from a GitHub repository with a JSON file.

## Usage

```bash
bash ./label-synchronize.sh
```

## Arguments

- accesstoken: GitHub personal access token
- LabelFile: Path to JSON file with label definitions
- repo: GitHub repository (format: username/repo)
- Dry run: Preview only without applying changes (true/false)
- keep-labels: keep existing labels (true/false)

## Example label JSON

```json
[
  {
    "name": "bug",
    "color": "d73a4a",
    "description": "Something isn't working"
  },
  {
    "name": "documentation",
    "color": "0075ca",
    "description": "Improvements or additions to documentation"
  },
  {
    "name": "feature",
    "color": "bfdadc",
    "description": "New feature"
  },
  {
    "name": "question",
    "color": "d876e3",
    "description": "Further information is requested"
  },
  {
    "name": "reference",
    "color": "137190",
    "description": "Good reference"
  },
  {
    "name": "schedule",
    "color": "1087cc",
    "description": "This issue relevant with project schedule."
  }
]
```

## Output format

The script outputs in the following format

- `update:labelname` - updated label.
- create:labelname` - newly created label
- delete:labelname` - deleted label
- `done` - operation completed

## Requirements

- Requires `curl` and `jq` installed
