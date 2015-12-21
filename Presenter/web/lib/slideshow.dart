library slideshowobjects;

import "dart:html";
import "lifecyclemixin.dart";

/// A class to hand Slides and their display.
class Slide extends Object with LifecycleTracker {
  
  String titleText = "";
  List<String> bulletPoints;
  String imageUrl = "";

  // Ctor for the slide.
  Slide(this.titleText) {
    bulletPoints = new List<String>();
    recordCreateTimestamp();
    
  }

  // Returns Div element for this slide contents.
  getDiv() {
    
    DivElement slide = new DivElement();
    DivElement title = new DivElement();
    DivElement bullets = new DivElement();

    title.appendHtml("<h1>$titleText</h1>");
    slide.append(title);

    if (imageUrl.length > 0) slide.appendHtml("<img src=\"$imageUrl\" /><br/>");

    bulletPoints.forEach((bp) {
      if (bp.trim().length > 0) bullets.appendHtml("<li>$bp</li>");
    });

    slide.append(bullets);

    return slide;
  }
}

/// A class to hand a set of Slides in a presentation.
class SlideShow extends Object with LifecycleTracker {
  
  List<Slide> _slides;

  List<Slide> get slides => _slides;
  
  // Ctor for the slide.
  SlideShow() {
    _slides = new List<Slide>();
    recordCreateTimestamp();
  }

  // Build a slideshow from the supplied [src] Markdown.
  build(String src) {
    updateEditTimestamp();
    _slides = new List<Slide>();
    Slide nextSlide;

    src.split("\n").forEach((String line) {
      if (line.trim().length > 0) {

        //Title - also marks start of the next slide.
        if (line.startsWith("#")) {
          nextSlide = new Slide(line.substring(1));
          _slides.add(nextSlide);
        }
        if (nextSlide != null) {
          if (line.startsWith("+")) {
            nextSlide.bulletPoints.add(line.substring(1));
          } else if (line.startsWith("!")) {
            nextSlide.imageUrl = line.substring(1);
          }
        }
      }
    });
  }
}
