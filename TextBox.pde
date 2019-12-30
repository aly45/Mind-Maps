class TextBox {
  float fontSize = 20, vertSpace = 20, w = 70, h = 30, x, y;
  boolean selected = false, doneTyping = false;
  StringList letters = new StringList();
  String words = "";
  int k = 0;

  TextBox(float xPos, float yPos, float boxWidth, float boxHeight) {
    x = xPos;
    y = yPos;
    w = boxWidth;
    h = boxHeight;
  }

  void display(boolean finishedTyping) {
    doneTyping = finishedTyping;
    if (!doneTyping) {
      // draw text box
      stroke(0);
      fill(255);
      rectMode(CENTER);
      rect(x, y, w, h);

      // draw text
      fill(0);
      textSize(fontSize);
      textAlign(LEFT);
      text(words, x+2, y, w, h);  // display typed text on rectangle location
    }
  }

  void addText(boolean finishedTyping) {  
    doneTyping = finishedTyping;
    if (!doneTyping) {
      if ((key == ENTER)||(key == RETURN)) {
        if (k>0) {
          doneTyping = true;
        }
      } else if (key == BACKSPACE) {
        if (k>0) {
          letters.remove(k-1);
          k -= 1;
        }
      } else if (key == ' ') {
        letters.append("_"); 
        k += 1;
      } else {
        letters.append(str(key)); 
        k += 1;
      }

      words = "";
      for (int i=0; i<letters.size(); i+=1) {  // build up words String out of letters StringList
        words += letters.get(i);
      }
    }
  }
  
  void move(float tempX, float tempY){
    x = tempX;
    y = tempY;
  }
}
