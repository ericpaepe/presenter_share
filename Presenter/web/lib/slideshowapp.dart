library SlideShowApp;

import "dart:html";
import 'dart:math';
import 'dart:async';

import 'slideshow.dart';
import 'sampleshows.dart';

/// Slide Show Application for giving presentations.
class SlideShowApp {

  // Slideshow data.
  int slide = 0;
  SlideShow currentSlideShow = new SlideShow();

  // Timer.
  Stopwatch slidesTime = new Stopwatch();
  Timer updateTimer = null;

  // Page HTML.
  SpanElement timerDisplay;
  DivElement slideScreen;
  DivElement overviewScreen;
  TextAreaElement presEditor;
  RangeInputElement rangeSlidepos;

  //Ctor for the core SlideShow presentation application.
  SlideShowApp() {
    setButton("#btnDemo", buildDemo);
    setButton("#btnFirst", startSlideShow);
    setButton("#btnLast", lastSlideShow);
    setButton("#btnPrev", backSlideShow);
    setButton("#btnNext", nextSlide);
    setButton("#btnTimer", toggleTimer);

    Function qs = querySelector;
    var controls = qs("#controls");
    presEditor = qs("#presentation");

    //Slide navigation via range control.
    rangeSlidepos = qs("#rngSlides");
    rangeSlidepos.onChange.listen(moveToSlide);

    //Insert Date Into Presentation
    var btnInsertDate = qs("#btnInsertDate");
    btnInsertDate.onClick.listen(insertDate);

    //Display an overview
    setButton("#btnOverview", showOverview);

    //Printable handout sheet
    setButton("#btnHandouts", showHandout);

    //Get reference to the main slide display.
    slideScreen = qs("#slides");

    //Get reference to the timer display.
    timerDisplay = qs("#timerDisplay");

    //Set the Overview to hide when clicked.
    overviewScreen = new DivElement();
    overviewScreen.classes.toggle("fullScreen");
    overviewScreen.onClick.listen((e) => overviewScreen.remove());

    //Update the presentation on change.
    presEditor.onKeyUp.listen(updatePresentation);

    //Keyboard navigation.
    window.onKeyUp.listen((KeyboardEvent e) {

      //Check the editor does not have focus.
      if (presEditor != document.activeElement) {
        if (e.keyCode == 39) showNextSlide();
        else if (e.keyCode == 37) showPrevSlide();
        else if (e.keyCode == 38) showFirstSlide();
        else if (e.keyCode == 40) showLastSlide();
      }
    });
    
    //Show and hide help box.
    window.onKeyUp.listen(
        (KeyboardEvent e) {
          print(e);

              //Check the editor does not have focus.
              if (presEditor != document.activeElement) {
                DivElement helpBox = qs("#helpKeyboardShortcuts");
                if (e.keyCode == 191){
                  if (helpBox.style.visibility=="visible")
                    helpBox.style.visibility = "hidden";
                  else
                    helpBox.style.visibility = "visible";
                }
              }
        }
    );

    //Allow the color of the page to be set.
    InputElement cp = qs("#pckBackColor");
    cp.onChange.listen((e) => document.body.style.backgroundColor = cp.value);
  }

  //Find a button with the specified [id] and set the triggered method when it is clicked.
  setButton(String id, Function clickHandler) {
    ButtonInputElement btn = querySelector(id);
    btn.onClick.listen(clickHandler);
  }

  void buildDemo(MouseEvent event) {

    //Recreate the slideshow.
    presEditor.value = demo;

    slide = 0;
    updatePresentation(null);
    //showSlide(slide);

    updateRangeControl();
  }

  // Update Range control.
  void updateRangeControl() {
    rangeSlidepos
      ..min = "0"
      ..max = (currentSlideShow.slides.length - 1).toString();
  }

