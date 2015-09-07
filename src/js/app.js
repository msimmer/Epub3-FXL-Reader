var Reader,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Reader = (function() {
  Reader.debug = true;

  Reader.fsEnabled = false;

  Reader.prototype.log = function(args) {
    if (Reader.debug) {
      return window.console.log(args);
    }
  };

  Reader.prototype.updatenodeCount = function(nodes, currentSection, lastSection) {
    if (currentSection === lastSection) {
      this.log("\nAll sections successfully added to the DOM.");
      return $(document).trigger('reader.contentReady');
    }
  };

  Reader.prototype.navToggle = function() {
    $('#nav-toggle').toggleClass('nav-open');
    $('#nav-bar').toggleClass('nav-open');
    $(this.settings.outerContainer).toggleClass('nav-open');
    return $('#chapter-list').removeClass('open');
  };

  Reader.prototype.fsToggle = function() {
    var elem;
    elem = this.settings.docElem || document.documentElement;
    if (!this.fsEnabled) {
      this.fsEnabled = true;
      if (elem.requestFullscreen) {
        return elem.requestFullscreen();
      } else if (elem.mozRequestFullScreen) {
        return elem.mozRequestFullScreen();
      } else if (elem.webkitRequestFullscreen) {
        return elem.webkitRequestFullscreen();
      } else if (elem.msRequestFullscreen) {
        return elem.msRequestFullscreen();
      }
    } else {
      this.fsEnabled = false;
      if (document.exitFullscreen) {
        return document.exitFullscreen();
      } else if (document.mozCancelFullScreen) {
        return document.mozCancelFullScreen();
      } else if (document.webkitExitFullscreen) {
        return document.webkitExitFullscreen();
      }
    }
  };

  function Reader(options) {
    this.fsToggle = bind(this.fsToggle, this);
    this.navToggle = bind(this.navToggle, this);
    this.updatenodeCount = bind(this.updatenodeCount, this);
    this.log = bind(this.log, this);
    var defaults;
    defaults = {
      scope: 'reader',
      transitionSpeed: 250,
      contentUrl: null,
      spread: true,
      gutter: 0,
      hideOnResize: false,
      viewport: {
        width: 468,
        height: 680
      },
      outerContainer: 'main',
      innerContainer: '#content',
      nativeScroll: false,
      lazy: false,
      docElem: null,
      origin: {
        x: 0,
        y: 0
      }
    };
    this.settings = $.extend({}, defaults, options);
    this.utils = new Reader.Utils;
    this.parser = new Reader.Parser;
    this.http = new Reader.Http;
    this.aspect = new Reader.Aspect(this.settings);
    this.layout = new Reader.Layout(this.settings);
    this.navigate = new Reader.Navigate(this.settings);
    this.isResizing = false;
    this.isPositioned = false;
    this.nodeCount = 0;
    $('body').addClass('loading');
    $(document).on('reader.contentReady', (function(_this) {
      return function() {
        _this.log("\nReader content has been added to the DOM.");
        _this.nodeCount = $('*').length;
        return _this.aspect.setZoom(function() {
          return _this.aspect.adjustArticlePosition();
        });
      };
    })(this));
    $(document).on('reader.pagesFit', (function(_this) {
      return function() {
        return _this.log("\nSizing pages to `window`.");
      };
    })(this));
    $(document).on('reader.articlesPositioned', (function(_this) {
      return function(e, data) {
        _this.isPositioned = true;
        _this.log("\nAll articles successfully positioned.");
        _this.navigate.setIncrement(data.inc);
        _this.navigate.setTotalLen(data.len);
        _this.navigate.setCurrentIdx(0);
        return $('body').removeClass('loading');
      };
    })(this));
    this.layout.render();
    $(window).on({
      'resize': (function(_this) {
        return function() {
          var $body, resizeTimer;
          if (!_this.isPositioned) {
            return;
          }
          _this.isResizing = true;
          resizeTimer = null;
          $body = $('body');
          $body.addClass(_this.settings.scope + "-resize " + _this.settings.scope + "-resize-start");
          clearTimeout(resizeTimer);
          return _this.utils.waitForFinalEvent((function() {
            _this.isResizing = false;
            _this.aspect.setZoom();
            $body.removeClass(_this.settings.scope + "-resize-start");
            $body.addClass(_this.settings.scope + "-resize-end");
            setTimeout(function() {
              return $body.removeClass(_this.settings.scope + "-resize " + _this.settings.scope + "-resize-end");
            }, _this.settings.transitionSpeed);
          }), 400, 'some unique string');
        };
      })(this)
    });
    $(document).on('keydown', (function(_this) {
      return function(e) {
        switch (e.which) {
          case 39:
            return _this.navigate.goToNext();
          case 37:
            return _this.navigate.goToPrev();
          case 27:
            if ($(_this.settings.outerContainer).hasClass('nav-open')) {
              return _this.navToggle();
            }
        }
      };
    })(this));
    $('#nav-toggle').on('click', (function(_this) {
      return function(e) {
        e.preventDefault();
        return _this.navToggle();
      };
    })(this));
    $('.fs').on('click', (function(_this) {
      return function(e) {
        e.preventDefault();
        _this.fsToggle();
        return _this.navToggle();
      };
    })(this));
    $('#click-nav a').on('click', (function(_this) {
      return function(e) {
        var $this;
        e.preventDefault();
        $this = $(e.target);
        if ($this.hasClass('prev')) {
          return _this.navigate.goToPrev();
        } else if ($this.hasClass('next')) {
          return _this.navigate.goToNext();
        }
      };
    })(this));
    $('.go-to-pos').on('click', (function(_this) {
      return function(e) {
        e.preventDefault();
        _this.navToggle();
        return _this.navigate.goToIdx($(e.currentTarget).attr('data-nav-pos'));
      };
    })(this));
    $('#chapter-display').on('click', function(e) {
      e.preventDefault();
      return $('#chapter-list').toggleClass('open');
    });
  }

  return Reader;

})();

