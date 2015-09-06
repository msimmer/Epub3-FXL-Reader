// Generated by CoffeeScript 1.9.3
(function() {
  var Reader,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Reader = window.Reader != null ? window.Reader : window.Reader = {};

  Reader.Parser = (function() {
    function Parser() {
      this.render = bind(this.render, this);
      this.xmlToJson = bind(this.xmlToJson, this);
    }

    Parser.prototype.xmlToJson = function(xml) {
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
            obj[nodeName] = window.Reader.Parser.prototype.xmlToJson(item);
          } else {
            if (typeof obj[nodeName].push === 'undefined') {
              old = obj[nodeName];
              obj[nodeName] = [];
              obj[nodeName].push(old);
            }
            obj[nodeName].push(window.Reader.Parser.prototype.xmlToJson(item));
          }
          i++;
        }
      }
      return obj;
    };

    Parser.prototype.render = function(file, type) {
      switch (type) {
        case 'xml':
          return window.Reader.Parser.prototype.xmlToJson(file);
      }
    };

    return Parser;

  })();

}).call(this);
