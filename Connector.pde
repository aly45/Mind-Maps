class Connector {
  Vec2D curveBegin, anchor1, anchor2, curveEnd, node1Pos, node2Pos, connectorVector, VirtualPos1, VirtualPos2;
  //int connectedFrom; // node number in nodes ArrayList
  //int connectedTo;   // node number in nodes ArrayList
  Node startNode, endNode, closestNode;
  int startNodeIndex, endNodeIndex, n;
  //boolean drawing = false;    // is the connector currently being drawn?
  float dist;
  float springLength = 130;
  float springStrength = 0.0015;//0.002;
  float virtualDistance = 0.0001; //0.01 changing this won't change much because of the repulsion forces on the virtual particles (?)
  //float strength = 2;
  String connectionMode;
  VerletParticle2D v1, v2;
  AttractionBehavior2D a1, a2;  //attraction behaviours of virtual particles v1 and v2
  VerletSpring2D s1, s2, s3;    //goes start node > s1 > v1 > s2 > v2 > s3 > endNode

  Connector(VerletParticle2D p1, VerletParticle2D p2) { //add extra two PVector positions if using bezier
    curveBegin = p1;
    anchor1 = p2;    // where the curve start should be next
  }

  void display() {
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

  Node findClosestNode(ArrayList<Node> candidates, VerletParticle2D anchor, boolean beingDrawn) {    // finds closest node to connector end(s)
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

  int getClosestIndex(ArrayList<Node> candidates, VerletParticle2D anchor) {    // returns closest node index. No idea why cloestNode is always 0 if I try to extract it without using this function.
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

  void setEndpoint(VerletParticle2D p3, VerletParticle2D p4) {
    anchor2 = p3;    // where the curve end point should be next
    curveEnd = p4;
  }

  // Connects nodes with connectors from tables
  void connect(Node n1, Node n2) { // add a spring between two connected nodes
    float nodesDist = sqrt(sq(n1.x - n2.x) + sq(n1.y - n2.y));
    node1Pos = new Vec2D(n1.x, n1.y); // node 1 position vector
    node2Pos = new Vec2D(n2.x, n2.y); // node 2 position vector
    connectorVector = node2Pos.sub(node1Pos); // hopefully this is pointing from node 1 to node 2
    //Vec2D connectionVector = new Vec2D(n2.x - n1.x, n2.y - n1.y); // points from node 1 to node 2    
    VirtualPos1 = node1Pos.add(connectorVector.scale(0.01));  // position vector of virtual particle 1
    VirtualPos2 = node2Pos.sub(connectorVector.scale(0.01));  // position vector of virtual particle 2

    if (curveBegin != curveEnd) {
      println("NOT THE SAME NODE");
      v1 = new VerletParticle2D(VirtualPos1);
      a1 = new AttractionBehavior2D(v2, 73, -n1.strength);
      physics.addBehavior(a1);    // what happens if we don't have attraction behaviors on the virtual particles?
      physics.addParticle(v1);
      v2 = new VerletParticle2D(VirtualPos2);
      physics.addParticle(v2);
      a2 = new AttractionBehavior2D(v2, 73, -n1.strength);
      physics.addBehavior(a2);
      s1 = new VerletSpring2D(n1, v1, nodesDist*virtualDistance, springStrength);
      physics.addSpring(s1);  // mini spring from first node to v1
      //println("node 1 is at " + n1.x + ", " + n1.y);      

      //println("virtual particle 1 is at: " + VirtualPos1.x + ", " + VirtualPos1.y);
      s2 = new VerletSpring2D(v1, v2, nodesDist*0.7, springStrength);
      physics.addSpring(s2);  // main verlet spring

      //println("virtual particle 2 is at: " + VirtualPos2.x + ", " + VirtualPos2.y);
      s3 = new VerletSpring2D(v2, n2, nodesDist*virtualDistance, springStrength);
      physics.addSpring(s3);  // mini spring from second node
      //println("node 2 is at " + n2.x + ", " + n2.y);
    }
  }

  // Connects nodes with connectors by clicking
  // want to add an additional verlet particle connection to each node connection
  void connect(Node n1, Node n2, float tempLength) { // add a spring between two connected nodes
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
      println("node 1 is at " + n1.x + ", " + n1.y);      

      println("virtual particle 1 is at: " + VirtualPos1.x + ", " + VirtualPos1.y);
      s2 = new VerletSpring2D(v1, v2, nodesDist*0.7 + tempLength, springStrength);
      physics.addSpring(s2);  // main verlet spring

      println("virtual particle 2 is at: " + VirtualPos2.x + ", " + VirtualPos2.y);
      s3 = new VerletSpring2D(v2, n2, nodesDist*virtualDistance, springStrength);
      physics.addSpring(s3);  // mini spring from second node
      println("node 2 is at " + n2.x + ", " + n2.y);
    }
  }

  // If deleting a connector by deleting the attached node
  void delete(Node n) {
    if ((n == startNode)||(n == endNode)) {  //checks if n is actually a starting or ending node for this connection
      println("Deleting connection between startNode " + startNode + " and endNode " + endNode);
      // deletes all virtual particles in this connection
      if (n != null) {
        physics.removeParticle(n);  // delete node particle
        physics.removeBehavior(n.a);
      }

      physics.removeBehavior(a1);
      physics.removeParticle(v1);

      physics.removeBehavior(a2);
      physics.removeParticle(v2);

      physics.removeSpring(s1);  // remove mini spring from first node to v1
      physics.removeSpring(s2);  // remove spring from v1 to v2
      physics.removeSpring(s3);  // remove mini spring from v2 to last node

      //physics.removeParticle(end);
    }
  }

  // If deleting a connector by first selecting the connector:
  void delete() {    // Node start, Node end
    // deletes all virtual particles in this connection
    //physics.removeParticle(start);  // don't want to remove starting and ending nodes!
    physics.removeBehavior(a1);
    physics.removeParticle(v1);
    physics.removeBehavior(a2);
    physics.removeParticle(v2);
    physics.removeSpring(s1);  // remove mini spring from first node to v1
    physics.removeSpring(s2);  // remove spring from v1 to v2
    physics.removeSpring(s3);  // remove mini spring from v2 to last node
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

  void mouseOver() {    // can use startNodeIndex and endNodeIndex
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
