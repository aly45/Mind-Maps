import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import org.gicentre.handy.*;

VerletPhysics2D physics;

Table nodeData = new Table(), connectorData = new Table();
ArrayList<Node> nodes;  //array list of nodes
ArrayList<Connector> connectors;  //array list of connectors (arrows/lines)
//Vec2D mouse, lastnode, draggedline;//lastline;
float rectW = 70, rectH = 30;
float xAnchor, yAnchor;
String MODE = "PLACING_NODES"; // "NODE_SELECTED";
boolean overNode = false, nodeSelected = false, nodeMoved = false, drawing = false, sketchy = false;
Node selectedNode, draggedNode, startNode, endNode;

void setup() {
  size(600, 400);
  surface.setTitle("Mind Maps");  // add file name to this, or "New mind map" if no file selected
  surface.setResizable(true);
  //surface.setLocation(100, 100); // location on device screen

  physics = new VerletPhysics2D();
  physics.setDrag (0.015); //0.05  

  nodes = new ArrayList<Node>();
  connectors = new ArrayList<Connector>();

  //lastnode = new Vec2D(0, 0);
  //draggedline = new Vec2D(0, 0);
}

void draw() {
  physics.setWorldBounds(new Rect(0, 0, width, height));
  background(150); //10, 17, 60);
  physics.update ();

  //mouse = new Vec2D(mouseX, mouseY);

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

    if ((mousePressed)&&(mouseButton == LEFT)&&(nodes.get(i).mouseOver(nodes.get(i).x, nodes.get(i).y))) {
      nodes.get(i).lock();
      nodes.get(i).set(mouseX, mouseY);
    } else {
      nodes.get(i).unlock();
    }
  }

  for (Connector c : connectors) {  // for every connector in the arrayList connectors,
    c.display();         // display the connector
  }

  for (Node n : nodes) {  // for every node in the arrayList nodes,
    n.display();          // display the node
  }
  //println(overNode);
}

void mouseReleased() {
  if (mouseButton == LEFT) {
    //println(nodes.size());
    if (!overNode) {
      //MODE = "PLACING_NODES";
      nodeSelected = false;
      //lastnode.set(mouseX, mouseY);
      nodes.add(new Node(new Vec2D(mouseX, mouseY), rectW, rectH, this));    // ADD a new NODE
    } else {
      nodeSelected = false;
      for (Node n : nodes) {
        if (n.mouseOver(n.x, n.y)) {    // mouse is L-clicked on a node
          //MODE = "NODE_SELECTED";
          n.selected = !n.selected; //true;
          nodeSelected = nodeSelected||(n.selected);
          //nodeSelected = true;   // should rewrite ... to only select if the node hasn't been dragged.
          selectedNode = n;
        } else {
          n.selected = false;
        }
      }
    }
    //println(nodeSelected);
  }

  if ((mouseButton == RIGHT)&&(nodes.size()>0)) {
    xAnchor = mouseX;
    yAnchor = mouseY;

    if (!drawing) {
      drawing = true;
      connectors.add(new Connector(new VerletParticle2D(xAnchor, yAnchor), new VerletParticle2D(xAnchor, yAnchor)));    // ADD a new CONNECTOR
      startNode = connectors.get(connectors.size()-1).findClosestNode(nodes, new VerletParticle2D(xAnchor, yAnchor));       // find closest node 
      connectors.set(connectors.size()-1, new Connector(startNode, startNode));  // set closest node as new starting node (for this connection)
    } else {
      drawing = false;
      endNode = connectors.get(connectors.size()-1).findClosestNode(nodes, new VerletParticle2D(xAnchor, yAnchor));       // find closest node
      connectors.get(connectors.size()-1).setEndpoint(endNode, endNode);          // set closest node as end node (for this connection)
      connectors.get(connectors.size()-1).connect(startNode, endNode);            // connect the nodes together with a verletSpring
      Connector c = connectors.get(connectors.size()-1);

      if (connectors.size()>1) {
        for (int i = connectors.size() - 2; i >= 0; i--) {                           // this loop removes duplicate connectors, but it doesn't work
          if ((connectors.get(i).curveBegin == c.curveBegin)&&(connectors.get(i).curveEnd == c.curveEnd)) {
            connectors.remove(i);
            //println("DELETING A CONNECTOR");
          }
        }
      }
    }
  }
}

void keyTyped() { 
  for (int i = 0; i < nodes.size(); i++) {    // goes through all the nodes
    nodes.get(i).addText(nodes.get(i).selected);     // add text to selected node
  }
}

void keyPressed(){
  if (key == ESC){
    //saveData("test");
  }
}

//void MouseDragged() {
//}

//void MouseMoved() {
//}

//void saveData(String filename) {
//  nodeData.addColumn("x");
//  nodeData.addColumn("y");
//  nodeData.addColumn("w");
//  nodeData.addColumn("h");
//  nodeData.addColumn("text");
//  TableRow row = nodeData.addRow();
//  for (int i = 0; i < nodes.size(); i++) {
//    row.setFloat("x", nodes.get(i).x);
//    row.setFloat("y", nodes.get(i).y);
//    row.setFloat("w", nodes.get(i).w);
//    row.setFloat("h", nodes.get(i).h);
//    row.set("text", nodes.get(i).letters);
//  }
  
//  saveTable(nodeData, filename + "/nodeData.csv");
//}

//void loadData(String filename) {
//  // "header" indicates the file has header row. The size of the array 
//  // is then determined by the number of rows in the table. 
//  ArrayList<Node> nodes = new ArrayList<Node>();  // clear the nodes ArrayList
//  //nodes.add(new Node(new Vec2D(mouseX, mouseY), rectW, rectH, this))
//  nodeData = loadTable("nodeData.csv", "header");


//  for (int i = 0; i<table.getRowCount(); i++) {
//    // Iterate over all the rows in a table.
//    TableRow row = table.getRow(i);


//    // Access the fields via their column name (or index).
//    float x = row.getFloat("x");
//    float y = row.getFloat("y");
//    float d = row.getFloat("diameter");
//    String n = row.getString("name");
//    // Make a Bubble object out of the data from each row.
//    bubbles[i] = new Bubble(x, y, d, n);
//  }
//}

//void keyPressed() {
//  if (key == BACKSPACE) {
//    if (nodes.size() > 0) {
//      println(nodes.get(nodes.size() - 1));
//      nodes.remove(nodes.size() - 1);
//    }
//  }
//}
