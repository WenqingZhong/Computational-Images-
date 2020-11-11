import processing.video.*;

int state;
Capture cam;
void setup() {
  size(1200, 800);
  cam = new Capture(this, 320, 240);
  cam.start();
  state=0;
}


color convolution(int x, int y, float[][] matrix , int matrixsize, PImage img) {
  float rtotal=0.0;
  float gtotal=0.0;
  float btotal=0.0;
  int offset = matrixsize/2;
  for (int i =0; i<matrixsize; i++) {
    for (int j =0; j<matrixsize; j++) {
      int xloc = x+i-offset;
      int yloc = y+j-offset;
      int loc = xloc +img.width*yloc;
      loc = constrain(loc, 0, img.pixels.length-1);
      rtotal+=(red(img.pixels[loc])*matrix[i][j]);
      gtotal+=(green(img.pixels[loc])*matrix[i][j]);
      btotal+=(blue(img.pixels[loc])*matrix[i][j]);
    }
  }
  rtotal=constrain(abs(rtotal), 0, 255);
  gtotal=constrain(abs(gtotal), 0, 255);
  btotal=constrain(abs(btotal), 0, 255);
  return color(rtotal, gtotal, btotal);
}

float[][]getMatrix(float ker, float[]Ker) { 
  int lmatrix=int(sqrt(Ker.length+1));
  float[][] matrix = new float[lmatrix][lmatrix];
  int k=0;
  for (int i=0; i<lmatrix; i++) {
    for (int j=0; j<lmatrix; j++) {
      matrix[i][j]=Ker[k]*ker;
      k++;
    }
  }  
  return matrix;
}

PImage Blur(PImage img) {
  img.resize(600, 400);
  PImage newimg=get();
  newimg.resize(600, 400);
  float ker[]={1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0};
  float m[][]=getMatrix(0.04, ker);

  for (int x =0; x<img.width; x++) {
    for (int y =0; y<img.height; y++) {
      color c=convolution(x, y, m, m.length, img);
      float r = (c >> 16) & 0xff;
      float g = (c >> 8) & 0xff;
      float b = c & 0xff;
      int loc=x+y*img.width;
      newimg.pixels[loc]=color(r, g, b);
    }
  } 
  return newimg;
}

PImage Vertical_Sobel(PImage img) {
  img.resize(600, 400);
  PImage newimg=get();
  newimg.resize(600, 400);
  float ker[]={-1.0, -2.0, -1.0, 0.0, 0.0, 0.0, 1.0, 2.0, 1.0};
  float m[][]=getMatrix(1.0, ker);

  for (int x =0; x<img.width; x++) {
    for (int y =0; y<img.height; y++) {
      color c=convolution(x, y, m, m.length, img);
      float r = (c >> 16) & 0xff;
      float g = (c >> 8) & 0xff;
      float b = c & 0xff;
      int loc=x+y*img.width;
      newimg.pixels[loc]=color(r, g, b);
    }
  } 
  return newimg;
}

PImage Horizontal_Sobel(PImage img) {
  img.resize(600, 400);
  PImage newimg=get();
  newimg.resize(600, 400);
  float ker[]={-1.0, 0.0, 1.0, -2.0, 0.0, 2.0, -1.0, 0.0, 1.0};
  float m[][]=getMatrix(1.0, ker);

  for (int x =0; x<img.width; x++) {
    for (int y =0; y<img.height; y++) {
      color c=convolution(x, y, m, m.length, img);
      float r = (c >> 16) & 0xff;
      float g = (c >> 8) & 0xff;
      float b = c & 0xff;
      int loc=x+y*img.width;
      newimg.pixels[loc]=color(r, g, b);
    }
  } 
  return newimg;
}

