
SpecialPlane horPlane = new SpecialPlane(0,0.2, new PVector(253, 184, 19));
SpecialPlane parPlane = new SpecialPlane(1, 0.5, new PVector(246, 139, 31));
SpecialPlane obPlane  = new SpecialPlane(0.5, 0.3, new PVector(241, 112, 34));
VPlane vertPlane      = new VPlane(-0.4, new PVector(238, 246, 108));

boolean[] visible = {true, true, true, true, true}; // which parts of the cone are visible
float rotY = 0, rotX = 0;
PVector[][] ps = generatePoints(100);

void setup() {
  size(640, 600, P3D);
  noStroke();
  noLoop();
}

class SpecialPlane {
  float m; // Plane: {(x,y,z) / m*x+b = y}
  float b;
  PVector col;
  
  SpecialPlane(float xyslope, float origpoint, PVector planeColor) {
    m = xyslope;
    b = origpoint;
    col = planeColor;
  }
  
  PVector intersect(float lx, float ly) {
    float f = -b / (m*lx-1);
    return new PVector(f * lx, f, f * ly);
  }
  
  void drawPlane() {
    beginShape(QUAD);
      fill(col.x,col.y,col.z,150);
      vertex(-1, -m+b, -1);
      vertex(-1, -m+b,  1);
      vertex(1,  m+b,  1);
      vertex(1,  m+b, -1);
    endShape();
  }
}

class VPlane {
  public float x;
  PVector col;
  
  // Plane: {(x,y,z) / x = x0}
  VPlane(float x0, PVector planeColor) {
    x = x0;
    col = planeColor;
  }
  
  PVector intersect(float lx, float ly) {
    return new PVector(x, x/lx, x*ly/lx);
  }
  
  void drawPlane() {
    beginShape(QUAD);
      fill(col.x,col.y,col.z,150);
      vertex(x, -1, -1);
      vertex(x, -1,  1);
      vertex(x,  1.3,  1);
      vertex(x,  1.3, -1);
    endShape();
  }
}

void draw() {
  background(0);
  lights();
  translate(width / 2, 2 * height / 3);
  rotateX(map(rotX, 0, width, 0, PI));
  rotateY(map(rotY, 0, width, 0, PI));
  scale(150,150,150);
  translate(0, -1, 0);
  
  horPlane.drawPlane();
  parPlane.drawPlane();
  obPlane.drawPlane();
  vertPlane.drawPlane();
  
  drawCone(ps, visible);
}

PVector[][] generatePoints(int coneSides) {
  float angle = 0;
  float angleIncrement = TWO_PI / coneSides;
  PVector[][] res = new PVector[coneSides+1][6];
  
  for (int i=0;i<=coneSides;++i) { // circle -> ellipse -> parabola -> hiperbola
    res[i][0] = new PVector(0,0,0);
    res[i][1] = new PVector(0.2*cos(angle), 0.2, 0.2*sin(angle));
    res[i][2] = obPlane.intersect(cos(angle), sin(angle));
    res[i][3] = parPlane.intersect(cos(angle), sin(angle));
    res[i][4] = vertPlane.intersect(cos(angle), sin(angle));
    res[i][5] = new PVector(cos(angle), 1, sin(angle));
    if (res[i][5].x >= vertPlane.x)
      res[i][4] = res[i][5];
    if (res[i][3].y >= 1 || i==0 || i==coneSides)
      res[i][3] = res[i][5];
    
    angle += angleIncrement;
  }
  
  return res;
}

void drawCone(PVector[][] ps, boolean[] showPiece) {
  int[][] colors= {{37, 56, 62},{105, 67, 41},{174, 78, 21},{242,89,0},{222,192,0}};
  
  for (int f=0;f<5;f++) {
    if (showPiece[f]) {
      fill(colors[f][0],colors[f][1],colors[f][2]);
      beginShape(QUAD_STRIP);
        for (int i = 0; i < ps.length; ++i) {
          vertex(ps[i][f].x, ps[i][f].y, ps[i][f].z);
          vertex(ps[i][f+1].x, ps[i][f+1].y, ps[i][f+1].z);
        }
      endShape();
    }
  }
}

void keyPressed() {
  if (keyCode >= '1' && keyCode <= '5')
    visible[keyCode-'1'] = !visible[keyCode-'1'];
  else if (keyCode == LEFT)
    rotY-=6;
  else if (keyCode == RIGHT)
    rotY+=6;
  else if (keyCode == UP)
    rotX-=6;
  else if (keyCode == DOWN)
    rotX+=6;
  redraw();
}
