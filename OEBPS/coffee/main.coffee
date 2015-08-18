class App
  constructor: (options)->

    defaults =
      contentUrl:null
      spread:true
      gutter:15
      viewport:
        width:468
        height:680
      container:'main'
      lazy:false
      origin:
        x:0
        y:0


    settings = $.extend({}, defaults, options)


    @utils  = new window.Reader.Utils
    @parser = new window.Reader.Parser
    @http   = new window.Reader.Http
    @aspect = new window.Reader.Aspect(settings)
    @layout = new window.Reader.Layout(settings)

    @isResizing = false
    @nodeCt     = 0


    # Bootstrap
    @layout.render()

    $(document).on('reader.contentReady', =>
      @nodeCt = $('*').length
      @aspect.setZoom(=>
        @aspect.adjustArticlePosition()
      )
    )

    $(document).on('reader.pagesFit', =>
      console.log "\nSizing pages to `window`."
    )

    $(document).on('reader.articlesPositioned', =>
      console.log "\nPositioning articles."
    )



  @updateNodeCt: (nodes, currentSection, lastSection) ->
    if currentSection is lastSection
      console.log "\nAll sections successfully added to the DOM."
      $(document).trigger('reader.contentReady')







    # $ =>



    #   # DOM Events
    #   #



    #   $(window).on
    #     'resize': =>
    #       @isResizing = true
    #       @utils.waitForFinalEvent (=>
    #         @isResizing = false
    #         @aspect.setZoom()
    #         return
    #       ), 500, 'some unique string'



window.Reader ?= {}
window.Reader.App = App
