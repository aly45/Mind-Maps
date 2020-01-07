import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import toxi.geom.*; 
import toxi.physics2d.*; 
import toxi.physics2d.behaviors.*; 
import org.gicentre.handy.*; 
import org.gicentre.handy.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class mind_maps extends PApplet {

 //<>//




VerletPhysics2D physics;

Table nodeData = new Table(), connectorData = new Table();
ArrayList<Node> nodes;  //array list of nodes
ArrayList<Connector> connectors;  //array list of connectors (arrows/lines)
Vec2D mouse;//, lastnode, draggedline;//lastline;
float rectW = 70, rectH = 30;
float xAnchor, yAnchor;
String MODE = "PLACING_NODES"; // "NODE_SELECTED";
boolean overNode = false, nodeSelected = false, nodeMoved = false, drawing = false, sketchy = false, textLoaded = false, dragging = false;
Node selectedNode, someNode, sn, en; //startNode, endNode;
int sni, eni;//startNodeIndex, endNodeIndex;
int maxWidth = 800, maxHeight = 600;
Menu m;
//String path = dataPath("captures");    // current path to Data folder
String[] filenames;

public void settings() {
  size(maxWidth, maxHeight);
  smooth();
}

public void setup() {
  surface.setTitle("Mind Maps");  // add file name to this, or "New mind map" if no file selected
  surface.setResizable(true);
  //surface.setLocation(100, 100); // location on device screen

  m = new Menu();    // Creates new menu

  physics = new VerletPhysics2D();
  physics.setDrag (0.04f); //1, 0.025  

  nodes = new ArrayList<Node>();
  connectors = new ArrayList<Connector>();

  nodeData.addColumn("x");    // adds columns to table nodeData
  nodeData.addColumn("y");
  nodeData.addColumn("w");
  nodeData.addColumn("h");
  nodeData.addColumn("text");

  connectorData.addColumn("# row number");
  connectorData.addColumn("starting node index");    // adds columns to table connectorData
  connectorData.addColumn("ending node index");
  connectorData.clearRows();                           // resets table
}

public void draw() {
  background(150); //10, 17, 60);
  if (width > maxWidth) {
    maxWidth = width;
  }
  if (height > maxHeight) {
    maxHeight = height;
  }

  if (!m.showingMenu) {
    physics.setWorldBounds(new Rect(0, 0, maxWidth - 5, maxHeight - 5));  // should never shrink physics world bounds!   

    try {
      physics.update ();    // common error is having a null particle
    } 
    catch (NullPointerException e) {
      println(someNode);
      //exit();
    }

    mouse = new Vec2D(mouseX, mouseY);

    if (drawing) {
      stroke(0);
      line(xAnchor, yAnchor, mouseX, mouseY);
    }

    if (nodes.size() > 0) {
      overNode = nodes.get(0).mouseOver(nodes.get(0).x, nodes.get(0).y);
    }
    for (int i = 0; i < nodes.size(); i++) {    // goes through all the nodes
      overNode = overNode||(nodes.get(i).mouseOver(nodes.get(i).x, nodes.get(i).y));    // update global variable overNode
      nodes.get(i).sketch(nodes.get(i).selected);
      nodes.get(i).addText(nodes.get(i).selected && !textLoaded);
      textLoaded = true;

      if ((mousePressed)&&(mouseButton == LEFT)&&(nodes.get(i).mouseOver(nodes.get(i).x, nodes.get(i).y))) {
        nodes.get(i).lock();
        nodes.get(i).set(mouseX, mouseY);
      } else {
        nodes.get(i).unlock();
      }
    }
  }

  for (Connector c : connectors) {  // for every connector in the arrayList connectors,   
    //if (c.mouseOver()){
    //  println("over a connector!");
    //}
    c.mouseOver();
    c.display();         // display the connector
  }

  for (Node n : nodes) {  // for every node in the arrayList nodes,
    n.display();          // display the node
  }

  // updates and displays menu:
  m.move(width, height);
  m.display();

  //println("YES is " + m.yesButton.isOver);    // (prints for debugging)
  //println("NO is " + m.noButton.isOver);
}

public void mouseClicked() {
  //if ((mouseX==pmouseX)&&(mouseY==pmouseY)) { // stay still!  -- only need this if using mouseRelased() ?

  if (m.showingMenu) {
    if (m.X.isOver) {
      m.showingMenu = false;
      m.menuMode = "MAIN";
    } else if (m.menuMode=="MAIN") {      // MAIN MENU BUTTON CONTROLS
      if (m.saveButton.isOver) {
        m.menuMode = "SAVE";
        m.previousMode = "MAIN";
        m.saveButton.isOver = false;
      }
      if (m.loadButton.isOver) {
        m.menuMode = "LOAD";
        m.previousMode = "MAIN";
        m.loadButton.isOver = false;
      }
      if (m.newButton.isOver) {
        m.menuMode = "NEW";
        m.previousMode = "MAIN";
        m.newButton.isOver = false;
      }
    } else if (m.menuMode=="SAVE") {      // SAVE MENU CONTROLS
      if (m.yesButton.isOver) {
        m.filename = m.t1.text;
        // save file
        saveData(m.filename);
        // close menu
        m.showingMenu = false;
        m.menuMode = "MAIN";
        m.yesButton.isOver = false;
      }
      if (m.noButton.isOver) {
        m.filename = m.t1.text;
        // go back to typing
        m.t1.doneTyping = false;
        m.previousMode = "SAVE";
        m.noButton.isOver = false;
      }
      if ((m.backButton.isOver)) {
        println("entering back if statement");
        m.menuMode = "MAIN";
        m.t1.doneTyping = false;
      }
    } else if (m.menuMode=="LOAD") {      // LOAD MENU CONTROLS
      if (m.folderButton.isOver) {
        selectFolder("Select a folder to process:", "folderSelected");
        m.folderButton.isOver = false;
      }
      if (m.yesButton.isOver) {
        m.filename = m.t2.text;
        // LOAD FILE "filename"
        try {
          loadData(m.filename);
        } 
        catch (NullPointerException e) {
          e.printStackTrace();
        }

        for (int i = 0; i < nodes.size(); i++) {
          nodes.get(i).findAdjacentNodes(i, connectorData);
        }
        // menuMode = "END";
        m.menuMode = "MAIN";
        m.showingMenu = false;
        m.yesButton.isOver = false;
      }
      if (m.noButton.isOver) {
        m.filename = m.t2.text;
        m.t2.doneTyping = false;
        m.previousMode = "SAVE";
        m.noButton.isOver = false;
      }
      if (m.backButton.isOver) {
        println("entering back if statement");      
        m.t2.doneTyping = false;
        m.menuMode = "MAIN";
        m.backButton.isOver = false;
      }
    } else if (m.menuMode=="NEW") {      // NEW MENU CONTROLS
      if (m.yesButton.isOver) {
        m.filename = m.t2.text;
        // reset current filename to ""
        // reset current work  
        m.menuMode = "MAIN";
        m.showingMenu = false;
        m.yesButton.isOver = false;
      }
      if (m.noButton.isOver) {
        m.filename = m.t2.text;
        m.menuMode = "MAIN";
        m.noButton.isOver = false;
      }
      if (m.backButton.isOver) {
        println("entering back if statement");
        m.menuMode = "MAIN";
        m.backButton.isOver = false;
      }
    }
  } else {
    if (mouseButton == LEFT) {
      //println(nodes.size());
      if (!overNode) {
        if (nodeSelected) {    // don't want to add nodes if a node is selected. Want to deselect current node.
          nodeSelected = false;
          for (Node n : nodes) {
            //MODE = "NODE_DESELECTED";
            n.selected = false; //true;
            nodeSelected = nodeSelected||(n.selected);
          }
        } else { // may not need an else
          //MODE = "PLACING_NODES";
          nodeSelected = false;
          Node newNode = new Node(mouse, rectW, rectH, this);    // well hopefully this works!
          nodes.add(newNode);    // ADD a new NODE

          // Add new row to nodeData
          TableRow row = nodeData.addRow();
          row.setFloat("x", newNode.x);
          row.setFloat("y", newNode.y);
          row.setFloat("w", newNode.w);
          row.setFloat("h", newNode.h);
          row.setString("words", newNode.words);    // maybe just using StringList 'letters' as is would work too?
        }
      } else {
        nodeSelected = false;
        for (Node n : nodes) {
          if (n.mouseOver(n.x, n.y)) {    // mouse is L-clicked on a node
            //MODE = "NODE_SELECTED";
            n.selected = !n.selected; //true;
            nodeSelected = nodeSelected||(n.selected);
            selectedNode = n;
          } else {
            n.selected = false;
          }
        }
      }
    }
  }
}

public void mouseReleased() {
  if ((mouseButton == RIGHT)&&(nodes.size()>0)&&(!m.showingMenu)&&(overNode)) {
    xAnchor = mouseX;
    yAnchor = mouseY;

    if (!drawing) {
      TableRow row = connectorData.addRow();
      drawing = true;
      connectors.add(new Connector(new VerletParticle2D(xAnchor, yAnchor), new VerletParticle2D(xAnchor, yAnchor)));        // ADD a new CONNECTOR
      //startNode = connectors.get(connectors.size()-1).findClosestNode(nodes, new VerletParticle2D(xAnchor, yAnchor), false);       // find closest node 
      connectors.get(connectors.size()-1).startNode = connectors.get(connectors.size()-1).findClosestNode(nodes, new VerletParticle2D(xAnchor, yAnchor), false);       // find closest node //startNode;    // set connector startNode
      sn = connectors.get(connectors.size()-1).startNode;
      println(sn);

      connectors.get(connectors.size()-1).startNodeIndex = connectors.get(connectors.size()-1).getClosestIndex(nodes, new VerletParticle2D(xAnchor, yAnchor));       // return closest node index
      sni = connectors.get(connectors.size()-1).startNodeIndex;
      //connectors.get(connectors.size()-1).startNode = nodes.get(sn);    // set connector startNode
      row = connectorData.getRow(connectors.size()-1);
      row.setInt("starting node index", connectors.get(connectors.size()-1).startNodeIndex);
      println("Start node index is " + connectors.get(connectors.size()-1).startNodeIndex);
      connectors.set(connectors.size()-1, new Connector(connectors.get(connectors.size()-1).startNode, connectors.get(connectors.size()-1).startNode));  // set closest node as new starting node (for this connection)
    } else {
      TableRow row = connectorData.getRow(connectors.size()-1);
      drawing = false;
      //endNode = connectors.get(connectors.size()-1).findClosestNode(nodes, new VerletParticle2D(xAnchor, yAnchor), true);       // find closest node
      connectors.get(connectors.size()-1).endNode = connectors.get(connectors.size()-1).findClosestNode(nodes, new VerletParticle2D(xAnchor, yAnchor), true);//endNode;  // set connector endNode
      en = connectors.get(connectors.size()-1).endNode;
      println(en);

      connectors.get(connectors.size()-1).endNodeIndex = connectors.get(connectors.size()-1).getClosestIndex(nodes, new VerletParticle2D(xAnchor, yAnchor));       // return closest node index
      eni = connectors.get(connectors.size()-1).endNodeIndex;
      //connectors.get(connectors.size()-1).endNode = nodes.get(en);  // set connector endNode
      row.setInt("ending node index", connectors.get(connectors.size()-1).endNodeIndex);
      //println("End node index is " + connectors.get(connectors.size()-1).endNodeIndex);
      connectors.get(connectors.size()-1).setEndpoint(connectors.get(connectors.size()-1).endNode, connectors.get(connectors.size()-1).endNode);          // set closest node as end node (for this connection)

      connectors.get(connectors.size()-1).connect(sn, en, -15);            // connect the nodes together with a verletSpring
      Connector c = connectors.get(connectors.size()-1);                   // c is the last connection in the connectors ArrayList

      //println("c.curveBegin is ......." + c.curveBegin + ", and c.curveEnd is ......." + c.curveEnd);
      // Delete duplicate connectors:
      if (connectors.size()>1) {
        for (int i = connectors.size() - 2; i >= 0; i--) {                           // this loop removes duplicate connectors
          //if (c.curveBegin != c.curveEnd) {
          //println("INITIAL CONNECTORS SIZE: " + connectors.size());
          //println("connectors.get(i).curveBegin is ......." + connectors.get(i).curveBegin + ", and connectors.get(i).curveEnd is ......." + connectors.get(i).curveEnd);
          if (((connectors.get(i).curveBegin == c.curveBegin)&&(connectors.get(i).curveEnd == c.curveEnd))
            ||((connectors.get(i).curveBegin == c.curveEnd)&&(connectors.get(i).curveEnd == c.curveBegin))) {
            //delete connector from list and physics world:
            //connectors.get(i).delete();  // not even sure if this is necessary, or if it even works


            println("curveBegin = " + connectors.get(i).curveBegin);
            println("curveEnd = " + connectors.get(i).curveEnd);

            connectors.remove(i);        // removes connector from arraylist

            //delete connector i from table:
            connectorData.removeRow(i);            

            println("DELETED A CONNECTOR");
          }
          //}
          //println("FINAL CONNECTORS SIZE: " + connectors.size());
        }
      }

      //Deletes connectors connecting a node to itself
      if (connectors.size()>1) {
        println("INITIAL CONNECTORS SIZE: " + connectors.size());
        if (connectors.get(connectors.size()-1).curveBegin == connectors.get(connectors.size()-1).curveEnd) {
          //delete connector from list and physics world:
          //connectors.get(connectors.size()-1).delete();  // not even sure if this is necessary, or if it even works
          connectors.remove(connectors.size()-1);        // removes connector from arraylist

          //delete connector i from table:
          connectorData.removeRow(connectorData.getRowCount() - 1);  // should maybe use connectorData.getRowCount() here instead

          println("DELETED A CONNECTOR");
        }
        println("FINAL CONNECTORS SIZE: " + connectors.size());
      }

      // Update 'connections' list for each node
      for (int i = 0; i < nodes.size(); i++) {
        nodes.get(i).findAdjacentNodes(i, connectorData);
      }

      // Update startNodeIndex and endNodeIndex for each connector
      if (connectorData.getRowCount() > 0) {
        updateConnectedNodes(connectorData);
      }
    }
  }
}

// Sets all startNodeIndex and endNodeIndex values in ArrayList Connectors using a table (use connectorData)
public void updateConnectedNodes(Table t) {  //input connectorData table
  int rowNum = 0;
  //println("***connectors size is____ " + connectors.size());
  //println("*** number of rows in connectorData is____ " + t.getRowCount());
  for (TableRow row : t.rows()) {          // for all rows in t
    //println("***table row " + rowNum + " is " + t.getRow(rowNum));    
    connectors.get(rowNum).startNodeIndex = PApplet.parseInt(row.getString("starting node index"));      // does .get().startNodeIndex actually set startNodeIndex?
    connectors.get(rowNum).endNodeIndex = PApplet.parseInt(row.getString("ending node index"));
    rowNum++;
  }
}

public void keyTyped() {
  // type in menu text boxes
  if (m.showingMenu) {
    if (m.menuMode == "SAVE") {
      m.t1.addText(m.t1.doneTyping);
    } else if (m.menuMode == "LOAD") {
      m.t2.addText(m.t2.doneTyping);
    }
  } else {
    // type in node text areas
    textSize(20);
    for (int i = 0; i < nodes.size(); i++) {    // goes through all the nodes
      nodes.get(i).addText(nodes.get(i).selected);     // add text to selected node
    }
  }
}

public void keyPressed() {
  if (key == ESC) {
    key = 0;  // clears current key to override usual exit function
    if (m.showingMenu) {
      m.menuMode = "MAIN";
    }
    m.showingMenu = !m.showingMenu;
  }
  if (keyCode == 123) {
    screenshot();
  }
  //if (key == 'a') {      // this is for testing purposes
  //  for (int i = 0; i <= nodes.size() - 1; i++) {
  //    nodes.get(i).findAdjacentNodes(i, connectorData);
  //    println("\n node " + i + " is connected to nodes:");
  //    for (int j = 0; j <= nodes.get(i).connections.size() - 1; j++) {
  //      println(nodes.get(i).connections.get(j));
  //    }
  //  }
  //}
  if (((key == BACKSPACE)||(key == DELETE))&&(overNode)) {      // FIX: when all nodes are deleted, can't add new nodes. Why?
    println("nodeData has " + nodeData.getRowCount() + " rows");
    println("_____________________________________________________");
    // Find and delete node:
    // Find the node to be deleted:
    if (nodes.size() > 0) {
      int i = 0;  // This is the index of the node to be deleted
      for (int n = nodes.size() - 1; n >= 0; n--) {      // for all nodes
        if (nodes.get(n).mouseOver(nodes.get(n).x, nodes.get(n).y)) {  // find the specific node that is moused over
          // Now we know which node we are deleting:
          i = n;
        }
      }

      // Remove node index i from all nodes' connections IntLists:
      println("REMOVING NODE " + i + " FROM CONNECTIONS INTLISTS");
      for (int j = nodes.size() - 1; j >= 0; j--) {      // for all nodes
        for (int c = nodes.get(j).connections.size() - 1; c >= 0; c--) {      // for all node(j)'s connections
          if (nodes.get(j).connections.get(c) == i) {
            println("removing node " + j + "'s connection int" + nodes.get(j).connections.get(c));
            nodes.get(j).connections.remove(c);
          }
        }
      }

      // Remove node i from nodes ArrayList:
      println("REMOVING NODE " + i + " FROM NODES ARRAYLIST");
      nodes.get(i).delete(i);
      nodes.remove(i);
      println("REMOVING NODE ROW " + i + " FROM TABLE nodeData");
      nodeData.removeRow(i);    // hopefully this is removing the correct row!
      println("nodeData has " + nodeData.getRowCount() + " rows");

      // Shift down connections ints for > i:
      println("SHIFTING DOWN ALL CONNECTIONS' INTS > " + i);
      for (int j = nodes.size() - 1; j >= 0; j--) {      // for all nodes
        for (int c = nodes.get(j).connections.size() - 1; c >= 0; c--) {            // for all node(j)'s connections
          if (nodes.get(j).connections.get(c) > i) {
            println("shifting down node " + nodes.get(j).connections.get(c) + " to ");
            nodes.get(j).connections.set(c, nodes.get(j).connections.get(c) - 1);   // decrement the cth connection
            println("become node " + nodes.get(j).connections.get(c));
          }
        }
      }

      updateConnectedNodes(connectorData);  //updates all startNodes and endNodes

      // Remove all connectors with startNode = i OR endNode = i:
      println("The size of connectors arraylist is: " + connectors.size());
      println("REMOVING ALL CONNECTORS FROM CONNECTORS ARRAYLIST WITH startNodeIndex = " + i + " OR endNodeIndex = " + i);
      for (int c = connectors.size() - 1; c >= 0; c--) {    // for all connectors
        println("Connector " + c + " has startNodeIndex " + connectors.get(c).startNodeIndex + " and endNodeIndex " +  connectors.get(c).endNodeIndex);
        // Check if startNodeIndex or endNodeIndex = i
        if ((connectors.get(c).startNodeIndex == i)||(connectors.get(c).endNodeIndex == i)) {

          //Delete physics for this connector:
          connectors.get(c).delete(c);
          //Remove this connector from connectors list:
          println("Removing connector " + c + " with startNodeIndex " + connectors.get(c).startNodeIndex + " and endNodeIndex " +  connectors.get(c).endNodeIndex);
          connectors.remove(c);
        }
      }
      println("The size of connectors arraylist is: " + connectors.size());

      // Delete connectors from table ConnectorData:
      println("DELETING CONNECTOR ROWS FROM TABLE ConnectorData");
      for (int r = connectorData.getRowCount() - 1; r >= 0; r--) {
        TableRow row = connectorData.getRow(r);    // row is the rth row of connectorData
        if ((PApplet.parseInt(row.getString("starting node index")) == i)||(PApplet.parseInt(row.getString("ending node index")) == i)) {
          connectorData.removeRow(r);
        }
      }

      // Shift down connectors' startNodes and endNodes in table ConnectorData:
      println("SHIFTING DOWN CONNECTOR startNodes AND endNodes IN TABLE ConnectorData");
      for (int r = connectorData.getRowCount() - 1; r >= 0; r--) {
        TableRow row = connectorData.getRow(r);    // row is the rth row of connectorData
        int prevInt = PApplet.parseInt(row.getString("starting node index"));
        if (prevInt > i) {
          row.setInt("starting node index", prevInt - 1);
        }
        prevInt = PApplet.parseInt(row.getString("ending node index"));
        if (prevInt > i) {
          row.setInt("ending node index", prevInt - 1);
        }
      }
    }
  }
}

public void saveData(String filename) {
  nodeData.clearRows();                      // resets table
  for (int i = 0; i < nodes.size(); i++) {   // fills rows of table
    TableRow row = nodeData.addRow();
    row.setFloat("x", nodes.get(i).x);
    row.setFloat("y", nodes.get(i).y);
    row.setFloat("w", nodes.get(i).w);
    row.setFloat("h", nodes.get(i).h);
    row.setString("words", nodes.get(i).words);    // maybe just using StringList 'letters' as is would work too?
  }
  saveTable(nodeData, filename + "/nodeData.csv");
  saveTable(connectorData, filename + "/connectorData.csv");
}

public void loadData(String filename) {        // FIX: loading a file when nodes/connectors are already present, results in strange things...

  nodes.clear();             // clear the nodes ArrayList
  connectors.clear();             // clear the connectors ArrayList
  physics.clear();

  // LOAD NODES
  nodeData = loadTable(filename + "/nodeData.csv", "header");
  //connectorData = loadTable(filename + "/connectorData.csv", "header");

  for (int i = 0; i<nodeData.getRowCount(); i++) {
    // Iterate over all the rows in table rowData
    TableRow row = nodeData.getRow(i);

    // Access the fields via their column name (or index)
    float x = row.getFloat("x");
    float y = row.getFloat("y");
    float w = row.getFloat("w");
    float h = row.getFloat("w");
    String t = row.getString("words");

    // Turn each row into a node
    if (x > 0) { // this makes sure blank rows aren't being turned into nodes (checks validity of x position)
      nodes.add(new Node(new Vec2D(x, y), w, h, this));    // ADD a new NODE
      nodes.get(i).k = t.length();
      nodes.get(i).letters.clear();
      for (int c = 0; c < t.length(); c++) {
        nodes.get(i).letters.append(str(t.charAt(c)));      // fills the letters ArrayList
      }
    }
  }
  println("Loaded " + nodes.size() + " nodes.");

  // LOAD CONNECTORS
  //connectors.clear();             // clear the connectors ArrayList
  connectorData = loadTable(filename + "/connectorData.csv", "header");

  for (int i = 0; i<connectorData.getRowCount(); i++) {
    // Iterate over all the rows in table connectorData
    TableRow row = connectorData.getRow(i);

    // Access the fields via their column name (or index)
    //String rowNum = row.getString("# row number");
    int sni = row.getInt("starting node index");
    int eni = row.getInt("ending node index");

    // Turn each row into a connector
    if (sni != eni) {    // a node can't be connected to itself
      connectors.add(new Connector(nodes.get(sni), nodes.get(sni)));    // ADD a new CONNECTOR
      connectors.get(connectors.size()-1).setEndpoint(nodes.get(eni), nodes.get(eni));          // set closest node as end node (for this connection)
      connectors.get(connectors.size()-1).connect(nodes.get(sni), nodes.get(eni));              // connect the nodes together with a verletSpring
    }
  }
  updateConnectedNodes(connectorData);  //updates all startNodes and endNodes
  println("Loaded " + connectors.size() + " connectors.");
}

public void folderSelected(File selection) {
  if (selection == null) {
    println("You folde(re)d.");
  } else {
    String filePath = selection.getAbsolutePath();
    println("You selected: " + filePath);
    String[] match = match(filePath, "([^\\\\]*)$");
    if (match != null) {
      m.filename = match[0];
      println("match found is: " + m.filename);
      //path = filePath;            // should update path somehow
    }

    m.t2.text = m.filename;        // sets textbox text to file path
    m.t2.k = m.t2.text.length();   // sets number of characters in letters arraylist
    m.t2.letters.clear();
    for (int c = 0; c < m.t2.k; c++) {
      m.t2.letters.append(str(m.t2.text.charAt(c)));      // fills the letters ArrayList of the t2 textbox of menu m
    }
  }
}

public void screenshot() {
  String path = sketchPath();//sketchPath("Data");    // current path to Data folder
  println("Saving capture to " + path);
  String[] filenames = listFileNames(path);
  int numCaptures = 0;
  for (int i = 0; i < filenames.length; i++) {
    if (filenames[i].length() > 7) {
      println(filenames[i].substring(0, 7));
      if (filenames[i].substring(0, 7).equals("capture")) {
        numCaptures++;
      }
    }
  }
  printArray(filenames);
  println("number of capture files is " + numCaptures);
  save("capture-" + numCaptures + ".png");    // this actually saves to the sketch folder unless save(path + "capture-" + numCaptures + ".png"); is used instead
}

// Listing file names (Daniel Shiffman):
public String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    return null;
  }
}
class Button {
  float fontSize = 32.3f;
  float x; //left location of button
  float y; //top location of button
  float w; //button width
  float h; //button height
  int c; //colour
  String s; //button text
  float centreX;
  float centreY;
  float textX; //leftmost of button text
  float textY; //bottom of button text
  float b_alpha; //button opacity
  float litAlpha = 255, darkAlpha = 100;
  boolean isOver = false;

