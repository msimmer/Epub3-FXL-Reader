class Reader
  constructor: (@utils, @aspect, @http)->

    console.log 'Main'


    @settings =
      spread:true
      zoom:1
      viewport:null
      resize:false
      container:'#LB-Buch-Content-Def-1'
      origin:
        x:0
        y:0


    @utils  = new Utils
    @aspect = new Aspect(@settings, @utils)
    @http   = new Http(@settings, @utils)

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








if typeof module != "undefined" && module.exports
  exports.Reader = Reader
else
  window.Reader = Reader


