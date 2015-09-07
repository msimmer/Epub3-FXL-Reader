
class Reader.Parser

  # http://davidwalsh.name/convert-xml-json
  xmlToJson: (xml) =>
    # Create the return object
    obj = {}
    if xml.nodeType == 1
      # element
      # do attributes
      if xml.attributes.length > 0
        obj['@attributes'] = {}
        j = 0
        while j < xml.attributes.length
          attribute = xml.attributes.item(j)
          obj['@attributes'][attribute.nodeName] = attribute.nodeValue
          j++
    else if xml.nodeType == 3
      # text
      obj = xml.nodeValue
    # do children
    if xml.hasChildNodes()
      i = 0
      while i < xml.childNodes.length
        item = xml.childNodes.item(i)
        nodeName = item.nodeName
        if typeof obj[nodeName] == 'undefined'
          obj[nodeName] = Reader.Parser::xmlToJson(item)
        else
          if typeof obj[nodeName].push == 'undefined'
            old = obj[nodeName]
            obj[nodeName] = []
            obj[nodeName].push old
          obj[nodeName].push Reader.Parser::xmlToJson(item)
        i++
    obj

  render: (file, type) =>
    switch type
      when 'xml'
        Reader.Parser::xmlToJson(file)

