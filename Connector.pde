class Connector {
  PVector curveBegin, anchor1, anchor2, curveEnd;

  Connector(PVector p1, PVector p2, PVector p3, PVector p4) { //add extra two PVector positions if using bezier
    curveBegin = p1;
    anchor1 = p2;    // where the curve start should be next
    anchor2 = p3;    // where the curve end point should be next
    curveEnd = p4;
  }

  void display() {
    stroke(0);
    //line(point1.x, point1.y, point2.x, point2.y);
    bezier(curveBegin.x, curveBegin.y, anchor1.x, anchor1.y, anchor2.x, anchor2.y, curveEnd.x, curveEnd.y);
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
