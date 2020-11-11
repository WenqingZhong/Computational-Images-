/*
 * Barebones 3D viewer
 * Keith O'Hara <kohara@bard.edu>
 * 
 * Face Data set: http://tosca.cs.technion.ac.il/data/face.zip
 * Jama: http://math.nist.gov/javanumerics/jama/doc/
 *
 */
import Jama.*;
//import matrixMath.*;

ArrayList<Matrix> vertices = new ArrayList<Matrix>();

float f;


float ax;
float ay;
float az;
float mx;
float my;

float tx;
float ty;
float tz;

float rot_x;
float rot_z;
float rot_y;

void loadPoints() {
  String [] lines = loadStrings("face06.vert");
  for (int i = 0; i < lines.length; i++) {
    String[] pieces = split(lines[i], ' ');
    Matrix m = new Matrix(4, 1);
    m.set(0, 0, float(pieces[0]));//x
    m.set(1, 0, float(pieces[1]));//y
    m.set(2, 0, float(pieces[2]));//z
    m.set(3, 0, 1);
    vertices.add(m);//[x,y,z,0]
  }
}

void setup() {
  size(800, 600, P3D);
  loadPoints();
  f=200;
  ax=0;
  ay=0;
  az=0;
  mx=5;
  my=5;

  tx=0;
  ty=0;
  tz=0;

  rot_x = 3;
  rot_z = 0;
  rot_y = 0;
}

void changef() {
  if (keyPressed&&key=='=') {
    f+=10;
  }
  if (keyPressed&&key=='-'&&f>0) {
    f-=10;
  }
}

void changeAngle() {
  if (keyPressed) {
    if (key=='s') {
      ax+=0.03;
    } else if (key=='w') {
      ax-=0.03;
    } else if (key=='a') {
      ay+=0.03;
    } else if (key=='d') {
      ay-=0.03;
    } else if (key=='r') {
      az+=0.1;
    } else if (key=='t') {
      az-=0.1;
    }
  }
}

void move() {
  if (keyPressed) {
    if (key=='j') {
      tx-=0.02;
    } else if (key=='l') {
      tx+=0.02;
    } else if (key=='i') {
      ty+=0.02;
    } else if (key=='k') {
      ty-=0.02;
    } else if (key=='o') {
      tz+=0.01;
    } else if (key=='p') {
      tz-=0.01;
    }
  }
}


void draw() {


  Matrix exC = Matrix.identity(4, 4);//[R|T] matrix
  Matrix inC = Matrix.identity(3, 4);//what gonna show in the screen
  Matrix anglex = Matrix.identity(4, 4);
  Matrix angley = Matrix.identity(4, 4);
  Matrix anglez = Matrix.identity(4, 4);


  changef();
  changeAngle();
  move();

  ax=constrain(ax, -PI/2, PI/2);
  ay=constrain(ay, -PI/2, PI/2);

  inC.set(0, 0, f);
  inC.set(1, 0, 0);
  inC.set(2, 0, 0);

  inC.set(0, 1, 0);
  inC.set(1, 1, f);
  inC.set(2, 1, 0);

  inC.set(0, 2, 0);
  inC.set(1, 2, 0);
  inC.set(2, 2, 1);

  ///
  anglex.set(1, 1, cos(ax));
  anglex.set(2, 1, -sin(ax)); 
  anglex.set(1, 2, sin(ax));
  anglex.set(2, 2, cos(ax));
  //

  angley.set(0, 0, cos(ay));
  angley.set(2, 0, sin(ay));  
  angley.set(0, 2, -sin(ay));
  angley.set(2, 2, cos(ay));

  //
  anglez.set(0, 0, cos(az));
  anglez.set(1, 0, -sin(az));
  anglez.set(0, 1, sin(az));
  anglez.set(1, 1, cos(az));

  exC=anglex.times(angley.times(anglez));
  exC.set(0, 3, tx);
  exC.set(1, 3, ty);
  exC.set(2, 3, tz);
  exC.print(4, 4);
  background(0);
  translate(width/2, height/2);

  //draw vertices
  fill(255);
  noStroke();
  for (Matrix v : vertices) {//p1,p2 in the quize
    Matrix t = inC.times(exC.times(v));//P1*p in the quiz
    ellipse((float)(t.get(0, 0)/t.get(2, 0)), (float)(t.get(1, 0)/t.get(2, 0)), 3, 3);
  }
}
