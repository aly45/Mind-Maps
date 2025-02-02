class Button {
  float fontSize = 32.3;
  float x; //left location of button
  float y; //top location of button
  float w; //button width
  float h; //button height
  color c; //colour
  String s; //button text
  float centreX;
  float centreY;
  float textX; //leftmost of button text
  float textY; //bottom of button text
  float b_alpha; //button opacity
  float litAlpha = 255, darkAlpha = 100;
  boolean isOver = false;

  Button(String text, float xTemp, float yTemp, float wTemp, float hTemp, color colour, float size) {
    s = text;
    x = xTemp; //button leftmost point
    y = yTemp; //button topmost point
    w = wTemp; //button width
    h = hTemp; //button height
    c = colour;
    centreX = x + w/2;
    centreY = y + h/2;
    fontSize = size;
  }

  void mouseOver() {
    if (((mouseX >= x-w/2)&&(mouseX <= x+w/2)) && 
      ((mouseY >= y-h/2)&&(mouseY <= y+h/2))) {
      isOver = true;
    } else {
      isOver = false;
    }
  }

  void display(float tempAlpha) {
    //draw button:
    if (isOver) {
      b_alpha = litAlpha;
    } else {
      b_alpha = tempAlpha;
    }

    fill(c, b_alpha);
    stroke(0, 0);
    rectMode(CENTER);
    rect(x, y, w, h);

    //draw text:
    textSize(fontSize);
    fill(0, b_alpha - 50);   


    float gap = h/4 + 1; // calculates how far to shift down the text
    textX = centreX - textWidth(s)/2; //shifts button number text to align with centre
    textAlign(CENTER);
    text(s, x, y + gap);
  }

  void move(float tempX, float tempY) {
    x = tempX;
    y = tempY;
  }
}

class XButton extends Button {
  color Xcolour;
  float buffer = 5;
  XButton(String text, float xTemp, float yTemp, float wTemp, float hTemp, color colour, color xc) { // button colour, X colour
    super(text, xTemp, yTemp, wTemp, hTemp, colour, xc);
    Xcolour = xc;
  }

  void display(float tempAlpha) {
    //draw button:
    if (isOver) {
      b_alpha = litAlpha;
    } else {
      b_alpha = tempAlpha;    //a is the temporary button opacity before mouseOver
    }

    fill(c, b_alpha);
    stroke(0, 0);
    rectMode(CENTER);
    rect(x, y, w, h);

    //draw X using lines:
    stroke(Xcolour, b_alpha);
    line(x-w/2 + buffer, y-h/2 + buffer, x+w/2 - buffer, y+h/2 - buffer);
    line(x-w/2 + buffer, y+h/2 - buffer, x+w/2 - buffer, y-h/2 + buffer);
  }
}

class darkButton extends Button {
  color iconColour, outline = color(0), litOutline = color(255), buttonColour = color(28, 56, 250);
  float buffer = 5;
  darkButton(String text, float xTemp, float yTemp, float wTemp, float hTemp, color colour, color xc) { // button colour, X colour
    super(text, xTemp, yTemp, wTemp, hTemp, colour, xc);
    iconColour = xc;
  }

  void display(float tempAlpha) {
    //draw button:
    if (isOver) {
      b_alpha = litAlpha;
      outline = litOutline;
    } else {
      b_alpha = tempAlpha;    //a is the temporary button opacity before mouseOver
      outline = color(0, 0);
    }

    fill(c, b_alpha);
    stroke(outline);
    rectMode(CENTER);
    rect(x, y, w, h);

    //draw icon:
    if (darkMode) {
      moon();
    } else {
      sun();
    }

    //line(x-w/2 + buffer,y-h/2 + buffer,x+w/2 - buffer,y+h/2 - buffer);
    //line(x-w/2 + buffer,y+h/2 - buffer,x+w/2 - buffer,y-h/2 + buffer);
  }

  void sun() {
    buttonColour = color(28, 56, 250);    // cream
    iconColour = color(0);                // black
    litOutline = color(50, 0, 255);       // blue
    stroke(iconColour, b_alpha);
    ellipse(x-w/2 + buffer, y-h/2 + buffer, x+w/2 - buffer, y+h/2 - buffer);
  }
  void moon() {
    PShape m;
    buttonColour = color(0);              // black
    iconColour = color(28, 56, 250);      // cream      
    litOutline = color(255, 255, 0);      // yellow

    m = createShape();
    //m.beginShape();
    //m.fill(iconColour);
    //m.noStroke();
    //m.vertex(
  }
}
