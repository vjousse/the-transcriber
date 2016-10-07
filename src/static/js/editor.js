export class SpeakerTurnEditor {

  constructor(elmApp, onStateChange) {
    this.elmApp = elmApp;
    this.onStateChange = onStateChange;
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

    console.log("Highlighting");
    let speakerTurnIndex = state.speakerTurns.findIndex(function(element) {

      if (element.start <= timestamp && element.end >= timestamp) {
        return true;
      }

    });

    console.log(speakerTurnIndex);

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
          console.log(parseFloat(elem.dataset.start), timestamp);
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
