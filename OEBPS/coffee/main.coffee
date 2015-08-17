class App
  constructor: (options)->

    defaults =
      contentUrl:null
      spread:true
<<<<<<< HEAD
      gutter:15
=======
      gutter:0
>>>>>>> dd854c4ee057fb2546a520b2d238d7e786243655
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
      console.log "Elements added to DOM."
      @nodeCt = $('*').length
      @aspect.setZoom(=>
        @aspect.adjustArticlePosition()
      )
    )

    $(document).on('reader.pagesFit', =>
      console.log 'Pages adjust to `window`.'
    )

    $(document).on('reader.articlesPositioned', =>
      console.log 'Pages adjusted for width.'
    )



  @updateNodeCt: (nodes, currentSection, lastSection) ->
    if currentSection is lastSection
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
