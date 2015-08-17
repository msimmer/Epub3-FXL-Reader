// Generated by CoffeeScript 1.9.3
var Layout;

Layout = (function() {
  var app;

  function Layout(settings, spine) {
    this.settings = settings;
    this.spine = spine != null ? spine : {};
  }

  app = window.Reader;

  Layout.prototype.render = function() {
    var nodeCt;
    nodeCt = 0;
    return $.when(app.Http.prototype.get(this.settings.contentUrl, 'xml')).then((function(_this) {
      return function(data) {
        return _this.spine = app.Http.prototype.getSpine(data);
      };
    })(this)).then((function(_this) {
      return function(data) {
        var $spread, k, pageCount, results, sectionPos, spreadCount, v;
        spreadCount = 0;
        pageCount = 0;
        sectionPos = 'left';
        $spread = null;
        results = [];
        for (k in data) {
          v = data[k];
          results.push(app.Http.prototype.get(v.href, 'html', function(section) {
            switch (sectionPos) {
              case 'left':
                $spread = $('<article/>', {
                  'class': 'spread',
                  'data-idx': spreadCount
                }).append($('<section/>', {
                  html: section
                }));
                break;
              case 'right':
                if ($spread) {
                  $spread.append($('<section/>', {
                    html: section
                  }));
                } else {
                  console.warn("Appending a right-hand section at position " + spreadCount + " to an empty article.");
                  $spread = $('<article/>', {
                    'class': 'spread',
                    'data-idx': spreadCount
                  }).append($('<section/>', {
                    html: section
                  }));
                }
            }
            $(_this.settings.container).append($spread);
            ++spreadCount;
            ++pageCount;
            sectionPos = sectionPos === 'left' ? 'right' : 'left';
            return app.App.updateNodeCt($(section).find('*').length, pageCount, Object.keys(data).length);
          }));
        }
        return results;
      };
    })(this));
  };

  return Layout;

})();

if (window.Reader == null) {
  window.Reader = {};
}

window.Reader.Layout = Layout;
