// Generated by CoffeeScript 1.9.3
var App;

App = (function() {
  function App(options) {
    var defaults, settings;
    defaults = {
      contentUrl: null,
      spread: true,
      gutter: 0,
      viewport: {
        width: 468,
        height: 680
      },
      container: 'main',
      lazy: false,
      origin: {
        x: 0,
        y: 0
      }
    };
    settings = $.extend({}, defaults, options);
    this.utils = new window.Reader.Utils;
    this.parser = new window.Reader.Parser;
    this.http = new window.Reader.Http;
    this.aspect = new window.Reader.Aspect(settings);
    this.layout = new window.Reader.Layout(settings);
    this.isResizing = false;
    this.nodeCt = 0;
    this.layout.render();
    $(document).on('reader.contentReady', (function(_this) {
      return function() {
        console.log("Elements added to DOM.");
        _this.nodeCt = $('*').length;
        return _this.aspect.setZoom(function() {
          return _this.aspect.adjustArticlePosition();
        });
      };
    })(this));
    $(document).on('reader.pagesFit', (function(_this) {
      return function() {
        return console.log('Pages adjust to `window`.');
      };
    })(this));
    $(document).on('reader.articlesPositioned', (function(_this) {
      return function() {
        return console.log('Pages adjusted for width.');
      };
    })(this));
  }

  App.updateNodeCt = function(nodes, currentSection, lastSection) {
    if (currentSection === lastSection) {
      return $(document).trigger('reader.contentReady');
    }
  };

  return App;

})();

if (window.Reader == null) {
  window.Reader = {};
}

window.Reader.App = App;
