# img2url

Converts locally or remote images in data url content

## Features

- Work with local paths and remote urls seamless
- Save all results in a `TSV` file using `-O` option
- Can be integrated with any project
<!-- - Lib works with JS (Not tested) -->

## Installation

### Requirements
- [Nim](https://nim-lang.org/)
- Git

```bash
$ nimble install https://github.com/thisago/downpodia
```

## Usage
```bash
$ dataUrl image.png https://example.com/image.png
# Output each image in a file
$ dataUrl image.png https://example.com/image.png -o .
# Output all images in single file (tsv)
$ dataUrl image.png https://example.com/image.png -O images.txt
```

## Help
```bash
$ dataUrl --help
Usage:
  main [optional-params] Content urls (can be local or remote)
Data Url
Options:
  -h, --help                     print this cligen-erated help
  --help-syntax                  advanced: prepend,plurals,..
  -m=, --mime=     string  ""    Force the mime type; Default is auto
  -b, --base64     bool    true  set base64
  -o=, --outDir=   string  ""    Saves the output files in one folder
  -O=, --outFile=  string  ""    Saves the output to one file (tsv)
```

## TODO

- [ ] Add tests

## License
GPL-3
