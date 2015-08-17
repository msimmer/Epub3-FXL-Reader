window.Reader ?= {}
class window.Reader.App
  constructor: (options)->

    defaults =
      contentUrl:null
      spread:true
      viewport:
        width:468
        height:680
      container:'main'
      lazy:false
      origin:
        x:0
        y:0


    settings = $.extend({}, defaults, options)


    @isResizing = false

    @utils  = new window.Reader.Utils
    @parse  = new window.Reader.Parse
    @aspect = new window.Reader.Aspect(settings)
    @layout = new window.Reader.Layout(settings)
    @http   = new window.Reader.Http


    # get content.opf
    # extract spine from opf
    # get each page (options.lazy limit to n pages)
    # add pages to dom
    # layout pages for spreads
    # resize everything
    # init page turns

    @layout.render()



    $ =>

      # DOM Ready
      #
      # TODO: move to `reader.ready` event
      #

      # @aspect.getViewportValues()
      @aspect.setZoom()


      # DOM Events
      #

      $(window).on
        'resize': =>
          @isResizing = true
          @utils.waitForFinalEvent (=>
            @isResizing = false
            @aspect.setZoom()
            return
          ), 500, 'some unique string'