  Button(String text, float xTemp, float yTemp, float wTemp, float hTemp, int colour, float size) {
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

  public void mouseOver() {
    if (((mouseX >= x-w/2)&&(mouseX <= x+w/2)) && 
      ((mouseY >= y-h/2)&&(mouseY <= y+h/2))) {
      isOver = true;
    } else {
      isOver = false;
    }
  }

  public void display(float tempAlpha) {
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
  
    public void move(float tempX, float tempY){
    x = tempX;
    y = tempY;
  }
}

class XButton extends Button{
  int Xcolour;
  float buffer = 5;
  XButton(String text, float xTemp, float yTemp, float wTemp, float hTemp, int colour, int xc) { // button colour, X colour
    super(text, xTemp, yTemp, wTemp, hTemp, colour, xc);
    Xcolour = xc;
  }
  
  public void display(float tempAlpha) {
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
    line(x-w/2 + buffer,y-h/2 + buffer,x+w/2 - buffer,y+h/2 - buffer);
    line(x-w/2 + buffer,y+h/2 - buffer,x+w/2 - buffer,y-h/2 + buffer);     
  }
}
class Connector {
  Vec2D curveBegin, anchor1, anchor2, curveEnd, node1Pos, node2Pos, connectorVector, VirtualPos1, VirtualPos2;
  //int connectedFrom; // node number in nodes ArrayList
  //int connectedTo;   // node number in nodes ArrayList
  Node startNode, endNode, closestNode;
  int startNodeIndex, endNodeIndex, n;
  //boolean drawing = false;    // is the connector currently being drawn?
  float dist;
  float springLength = 130;
  float springStrength = 0.0015f;//0.002;
  float virtualDistance = 0.0001f; //0.01 changing this won't change much because of the repulsion forces on the virtual particles (?)
  //float strength = 2;
  String connectionMode;
  VerletParticle2D v1, v2;
  AttractionBehavior2D a1, a2;  //attraction behaviours of virtual particles v1 and v2
  VerletSpring2D s1, s2, s3;    //goes start node > s1 > v1 > s2 > v2 > s3 > endNode

  Connector(VerletParticle2D p1, VerletParticle2D p2) { //add extra two PVector positions if using bezier
    curveBegin = p1;
    anchor1 = p2;    // where the curve start should be next
  }

  public void display() {
    strokeWeight(2);
    noFill();
    if ((curveBegin != null)&&(curveEnd != null)) {  // checks if curveBegin and curveEnd are actually assigned.
      if (curveBegin != curveEnd) {
        stroke(0);
        bezier(curveBegin.x, curveBegin.y, v1.x, v1.y, v2.x, v2.y, curveEnd.x, curveEnd.y);
        //stroke(255);
        //ellipse(v1.x, v1.y, 5, 5);
        //ellipse(v2.x, v2.y, 5, 5);
      }
    }
  }

  public Node findClosestNode(ArrayList<Node> candidates, VerletParticle2D anchor, boolean beingDrawn) {    // finds closest node to connector end(s)
    float minDist = width*height;
    for (int i = candidates.size()-1; i >= 0; i--) {
      dist = sqrt(sq(candidates.get(i).x - anchor.x) + sq(candidates.get(i).y - anchor.y));
      if ((dist < minDist)) { //&&(dist != 0)
        minDist = dist;
        closestNode = candidates.get(i);
        if (!beingDrawn) {
          startNode = nodes.get(i);    // ok, so I guess I can just use nodes since it's public?
        } else {
          endNode = nodes.get(i);
        }
      }
    }
    //println(n);
    return closestNode;
  }

  public int getClosestIndex(ArrayList<Node> candidates, VerletParticle2D anchor) {    // returns closest node index. No idea why cloestNode is always 0 if I try to extract it without using this function.
    float minDist = width*height;
    for (int i = candidates.size()-1; i >= 0; i--) {
      dist = sqrt(sq(candidates.get(i).x - anchor.x) + sq(candidates.get(i).y - anchor.y));
      if ((dist < minDist)) { //&&(dist != 0)
        minDist = dist;
        //if (minDist < 20) {      // limit to some radius
        closestNode = candidates.get(i);
        n = i;

        //}
      }
    }
    return n;  // should check for closestNode == null (if limiting minDist to some radius)
  }

  public void setEndpoint(VerletParticle2D p3, VerletParticle2D p4) {
    anchor2 = p3;    // where the curve end point should be next
    curveEnd = p4;
  }

  //// Connects nodes with connectors from tables
  public void connect(Node n1, Node n2) { // add a spring between two connected nodes
    float nodesDist = sqrt(sq(n1.x - n2.x) + sq(n1.y - n2.y));
    node1Pos = new Vec2D(n1.x, n1.y); // node 1 position vector
    node2Pos = new Vec2D(n2.x, n2.y); // node 2 position vector
    connectorVector = node2Pos.sub(node1Pos); // hopefully this is pointing from node 1 to node 2
    //Vec2D connectionVector = new Vec2D(n2.x - n1.x, n2.y - n1.y); // points from node 1 to node 2    
    VirtualPos1 = node1Pos.add(connectorVector.scale(0.01f));  // position vector of virtual particle 1
    VirtualPos2 = node2Pos.sub(connectorVector.scale(0.01f));  // position vector of virtual particle 2

    if (curveBegin != curveEnd) {
      v1 = new VerletParticle2D(VirtualPos1);
      a1 = new AttractionBehavior2D(v1, 73, -n1.strength);
      physics.addBehavior(a1);
      physics.addParticle(v1);
      v2 = new VerletParticle2D(VirtualPos2);
      physics.addParticle(v2);
      a2 = new AttractionBehavior2D(v2, 73, -n1.strength);
      physics.addBehavior(a2);
      s1 = new VerletSpring2D(n1, v1, nodesDist*virtualDistance, springStrength);
      physics.addSpring(s1);  // mini spring from first node
      //println("node 1 is at " + n1.x + ", " + n1.y);      

      //println("virtual particle 1 is at: " + VirtualPos1.x + ", " + VirtualPos1.y);
      s2 = new VerletSpring2D(v1, v2, nodesDist*0.7f, springStrength);
      physics.addSpring(s2);  // main verlet spring

      //println("virtual particle 2 is at: " + VirtualPos2.x + ", " + VirtualPos2.y);
      s3 = new VerletSpring2D(v2, n2, nodesDist*virtualDistance, springStrength);
      physics.addSpring(s3);  // mini spring from second node
      //println("node 2 is at " + n2.x + ", " + n2.y);
    }
  }

  // Connects nodes with connectors by clicking
  // want to add an additional verlet particle connection to each node connection
  public void connect(Node n1, Node n2, float tempLength) { // add a spring between two connected nodes
    float nodesDist = sqrt(sq(n1.x - n2.x) + sq(n1.y - n2.y));
    // calculate where virtual particles are:
    node1Pos = new Vec2D(n1.x, n1.y); // node 1 position vector
    node2Pos = new Vec2D(n2.x, n2.y); // node 2 position vector
    connectorVector = node2Pos.sub(node1Pos); // points from node 1 to node 2  
    VirtualPos1 = node1Pos.add(connectorVector.scale(virtualDistance));  // position vector of virtual particle 1
    VirtualPos2 = node2Pos.sub(connectorVector.scale(virtualDistance));  // position vector of virtual particle 2

    if (curveBegin != curveEnd) {
      v1 = new VerletParticle2D(VirtualPos1);
      a1 = new AttractionBehavior2D(v1, 73, -n1.strength);
      physics.addBehavior(a1);
      physics.addParticle(v1);
      v2 = new VerletParticle2D(VirtualPos2);
      a2 = new AttractionBehavior2D(v2, 73, -n1.strength);
      physics.addBehavior(a2);
      physics.addParticle(v2);
      s1 = new VerletSpring2D(n1, v1, nodesDist*virtualDistance, springStrength);
      physics.addSpring(s1);  // mini spring from first node
      //println("node 1 is at " + n1.x + ", " + n1.y);      

      //println("virtual particle 1 is at: " + VirtualPos1.x + ", " + VirtualPos1.y);
      s2 = new VerletSpring2D(v1, v2, nodesDist*0.7f + tempLength, springStrength);
      physics.addSpring(s2);  // main verlet spring

      //println("virtual particle 2 is at: " + VirtualPos2.x + ", " + VirtualPos2.y);
      s3 = new VerletSpring2D(v2, n2, nodesDist*virtualDistance, springStrength);
      physics.addSpring(s3);  // mini spring from second node
      //println("node 2 is at " + n2.x + ", " + n2.y);
    }
  }

  // If deleting a connector by deleting the attached node
  public void delete(Node n, int nodeIndex) { //Node n
    if ((nodeIndex == startNodeIndex)||(nodeIndex == endNodeIndex)) {  //checks if n is actually a starting or ending node for this connection    // for some reason, startNode isn't updating and is always null
      println("Deleting connection between startNode " + startNodeIndex + " and endNode " + endNodeIndex);
      // deletes all virtual particles in this connection

      physics.removeSpring(s1);      // remove mini spring from first node to v1
      physics.removeSpring(s2);      // remove spring from v1 to v2
      physics.removeSpring(s3);      // remove mini spring from v2 to last node

      if (n != null) {
        physics.removeBehavior(n.a); // delete node particle attraction behaviour
        physics.removeParticle(n);   // delete node particle
      }

      physics.removeBehavior(a1);    // delete virtual particle 1 attraction behaviour
      physics.removeParticle(v1);    // delete virtual particle 1

      physics.removeBehavior(a2);    // delete virtual particle 2 attraction behaviour
      physics.removeParticle(v2);    // delete virtual particle 2

      //physics.removeParticle(end);
    }
  }

  // If deleting a connector by first selecting the connector:
  public void delete(int i) {    // Node start, Node end
    println("Deleting connector " + i + " physics...");
    // deletes all virtual particles in this connection
    //physics.removeParticle(start);  // don't want to remove starting and ending nodes!
    
    physics.removeSpring(s1);  // remove mini spring from first node to v1
    physics.removeSpring(s2);  // remove spring from v1 to v2
    physics.removeSpring(s3);  // remove mini spring from v2 to last node

    physics.removeBehavior(a1);
    physics.removeParticle(v1);
    
    physics.removeBehavior(a2);
    physics.removeParticle(v2);
  }

  //boolean mouseOver() {    // can use startNodeIndex and endNodeIndex
  //  //float gradient = (v2.y-v1.y)/(v2.x-v1.x);    // gradient between the virtual particles v1 and v2
  //  if ((startNode != null)&&(endNode != null)&&(mouseX > min(startNode.x, endNode.x))&&(mouseX < max(startNode.x, endNode.x))
  //    &&(mouseY > min(startNode.y, endNode.y))&&(mouseY < max(startNode.y, endNode.y))
  //    &&(mouseY == (v2.y-v1.y)/(v2.x-v1.x)*startNode.x + startNode.y)) {
  //    return true;
  //  } else {
  //    return false;
  //  }
  //}

  public void mouseOver() {    // can use startNodeIndex and endNodeIndex
    //float gradient = (v2.y-v1.y)/(v2.x-v1.x);    // gradient between the virtual particles v1 and v2
    if ((startNode != null)&&(endNode != null)&&(mouseX > min(startNode.x, endNode.x))&&(mouseX < max(startNode.x, endNode.x))
      &&(mouseY > min(startNode.y, endNode.y))&&(mouseY < max(startNode.y, endNode.y))
      ) {
      println("OVER a connector");
    } else {
      //println("Starting node is : " + startNode);
      //println("NOT over a connector");
    }
  }
}

class Menu {
  float menuWidth = 300, menuHeight = 100;
  int numButtons = 3, divisions = numButtons + 1;
  float buttonWidth = 80, buttonHeight = 40, xSize = 18;
  int w = 800, h = 600, dispTime = 60; // dispTime is number of frames for displaying a message
  int yellow = color(237, 226, 33), green = color(77, 168, 70), aqua = color(4, 211, 156), blue = color(4, 107, 211), purple = color(98, 3, 193), magenta = color(155, 3, 160), red_pink = color(160, 3, 102), orange = color(221, 118, 33);
  float size1 = 32.3f, size2 = 23.2f;
  String menuMode = "MAIN", filename, previousMode = "";
  boolean showingMenu = false;

  Button X, saveButton, loadButton, newButton, yesButton, noButton, backButton, folderButton;

  TextBox t1, t2;

  Menu() {
    X = new XButton("X", w/2 + menuWidth/2 - xSize/2 - 0.5f, h/2 - menuHeight/2 + xSize/2 + 1, xSize, xSize, green, color(255));
    saveButton = new Button("Save", w/2 - menuWidth/2 + (menuWidth/divisions) - 20, h/2, buttonWidth, buttonHeight, green, size1);
    loadButton = new Button("Load", w/2 - menuWidth/2 + 2*(menuWidth/divisions), h/2, buttonWidth, buttonHeight, blue, size1);
    newButton = new Button("New", w/2 - menuWidth/2 + 3*(menuWidth/divisions) + 20, h/2, buttonWidth, buttonHeight, orange, size1);
    yesButton = new Button("Yes", w/2 - menuWidth/5, h/2 + 25, buttonWidth - 15, buttonHeight  - 15, green, size2);
    noButton = new Button("No", w/2 + menuWidth/5, h/2 + 25, buttonWidth - 15, buttonHeight  - 15, red_pink, size2);
    backButton = new Button("Back", w/2, h/2 + 30, buttonWidth - 15, buttonHeight  - 15, green, size2);
    folderButton = new Button("Choose folder", w/2 - menuWidth*0.3f + 5, h/2 - 25, buttonWidth + 27, buttonHeight  - 20, green, 15);

    t1 = new TextBox(w/2, h/2, menuWidth*0.8f, 25);
    t2 = new TextBox(w/2, h/2, menuWidth*0.8f, 25);
  }

  public void display() {
    // Draw menu:
    if (showingMenu) {
      stroke(green, 220);
      strokeWeight(2);
      fill(0, 230);
      rect(w/2, h/2, menuWidth, menuHeight);
      X.display(160);
      X.mouseOver();

      switch(menuMode) {
      case "MAIN":
        saveButton.display(160);
        saveButton.mouseOver();
        loadButton.display(160);
        loadButton.mouseOver();
        newButton.display(160);
        newButton.mouseOver();
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

  public void move(int tw, int th) {  // w and h are screen width and height or wherever to move the menu
    w = tw;
    h = th;
    X.move(w/2 + menuWidth/2 - xSize/2 - 0.5f, h/2 - menuHeight/2 + xSize/2 + 1);
    saveButton.move(w/2 - menuWidth/2 + (menuWidth/divisions) - 20, h/2);
    loadButton.move(w/2 - menuWidth/2 + 2*(menuWidth/divisions), h/2);
    newButton.move(w/2 - menuWidth/2 + 3*(menuWidth/divisions) + 20, h/2);
    yesButton.move(w/2 - menuWidth/5, h/2 + 25);
    noButton.move(w/2 + menuWidth/5, h/2 + 25);
    backButton.move(w/2, h/2 + 30);
    folderButton.move(w/2 - menuWidth*0.3f + 5, h/2 - 25);

    t1.move(w/2, h/2);
    t2.move(w/2, h/2);
  }
}

HandyRenderer HR;

class Node extends VerletParticle2D {
  boolean sketchy = false;
  float fontSize = 20, vertSpace = 20, w = 70, h = 30, maxWidth = 120, radius, strength = 1; //0.2;
  PFont gulim = createFont("Gulim", fontSize);
  boolean selected = false, highlighted = false, wrapped = false;
  Vec2D displacement, velocity, acceleration; // initialised from draw screen origin (0,0)
  StringList letters = new StringList();
  String words = "";
  int k = 0;
  IntList connections = new IntList();    // array of node indices that this node is connected to
  String connectionMode;
  AttractionBehavior2D a;

  Node(Vec2D loc, float tempw, float temph, PApplet pa) {
    super(loc);  // loc is an x, y vector (I think)
    //displacement = loc;
    //velocity = this.getVelocity();
    physics.addParticle(this);

    w = tempw;  // width and height of node
    h = temph;

    a = new AttractionBehavior2D(this, 73, -strength);  // sets a to new 2D attraction behavior
    physics.addBehavior(a); // the second entry used to be: w + 3, but having differing attractionbehaviors makes things go crazy

    // HANDY STUFF:
    HR = HandyPresets.createMarker(pa); //new HandyRenderer(this);
    HR.setHachurePerturbationAngle(12);
    HR.setRoughness(1.1f);
    HR.setFillGap(5);
    HR.setFillWeight(2);
    HR.setStrokeWeight(1.5f);
    //HR.setIsAlternating(true);
  }

  public void display() {    // draws the node (rectangle)
    fill(255);
    rectMode(CENTER);
    HR.setIsHandy(sketchy);   // if node selected, make rectangle sketchy
    if (highlighted) {
      strokeWeight(2);
      stroke(0);
    } else {
      noStroke();
    }
    HR.rect(x, y, w, h);      // draw node as a rectangle
    fill(0);
    textAlign(CENTER);
    textFont(gulim);
    textSize(fontSize);
    textLeading(vertSpace);
    text(words, x, y, w, h);  // display typed text on rectangle location
  }

  public void sketch(boolean selected) {
    if (selected) {
      sketchy = true;
    } else {
      sketchy = false;
    }
  }

  public void addText(boolean selected) {
    if (selected) {
      if (key == BACKSPACE) {
        if (k>0) {
          letters.remove(k-1);
          k -= 1;
        }
      } else {
        letters.append(str(key)); 
        k += 1;
      }
    }

    words = "";
    for (int i=0; i<letters.size(); i+=1) {  // build up words String out of letters StringList
      words += letters.get(i);
    }

    if (letters.size()>0) {

      w = textWidth(words) + 5;    // resizes width of node and text area

      int lastIndex = 0;
      int numNewlines = 0;
      h = 25;
      if (words.contains("\n")) {
        for (int i = 0; i < words.length(); i++) {
          int n = words.indexOf("\n", i);
          if ((n > -1)&&(n != lastIndex)) {
            numNewlines += 1;
          }
          lastIndex = n;
        }
      }
      h += numNewlines*(fontSize);    // resizes height of node and text area
    } else {
      w = 70;
      h = 30;
    }
  }

  public void findAdjacentNodes(int i, Table t) {  //input current node index, connectorData table
    //int numConnections = 0;
    connections.clear();
    //String lastIndex = "";
    int rowNum = 0;
    for (TableRow row : t.findRows(str(i), "starting node index")) {    // finds rows with starting node index i
      connectors.get(rowNum).startNodeIndex = PApplet.parseInt(row.getString("starting node index"));
      connectors.get(rowNum).endNodeIndex = PApplet.parseInt(row.getString("ending node index"));
      if ((PApplet.parseInt(row.getString("starting node index")) != PApplet.parseInt(row.getString("ending node index")))&&(!connections.hasValue(PApplet.parseInt(row.getString("ending node index"))))) {
        connections.append(PApplet.parseInt(row.getString("ending node index")));    // compiles list of nodes to which this node is connected
      }
      rowNum++;
    }
    rowNum = 0;
    //println(t.getRowCount() + " rows");
    for (TableRow row : t.findRows(str(i), "ending node index")) {    // finds rows with starting node index i
      //println(connectors.size());

      connectors.get(rowNum).startNodeIndex = PApplet.parseInt(row.getString("starting node index"));
      connectors.get(rowNum).endNodeIndex = PApplet.parseInt(row.getString("ending node index"));
      if ((PApplet.parseInt(row.getString("starting node index")) != PApplet.parseInt(row.getString("ending node index")))&&(!connections.hasValue(PApplet.parseInt(row.getString("starting node index"))))) {
        connections.append(PApplet.parseInt(row.getString("starting node index")));    // compiles list of nodes to which this node is connected
        //println(row.getString("ending node index") + " connects to " + row.getString("starting node index"));
      }
      rowNum++;
    }
    //int duplicates = 0;
    //for (int i = connections.size() - 1; i >= 0; i--){
    //  for (int j = connections.size() - 1; j >= 0; j--){
    //  if (
    //}
  }

  public boolean mouseOver(float tempx, float tempy) {    //tempx and tempy are the centre of the node (could just remove these args)
    if ((pmouseX >= tempx - w/2)&&(pmouseX <= tempx + w/2) && 
      (pmouseY >= tempy - h/2)&&(pmouseY <= tempy + h/2)) {
      highlighted = true;
      return true;
    } else {
      highlighted = false;
      return false;
    }
  }

  public void delete(int i) {
    println("Deleting node " + i + " physics...");
    //if (this != null) {
    physics.removeBehavior(this.a); // delete node particle attraction behaviour
    physics.removeParticle(this);   // delete node particle
    //}
  }
}

class TextBox {
  float fontSize = 20, vertSpace = 20, w = 70, h = 30, x, y;
  boolean selected = false, doneTyping = false;
  StringList letters = new StringList();
  String text = "";
  int k = 0;

// TODO: should shift text left by last character width whenever total text width exceeds text box size
  TextBox(float xPos, float yPos, float boxWidth, float boxHeight) {
    x = xPos;
    y = yPos;
    w = boxWidth;
    h = boxHeight;
  }

  public void display(boolean finishedTyping) {
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
      text(text, x+2, y, w, h);  // display typed text on rectangle location
    }
  }

  public void addText(boolean finishedTyping) {  
    doneTyping = finishedTyping;
    if (!doneTyping) {
      if ((key == ENTER)||(key == RETURN)) {
        if (k>0) {
          doneTyping = true;
          m.filename = m.t2.text;
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

      text = "";
      for (int i=0; i<letters.size(); i+=1) {  // build up words String out of letters StringList
        text += letters.get(i);
      }
    }
  }
  
  public void move(float tempX, float tempY){
    x = tempX;
    y = tempY;
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "mind_maps" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
