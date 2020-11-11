// CMSC317 assignment 2
// different binary thresholding functions
//
// (1) complete the two missing functions: 
//      - calcmean 
//      - calcotsu 
//
// (2) For the report (PDF):
//      - show results (binary images) for the different thresholds
//      - find an image where otsu fails; reflect on why it failed? 
//      - describe another way to pick the threshold 
//
// submit your sketch as a .zip file with the PDF and images included
//
// Keith O'Hara <kohara@bard.edu>
// Feb 2019

import processing.video.*;

//Capture cam;
PImage cam;

int hist[];
float thresh = 128;

void setup() {
  size(640, 480);

  // for the webcam
  // cam = new Capture(this, width/2, height/2);
  // cam.start();

  // to load image from file
 // cam = loadImage("img-01861.png");
  cam = loadImage("sky.jpg");
  cam.filter(GRAY);  // to convert image to gray scale
  cam.resize(width/2, height/2);

  hist = new int[256];
}

void mousePressed() {
  println("thresh = " + thresh);
}

void drawhist(int [] h) {
  int sum = 0;
  noStroke();    
  for (int i = 0; i < h.length; i++) {
    //draw pdf
    fill(i);
    rect(i, height/2, 1, h[i]/10);

    //draw cdf
    sum += h[i];
    rect(width/2+i, height/2, 1, sum/300);
  }
}

void calchist(PImage img, int []h) {
  img.loadPixels();
  //clear the histogram
  for (int i = 0; i < h.length; i++) {
    h[i] = 0;
  }
  for (int i = 0; i < img.pixels.length; i++) {
    // to gamma correct or not?
    int value = (img.pixels[i] & 0xFF00) >> 8;
    h[value]++;
  }
}

// given a histogram, find the mean
int calcmean(int[] h) {
  int mean=0;
  for (int i=0; i<h.length; i++) {
    int hii=h[i]*i;
    mean+=hii;
  }
  int N=calN(h);
  mean=mean/N;   
  return mean;
}

float findWCV(int[] h, float[]pi, int k) {
  float classocc1=0;
  float classocc2=0;
  float classmean1=0;
  float classmean2=0;
  float classvar1=0;
  float classvar2=0;
  float wcv=0;
  int[]h1=new int[k];  
  arrayCopy(h, 0, h1, 0, k);
  int[]h2=new int[h.length-k];
  arrayCopy(h, k, h2, 0, h.length-k);
  float classpi1[]= new float[k];
  arrayCopy(pi, 0, classpi1, 0, k);
  float classpi2[]= new float[h.length-k];
  arrayCopy(pi, k, classpi2, 0, h.length-k);

  for (int i=0; i<classpi1.length; i++) {
    classocc1+=classpi1[i];
  }
 // println("classocc1:"+classocc1);
  for (int i=0; i<classpi2.length; i++) {
    classocc2+=classpi2[i];
  }
 // println("classocc2:"+classocc2);
  
  for (int j=0; j<k; j++) {
    float ipi=(j*pi[j])/classocc1;
    classmean1+=ipi;
  }
   //println("classmean1:"+classmean1);
   for (int j=k+1; j<pi.length; j++) {
    float ipi=(j*pi[j])/classocc2;
    classmean2+=ipi;
  }
  //println("classmean2:"+classmean2);
  
 for (int t=0; t<k;t++) {
    float cv=(sq(t-classmean1)*pi[t])/classocc1;
    classvar1+=cv;
  }
  for (int t=k+1; t<pi.length;t++) {
    float cv=(sq(t-classmean2)*pi[t])/classocc2;
    classvar2+=cv;
  }
   wcv=classocc1*classvar1+classocc2*classvar2;
  return wcv;
}

int calN(int[] h){
  int N=0;
  for (int i=0; i<h.length; i++) {
    N+=h[i];
  }
  return N;
}

// given a histogram, find the otsu threshold
int calcotsu(int[] h) {
  float allpi[]=new float[h.length];
  float wcv=0;
  float smallest=100000000;
  int choosen=0;
  float N=float(calN(h));
  
  for (int j=0; j<h.length; j++) {
    float pi=h[j]/N;
   // println("hj:"+h[j]);
    //println("pi:"+pi);
    allpi[j]=pi;
  }

 for(int k=h.length;k>0;k--){
 wcv=findWCV(h, allpi, k);
// println("wcv:"+wcv);
  //println("smallest:"+smallest);
 if(wcv<smallest){
   smallest=wcv;
  // println("smallest:"+smallest);
   choosen=k;
 }
}
//  println("n: "+N);
//  println("choosen:"+choosen);
 
  return choosen;
}
// given a histogram, find the median
int calcmedian(int []h) {
  int tsum = 0;
  for (int i = 0; i < h.length; i++) {
    tsum += h[i];
  }
  int sum = 0;
  for (int i = 0; i < h.length; i++) {
    sum += h[i];
    if (sum >= tsum/2) return i;
  }
  return -1;
}

int mode(int[] h){
  int mode=0;
  int biggest=0;
  for(int i=0;i<h.length;i++){
    int big=h[i];
    if(big>biggest){
      biggest=big;
      mode=i;
    }
  }
  return mode;  
}


void draw() {
  PImage frame = cam.get(); // make a copy of the image
  frame.filter(GRAY);

  background(0, 0, 48);

  image(frame, 0, 0);
  thresh = mouseX % (width/2);
  frame.loadPixels();

  calchist(frame, hist);
  drawhist(hist);

  // calcuate median and draw it on the histogram
  stroke(0, 255, 0);
  int m = calcmedian(hist);
  line(m, height/2, m, height);
  line(m+width/2, height/2, m+width/2, height);

  // calcuate mean and draw it on the histogram
  stroke(0, 255,255);
  int u = calcmean(hist);
  line(u, height/2, u, height);
  line(u+width/2, height/2, u+width/2, height);

  // calcuate otsu threshold and draw it on the histogram
  stroke(255, 255, 0);
  int o = calcotsu(hist);
  line(o, height/2, o, height);
  line(o+width/2, height/2, o+width/2, height);
  
  stroke(255, 0, 255);
  int d = mode(hist);
  line(d, height/2, d, height);
  line(d+width/2, height/2, d+width/2, height);

  if (key == 'u') thresh = u;
  if (key == 'm') thresh = m;
  if (key == 'o') thresh = o;
  if (key == 'd') thresh = d;

  for (int i = 0; i < frame.pixels.length; i++) {
    // to gamma correct or not?
    int ivalue = frame.pixels[i] & 0xFF00 >> 8;
    //float value = pow(ivalue/255.0, 1/2.2)*255;
    int value = ivalue;
    frame.pixels[i] = value > thresh? 0xFFFFFF: 0x000000;
  }
  frame.updatePixels();
  //frame.filter(DILATE);
  //frame.filter(DILATE);
  //frame.filter(DILATE);
  image(frame, width/2, 0);

  stroke(0, 0, 255);
  fill(0, 0, 255);
  rect(thresh-3, height-100, 6, 45);
  rect(thresh+width/2-3, height-100, 6, 45);
}

void captureEvent(Capture c) {
  c.read();
}
