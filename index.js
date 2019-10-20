// import hljs from "highlight.js";
// import "highlight.js/styles/github.css";
import './lib/code-editor.js';
import './style.css';
// @ts-ignore
// window.hljs = hljs;
const { Elm } = require('./src/Main.elm');
const pagesInit = require('elm-pages');

pagesInit({
  mainElmModule: Elm.Main
});
