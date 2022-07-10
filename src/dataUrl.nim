## Data Url encoding

from std/base64 import encode
from std/uri import encodeUrl
from std/strformat import `&`

type
  DataUrl* = object
    mime*: string
    props*: seq[DataUrlProp]
    data*: string
  DataUrlProp* = tuple
    key, value: string

using
  self: DataUrl

proc `$`*(self): string =
  ## Stringify
  var
    data = ""
    props = ""
    toBase64 = false
  for (key, val) in self.props:
    var prop = &";{key}"
    if val.len > 0:
      prop.add &"={val}"
    if key == "base64":
      toBase64 = true
    props.add prop
  if toBase64:
    data = base64.encode self.data
  else:
    data = encodeUrl self.data
  result = &"data:{self.mime}{props},{data}"

const maxDataSize = 65529
  ## Max size of data url (https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/Data_URIs#common_problems)

func initDataUrl*(data: string; mime = "text/plain"; base64 = true;
                  props = newSeq[DataUrlProp](); verifySize = true): DataUrl =
  ## Creates new DataUrl
  if '/' notin mime:
    raise newException(ValueError, "Invalid mime type")
  if verifySize and data.len > maxDataSize:
    raise newException(ValueError, "Data is too large")
  result.data = data
  result.mime = mime
  if base64:
    result.props.add ("base64", "")
  for prop in props:
    result.props.add prop

const mimeTypes = {
  # https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Common_types
  "aac": "audio/aac", "abw": "application/x-abiword",
  "arc": "application/x-freearc", "avi": "video/x-msvideo",
  "azw": "application/vnd.amazon.ebook", "bin": "application/octet-stream",
  "bmp": "image/bmp", "bz": "application/x-bzip",
  "bz2": "application/x-bzip2", "cda": "application/x-cdf",
  "csh": "application/x-csh", "css": "text/css", "csv": "text/csv",
  "doc": "application/msword",
  "docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
  "eot": "application/vnd.ms-fontobject", "epub": "application/epub+zip",
  "gz": "application/gzip", "gif": "image/gif", "htm": "text/html",
  "ico": "image/vnd.microsoft.icon", "ics": "text/calendar",
  "jar": "application/java-archive", "jpeg": "image/jpeg", "jpg": "image/jpeg",
  "js": "text/javascript", "json": "application/json",
  "jsonld": "application/ld+json", "mid": "audio/midi",
  "mjs": "text/javascript", "mp3": "audio/mpeg", "mp4": "video/mp4",
  "mpeg": "video/mpeg", "mpkg": "application/vnd.apple.installer+xml",
  "odp": "application/vnd.oasis.opendocument.presentation",
  "ods": "application/vnd.oasis.opendocument.spreadsheet",
  "odt": "application/vnd.oasis.opendocument.text", "oga": "audio/ogg",
  "ogv": "video/ogg", "ogx": "application/ogg", "opus": "audio/opus",
  "otf": "font/otf", "png": "image/png", "pdf": "application/pdf",
  "php": "application/x-httpd-php", "ppt": "application/vnd.ms-powerpoint",
  "pptx": "application/vnd.openxmlformats-officedocument.presentationml.presentation",
  "rar": "application/vnd.rar", "rtf": "application/rtf",
  "sh": "application/x-sh", "svg": "image/svg+xml",
  "swf": "application/x-shockwave-flash", "tar": "application/x-tar",
  "tif": "image/tiff", "ts": "video/mp2t", "ttf": "font/ttf",
  "txt": "text/plain", "vsd": "application/vnd.visio", "wav": "audio/wav",
  "weba": "audio/webm", "webm": "video/webm", "webp": "image/webp",
  "woff": "font/woff", "woff2": "font/woff2",
  "xhtml": "application/xhtml+xml", "xls": "application/vnd.ms-excel",
  "xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
  "xml": "application/xml", "xul": "application/vnd.mozilla.xul+xml",
  "zip": "application/zip", "3gp": "video/3gpp", "3g2": "video/3gpp2",
  "7z": "application/x-7z-compressed",
  # Extra added
  "html": "text/html"}
