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

    // Handle double click on a word
    this.mainDiv.addEventListener("dblclick", event => {
      if(event.target.dataset.start) {

      var clickEvent = new CustomEvent(
        'word-clicked',
        { 
          detail: {
            'start': parseFloat(event.target.dataset.start),
            'textContent': event.target.textContent,
            'htmlContent': event.target.innerHTML}
        });


        console.log("Fire click", clickEvent);
        this.dispatchEvent(clickEvent);
      }

    });

    // Handle input insertion
    this.mainDiv.addEventListener("input", event => {

      var changedEvent = new CustomEvent(
        'content-changed',
        { 
          detail: {
            'htmlContent': event.target.innerHTML,
            'textContent': event.target.textContent}
        });

      console.log("Fire changed", changedEvent);
      this.dispatchEvent(changedEvent);

    });


    shadow.appendChild(this.mainDiv);

  }

  // Monitor the attributes for changes.
  static get observedAttributes() {return ['content', 'time', 'current']; }


  // Reflect properties to attributes
  get starttime() {
    return this.getAttribute('starttime');
  }

  set starttime(val) {
    if (val) {
      this.setAttribute('starttime', val);
    } else {
      this.removeAttribute('starttime');
    }
  }

  // Reflect properties to attributes
  get endtime() {
    return this.getAttribute('endtime');
  }

  set endtime(val) {
    if (val) {
      this.setAttribute('endtime', val);
    } else {
      this.removeAttribute('endtime');
    }
  }
  // Respond to attribute changes.
  attributeChangedCallback(attr, oldValue, newValue) {

    if (attr == 'content') {

      if(!this.init) {

        this.mainDiv.innerHTML = newValue;

        // Trick to fire the input event after loading the content
        // without setTimeout, the event is not fired
        setTimeout(() => { 

          var event = new Event('input', {
            'bubbles': true,
            'cancelable': true
          });

          this.mainDiv.dispatchEvent(event);
        }, 1);

        this.init=true;
      }

    } else if (attr == 'time') {

      var timestamp = parseInt(newValue)/1000;

      // Unhighlight stuff already highlighted
      var spansHighlighted = this.mainDiv.getElementsByClassName("highlighted");
      Array.prototype.find.call( spansHighlighted, function(elem){
        elem.classList.remove("highlighted");
      });


      if(timestamp == 0) return;

      // Don't highlight if the time is not in the start / end time range
      if(this.starttime && this.endtime && (this.starttime > timestamp || timestamp > this.endtime)) return;

      var spans = this.mainDiv.getElementsByClassName("word");
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

