class Arena { //<>//
  PVector[] corners;
  PGraphics mask;

  Arena() {
    mask = createGraphics(width, height);
    corners = new PVector[7];
    for (int i = 0; i< 7; i++) {
    }
  }
  PGraphics init(PVector[] corners_) {
    corners = corners_;
    mask.beginDraw();
    mask.clear();
    mask.fill(255);
    mask.stroke(150);
    mask.background(0);
    mask.pushMatrix();
    mask.translate(width/2, height/2);

    mask.beginShape();
    for (int i = 0; i < corners.length; i++) {
      mask.vertex(corners[i].x, corners[i].y);
    }
    mask.endShape(CLOSE);
    mask.popMatrix();
    mask.endDraw();
    mask.updatePixels();
    return (mask);
  }
}
