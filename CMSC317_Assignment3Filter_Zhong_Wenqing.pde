import processing.video.*;

PImage img;
PImage img2; 
PImage img3; 
PImage img4; 
PImage img5;
PImage img6;
PImage img7;
PImage img8;

Capture cam;
void setup() {
  size(1200, 800);
  cam = new Capture(this, 320, 240);
  cam.start();

  //img = loadImage("three.jpg");
  //img2=Horizontal_Sobel(img);
  //img3=Vertical_Sobel(img); 
  //img4=Vertical_Sobel_1D(img);  
  //img5= Sobel(img);
  //img6=Blur(img);
  //img7=Blur_1D(img);
  //img8=Blur2(img);
}


color convolution(int x, int y, float[][] matrix, int matrixsize, PImage img) {
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

//color convolution_1D_Horizontal(int x, int y, float[] Horizontal_matrix, float index, int matrixsize, PImage img) {
//  float rtotal=0.0;
//  float gtotal=0.0;
//  float btotal=0.0;
//  int offset = matrixsize/2;
//  for (int i =0; i<matrixsize; i++) {   
//    int xloc = x+i-offset;
//    int yloc = y;
//    int loc = xloc +img.width*yloc;
//    loc = constrain(loc, 0, img.pixels.length-1);
//    rtotal+=(red(img.pixels[loc])*Horizontal_matrix[i]*index);
//    gtotal+=(green(img.pixels[loc])*Horizontal_matrix[i]*index);
//    btotal+=(blue(img.pixels[loc])*Horizontal_matrix[i]*index);
//  }
//  rtotal=constrain(abs(rtotal), 0, 255);
//  gtotal=constrain(abs(gtotal), 0, 255);
//  btotal=constrain(abs(btotal), 0, 255);

//  return color(rtotal, gtotal, btotal);
//}

//color convolution_1D_Vertical(int x, int y, float[] Vertical_matrix, int matrixsize, PImage img) {
//  float rtotal=0.0;
//  float gtotal=0.0;
//  float btotal=0.0;
//  int offset = matrixsize/2;

//  for (int j =0; j<matrixsize; j++) {   
//    int xloc = x;
//    int yloc = y+j-offset;
//    int loc = xloc +img.width*yloc;
//    loc = constrain(loc, 0, img.pixels.length-1);
//    rtotal+=(red(img.pixels[loc])*Vertical_matrix[j]);
//    gtotal+=(green(img.pixels[loc])*Vertical_matrix[j]);
//    btotal+=(blue(img.pixels[loc])*Vertical_matrix[j]);
//  }
//  rtotal=constrain(abs(rtotal), 0, 255);
//  gtotal=constrain(abs(gtotal), 0, 255);
//  btotal=constrain(abs(btotal), 0, 255);

//  return color(rtotal, gtotal, btotal);
//}

//PImage Blur_1D(PImage img) {
//  //long startTime = System.nanoTime();
//  img.resize(600, 400);
//  PImage newimg=get();
//  PImage newimg2=get();
//  newimg.resize(600, 400);
//  newimg2.resize(600, 400);
//  float ker_hori[]={1.0, 1.0, 1.0, 1.0, 1.0};
//  float ker_verti[]={1.0, 1.0, 1.0, 1.0, 1.0};

//  for (int x =0; x<img.width; x++) {
//    for (int y =0; y<img.height; y++) {
//      color d=convolution_1D_Horizontal(x, y, ker_hori, 0.04, ker_verti.length, img);
//      float r = (d >> 16) & 0xff;
//      float g = (d >> 8) & 0xff;
//      float b = d & 0xff;
//      int loc=x+y*img.width;
//      newimg.pixels[loc]=color(r, g, b);
//    }
//  } 

//  for (int x =0; x<img.width; x++) {
//    for (int y =0; y<img.height; y++) {
//      color d=convolution_1D_Vertical(x, y, ker_verti, ker_verti.length, newimg);
//      float r = (d >> 16) & 0xff;
//      float g = (d >> 8) & 0xff;
//      float b = d & 0xff;
//      int loc=x+y*img.width;
//      newimg2.pixels[loc]=color(r, g, b);
//    }
//  } 

//  //long timeNeeded = System.nanoTime() - startTime;
//  //println("1d_Needed "+ timeNeeded + " nanoseconds.");
//  return newimg2;
//}


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
      if (h>v) {
        newimg.pixels[loc]=h;
      } else {
        newimg.pixels[loc]=v;
      }
    }
  }
  return newimg;
}

