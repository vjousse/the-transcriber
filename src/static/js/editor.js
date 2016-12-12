var Elm = require( '../../elm/Main' );

export class SpeakerTurnEditor {

  constructor(elmTarget) {

    if(!this.isElement(elmTarget)) {
      elmTarget = document.querySelector(elmTarget);
    }

    this.elmApp = Elm.Main.embed(elmTarget, {
      mediaUrl: "http://localhost:8080/examples/lcp_q_gov.mp3"
        //mediaUrl: "http://localhost/resumemo.mp3"
      , mediaType: "audio/mp3"
      , jsonUrl: "http://localhost:8080/examples/lcp_q_gov_ckeditor.json"
    });


    this.appState = {};
    this.appState.turns = {};
    this.appState.turns.currentTurn = -1;
    this.appState.turns.speakerTurns = [];

    this.wirePorts(this.elmApp);
  }

  // http://stackoverflow.com/questions/384286/javascript-isdom-how-do-you-check-if-a-javascript-object-is-a-dom-object
  isElement(obj) {
    try {
      //Using W3 DOM2 (works for FF, Opera and Chrom)
      return obj instanceof HTMLElement;
    }
    catch(e){
      //Browsers not supporting W3 DOM2 don't have HTMLElement and
      //an exception is thrown and we end up here. Testing some
      //properties that all elements have. (works on IE7)
      return (typeof obj==="object") &&
        (obj.nodeType===1) && (typeof obj.style === "object") &&
        (typeof obj.ownerDocument ==="object");
    }
  }

  onStateChange(newState) {
    //Merge new state into old one
    for (var attrname in newState) { 
      this.appState.turns[attrname] = newState[attrname];
    }
  }

  wirePorts(app) {


    app.ports.setCurrentTime.subscribe(function(time) {
      var audio = document.getElementById('audio-player');
      console.log("Time: " + time, audio);

      audio.currentTime = time;
    });

    app.ports.setPlaybackRate.subscribe(function(rate) {
      var audio = document.getElementById('audio-player');
      console.log("Rate: " + rate, audio);

      audio.playbackRate = rate;
    });

    app.ports.play.subscribe(function() {
      var audio = document.getElementById('audio-player');
      console.log("Play: ", audio);

      audio.play();
    });

    app.ports.pause.subscribe(function() {
      var audio = document.getElementById('audio-player');
      console.log("Pause: ", audio);

      audio.pause();
    });

    app.ports.sendCurrentTime.subscribe((timestamp) => {
      this.highlightWord(this.appState.turns, timestamp);
    });


    app.ports.sendSpeakerTurn.subscribe(({index, speakerTurn}) => {
      console.log(speakerTurn);
      this.loadSpeaker(this.appState.turns, index, speakerTurn);
    });
  }

  getTurnContent(index) {
    var ckeditorInstance = CKEDITOR.instances['S' + index];

    return {
      'index': index,
      'textContent' : ckeditorInstance.document.getById("S"+index).$.innerText,
      'htmlContent' : ckeditorInstance.getData()
    }
  }

  loadSpeaker(state, index, speakerTurn) {

    let domElement = document.getElementById("S" + index);
    let updateElm = (index) => {

      var ckeditorInstance = CKEDITOR.instances['S' + index];

      this.elmApp.ports.getSpeakerTurnContent.send(this.getTurnContent(index));
    }

    //
    // Wait for the Elm element to be displayed before loading React stuff
    // Kind of hacky, but I can't thing of a better solution for now
    if (domElement && !CKEDITOR.instances['S' + index]) {

      let htmlContent = speakerTurn.htmlContent;

      while (index >= state.speakerTurns.length) {
        state.speakerTurns.push({});
      }
      var editorElement = CKEDITOR.document.getById( 'S' + index);

      editorElement.setAttribute( 'contenteditable', 'true' );

      CKEDITOR.inline( 'S' + index, {
          allowedContent: true,
          on: {
              instanceReady: function( evt ) {
                  // your stuff here

              },
              change: function(evt) {
                updateElm(index);
              }
          }

      });

      var that = this;
      CKEDITOR.instances['S' + index].setData( htmlContent, {
          callback: function() {

              updateElm(index);

              that.elmApp.ports.speakerLoaded.send(that.getTurnContent(index));
              this.checkDirty(); // true
          }
      } );

      CKEDITOR.instances['S' + index].on( 'doubleclick', function( evt )
          {
              var element = evt.data.element;
              console.log("[Double click]",element.data('start'));

              var audio = document.getElementById('audio-player');
              audio.currentTime = parseFloat(element.data('start'));

          });

      // Copies needed properties into local state
      state.speakerTurns[index].start = speakerTurn.start;
      state.speakerTurns[index].end = speakerTurn.end;


    } else {
      setTimeout( () => { this.loadSpeaker(state, index, speakerTurn) }, 10 );
    }
  }

  highlightWord(state, timestamp) {

    let speakerTurnIndex = state.speakerTurns.findIndex(function(element) {

      if (element.start <= timestamp && element.end >= timestamp) {
        return true;
      }

    });

    if (speakerTurnIndex != -1) {

      let speakerTurn = state.speakerTurns[speakerTurnIndex];

      if(state.currentTurn == -1) {
        state.currentTurn = speakerTurnIndex;
      }

      state.currentTurn = speakerTurnIndex;

      var editor = CKEDITOR.instances['S' + speakerTurnIndex];

      var spansHighlighted = editor.document.$.getElementsByClassName("highlighted");
      Array.prototype.find.call( spansHighlighted, function(elem){
        elem.classList.remove("highlighted");
      });


      var spans = editor.document.$.getElementsByClassName("word");
      var found = false;
      var span = Array.prototype.find.call( spans, function(elem){
          //console.log("Ckeditor", parseFloat(elem.dataset.start), timestamp);
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