func getMime*(rawExt: string): string =
  ## Infer the filename mime type be given ext
  ##
  ## ext can have dot (`.`) in start
  result = "text/plain"
  if rawExt.len > 0:
    var fileExt = rawExt
    if rawExt[0] == '.':
      fileExt = rawExt[1..^1]
    for (ext, mime) in mimeTypes:
      if ext == fileExt:
        result = mime

when isMainModule:
  from std/terminal import styledEcho, fgGreen, styleDim, resetStyle,
                           styledWriteLine, fgRed, terminalWidth
  import std/httpclient
  from std/strutils import split, repeat
  from std/os import fileExists, expandFilename, `/`, createDir, dirExists,
                     splitFile, removeFile, getTempDir

  const remoteProtocols = ["http", "https", "ftp", "ftps"]
  func isRemote(url: string): bool =
    result = false
    let parts = url.split ":"
    if parts.len > 0:
      if parts[0] in remoteProtocols:
        result = true

  const InvalidFilename = {'/','\\',':','*','?','"','<','>'}
  proc secureName*(str: string): string =
    for ch in str:
      if ch notin InvalidFilename:
        result.add ch

  let tempStdinFile = getTempDir() / ".stdin"

  proc main(urls: seq[string]; mime = ""; base64 = true; outDir = "";
            outFile = ""; clean = false; anySize = false) =
    ## Data Url
    var allUrls = urls
    if urls.len < 1:
      var
        stdinput = ""
        line = ""
      while stdin.readLine line:
        stdinput.add &"{line}\l"
      if stdinput.len > 0:
        writeFile tempStdinFile, stdinput
        allUrls.add tempStdinFile
      else:
        styledEcho fgRed, "No url provided"
        quit 1
    if outFile.len > 0:
      writeFile outFile, "source\tdata url\n"
    for i, url in allUrls:
      var
        mimeType = mime
        data = ""
      if not clean:
        styledEcho fgGreen, styleDim, url
      if url.isRemote:
        let
          client = newHttpClient()
          resp =  client.get url
        if mime.len < 1:
          mimeType = resp.contentType
        data = resp.body
      else:
        if fileExists url:
          if mime.len < 1:
            mimeType = getMime url.splitFile.ext
          data = readFile url

      if data.len > 0:
        let
          dataUrl = initDataUrl(
            data = data,
            base64 = base64,
            mime = mimeType,
            verifySize = not anySize
          )
          res = $dataUrl
        if outFile.len > 0 or outDir.len > 0:
          proc toOut(data, dir, ugetMimerl: string; isDir: bool) =
            var
              outFile = dir
              content = data
            if isDir:
              if not dirExists dir:
                createDir dir
              let parts = splitFile url
              outFile = dir / secureName parts.name & parts.ext
              styledEcho styleDim, "Saved this data url in ", resetStyle, outFile
            else:
              styledEcho styleDim, "Saved all data urls in ", resetStyle, outFile
              content = &"{url}\t{data}"

            let f = open(outFile, fmAppend)
            f.writeLine content
            f.close()

          if outFile.len > 0:
            res.toOut outFile, url, false
          if outDir.len > 0:
            res.toOut outDir, url, true
        else:
          echo res
      if not clean:
        if i < urls.len - 1:
          styledEcho "\n", styleDim, "-".repeat terminalWidth(), "\n"
    if fileExists tempStdinFile:
      removeFile tempStdinFile

  import pkg/cligen
  dispatch main, help = {
    "urls": "Content urls (can be local or remote)",
    "mime": "Force the mime type; Default is auto",
    "outFile": "Saves the output to one file (tsv)",
    "outDir": "Saves the output files in one folder",
    "base64": "Disable base64 encoding",
    "clean": "Easy to integrate output",
    "anySize": "Disable max data url size (" & $maxDataSize & ") verification",
  }, short = {
    "outFile": 'O',
    "outDir": 'o'
  }
