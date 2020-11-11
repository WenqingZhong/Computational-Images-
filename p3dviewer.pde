/*
 * Barebones 3D viewer
 * Keith O'Hara <kohara@bard.edu>
 * 
 * Face Data set: http://tosca.cs.technion.ac.il/data/face.zip
 * Jama: http://math.nist.gov/javanumerics/jama/doc/
 *
 */

ArrayList<PVector> vertices = new ArrayList<PVector>();
float camX, camY, camZ, centerX, centerY, centerZ, upX, upY, upZ,angle;

void loadPoints() {                                        
  String [] lines = loadStrings("face04.vert");
  for (int i = 0; i < lines.length; i++) {
    String[] pieces = split(lines[i], ' ');
    PVector m = new PVector(float(pieces[0]), float(pieces[1]), float(pieces[2]));
    vertices.add(m);
  }
}

void setup() {
  size(800, 600, P3D);
  loadPoints();
  camX=400;
  camY=300;
  camZ=520;
  centerX=400;
  centerY=300;
  centerZ=0;
  angle=PI;
  upX=0;
  upY=-1;
  upZ=0;
  println("camX:a,d     camY:w,s      camZ:r,t");
  println("centerX:j,l  centerY:i,k   centerZ:o,p");
  println("rotate:f,h");
  println("perspective/orthographic:+,-");
}

void changeCameraPosition() {
  if (keyPressed) {
    if (key=='a') {
      camX+=10;
    }else if (key=='d') {
      camX-=10;
    }else if (key=='w') {
      camY+=10;
    }else if (key=='s') {
      camY-=10;
    }else if (key=='r') {
      camZ+=10;
    }else if (key=='t') {
      camZ-=10;
    }
  }
}

void changeCameraAim() {
  if (keyPressed) {
    if (key=='l') {
      centerX+=10;
    }else if (key=='j') {
      centerX-=10;
    }else if (key=='k') {
      centerY+=10;
    }else if (key=='i') {
      centerY-=10;
    }else if (key=='o') {
      centerZ+=1;
    }else if (key=='p') {
      centerZ-=1;
    }
  }
}

void rotateCamera(){
  if (keyPressed) {
    if (key=='h') {
     angle+=PI/20;
    }else if (key=='f') {
      angle-=PI/20;
    }
  }
}


void draw() {
  background(0);
  pushMatrix();   // saves the coordinate system; we're about to change it 
  camera(camX, camY, camZ, centerX, centerY, centerZ, upX, upY, upZ);
  changeCameraPosition();
  changeCameraAim();
  upX=sin(angle);
  upY=cos(angle);
  rotateCamera();
  if (keyPressed) {
    if (key=='=') {
     perspective();
    }else if (key=='-') {
     ortho(-width/2, width/2, -height/2, height/2);
    }
  }
  
  translate(width/2, height/2);
  scale(300);
  strokeWeight(0.01);

  stroke(255);
  beginShape(POINTS);
  for (PVector v : vertices) {
    vertex(v.x, v.y, v.z);
  }
  endShape();
  popMatrix();  // restore the old saved coordinate system
}