var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Reader.Aspect = (function() {
  function Aspect(settings) {
    this.settings = settings;
    this.setZoom = bind(this.setZoom, this);
    this.adjustArticlePosition = bind(this.adjustArticlePosition, this);
    this.getScale = bind(this.getScale, this);
    this.adjustMainContentTo = bind(this.adjustMainContentTo, this);
    this.windowDimensions = bind(this.windowDimensions, this);
    this.calcScale = bind(this.calcScale, this);
    this.originalY = bind(this.originalY, this);
    this.originalX = bind(this.originalX, this);
    this.windowY = bind(this.windowY, this);
    this.windowX = bind(this.windowX, this);
  }

  Aspect.sanitizeValues = function(val) {
    switch (typeof val) {
      case 'string':
        val = val.match(/\d/g) ? parseInt(val, 10) : $.trim(val);
    }
    return val;
  };

  Aspect.prototype.windowX = function() {
    return this.windowDimensions().x;
  };

  Aspect.prototype.windowY = function() {
    return this.windowDimensions().y;
  };

  Aspect.prototype.originalX = function() {
    return this.settings.viewport.width;
  };

  Aspect.prototype.originalY = function() {
    return this.settings.viewport.height;
  };

  Aspect.prototype.calcScale = function() {
    return {
      x: this.windowX() / this.originalX(),
      y: this.windowY() / this.originalY()
    };
  };

  Aspect.prototype.windowDimensions = function() {
    var b, d, e, w, x, y;
    w = window;
    d = document;
    e = d.documentElement;
    b = d.getElementsByTagName('body')[0];
    x = w.innerWidth || e.clientWidth || b.clientWidth;
    y = w.innerHeight || e.clientHeight || b.clientHeight;
    return {
      x: x,
      y: y
    };
  };

  Aspect.prototype.adjustMainContentTo = function(scale, cb) {
    return setTimeout((function(_this) {
      return function() {
        var CSSproperties, j, len1, props, scaleCSS, str, windowDims;
        scaleCSS = {};
        windowDims = _this.windowDimensions();
        CSSproperties = [Reader.Utils.prototype.prefix.css + "transform:scale(" + scale + ")", Reader.Utils.prototype.prefix.css + "transform-origin:" + _this.settings.origin.x + " " + _this.settings.origin.y + " 0", "height:" + (windowDims.y / scale) + "px", "width:" + (_this.originalX() * 2) + "px", "left:" + ((windowDims.x - ((_this.originalX() * 2) * scale)) / 2) + "px"];
        for (j = 0, len1 = CSSproperties.length; j < len1; j++) {
          str = CSSproperties[j];
          props = str.split(':');
          scaleCSS[props[0]] = props[1];
        }
        $('.backgrounds').css({
          width: (_this.originalX() * 2) * scale,
          left: (windowDims.x - ((_this.originalX() * 2) * scale)) / 2
        });
        $(_this.settings.outerContainer).css(scaleCSS);
        if (cb) {
          return cb();
        }
      };
    })(this), 0);
  };

  Aspect.prototype.getScale = function() {
    var fit, maxX, maxY, multiplier, windowDims;
    multiplier = this.calcScale();
    windowDims = this.windowDimensions();
    maxX = this.originalX() * multiplier.x;
    maxY = this.originalY() * multiplier.y;
    fit = maxY >= windowDims.y ? (Reader.prototype.log("  Scaling content: Y > X, choosing Y."), multiplier.y) : maxX > windowDims.x ? (Reader.prototype.log("  Scaling content: X > Y, choosing X."), multiplier.x) : (Reader.prototype.log("  Scaling content: defaulting to Y."), multiplier.y);
    return {
      fitX: multiplier.x,
      fitY: multiplier.y,
      fit: fit
    };
  };

  Aspect.prototype.adjustArticlePosition = function() {
    var $sections, len, pageHeight, pageWidth, wx, wy;
    $sections = $('article.spread section');
    pageWidth = this.getScale().fit * this.originalX() + this.settings.gutter;
    pageHeight = this.getScale().fit * this.originalY();
    len = $sections.length - 1;
    wx = this.originalX();
    wy = this.originalY();
    return $sections.each(function(i) {
      var bgPos, idx, obj, scaledIncrement, sectionPos, windowIncrement;
      idx = $(this).closest('article').attr('data-idx');
      scaledIncrement = i * wx;
      windowIncrement = i * pageWidth;
      sectionPos = (
        obj = {},
        obj[Reader.Utils.prototype.prefix.css + "transform"] = "translateX(" + scaledIncrement + "px)",
        obj.position = 'absolute',
        obj.width = wx,
        obj.height = wy,
        obj
      );
      bgPos = {
        left: windowIncrement,
        width: pageWidth,
        height: pageHeight
      };
      $(this).css(sectionPos).attr('data-page-offset', scaledIncrement);
      $('.background[data-background-for="' + idx + '"]').css(bgPos);
      if (i === len) {
        return $(document).trigger('reader.articlesPositioned', {
          inc: wx,
          len: scaledIncrement
        });
      }
    });
  };

  Aspect.prototype.setZoom = function(cb) {
    var scale;
    scale = this.getScale();
    return this.adjustMainContentTo(scale.fit, (function(_this) {
      return function() {
        $(document).trigger('reader.pagesFit');
        if (cb) {
          return cb();
        }
      };
    })(this));
  };

  return Aspect;

})();

