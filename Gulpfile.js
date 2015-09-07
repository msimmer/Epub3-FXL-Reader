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

// JSHint config, adjusted for Coffeescript-compiled JS
var packageJSON = require("./package");
var jshintConfig = packageJSON.jshintConfig;
jshintConfig.lookup = false;

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
gulp.task("clean", require("del").bind(null, [".tmp", "dist"]));

// Copy
gulp.task("copy", ["clean"], function() {
  return gulp.src([
      "src/css/**/*.{css}",
      "src/fonts/**/*.*",
      "src/img/**/*.{jpg,png,svg,gif,webp,ico}",
      "src/index.html"
    ], {
      base: "src"
    })
    .pipe(gulp.dest("dist"));
});

// CSS Preprocessors
gulp.task("sass", function() {
  sass("src/css/scss/main.scss", {
      sourcemap: false,
      style: "expanded"
    })
    .pipe(autoprefixer("last 2 versions"))
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

// Livereload
gulp.task("watch", ["connect", "sass", "coffee"], function() {

  // Watch for livereoad
  gulp.watch([
    "src/js/**/*.js",
    "src/css/**/*.css",
    "src/*.html"
  ]).on("change", function(file) {
    console.log("  " + file.path);
    connect.reload()
  })

  // Watch for autoprefix
  gulp.watch(["src/css/scss/**/*.scss"], ["sass"]);

  // Watch for JSHint
  gulp.watch("src/js/app.js", ["scripts", "jshint"]);

  // Watch for Coffee
  gulp.watch("src/coffee/*.coffee", ["coffee"]);

});

gulp.task("serve", [
  "sass",
  "coffee",
  "scripts",
  "jshint",
  "connect",
  "watch"
], function() {
  //
});

gulp.task("build", [
  "clean",
  "sass",
  "coffee",
  "scripts",
  "jshint",
  "uglify",
  "copy"
], function() {
  console.log("  Build is finished.");
});
