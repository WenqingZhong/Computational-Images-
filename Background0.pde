import processing.video.*;
Capture video;
PImage bgImage;
PImage f;
int state;
float[]avg;
int t;

void setup() {
  size(640, 240);
  video = new Capture(this, width/2, height);
  video.start();
  bgImage=captureEvent(video);
  f=captureEvent(video);
  state =0;
  t=0;
  avg = new float[bgImage.pixels.length];
  for (int i=0; i<bgImage.width; i++) {
    for (int j=0; j<bgImage.height; j++) {
      int loc= i +bgImage.width*j;
      color b=bgImage.pixels[loc];
      float rb = (b >> 16) & 0xff;
      avg[loc]=rb;
    }
  }
}

void keyPressed() {
  if (key == ' ') {
    bgImage = video.get();
    bgImage.filter(GRAY);
    state =1;
  }
}

PImage Baseline(float T, PImage newimg, PImage oldimg) {  
  PImage img = createImage(newimg.width, newimg.height, ARGB);
  img.loadPixels();
  for (int i=0; i<newimg.width; i++) {
    for (int j=0; j<newimg.height; j++) {
      int loc= i +newimg.width*j;

      color b=oldimg.pixels[loc];
      float rb = (b >> 16) & 0xff;

      color f=newimg.pixels[loc];
      float rf = (f >> 16) & 0xff;
      float diff=abs(rb-rf);
      img.pixels[loc]= color(rf, rf, rf, 255);

      if (state==1) {
        if (diff>T) {
          img.pixels[loc]=color(rf, rf, rf, 255);
        } else {
          img.pixels[loc] = color(0, 0, 0, 255);
        }
      }
    }
  }
  return img;
}

PImage Average(float T, PImage newimg) {
  t=2;
  PImage img = createImage(newimg.width, newimg.height, ARGB);
  img.loadPixels();
  for (int i=0; i<newimg.width; i++) {
    for (int j=0; j<newimg.height; j++) {
      int loc= i +newimg.width*j;
      color f=newimg.pixels[loc];
      float rf = (f >> 16) & 0xff;

      float oldavg=avg[loc];
      float diff=abs(rf-avg[loc]);
      avg[loc]=oldavg+(rf-oldavg)/t;


      img.pixels[loc]= color(rf, rf, rf, 255);
      if (state==1) {
        if (diff>T) {       
          img.pixels[loc]=color(rf, rf, rf, 255);
        } else {
          img.pixels[loc] = color(0, 0, 0, 255);
        }
      }
    }
  }
  t++;
  return img;
}

void draw() {
  video.filter(GRAY); 
  image(video, 0, 0); 
  image(bgImage, 0, 0);
  PImage cam=captureEvent(video);
  cam.filter(GRAY);
  // f= Baseline(50, cam, bgImage);
  f=Average(100, cam);
  image(f, 0, 0);
  if (bgImage != null) image(bgImage, width/2, 0);
}

// for video capture

PImage captureEvent(Capture c) {  
  c.read();
  PImage camp=video.get();
  return camp;
}
