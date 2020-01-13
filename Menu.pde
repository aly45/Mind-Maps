class Menu {
  float menuWidth = 300, menuHeight = 100;
  int numButtons = 3, divisions = numButtons + 1;
  float buttonWidth = 80, buttonHeight = 40, xSize = 18;
  int w = 800, h = 600, dispTime = 60; // dispTime is number of frames for displaying a message
  color yellow = color(237, 226, 33), green = color(77, 168, 70), aqua = color(4, 211, 156), blue = color(4, 107, 211), purple = color(98, 3, 193), magenta = color(155, 3, 160), red_pink = color(160, 3, 102), orange = color(221, 118, 33);
  float size1 = 32.3, size2 = 23.2, size3 = 18;
  String menuMode = "MAIN", filename, previousMode = "";
  boolean showingMenu = false;
  float backButtonX = w/2, backButtonY = h/2 + 30;

  Button X, Q, saveButton, loadButton, newButton, yesButton, noButton, backButton, folderButton;

  TextBox t1, t2;

  Menu() {
    X = new XButton("X", w/2 + menuWidth/2 - xSize/2 - 0.5, h/2 - menuHeight/2 + xSize/2 + 1, xSize, xSize, green, color(255));
    Q = new Button("?", w/2 - menuWidth/2 + xSize/2 + 0.5, h/2 - menuHeight/2 + xSize/2 + 0.5, xSize, xSize, yellow, size3);
    saveButton = new Button("Save", w/2 - menuWidth/2 + (menuWidth/divisions) - 20, h/2, buttonWidth, buttonHeight, green, size1);
    loadButton = new Button("Load", w/2 - menuWidth/2 + 2*(menuWidth/divisions), h/2, buttonWidth, buttonHeight, blue, size1);
    newButton = new Button("New", w/2 - menuWidth/2 + 3*(menuWidth/divisions) + 20, h/2, buttonWidth, buttonHeight, orange, size1);
    yesButton = new Button("Yes", w/2 - menuWidth/5, h/2 + 25, buttonWidth - 15, buttonHeight  - 15, green, size2);
    noButton = new Button("No", w/2 + menuWidth/5, h/2 + 25, buttonWidth - 15, buttonHeight  - 15, red_pink, size2);
    backButton = new Button("Back", w/2, h/2 + 30, buttonWidth - 15, buttonHeight  - 15, green, size2);
    folderButton = new Button("Choose folder", w/2 - menuWidth*0.3 + 5, h/2 - 25, buttonWidth + 27, buttonHeight  - 20, green, 15);

    t1 = new TextBox(w/2, h/2, menuWidth*0.8, 25);
    t2 = new TextBox(w/2, h/2, menuWidth*0.8, 25);
  }

  void display() {
    // Draw menu:
    if (showingMenu) {
      stroke(green, 220);
      strokeWeight(2);
      fill(0, 230);
      rect(w/2, h/2, menuWidth, menuHeight);
      X.mouseOver();
      X.display(160);
      Q.mouseOver();
      Q.display(160);

      switch(menuMode) {
      case "MAIN":
        saveButton.display(160);
        saveButton.mouseOver();
        loadButton.display(160);
        loadButton.mouseOver();
        newButton.display(160);
        newButton.mouseOver();
        break;
      case "HELP":
        fill(green);
        textAlign(LEFT);
        textSize(14);
        text("Create node: LEFT-CLICK \nStop editing node: LEFT-CLICK \nConnect nodes: RIGHT-CLICK on one node, then another \nDelete node: DELETE/BACKSPACE while mouse is over a node \nCapture screen: F12", w/2 - 0.87*t1.w, h/2 - 1.97*t1.fontSize);
        menuHeight = 150;
        menuWidth = 450;
        break;
      case "SAVE":
        fill(green);
        textAlign(LEFT);
        textSize(15);
        text("Name this mind map:", w/2 - t1.w/2, h/2 - t1.fontSize);
        t1.display(t1.doneTyping);
        if (!t1.doneTyping) {
          backButton.display(160);
          backButton.mouseOver();
        }
        if (t1.doneTyping) {        
          fill(255);
          textSize(20);
          textAlign(CENTER);
          text("Save as '" + t1.text +"' ?", w/2, h/2 + 2);
          yesButton.display(160);
          yesButton.mouseOver();
          noButton.display(160);
          noButton.mouseOver();
        }
        break;
      case "LOAD":
        if (!t2.doneTyping) {
          folderButton.display(160);
          folderButton.mouseOver();
          fill(green);
          textAlign(LEFT);
          textSize(15);
          text(" or enter file name:", w/2 - 32, h/2 - t2.fontSize); // previously:  " or enter folder path:"
          t2.display(t2.doneTyping);
          //text("Press enter to continue", w/2 + t2.w/2, h/2 - t2.fontSize);    // need to set t2.letters = chosen folder path
          backButton.display(160);
          backButton.mouseOver();
        }
        if (t2.doneTyping) {        // doneTyping should be set when ENTER/RETURN is pressed
          fill(255);
          textSize(20);
          textAlign(CENTER);
          textLeading(20);
          text("Load file:\n'" + filename +"' ?", w/2, h/2 - menuHeight/4 + 5); 
          yesButton.display(160);
          yesButton.mouseOver();
          noButton.display(160);
          noButton.mouseOver();
        }
        break;
      case "NEW":
        fill(255);
        textSize(20);
        textAlign(CENTER);
        text("Create new mind map?", w/2, h/2 + 2);
        yesButton.display(160);
        yesButton.mouseOver();
        noButton.display(160);
        noButton.mouseOver();
      }
    }
  }

  void move(int tw, int th) {  // w and h are screen width and height or wherever to move the menu
    w = tw;
    h = th;
    X.move(w/2 + menuWidth/2 - xSize/2 - 0.5, h/2 - menuHeight/2 + xSize/2 + 1);
    Q.move(w/2 - menuWidth/2 + xSize/2 + 0.5, h/2 - menuHeight/2 + xSize/2 + 0.5);
    saveButton.move(w/2 - menuWidth/2 + (menuWidth/divisions) - 20, h/2);
    loadButton.move(w/2 - menuWidth/2 + 2*(menuWidth/divisions), h/2);
    newButton.move(w/2 - menuWidth/2 + 3*(menuWidth/divisions) + 20, h/2);
    yesButton.move(w/2 - menuWidth/5, h/2 + 25);
    noButton.move(w/2 + menuWidth/5, h/2 + 25);
    backButton.move(w/2, h/2 + 30);
    folderButton.move(w/2 - menuWidth*0.3 + 5, h/2 - 25);

    t1.move(w/2, h/2);
    t2.move(w/2, h/2);
  }
}
