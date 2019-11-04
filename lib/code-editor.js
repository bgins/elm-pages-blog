import Prism from 'prismjs';
import 'prismjs/components/prism-elm';
import 'prismjs/components/prism-haskell';
import 'prismjs/components/prism-javascript';
import 'prismjs/components/prism-json';
import 'prismjs/components/prism-yaml';
import './native-shim.js';

customElements.define(
  'code-editor',
  class extends HTMLElement {
    constructor() {
      super();
      this._editorValue = "-- If you see this, the Elm code didn't set the value.";
      this._editorLanguage = "-- If you see this, the Elm code didn't set the language.";
    }

    get editorValue() {
      return this._editorValue;
    }

    set editorValue(value) {
      if (this._editorValue === value) return;
      this._editorValue = value;
      if (!this._editor) return;
      this._editor.setValue(value);
    }

    get editorLanguage() {
      switch (this._editorLanguage) {
        case 'elm':
          return { grammar: Prism.languages.elm, language: this._editorLanguage };
        case 'haskell':
          return { grammar: Prism.languages.haskell, language: this._editorLanguage };
        case 'javascript':
          return { grammar: Prism.languages.javascript, language: this._editorLanguage };
        case 'json':
          return { grammar: Prism.languages.json, language: this._editorLanguage };
        case 'yaml':
          return { grammar: Prism.languages.yaml, language: this._editorLanguage };
      }
    }

    set editorLanguage(language) {
      if (this._editorLanguage === language) return;
      this._editorLanguage = language;
      if (!this._editor) return;
      this._editor.setValue(language);
    }

    connectedCallback() {
      let shadow = this.attachShadow({ mode: 'open' });

      let style = document.createElement('style');

      style.textContent = `@import "https://cdnjs.cloudflare.com/ajax/libs/prism/1.17.1/themes/prism.min.css";
      pre {
        padding: 10px;
        margin: 0px;
        background-color: #fbf9f9;
        font-size: 18px;
        overflow-x: auto !important;
      }
      `;

      if (this.editorLanguage) {
        let code = document.createElement('code');
        code.setAttribute('class', `language-${this.editorLanguage.language}`);
        code.innerHTML = Prism.highlight(this.editorValue, this.editorLanguage.grammar, this.editorLanguage.language);

        let pre = document.createElement('pre');
        pre.appendChild(code);

        shadow.appendChild(style);
        shadow.appendChild(pre);
      }
    }
  }
);
