window.Reader ?= {}
class window.Reader.App
  constructor: (options)->

    defaults =
      contentUrl:null
      spread:true
      gutter:0
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





    $ =>

      $.when(@layout.render())
      .then () =>
        $(document).trigger('reader.loaded')


      # DOM Events
      #

      $(document).on('reader.loaded', =>
        @aspect.setZoom()
      )

      $(window).on
        'resize': =>
          @isResizing = true
          @utils.waitForFinalEvent (=>
            @isResizing = false
            @aspect.setZoom()
            return
          ), 500, 'some unique string'



