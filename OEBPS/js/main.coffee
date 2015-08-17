window.Reader ?= {}
class window.Reader.App
  constructor: (options)->

    console.log 'Main'


    defaults =
      contentUrl:null
      spread:true
      zoom:1
      viewport:null
      resize:false
      container:'#LB-Buch-Content-Def-1'
      origin:
        x:0
        y:0


    settings = $.extend({}, defaults, options)


    @utils  = new window.Reader.Utils
    @parse  = new window.Reader.Parse
    @layout = new window.Reader.Layout
    @aspect = new window.Reader.Aspect(settings)
    @http   = new window.Reader.Http

    $ =>

      # DOM Ready
      #
      # TODO: move to `reader.ready` event
      #

      @aspect.getViewportValues()
      @aspect.setZoom()


      # DOM Events
      #

      $(window).on
        'resize': =>
          @settings.resize = true
          @utils.waitForFinalEvent (=>
            @settings.resize = false
            @aspect.setZoom()
            return
          ), 500, 'some unique string'



