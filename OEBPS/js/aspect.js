// Generated by CoffeeScript 1.9.3
(function() {
  if (window.Reader == null) {
    window.Reader = {};
  }

  window.Reader.Aspect = (function() {
    function Aspect(settings) {
      this.settings = settings;
    }

    Aspect.prototype.sanitizeValues = function(val) {
      switch (typeof val) {
        case 'string':
          val = val.match(/\d/g) ? parseInt(val, 10) : $.trim(val);
      }
      return val;
    };

    Aspect.prototype.getViewportValues = function() {
      var arr, obj;
      obj = {};
      arr = $('meta[name=viewport]').attr('content').split(',');
      arr.map((function(_this) {
        return function(val) {
          var attr, prop, vals;
          vals = val.split('=');
          prop = _this.sanitizeValues(vals[0]);
          attr = _this.sanitizeValues(vals[1]);
          return obj[prop] = attr;
        };
      })(this));
      this.settings.viewport = obj;
      return obj;
    };

    Aspect.prototype.windowX = function() {
      return window.innerWidth;
    };

    Aspect.prototype.windowY = function() {
      return window.innerHeight;
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

    Aspect.prototype.adjustMainContentTo = function(scale) {
      var CSSproperties, i, len, props, scaleCSS, str;
      scaleCSS = {};
      CSSproperties = [Reader.Utils.prototype.prefix.css + "transform:scale(" + scale + ")", Reader.Utils.prototype.prefix.css + "transform-origin:" + this.settings.origin.x + " " + this.settings.origin.y];
      for (i = 0, len = CSSproperties.length; i < len; i++) {
        str = CSSproperties[i];
        props = str.split(':');
        scaleCSS[props[0]] = props[1];
      }
      return $(this.settings.container).css(scaleCSS);
    };

    Aspect.prototype.adjustSectionContentTo = function(maxPageWidth) {};

    Aspect.prototype.setZoom = function() {
      var fit, fitX, fitY, multiplier;
      multiplier = this.calcScale();
      fitX = this.originalX() * multiplier.x;
      fitY = this.originalY() * multiplier.y;
      fit = fitY < fitX ? multiplier.y : multiplier.x;
      return this.adjustMainContentTo(fit);
    };

    return Aspect;

  })();

}).call(this);