Reader.Http = (function() {
  function Http() {}

  Http.prototype.get = function(url, dataType, cb) {
    return $.ajax({
      url: url,
      dataType: dataType,
      type: 'get',
      success: function(data) {
        if (cb && typeof cb === 'function') {
          return cb(data);
        }
        return data;
      },
      error: function(xhr) {
        return console.error(xhr.status + ": " + xhr.statusText);
      }
    });
  };

  Http.prototype.getSpine = function(data) {
    var content, entry, i, index, item, j, len, len1, manifest, manifestObj, readerSpine, spine;
    manifestObj = {};
    readerSpine = {};
    content = window.Reader.Parser.prototype.render(data, 'xml')["package"];
    manifest = content.manifest.item;
    spine = content.spine.itemref;
    for (i = 0, len = manifest.length; i < len; i++) {
      item = manifest[i];
      if (item['@attributes']['media-type'] === 'application/xhtml+xml') {
        manifestObj[item['@attributes'].id] = item['@attributes'].href;
      }
    }
    for (index = j = 0, len1 = spine.length; j < len1; index = ++j) {
      entry = spine[index];
      readerSpine[index] = {
        idref: entry['@attributes'].idref,
        props: entry['@attributes'].properties,
        href: manifestObj[entry['@attributes'].idref]
      };
    }
    return readerSpine;
  };

  return Http;

})();

