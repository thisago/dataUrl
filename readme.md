# dataUrl

Easily create data urls! CLI included

**Lib usage**
```nim
import dataUrl
echo initDataUrl(
  data = "<h1>Hello World</h1>",
  mime = "text/html"
)
```

## Installation

### Requirements
- [Nim](https://nim-lang.org/)
- Git

```bash
$ nimble install https://github.com/thisago/dataUrl
```

---

## CLI

Converts locally or remote images in data url content

### Features

- Work with local paths and remote urls seamless
- Save all results in a `TSV` file using `-O` option
- Can be integrated with any project
- Lib works with JS (not CLI)

### Usage
```bash
$ dataUrl image.png https://example.com/image.png
# Output each image in a file
$ dataUrl image.png https://example.com/image.png -o .
# Output all images in single file (tsv)
$ dataUrl image.png https://example.com/image.png -O images.txt
# inject with pipe
cat page.html | dataUrl -m text/html
```

### Help
```bash
$ dataUrl --help
Usage:
  main [optional-params] Content urls (can be local or remote)
Data Url
Options:
  -h, --help                      print this cligen-erated help
  --help-syntax                   advanced: prepend,plurals,..
  -m=, --mime=     string  ""     Force the mime type; Default is auto
  -b, --base64     bool    true   Disable base64 encoding
  -o=, --outDir=   string  ""     Saves the output files in one folder
  -O=, --outFile=  string  ""     Saves the output to one file (tsv)
  -c, --clean      bool    false  Easy to integrate output
  -a, --anySize    bool    false  Disable max data url size (65529) verification
```

---

## TODO

- [ ] Add tests
- [ ] Add `docs` to GH Pages
- [ ] Add js examples
- [ ] Add to `nim-lang/packages`

## License
GPL-3
