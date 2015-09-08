# Fixed Layout Epub Reader

A browser-based Epub 3.0 reader.

## Installation

Clone the repo and install dependencices with

```
npm install
```

## Development

You'll need to add some content, so drop in an `OPS` folder with the contents of a fixed layout ebook to the root folder.

Once there, update `src/template.html` with the path to the ebook’s `content.opf` and the ebook’s viewport values.

```js
new Reader({
  contentUrl: '/OPS/content.opf',
  viewport:{
    width:768,
    height:1024
  }
});
```

To view, run

```
gulp serve
```

and navigate to `http://localhost:8080`.

## Deployment

```
gulp build
```

Thanks Gulp!

## There’s more!

The reader is designed to allow multiple books on a page, and can be embedded via `iframe`s.  In this case, it’s necessary to instantiate the reader in the parent page rather than the template once the `iframe`s have been loaded.

```html

<div class="book">
  <iframe
    src="http://localhost:8080/src/template.html"
    data-content-url="/OEBPS-1/content.opf"
    data-viewport-x="468"
    data-viewport-y="680"></iframe>
</div>

<div class="book">
   <iframe
    src="http://localhost:8080/src/template.html"
    data-content-url="/OEBPS-2/content.opf"
    data-viewport-x="840"
    data-viewport-y="1191"></iframe>
</div>

<script type="text/javascript" src="https://code.jquery.com/jquery-2.1.4.min.js"></script>
<script type="text/javascript">
  $(function(){
    $('iframe').each(function(){
      $(this).on('load', function(){
        var $this = $(this);
        new this.contentWindow.Reader({ // Reference to the iframe's `window`
          docElem: this,                // Used to enable fullscreen iframes
          contentUrl: $this.attr('data-content-url'),
          viewport:{
            width:$this.attr('data-viewport-x'),
            height:$this.attr('data-viewport-y')
          }
        });
      });
    });
  });
</script>

```

Extend the reader by hooking into its events and methods

```js

var reader = new Reader({
  contentUrl: 'OPS/content.opf',
  viewport:{
    width:768,
    height:1024
   }
});

$(document).on('reader.contentReady', function(){
  // Content successfully loaded via ajax
});

$(document).on('reader.pagesFit', function(){
  // Element sizing has taken place
});

$(document).on('reader.articlesPositioned', function(){
  // Reader is ready to roll. Tie it into some custom business ...
  var mem = localStorage.getItem(epub3Reader) !== null ? JSON.parse(mem) : null;
  if (mem !== null && typeof mem.lastPos !== 'undefined') {
    reader.navigate.goToIdx(mem.lastPos);
  }
});
```

## License

This sofware is released under the MIT license. Read it [here](https://github.com/msimmer/Epub3-FXL-Reader/blob/master/LICENSE).

## Thanks

This project was made possible by the generous support of the Canada Council for the Arts, and was developed in conjunction with the launch of Lunch Bytes’ anthology, _No Internet, No Art_, which was edited by Melanie Bühler, and published by Onomatopee, 2015.

<img width="250" alt="Canada Council for the Arts" src="http://maxwellsimmer.com/img/CCFA_RGB_colour_e.jpg">