var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Reader.Layout = (function(superClass) {
  extend(Layout, superClass);

  function Layout(settings, spine) {
    this.settings = settings;
    this.spine = spine != null ? spine : {};
    this.render = bind(this.render, this);
    this.updatePageCollection = bind(this.updatePageCollection, this);
    this.prevSectionsExits = bind(this.prevSectionsExits, this);
    this.generateArticle = bind(this.generateArticle, this);
    this.pageQueue = [];
    this.pageCollection = {};
  }

  Layout.prototype.generateArticle = function(idx, pageSpread, position, section) {
    return $('<article/>', {
      'class': 'spread',
      'data-idx': idx,
      'data-page-spread': pageSpread,
      'data-spine-position': position
    }).append($('<section/>', {
      html: section
    }));
  };

  Layout.prototype.appendToDom = function($spread, n, len) {
    var $background, $backgrounds;
    Reader.prototype.log("      Appending spread " + n + " to DOM.");
    $(this.settings.innerContainer).append($spread);
    if (!$('article.backgrounds').length) {
      $backgrounds = $('<article/>', {
        'class': 'backgrounds'
      }).appendTo('body');
    } else {
      $backgrounds = $('article.backgrounds');
    }
    $background = $('<section/>', {
      'class': 'background',
      'data-background-for': n
    });
    $backgrounds.append($background);
    return Reader.prototype.updatenodeCount($spread.find('*').length, n, len);
  };

  Layout.prototype.prevSectionsExits = function(idx) {
    return (function(_this) {
      return function() {
        var i, j, ref;
        for (i = j = 0, ref = idx - 1; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
          if (_this.pageCollection[i] === null) {
            Reader.prototype.log("    Can't render @pageCollection[" + idx + "] because @pageCollection[" + i + "] doesn't exist.");
            return false;
          }
        }
        return true;
      };
    })(this)();
  };

  Layout.prototype.updatePageCollection = function(k, len, section, layoutProps) {
    var $spread, index, item, j, kInt, len1, ref, results;
    kInt = ~~k;
    Reader.prototype.log("Attempting to render @pageCollection[" + kInt + "].");
    if (kInt === 0) {
      this.pageCollection[kInt] = true;
      Reader.prototype.log("  Laying out first section.");
      $spread = this.generateArticle(kInt, layoutProps, kInt, section);
      return this.appendToDom($spread, kInt, len);
    } else if (this.prevSectionsExits(kInt)) {
      Reader.prototype.log("  Laying out section " + kInt);
      this.pageCollection[kInt] = true;
      $spread = this.generateArticle(kInt, layoutProps, kInt, section);
      this.appendToDom($spread, kInt, len);
      ref = this.pageQueue;
      results = [];
      for (index = j = 0, len1 = ref.length; j < len1; index = ++j) {
        item = ref[index];
        if (this.pageQueue[index] && this.prevSectionsExits(index)) {
          this.pageCollection[index] = true;
          Reader.prototype.log("    @pageCollection[" + index + "] exists in the queue, laying out section " + index + ".");
          $spread = this.generateArticle(index, item.props, index, item.content);
          this.appendToDom($spread, index, len);
          delete this.pageQueue[index];
          results.push(Reader.prototype.log("      Deleting @pageCollection[" + index + "] from queue."));
        } else {
          results.push(void 0);
        }
      }
      return results;
    } else {
      if ($.inArray(kInt, this.pageQueue) < 0 || this.pageQueue[kInt] === 'undefined') {
        Reader.prototype.log("    Adding @pageQueue[" + kInt + "] to queue.");
        return this.pageQueue[kInt] = {
          content: section,
          props: layoutProps
        };
      }
    }
  };

  Layout.prototype.render = function() {
    return $.when(Reader.Http.prototype.get(this.settings.contentUrl, 'xml')).then((function(_this) {
      return function(data) {
        return _this.spine = Reader.Http.prototype.getSpine(data);
      };
    })(this)).then((function(_this) {
      return function(data) {
        var dataKeys, sectionLen;
        dataKeys = Object.keys(data);
        sectionLen = ~~dataKeys.length - 1;
        _this.pageCollection = dataKeys.reduce(function(o, v, i) {
          o[i] = null;
          return o;
        }, {});
        return $.each(data, function(k, v) {
          return Reader.Http.prototype.get(v.href, 'html', function(section) {
            return _this.updatePageCollection(k, sectionLen, section, v.props);
          });
        });
      };
    })(this));
  };

  return Layout;

})(Reader);