  // Move to slide specified by [slide].
  showSlide(int slide) {
    if (currentSlideShow.slides.length == 0) return;

    slideScreen.style.visibility = "hidden";
    slideScreen
      ..nodes.clear()
      ..nodes.add(currentSlideShow.slides[slide].getDiv());

    rangeSlidepos.value = slide.toString();
    slideScreen.style.visibility = "visible";
  }

  // Move to the next slide.
  void nextSlide(MouseEvent event) {
    showNextSlide();
  }

  void showNextSlide() {
    slide = min(currentSlideShow.slides.length - 1, ++slide);
    showSlide(slide);
  }

  // Move to the previous slide.
  void backSlideShow(MouseEvent event) {
    showPrevSlide();
  }

  void showPrevSlide() {
    slide = max(0, --slide);
    showSlide(slide);
  }

  // Move to the first slide.
  void startSlideShow(MouseEvent event) {
    showFirstSlide();
  }

  void showFirstSlide() {
    showSlide(0);
  }

  // Move to the last slide.
  void lastSlideShow(MouseEvent event) {
    showLastSlide();
  }

  void showLastSlide() {
    slide = max(0, currentSlideShow.slides.length - 1);
    showSlide(slide);
  }

  // Move to the slide that the range control indicates.
  void moveToSlide(Event event) {
    slide = int.parse(rangeSlidepos.value);
    showSlide(slide);
  }

  // Append the date to the end of the presentation source.
  void insertDate(Event event) {
    DateInputElement datePicker = querySelector("#selDate");
    if (datePicker.valueAsDate != null) presEditor.value =
        presEditor.value + datePicker.valueAsDate.toLocal().toString();
  }

  // Show the overview version of the display.
  showOverview(Event event) {
    buildOverview();
  }

  // Show the handout version of the display.
  showHandout(Event event) {
    buildOverview(true);
  }

  //Build the overview Div element.
  void buildOverview([bool addNotes = false]) {
    if (currentSlideShow.slides.length == 0) return;

    DivElement aSlide;
    DivElement slideBackground;

    //Reset and add a gap.
    overviewScreen.nodes
      ..clear()
      ..add(new BRElement())
      ..add(new BRElement())
      ..add(new BRElement())
      ..add(new BRElement());

    //Build overview version of slideshow.
    currentSlideShow.slides.forEach((s) {
      aSlide = s.getDiv();
      aSlide.classes.toggle("slideOverview");
      aSlide.classes.toggle("shrink");

      slideBackground = new DivElement();
      slideBackground.classes.toggle("slideBackground");
      slideBackground.nodes.add(aSlide);

      if (addNotes) {
        DivElement Notes = new DivElement();
        Notes.classes.toggle("slideNotes");
        Notes.text = "Notes";
        slideBackground.nodes.add(Notes);
        aSlide.style.marginLeft = "0%";
      }

      overviewScreen.nodes.add(slideBackground);

      if (!addNotes) {
        overviewScreen.nodes
          ..add(new BRElement())
          ..add(new BRElement());
      }
    });

    //Add a gap.
    overviewScreen.nodes
      ..add(new BRElement())
      ..add(new BRElement())
      ..add(new BRElement())
      ..add(new BRElement());

    document.body.nodes.add(overviewScreen);
  }

  // Update the presentation datastructure based on the TextArea source.
  void updatePresentation(Event event) {
    currentSlideShow = new SlideShow();
    currentSlideShow.build(presEditor.value);

    updateRangeControl();
    showSlide(slide);
  }

  // Start or Stop the timer.
  void toggleTimer(Event event) {
    if (slidesTime.isRunning) {
      slidesTime.stop();
      updateTimer.cancel();
    } else {
      updateTimer = new Timer.periodic(new Duration(seconds: 1), (timer) {
        String seconds = (slidesTime.elapsed.inSeconds % 60).toString();
        seconds = seconds.padLeft(2, "0");
        timerDisplay.text = "${slidesTime.elapsed.inMinutes}:$seconds";
      });

      slidesTime
        ..reset()
        ..start();
    }
  }
}
