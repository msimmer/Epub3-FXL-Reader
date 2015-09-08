"use strict";

var gulp = require("gulp");
var coffee = require("gulp-coffee");
var gutil = require("gutil");
var concat = require("gulp-concat");
var path = require("path");
var jshint = require("gulp-jshint");
var uglify = require("gulp-uglify");
var autoprefixer = require("gulp-autoprefixer");
var sass = require("gulp-ruby-sass");
var livereload = require("gulp-livereload");
var connect = require("gulp-connect");
var postcss = require("gulp-postcss");
var minifyHTML = require("gulp-minify-html");

// JSHint config, adjusted for Coffeescript-compiled JS
var packageJSON = require("./package");
var jshintConfig = packageJSON.jshintConfig;
jshintConfig.lookup = false;

// Environment variable
var env = "develop";

// Coffeescripts
gulp.task("coffee", function() {
  return gulp.src([
      "src/coffee/main.coffee",
      "src/coffee/*.coffee"
    ])
    .pipe(coffee({
        bare: true
      })
      .on("error", gutil.log))
    .pipe(concat("app.js"))
    .pipe(gulp.dest("src/js"));
});

// Scripts
gulp.task("scripts", ["coffee"], function() {
  return gulp.src([
      "vendor/js/jquery.js",
      "src/js/app.js"
    ])
    .pipe(concat("main.js"))
    .pipe(gulp.dest("src"));
});

// Clean
gulp.task("clean", require("del").bind(null, ["dist"]));

// Copy
gulp.task("copy", ["clean", "sass"], function() {
  return gulp.src([
      "src/css/**/*.css",
      "src/fonts/**/*.*",
      "src/img/**/*.{jpg,png,svg,gif,webp,ico}"
    ], {
      base: "src"
    })
    .pipe(gulp.dest("dist"));
});

// CSS Preprocessors
gulp.task("sass", function() {
  sass("src/css/scss/main.scss", {
      sourcemap: false,
      style: env === "production" ? "compressed" : "expanded"
    })
    .pipe(autoprefixer({
      browsers: [
        "last 2 version",
        "safari 5",
        "ie 8",
        "ie 9",
        "opera 12.1",
        "ios 6",
        "android 4"
      ]
    }))
    .pipe(gulp.dest("src/css"));
});

// JSHint
gulp.task("jshint", ["scripts"], function() {
  return gulp.src("src/*.js}")
    .pipe(jshint(jshintConfig))
    .pipe(jshint.reporter("jshint-stylish"))
    .pipe(jshint.reporter("fail"));
});

// Uglify
gulp.task("uglify", ["jshint", "coffee", "scripts"], function() {
  return gulp.src("src/main.js")
    .pipe(uglify())
    .pipe(gulp.dest("dist"));
});

// Server
gulp.task('connect', function() {
  connect.server({
    root: "./",
    livereload: false
  });
});

// Watch
gulp.task("watch", ["connect", "sass", "coffee"], function() {

  gulp.watch([
    "src/js/**/*.js",
    "src/css/**/*.css",
    "src/*.{html,xhtml,htm}"
  ]).on("change", function(file) {
    console.log("  Changed: " + file.path);
    connect.reload()
  })

  // Watch for SASS
  gulp.watch(["src/css/scss/**/*.scss"], ["sass"]);

  // Watch for JavaScripts
  gulp.watch("src/js/app.js", ["scripts", "jshint"]);

  // Watch for Coffeescripts
  gulp.watch("src/coffee/*.coffee", ["coffee"]);

});

// Setting our env variable, switches minify settings for `build`
gulp.task("production", function() {
  return env = "production";
});

// Minify our HTML, saving precious bytes
gulp.task("minify-html", function() {
  return gulp.src("src/*.{html,xhtml,htm}")
    .pipe(minifyHTML({
      empty: true
    }))
    .pipe(gulp.dest("dist"));
});

gulp.task("serve", [
  "sass",
  "coffee",
  "scripts",
  "jshint",
  "connect",
  "watch"
], function() {});

gulp.task("build", [
  "production",
  "minify-html",
  "clean",
  "sass",
  "coffee",
  "scripts",
  "jshint",
  "uglify",
  "copy",
  "connect"
], function() {
  console.log("  Build is finished.");
});
