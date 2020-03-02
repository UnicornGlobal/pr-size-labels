## Usage

Create a file named `labeler.yml` inside the `.gihub/workflows` directory and paste:

```yml
name: PR Size Labels

on:
  pull_request:

jobs:
  labels:
    runs-on: ubuntu-latest
    name: Label the PR size
    steps:
      - uses: UnicornGlobal/pr-size-labels@v1
        with:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Why the Fork?

So we could make the sizes and names of the labels to match our
existing internal setup.

## License

[MIT](LICENSE)
