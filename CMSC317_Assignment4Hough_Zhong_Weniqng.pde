/* * * * * * * * * * * * * * * * * * *
 * Hough Transform Assignment
 *
 * Keith O'Hara <kohara@bard.edu>
 * 
 * Finish this sketch by visualizing the resulting Hough transform. 
 * Choose one method:
 *   (1) Draw all lines voted on at least n times
 *   (2) Devise a method to pick the voting threshold automatically? 
 *   (3) Draw the top-n lines (e.g. display the 3 most voted for lines)
 *
 * Extra:
 *   - perform canny edge detection first
 *   - Use wider bins for theta and rho to speed up the hough calculation. 
 *     Rather than having an array cell for each degree of theta and pixel 
 *     of distance, group them by say 5 degrees per bin, or 5 pixels per bin.
 *
 */

import processing.video.*;

Capture cap;
PImage img;
PImage nimg;

float[][]kernel = 
  {
  { 0, -1, 0 }
  , 
  { -1, 4, -1}
  , 
  { 0, -1, 0}
}; //laplacian kernel


int[][] hough;
int nrho = 600;
int ntheta = 360;
float avg1;
float threshold;

void setup() {
  size(320, 240);
  cap = new Capture(this, width, height);

  if (cap != null) {
    cap.start();
  } else {
    img = loadImage("test.jpg");
    img.resize(width, height);
    img.filter(GRAY);
  }
  nimg = createImage(width, height, ARGB);
  avg1=20;
}


void draw() {
  background(0);
  hough = new int[nrho][ntheta];
  if (cap != null) {
    img = cap.get();
    img.filter(GRAY);
  }

  img.loadPixels();
  nimg.loadPixels();
  float avg=0;
  
  for (int y = 5; y < img.height-5; y++) { 
    for (int x = 5; x < img.width-5; x++) {
       float s=0;
      for (int kj = 0; kj < kernel.length; kj++) {
        for (int ki = 0; ki < kernel[kj].length; ki++) {
          // Calculate the pixel position for kernel entry (kj,ki)
          int ky = ki - kernel.length/2;
          int kx = kj - kernel[kj].length/2;
          int yy = y + ky;
          int xx = x + kx;     
          // find (xx,yy) position in the pixel aray    
          int pos = yy*img.width + xx;
          // make sure the pixel position is valid
          if (yy >= 0 && yy < img.height && xx >= 0 && xx < img.width) {
            // assumes image is grayscale (r = g = b)
            s += kernel[kj][ki] * green(img.pixels[pos]);
          }
        }
      }
      
      s = abs(s);
      nimg.pixels[y*img.width + x] = color(s);      
      avg+=s;
      if (s > avg1) {
        for (int theta = 0; theta < ntheta; theta ++) {
          int rho = (int)(x*cos(theta) + y*sin(theta));
          if (rho > 0 && rho < nrho) {
            hough[rho][theta]++;  
          }
        }
      }
      
    }
  }
  //chose mean value to be the threshold
  avg1= avg/nimg.pixels.length; 
  
  nimg.updatePixels();
  image(nimg, 0, 0);

  // draw hough lines
  stroke(0, 255, 0);
  strokeWeight(1);
  //AllLinesOver150Votes(hough);
  TopVoted3Lines(hough);
}

// for video capture
void captureEvent(Capture c) {
  c.read();
}

void plotLine(float a, float b, float c) {
  if (abs(a) < abs(b)) {
    // mostly horizontal
    line(0, c/-b, width, (a*width + c)/-b);
  } else {
    //mostly vertical
    line(c/-a, 0, (b * height + c)/-a, height);
  }
}

void AllLinesOver150Votes(int[][] hough){
 for(int i=0;i<hough.length;i++){
    for(int j=0;j<hough[i].length;j++){
      if(hough[i][j]>150){
    plotLine(cos(float(j)),sin(float(j)),-float(i));
      }
    }
  }
}

void TopVoted3Lines(int[][] hough){
  int biggest1=0;
  int biggest1i=0;
  int biggest1j=0;
  int biggest2=0;
  int biggest2i=0;
  int biggest2j=0;
  int biggest3=0;
  int biggest3i=0;
  int biggest3j=0;
 for(int i=0;i<hough.length;i++){
    for(int j=0;j<hough[i].length;j++){
      if(hough[i][j]>biggest1){
        biggest1=hough[i][j];
        biggest1i=i;
        biggest1j=j;
      }
      else if(hough[i][j]<biggest1&&hough[i][j]>biggest2){
        biggest2=hough[i][j];
        biggest2i=i;
        biggest2j=j;
      }
      else if(hough[i][j]<biggest2&&hough[i][j]>biggest3){
        biggest3=hough[i][j];
        biggest3i=i;
        biggest3j=j;
      }
    }
  }
  plotLine(cos(float(biggest1j)),sin(float(biggest1j)),-float(biggest1i));
  plotLine(cos(float(biggest2j)),sin(float(biggest2j)),-float(biggest2i));
  plotLine(cos(float(biggest3j)),sin(float(biggest3j)),-float(biggest3i));
}



  