PImage Sobel(PImage img) {
  PImage newimg=get();
  newimg.resize(600, 400);
  PImage vimg=Vertical_Sobel(img);
  PImage himg=Horizontal_Sobel(img);

  for (int x =0; x<img.width; x++) {
    for (int y =0; y<img.height; y++) {
      int loc=x+y*img.width;
      color h=himg.pixels[loc];
      color v=vimg.pixels[loc];
      float hr=(h >> 16) & 0xff;
      float vr=(v >> 16) & 0xff;
      float hg = (h >> 8) & 0xff;
      float vg = (v >> 8) & 0xff;
      float hb = h & 0xff;
      float vb = v & 0xff;
      float hc=(hr+hg+hb)/3;
      float vc=(vr+vg+vb)/3;
      if (hc>vc) {
        newimg.pixels[loc]=h;
      } else {
        newimg.pixels[loc]=v;
      }
    }
  }
  return newimg;
}

void elli(PImage camp, float w, float h, int leftupx, int leftupy, int elliw) {
  camp.resize(width, height);
  for (int x =0; x<camp.width; x+=10) {
    for (int y =0; y<camp.height; y+=20) { 
      int loc=x+y*camp.width;
      color c=camp.pixels[loc];
      int shake=int(random(-10, 10));
      float colorshake=random(0, 10)/5;
      float r = ((c >> 16) & 0xff)*2*colorshake;    
      float g = ((c >> 8) & 0xff)*colorshake;
      float b = (c & 0xff)*colorshake;
      r=constrain(r, 0, 255);
      g=constrain(g, 0, 255);
      b=constrain(b, 0, 255);
      color e=color(r, g, b); 
      fill(e);
      noStroke();
      float positionx=(w/width)*x;
      float positiony=(h/height)*y;
      ellipse(positionx+shake+leftupx, positiony+shake+leftupy, elliw, elliw);
    }
  }
}

void fourImage(PImage camp, float leftupx, float leftupy, float campw, float camph, float totalw, float totalh) {
  PImage four=camp.get();
  
  tint(255, 70); 
  image(four, 0, 0, totalw, totalh);

  float shake2=random(100, 255);
  tint(138, 43, 226, shake2);
  image(four, leftupx, leftupy, campw, camph);
  float shake3=random(100, 255);
  tint(255, 215, 0, shake3);
  image(four, leftupx+(totalw-campw), leftupy, campw, camph);
  float shake4=random(100, 255);
  tint(30, 144, 255, shake4);
  image(four, leftupx, leftupy+(totalh-camph), campw, camph);
  float shake5=random(100, 255);
  tint(255, 69, 0, shake5);
  image(four, leftupx+(totalw-campw), leftupy+(totalh-camph), campw, camph);
  noTint();
}

void webcam(PImage camp) {
  PImage b2= camp.get();
  PImage b0=Blur(camp);
  PImage b1=Sobel(b0);

  elli(camp, width/2, height/2, width/2, 0, 7);
  image(b1, 0, 0);//sobel
  fourImage(b2, width/2, height/2, b2.width, b2.height, width/2, height/2);
  image(camp, 0, height/2, b1.width, b1.height);
}

PImage captureEvent(Capture c) {  
  c.read();
  PImage camp=cam.get();
  return camp;
}

void choseimg() {
  if (keyPressed==true) {
    if (key== '1') {
      state =1;
    } else if (key == '2') {
      state =2;
    } else if (key == '3') {
      state =3;
    } else if (key == '4') {
      state =4;
    }
  }
}

void draw() {
  PImage camp=captureEvent(cam);
  choseimg();
  if (state==0) {
    long startTime = System.nanoTime();
    webcam(camp);
    long timeNeeded = System.nanoTime() - startTime;
    println("time Needed "+ timeNeeded + " nanoseconds.");
  } else if (state==1) {
    image(Blur(camp), 0, 0, width, height);
  } else if (state ==2) {
    image(Sobel(camp), 0, 0, width, height);
  } else if (state ==3) {
    elli(camp, width, height, 0, 0, 5);
  } else if (state ==4) {
    fourImage(camp, 0, 0, width/2+40, height/2+40, width, height);
  }
}
