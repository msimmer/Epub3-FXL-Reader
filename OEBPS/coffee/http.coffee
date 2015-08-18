Reader = window.Reader ?= {}

class Reader.Http
  constructor: =>

  get: (url, dataType, cb) ->
    return $.ajax(
      url:url
      dataType:dataType
      type:'get'
      success:(data) ->
        if cb and typeof cb is 'function'
          return cb(data)
        return data
      error:(xhr) ->
        console.error "#{xhr.status}: #{xhr.statusText}"
    )

  getSpine: (data) ->

    manifestObj = {}
    readerSpine = {}
    content     = window.Reader.Parser::render(data, 'xml').package
    manifest    = content.manifest.item
    spine       = content.spine.itemref


    for item in manifest
      if item['@attributes']['media-type'] is 'application/xhtml+xml'
        manifestObj[item['@attributes'].id] = item['@attributes'].href

    for entry, index in spine
      readerSpine[index] =
        idref      :entry['@attributes'].idref
        properties :entry['@attributes'].properties
        properties :entry['@attributes'].properties
        href       :manifestObj[entry['@attributes'].idref]


    return readerSpine