PImage Blur(PImage img) {
  //long startTime = System.nanoTime();
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
  //long timeNeeded = System.nanoTime() - startTime;
  //println("2d_Needed "+ timeNeeded + " nanoseconds.");
  return newimg;
}

//PImage Blur2(PImage img) {
//  img.resize(600, 400);
//  PImage newimg=get();
//  newimg.resize(600, 400);
//  float ker[]={1.0, 4.0, 6.0, 4.0, 1.0, 4.0, 16.0, 24.0, 16.0, 4.0, 6.0, 24.0, 36.0, 24.0, 6.0, 4.0, 16.0, 24.0, 16.0, 4.0, 1.0, 4.0, 6.0, 4.0, 1.0};
//  float m[][]=getMatrix(0.0039, ker);

//  for (int x =0; x<img.width; x++) {
//    for (int y =0; y<img.height; y++) {
//      color c=convolution(x, y, m, m.length, img);
//      float r = (c >> 16) & 0xff;
//      float g = (c >> 8) & 0xff;
//      float b = c & 0xff;
//      int loc=x+y*img.width;
//      newimg.pixels[loc]=color(r, g, b);
//    }
//  } 
//  return newimg;
//}

//PImage Vertical_Sobel_1D(PImage img) {  
//  float ker_verti[]={1.0, 2.0, 1.0};
//  float ker_hori[]={-1.0, 0.0, 1.0};
//  img.resize(600, 400);
//  PImage newimg=get();
//  PImage newimg2=get();
//  newimg.resize(600, 400);
//  newimg2.resize(600, 400);

//  for (int x =0; x<img.width; x++) {
//    for (int y =0; y<img.height; y++) {
//      color d=convolution_1D_Horizontal(x, y, ker_hori, 1.0, ker_verti.length, img);
//      float r = (d >> 16) & 0xff;
//      float g = (d >> 8) & 0xff;
//      float b = d & 0xff;
//      int loc=x+y*img.width;
//      newimg.pixels[loc]=color(r, g, b);
//    }
//  } 

//  for (int x =0; x<img.width; x++) {
//    for (int y =0; y<img.height; y++) {
//      color d=convolution_1D_Vertical(x, y, ker_verti, ker_verti.length, newimg);
//      float r = (d >> 16) & 0xff;
//      float g = (d >> 8) & 0xff;
//      float b = d & 0xff;
//      int loc=x+y*img.width;
//      newimg2.pixels[loc]=color(r, g, b);
//    }
//  } 
//  return newimg2;
//}


void webcam(PImage camp) {
  PImage b2= camp.get();
  PImage b0=Blur(camp);
  PImage b1=Sobel(b0);

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
      ellipse(x+width/2+shake, y+shake, 5, 5);
    }
  }    
  noTint(); 
  image(b1, 0, 0);
  tint(255, 100); 
  image(camp, width/2, height/2, b2.width, b2.height);

  float shake2=random(0, 150);
  tint(138, 43, 226, shake2);
  image(b2, width/2, height/2, b2.width, b2.height);
  float shake3=random(0, 150);
  tint(255, 215, 0, shake3);
  image(b2, width-b2.width, height/2, b2.width, b2.height);
  float shake4=random(0, 150);
  tint(30, 144, 255, shake4);
  image(b2, width/2, height-b2.height, b2.width, b2.height);
  float shake5=random(0, 150);
  tint(255, 69, 0, shake5);
  image(b2, width-b2.width, height-b2.height, b2.width, b2.height);

  tint(255, 100); 
  image(camp, 0, height/2, b1.width, b1.height);
  scale(-1, 1);//flip on X axis
  image(camp, -camp.width, camp.height);
}

PImage captureEvent(Capture c) {  
  c.read();
  PImage camp=cam.get();
  return camp;
}

void draw() {
  PImage camp=captureEvent(cam);
  long startTime = System.nanoTime();
  webcam(camp);
  long timeNeeded = System.nanoTime() - startTime;
  println(timeNeeded);
  //image(img3, width/2, 0);
  //image(img4, width/2, 400);
  //image(img, 0, 0, width/2, img.height);
}
