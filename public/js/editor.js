'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var SpeakerTurnEditor = exports.SpeakerTurnEditor = function () {
  function SpeakerTurnEditor(elmApp, onStateChange) {
    _classCallCheck(this, SpeakerTurnEditor);

    this.elmApp = elmApp;
    this.onStateChange = onStateChange;
  }

  _createClass(SpeakerTurnEditor, [{
    key: 'getTurnContent',
    value: function getTurnContent(index) {
      var ckeditorInstance = CKEDITOR.instances['S' + index];

      return {
        'index': index,
        'textContent': ckeditorInstance.document.getById("S" + index).$.innerText,
        'htmlContent': ckeditorInstance.getData()
      };
    }
  }, {
    key: 'loadSpeaker',
    value: function loadSpeaker(state, index, speakerTurn) {
      var _this = this;

      var domElement = document.getElementById("S" + index);
      var updateElm = function updateElm(index) {

        var ckeditorInstance = CKEDITOR.instances['S' + index];

        _this.elmApp.ports.getSpeakerTurnContent.send(_this.getTurnContent(index));
      };

      //
      // Wait for the Elm element to be displayed before loading React stuff
      // Kind of hacky, but I can't thing of a better solution for now
      if (domElement && !CKEDITOR.instances['S' + index]) {

        var htmlContent = speakerTurn.htmlContent;

        while (index >= state.speakerTurns.length) {
          state.speakerTurns.push({});
        }
        var editorElement = CKEDITOR.document.getById('S' + index);

        editorElement.setAttribute('contenteditable', 'true');

        CKEDITOR.inline('S' + index, {
          allowedContent: true,
          on: {
            instanceReady: function instanceReady(evt) {
              // your stuff here

            },
            change: function change(evt) {
              updateElm(index);
            }
          }

        });

        var that = this;
        CKEDITOR.instances['S' + index].setData(htmlContent, {
          callback: function callback() {

            updateElm(index);

            that.elmApp.ports.speakerLoaded.send(that.getTurnContent(index));
            this.checkDirty(); // true
          }
        });

        CKEDITOR.instances['S' + index].on('doubleclick', function (evt) {
          var element = evt.data.element;
          console.log("[Double click]", element.data('start'));

          var audio = document.getElementById('audio-player');
          audio.currentTime = parseFloat(element.data('start'));
        });

        // Copies needed properties into local state
        state.speakerTurns[index].start = speakerTurn.start;
        state.speakerTurns[index].end = speakerTurn.end;
      } else {
        setTimeout(function () {
          _this.loadSpeaker(state, index, speakerTurn);
        }, 10);
      }
    }
  }, {
    key: 'highlightWord',
    value: function highlightWord(state, timestamp) {

      console.log("Highlighting");
      var speakerTurnIndex = state.speakerTurns.findIndex(function (element) {

        if (element.start <= timestamp && element.end >= timestamp) {
          return true;
        }
      });

      console.log(speakerTurnIndex);

      if (speakerTurnIndex != -1) {

        var speakerTurn = state.speakerTurns[speakerTurnIndex];

        if (state.currentTurn == -1) {
          state.currentTurn = speakerTurnIndex;
        }

        state.currentTurn = speakerTurnIndex;

        var editor = CKEDITOR.instances['S' + speakerTurnIndex];

        var spansHighlighted = editor.document.$.getElementsByClassName("highlighted");
        Array.prototype.find.call(spansHighlighted, function (elem) {
          elem.classList.remove("highlighted");
        });

        var spans = editor.document.$.getElementsByClassName("word");
        var found = false;
        var span = Array.prototype.find.call(spans, function (elem) {
          console.log(parseFloat(elem.dataset.start), timestamp);
          if (parseFloat(elem.dataset.start) >= timestamp) {
            return true;
          } else {
            return false;
          }
        });

        if (span) {
          span.classList.add('highlighted');
        }
      }
    }
  }]);

  return SpeakerTurnEditor;
}();