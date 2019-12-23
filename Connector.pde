class Connector {
  Vec2D curveBegin, anchor1, anchor2, curveEnd;
  //int connectedFrom; // node number in nodes ArrayList
  //int connectedTo;   // node number in nodes ArrayList
  Node startNode, endNode, closestNode;
  //boolean drawing = false;    // is the connector currently being drawn?
  float dist;
  float springLength = 160;

  Connector(Vec2D p1, Vec2D p2) { //add extra two PVector positions if using bezier
    curveBegin = p1;
    anchor1 = p2;    // where the curve start should be next
  }

  Node findClosestNode(ArrayList<Node> candidates, Vec2D anchor) {    // finds closest node to connector end(s)
    float minDist = width*height;
    for (int i = 0; i < candidates.size(); i++) {
      dist = sqrt(sq(candidates.get(i).x - anchor.x) + sq(candidates.get(i).y - anchor.y));
      if (dist < minDist) {
        minDist = dist;
        //if (minDist < 20){      // limit to some radius
        closestNode = candidates.get(i);
        //}
      }
    }
    return closestNode;
    //println(closestNode);

    //    if (!drawing) {
    //      drawing = true;
    //      startNode = closestNode;
    //    } else {
    //      drawing = false;
    //      endNode = closestNode;
    //    }
  }

  void setEndpoint(Vec2D p3, Vec2D p4) {
    anchor2 = p3;    // where the curve end point should be next
    curveEnd = p4;
  }

  void connect(VerletParticle2D n1, VerletParticle2D n2) { // add a spring between two connected nodes
    //springLength = dist*12;    // length at equilibrium
    print(springLength);
    if (curveBegin != curveEnd) {
      physics.addSpring(new VerletSpring2D(n1, n2, springLength, 0.005));
    }
  }

  void display() {
    stroke(0);
    if ((curveBegin != null)&&(curveEnd != null)) {  // checks if curveBegin and curveEnd are actually assigned.
      if (curveBegin != curveEnd) {
        bezier(curveBegin.x, curveBegin.y, anchor1.x, anchor1.y, anchor2.x, anchor2.y, curveEnd.x, curveEnd.y);
      }
    }
  }

  boolean mouseOver(float tempx, float tempy, float tempw, float temph) {
    if (((mouseX >= tempx)&&(mouseX <= tempx+tempw)) && 
      ((mouseY >= tempy)&&(mouseY <= tempy+temph))) {
      return true;
    } else {
      return false;
    }
  }
}
