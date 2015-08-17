// Generated by CoffeeScript 1.9.3
(function() {
  if (window.Reader == null) {
    window.Reader = {};
  }

  window.Reader.Layout = (function() {
    function Layout(settings, spine) {
      this.settings = settings;
      this.spine = spine != null ? spine : {};
    }

    Layout.prototype.render = function() {
      return $.when(Reader.Http.prototype.get(this.settings.contentUrl, 'xml')).then((function(_this) {
        return function(data) {
          return _this.spine = Reader.Http.prototype.getSpine(data);
        };
      })(this)).then((function(_this) {
        return function(data) {
          var $spread, k, results, sectionPos, spreadCount, v;
          spreadCount = 0;
          sectionPos = 'left';
          $spread = null;
          results = [];
          for (k in data) {
            v = data[k];
            results.push(Reader.Http.prototype.get(v.href, 'html', function(section) {
              switch (sectionPos) {
                case 'left':
                  console.log('append page left');
                  $spread = $('<article/>', {
                    'class': 'spread',
                    'data-idx': spreadCount
                  }).append(section);
                  break;
                case 'right':
                  console.log('append page right');
                  if ($spread) {
                    $spread.append(section);
                  } else {
                    $spread = $('<article/>', {
                      'class': 'spread',
                      'data-idx': spreadCount
                    }).append(section);
                  }
              }
              $(_this.settings.container).append($spread);
              ++spreadCount;
              return sectionPos = sectionPos === 'left' ? 'right' : 'left';
            }));
          }
          return results;
        };
      })(this));
    };

    return Layout;

  })();

}).call(this);