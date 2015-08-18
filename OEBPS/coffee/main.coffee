Reader = window.Reader ?= {}

class window.Reader

  log: (args) =>
    # window.console.log args

  updatenodeCount: (nodes, currentSection, lastSection) =>
    if currentSection is lastSection
      @log "\nAll sections successfully added to the DOM."
      $(document).trigger('reader.contentReady')


  constructor: (options)->

    defaults =
      scope:'reader'
      transitionSpeed:250
      contentUrl:null
      debug:false
      spread:true
      gutter:0
      hideOnResize:false
      viewport:
        width:468
        height:680
      outerContainer:'main'
      innerContainer:'#content'
      nativeScroll:false
      lazy:false
      origin:
        x:0
        y:0


    @settings = $.extend({}, defaults, options)
    @utils    = new Reader.Utils
    @parser   = new Reader.Parser
    @http     = new Reader.Http
    @aspect   = new Reader.Aspect(@settings)
    @layout   = new Reader.Layout(@settings)
    @navigate = new Reader.Navigate(@settings)

    console.log @navigate

    @isResizing   = false
    @isPositioned = false
    @nodeCount    = 0

    $(document).on('reader.contentReady', =>
      @log "\nReader content has been added to the DOM."
      @nodeCount = $('*').length
      @aspect.setZoom(=>
        @aspect.adjustArticlePosition()
      )
    )

    $(document).on('reader.pagesFit', =>
      @log "\nSizing pages to `window`."
    )

    $(document).on('reader.articlesPositioned', =>
      @isPositioned = true
      @log "\nAll articles successfully positioned."
    )


    # Bootstrap
    #
    @layout.render()



    # DOM Events
    #
    $(window).on
      'resize': =>

        if not @isPositioned then return

        @isResizing = true
        resizeTimer = null
        $body       = $('body')

        $body.addClass("#{@settings.scope}-resize #{@settings.scope}-resize-start")
        clearTimeout resizeTimer

        @utils.waitForFinalEvent (=>
          @isResizing = false
          @aspect.setZoom()
          $body.removeClass("#{@settings.scope}-resize-start")
          $body.addClass("#{@settings.scope}-resize-end")
          setTimeout(=>
            $body.removeClass("#{@settings.scope}-resize #{@settings.scope}-resize-end")
          , @settings.transitionSpeed)
          return
        ), 500, 'some unique string'



    $(document).on('click', (e) =>
      console.log 'click'
      @navigate.goToStart()
    )
