class CustomTextEditorElement extends HTMLElement {
  constructor() {
    super();

    var shadow = this.attachShadow({mode: 'open'});


    this.init = false;

    this.mainDiv = document.createElement('div');

    this.mainDiv.setAttribute('contenteditable', 'true');

    this.mainDiv.addEventListener("input", event => {
      var changedEvent = new CustomEvent(
        'content-changed',
        { 
          detail: {
            'htmlContent': event.target.innerHTML,
            'textContent': event.target.textContent}
        });

      this.dispatchEvent(changedEvent);

    });


    shadow.appendChild(this.mainDiv);

  }

  // Monitor the 'name' attribute for changes.
  static get observedAttributes() {return ['content']; }

  // Respond to attribute changes.
  attributeChangedCallback(attr, oldValue, newValue) {

    if (attr == 'content') {
      //this.textContent = `Hello, ${newValue}`;

      if(!this.init) {
        this.mainDiv.innerHTML = newValue;
        this.init=true;
      }

    }
  }

}

window.customElements.define('custom-text-editor', CustomTextEditorElement);

