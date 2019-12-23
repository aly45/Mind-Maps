import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import org.gicentre.handy.*;

VerletPhysics2D physics;

ArrayList<Node> nodes;  //array list of nodes
ArrayList<Connector> connectors;  //array list of connectors (arrows/lines)
//Vec2D mouse, lastnode, draggedline;//lastline;
boolean sketchy = false;
float rectW = 80, rectH = 40;
float xAnchor, yAnchor;
String MODE = "PLACING_NODES"; // "NODE_SELECTED";
boolean overNode = false, nodeSelected = false, drawing = false;
Node selectedNode, draggedNode, startNode, endNode;

void setup() {
  size(600, 400);
  surface.setTitle("Mind Maps");
  surface.setResizable(true);
  //surface.setLocation(100, 100); // location on device screen

  physics = new VerletPhysics2D();
  physics.setDrag (0.02); //0.05  

  nodes = new ArrayList<Node>();
  connectors = new ArrayList<Connector>();

  //lastnode = new Vec2D(0, 0);
  //draggedline = new Vec2D(0, 0);
}

void draw() {
  physics.setWorldBounds(new Rect(0, 0, width, height));
  background(200); //10, 17, 60);
  physics.update ();

  //mouse = new Vec2D(mouseX, mouseY);

  if (drawing) {
    stroke(0);
    line(xAnchor, yAnchor, mouseX, mouseY);
  }

  if (nodes.size() > 0) {
    overNode = nodes.get(0).mouseOver(nodes.get(0).x, nodes.get(0).y, rectW, rectH);
  }
  for (int i = 0; i < nodes.size(); i++) {    // goes through all the nodes
    overNode = overNode||(nodes.get(i).mouseOver(nodes.get(i).x, nodes.get(i).y, rectW, rectH));    // update global variable overNode
    nodes.get(i).addText(nodes.get(i).selected);     // add text to selected node

    if ((mousePressed)&&(mouseButton == LEFT)&&(nodes.get(i).mouseOver(nodes.get(i).x, nodes.get(i).y, rectW, rectH))) {
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
      for (Node n : nodes) {
        if (n.mouseOver(n.x, n.y, rectW, rectH)) {    // mouse is L-clicked on a node
          //MODE = "NODE_SELECTED";
          n.selected = !n.selected; //true;
          nodeSelected = !nodeSelected; //true;
          selectedNode = n;
        } else {
          n.selected = false;
        }
      }
    }
  }

  if (mouseButton == RIGHT) {
    xAnchor = mouseX;
    yAnchor = mouseY;
    //if (nodeSelected) {
    if (!drawing) {
      drawing = true;
      connectors.add(new Connector(new Vec2D(xAnchor, yAnchor), new Vec2D(xAnchor, yAnchor)));    // ADD a new CONNECTOR
      startNode = connectors.get(connectors.size()-1).findClosestNode(nodes, new Vec2D(xAnchor, yAnchor));       // find closest node
      xAnchor = startNode.x;
      yAnchor = startNode.y;      
      connectors.set(connectors.size()-1, new Connector(new Vec2D(xAnchor, yAnchor), new Vec2D(xAnchor, yAnchor)));  // set closest node as new starting node (for this connection)      
    } else {
      drawing = false;
      endNode = connectors.get(connectors.size()-1).findClosestNode(nodes, new Vec2D(xAnchor, yAnchor));       // find closest node
      xAnchor = connectors.get(connectors.size()-1).closestNode.x;
      yAnchor = connectors.get(connectors.size()-1).closestNode.y;
      connectors.get(connectors.size()-1).setEndpoint(new Vec2D(xAnchor, yAnchor), new Vec2D(xAnchor, yAnchor));     // set closest node as end node (for this connection)
      connectors.get(connectors.size()-1).connect(startNode, endNode);            // connect the nodes together with a verletSpring
    }

    //println(connectors.size());
  }
}
//}

void keyPressed() {
  if (key == BACKSPACE) {
    if (nodes.size() > 0) {
      println(nodes.get(nodes.size() - 1));
      nodes.remove(nodes.size() - 1);
    }
  }
}
