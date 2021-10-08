## Data Url encoding

from std/base64 import encode
from std/uri import encodeUrl
from std/strformat import fmt
from std/os import splitFile

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
    var prop = fmt";{key}"
    if val.len > 0:
      prop.add fmt"={val}"
    if key == "base64":
      toBase64 = true
    props.add prop
  if toBase64:
    data = base64.encode self.data
  else:
    data = encodeUrl self.data
  result = fmt"data:{self.mime}{props},{data}"

const maxDataSize = 65529

func initDataUrl*(data: string; mime = "text/plain"; base64 = true;
                  props = newSeq[DataUrlProp]()): DataUrl =
  ## Creates new DataUrl
  if '/' notin mime:
    raise newException(ValueError, "Invalid mime type")
  if data.len > maxDataSize:
    raise newException(ValueError, "Data is too large")
  result.data = data
  result.mime = mime
  if base64:
    result.props.add ("base64", "")
  for prop in props:
    result.props.add prop

const mimeTypes = {"aac": "audio/aac", "abw": "application/x-abiword",
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
    "jar": "application/java-archive", "jpeg": "image/jpeg",
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
    "7z": "application/x-7z-compressed"}
func getMime*(filename: string): string =
  ## Infer the filename mime type
  let file = filename.splitFile
  result = "text/plain"
  if file.ext.len > 0:
    let fileExt = file.ext[1..^1]
    for (ext, mime) in mimeTypes:
      if ext == fileExt:
        result = mime

when isMainModule:
  from std/terminal import styledEcho, fgGreen, styleDim, resetStyle,
                           styledWriteLine, fgRed
  # from std/httpclient import newHttpClient, get, close, contentType, body
  import std/httpclient
  from std/strutils import split, repeat
  from std/os import fileExists
  from std/terminal import terminalWidth

  const remoteProtocols = ["http", "https", "ftp", "ftps"]
  func isRemote(url: string): bool =
    result = false
    let parts = url.split ":"
    if parts.len > 0:
      if parts[0] in remoteProtocols:
        result = true

  proc main(urls: seq[string]; mime = ""; base64 = true) =
    ## Data Url
    if urls.len < 1:
      styledEcho fgRed, "No url provided"
      quit 1
    for i, url in urls:
      var
        mimeType = "mime"
        data = ""
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
            mimeType = getMime url
          data = readFile url

      if data.len > 0:
        let dataUrl = initDataUrl(
          data = data,
          base64 = base64,
          mime = mimeType
        )
        echo dataUrl

      if i < urls.len - 1:
        styledEcho "\n", styleDim, "-".repeat terminalWidth(), "\n"

  import pkg/cligen
  dispatch main, help = {
    "urls": "Content urls, can be local or remote",
    "mime": "Force the mime type; Default is auto",
  }
