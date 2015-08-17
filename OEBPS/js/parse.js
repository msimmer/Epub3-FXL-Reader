// Generated by CoffeeScript 1.9.3
(function() {
  if (window.Reader == null) {
    window.Reader = {};
  }

  window.Reader.Parse = (function() {
    function Parse() {}

    Parse.prototype.xmlToJson = function(xml) {
      var attribute, i, item, j, nodeName, obj, old;
      obj = {};
      if (xml.nodeType === 1) {
        if (xml.attributes.length > 0) {
          obj['@attributes'] = {};
          j = 0;
          while (j < xml.attributes.length) {
            attribute = xml.attributes.item(j);
            obj['@attributes'][attribute.nodeName] = attribute.nodeValue;
            j++;
          }
        }
      } else if (xml.nodeType === 3) {
        obj = xml.nodeValue;
      }
      if (xml.hasChildNodes()) {
        i = 0;
        while (i < xml.childNodes.length) {
          item = xml.childNodes.item(i);
          nodeName = item.nodeName;
          if (typeof obj[nodeName] === 'undefined') {
            obj[nodeName] = this.xmlToJson(item);
          } else {
            if (typeof obj[nodeName].push === 'undefined') {
              old = obj[nodeName];
              obj[nodeName] = [];
              obj[nodeName].push(old);
            }
            obj[nodeName].push(this.xmlToJson(item));
          }
          i++;
        }
      }
      return obj;
    };

    Parse.prototype.render = function(file, type) {
      switch (type) {
        case 'xml':
          return this.xmlToJson(file);
      }
    };

    return Parse;

  })();

}).call(this);