var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Reader.Navigate = (function(superClass) {
  extend(Navigate, superClass);

  function Navigate(settings, currentPos, currentIdx, currentSection, increment, elem1) {
    this.settings = settings;
    this.currentPos = currentPos;
    this.currentIdx = currentIdx;
    this.currentSection = currentSection;
    this.increment = increment;
    this.elem = elem1 != null ? elem1 : $(this.settings.innerContainer);
    this.goToEnd = bind(this.goToEnd, this);
    this.goToStart = bind(this.goToStart, this);
    this.goToIdx = bind(this.goToIdx, this);
    this.goToPrev = bind(this.goToPrev, this);
    this.goToNext = bind(this.goToNext, this);
    this.animateElem = bind(this.animateElem, this);
    this.getPrevPos = bind(this.getPrevPos, this);
    this.getNextPos = bind(this.getNextPos, this);
    this.setIncrement = bind(this.setIncrement, this);
    this.getIncrement = bind(this.getIncrement, this);
    this.getCurrentSection = bind(this.getCurrentSection, this);
    this.setCurrentSection = bind(this.setCurrentSection, this);
    this.getCurrentIdx = bind(this.getCurrentIdx, this);
    this.setCurrentIdx = bind(this.setCurrentIdx, this);
    this.getTotalLen = bind(this.getTotalLen, this);
    this.setTotalLen = bind(this.setTotalLen, this);
    this.getPosByIdx = bind(this.getPosByIdx, this);
  }

  Navigate.prototype.getPosByIdx = function(idx) {
    var elem, pos;
    elem = $("[data-idx=" + idx + "]");
    if (elem.length) {
      pos = ~~elem.find("[data-page-offset]").attr("data-page-offset");
      return -pos;
    }
  };

  Navigate.prototype.setTotalLen = function(len) {
    return this.totalLen = ~~len;
  };

  Navigate.prototype.getTotalLen = function() {
    return -this.totalLen;
  };

  Navigate.prototype.setCurrentIdx = function(idx) {
    return this.currentIdx = ~~idx;
  };

  Navigate.prototype.getCurrentIdx = function() {
    return this.currentIdx;
  };

  Navigate.prototype.setCurrentSection = function(section) {
    return this.currentSection = section;
  };

  Navigate.prototype.getCurrentSection = function() {
    return this.currentSection;
  };

  Navigate.prototype.getIncrement = function() {
    return this.increment;
  };

  Navigate.prototype.setIncrement = function(inc) {
    return this.increment = ~~inc;
  };

  Navigate.prototype.getNextPos = function() {
    var elem, nextIdx, pos;
    nextIdx = this.getCurrentIdx() + 1;
    elem = $("[data-idx=" + nextIdx + "]");
    if (elem.length) {
      pos = ~~elem.find("[data-page-offset]").attr("data-page-offset");
      return -pos;
    }
  };

  Navigate.prototype.getPrevPos = function() {
    var elem, pos, prevIdx;
    prevIdx = this.getCurrentIdx() - 1;
    elem = $("[data-idx=" + prevIdx + "]");
    if (elem.length) {
      pos = ~~elem.find("[data-page-offset]").attr("data-page-offset");
      return -pos;
    }
  };

  Navigate.prototype.animateElem = function(pos) {
    var obj;
    return this.elem.css((
      obj = {},
      obj[Reader.Utils.prototype.prefix.css + "transform"] = "translateX(" + pos + "px)",
      obj
    ));
  };

  Navigate.prototype.goToNext = function() {
    var desiredPos, idx, totalLength;
    desiredPos = this.getNextPos();
    totalLength = this.getTotalLen();
    if (desiredPos > totalLength) {
      this.animateElem(desiredPos);
      idx = this.getCurrentIdx();
      return this.setCurrentIdx(idx + 1);
    }
  };

  Navigate.prototype.goToPrev = function() {
    var desiredPos, idx;
    desiredPos = this.getPrevPos();
    if (desiredPos <= 0) {
      this.animateElem(desiredPos);
      idx = this.getCurrentIdx();
      return this.setCurrentIdx(idx - 1);
    }
  };

  Navigate.prototype.goToIdx = function(idx) {
    var pos;
    pos = this.getPosByIdx(idx);
    this.animateElem(pos);
    this.setCurrentIdx(idx);
    return this.setCurrentSection(idx);
  };

  Navigate.prototype.goToStart = function() {
    this.animateElem(0);
    this.setCurrentIdx(0);
    return this.setCurrentSection(0);
  };

  Navigate.prototype.goToEnd = function() {
    var dest, inc, totalLength;
    totalLength = this.getTotalLen();
    inc = this.getIncrement();
    dest = totalLength - inc;
    return this.animateElem(dest);
  };

  return Navigate;

})(Reader);

