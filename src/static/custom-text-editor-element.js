class CustomTextEditorElement extends HTMLElement {
  constructor() {
    super();

    var shadow = this.attachShadow({mode: 'open'});


    this.init = false;

    shadow.innerHTML = '<style>' +
    '.highlighted {background-color: rgb(248, 222, 126);}' +
    '[contenteditable]:focus { outline: 0px solid transparent; }' +
    '</style>';

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
  static get observedAttributes() {return ['content', 'time']; }

  // Respond to attribute changes.
  attributeChangedCallback(attr, oldValue, newValue) {

    if (attr == 'content') {

      if(!this.init) {
        this.mainDiv.innerHTML = newValue;

        var changedEvent = new CustomEvent(
          'content-changed',
          { 
            detail: {
              'htmlContent': this.mainDiv.innerHTML,
              'textContent': this.mainDiv.textContent}
          });

        this.mainDiv.dispatchEvent(changedEvent);

        this.init=true;
      }

    } else if (attr == 'time') {

      var timestamp = parseInt(newValue)/1000;
      console.log("Custom time changed", timestamp);

      // Unhighlight stuff already highlighted
      var spansHighlighted = this.mainDiv.getElementsByClassName("highlighted");
      Array.prototype.find.call( spansHighlighted, function(elem){
        elem.classList.remove("highlighted");
      });


      if(timestamp == 0) return;

      var spans = this.mainDiv.getElementsByClassName("word");
      console.log(spans);
      var found = false;

      var span = Array.prototype.find.call( spans, function(elem){
          if(parseFloat(elem.dataset.start) >= timestamp) {
              return true;
          } else {
              return false;
          }
      });

      if(span) {
        span.classList.add('highlighted');
      }

    }

  }

}

window.customElements.define('custom-text-editor', CustomTextEditorElement);