var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

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
          obj[nodeName] = Reader.Parser.prototype.xmlToJson(item);
        } else {
          if (typeof obj[nodeName].push === 'undefined') {
            old = obj[nodeName];
            obj[nodeName] = [];
            obj[nodeName].push(old);
          }
          obj[nodeName].push(Reader.Parser.prototype.xmlToJson(item));
        }
        i++;
      }
    }
    return obj;
  };

  Parser.prototype.render = function(file, type) {
    switch (type) {
      case 'xml':
        return Reader.Parser.prototype.xmlToJson(file);
    }
  };

  return Parser;

})();

Reader.Utils = (function() {
  function Utils() {}

  Utils.prototype.prefix = (function() {
    var dom, pre, styles;
    styles = window.getComputedStyle(document.documentElement, '');
    pre = (Array.prototype.slice.call(styles).join('').match(/-(moz|webkit|ms)-/) || styles.OLink === '' && ['', 'o'])[1];
    dom = 'WebKit|Moz|MS|O'.match(new RegExp('(' + pre + ')', 'i'))[1];
    return {
      dom: dom,
      lowercase: pre,
      css: '-' + pre + '-',
      js: pre[0].toUpperCase() + pre.substr(1)
    };
  })();

  Utils.prototype.waitForFinalEvent = (function() {
    var timers;
    timers = {};
    return function(callback, ms, uniqueId) {
      if (!uniqueId) {
        uniqueId = 'Don\'t call this twice without a uniqueId';
      }
      if (timers[uniqueId]) {
        clearTimeout(timers[uniqueId]);
      }
      timers[uniqueId] = setTimeout(callback, ms);
    };
  })();

  Utils.prototype.getComputedTranslateY = function(obj) {
    var mat, style, transform;
    if (!window.getComputedStyle) {
      return;
    }
    style = getComputedStyle(obj);
    transform = style.transform || style.webkitTransform || style.mozTransform;
    mat = transform.match(/^matrix3d\((.+)\)$/);
    if (mat) {
      return parseFloat(mat[1].split(', ')[13]);
    }
    mat = transform.match(/^matrix\((.+)\)$/);
    if (mat) {
      return parseFloat(mat[1].split(', ')[5]);
    } else {
      return 0;
    }
  };

  Utils.prototype.getComputedTranslateX = function(obj) {
    var mat, style, transform;
    if (!window.getComputedStyle) {
      return;
    }
    style = getComputedStyle(obj);
    transform = style.transform || style.webkitTransform || style.mozTransform;
    mat = transform.match(/^matrix3d\((.+)\)$/);
    if (mat) {
      return parseFloat(mat[1].split(', ')[12]);
    }
    mat = transform.match(/^matrix\((.+)\)$/);
    if (mat) {
      return parseFloat(mat[1].split(', ')[4]);
    } else {
      return 0;
    }
  };

  return Utils;

})();
