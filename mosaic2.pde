
/**
 * Vanilla Mosaic Maker (see: http://en.wikipedia.org/wiki/Photo_mosaic )
 * Keith O'Hara <kohara@bard.edu>
 * Sep 2014
 *
 * Depending on the number of images you might have to increase
 * the maximum available memory (in the Processing Preferences menu)
 * 
 * Required improvements:
 *  (1) replace each COMMENT with a meaningful comment
 *  (2) choose the small images in a non-random manner 
 *      (e.g. for a region or pixel, pick an image with a 
 *            similar average color (RGB or HSV?) or similar histogram)
 *  (3) prevent or discourage using the same image over and over again
 *
 * Other possible improvements:
 *  - allow overlap of images rather than a rigid grid (perhaps using transparency) 
 *  - blur smaller images around borders to be less rectangle-y
 *  - display the image in the webcam as a mosaic (rather than a static file)
 **/

// the image we are trying to recreate
PImage video;

// our array of smaller mosaic images
PImage imgs[];
int num_imgs = 0;

// size of the small mosaic images
int img_width = 3;
int img_height = 2;

int MAX_IMGS = 1882;  //5883;
color main[];
int used[];
int countUsed=0;
int hueRange=360;
PImage chose;
int[] hues;
public void setup() {
  colorMode(RGB, 255);
  video = loadImage("meme.jpg");
  chose= loadImage("meme.jpg");
  size(662, 600);

  imgs = new PImage[MAX_IMGS];
  main = new color[MAX_IMGS];
  used = new int[MAX_IMGS];
  for(int i=0;i<MAX_IMGS;i++){
      used[i]=0;
    }
  loadSavedImages();
  loadMainColor();

  randomSeed(0);
  noStroke();
}

//load the mosaic images
void loadSavedImages() {
  for (int i = 1; i < MAX_IMGS; i += 1) {
    try {
      imgs[num_imgs] =  loadImage("snap" + nf(i, 4) + ".jpg"); 
      //nf(num, digits)
      if (imgs[num_imgs] != null) {
        println ("loaded image #", num_imgs);
        num_imgs ++;
      }
    }
    catch(Exception e) {
    }
  }
  println("number of images = ", num_imgs);
}
color findAveragecolor(PImage mas){
  mas.loadPixels();
  int red = 0;
  int blue = 0;
  int green =0;
   for (int i = 0; i < mas.pixels.length; i++) {
  int pixel = mas.pixels[i];
    int r = (pixel >> 16) & 0xff;//shifting pixelColor to the right by 16 bits, where the red value is stored
    int g = (pixel >> 8) & 0xff;//get the green value
    int b = pixel & 0xff;//get the blue value
    red+=r;
    blue+=b;
    green+=g;
   }
   red=red/mas.pixels.length;
   blue=blue/mas.pixels.length;
   green=green/mas.pixels.length;
   color m=color(red, blue, green);
  return m;
}

color[]loadMainColor() {  
  for (int j=0; j<num_imgs; j++) {
    print("j: "+j);
    color d= findAveragecolor(imgs[j]);//find main color for each mosiac images  
    main[j]=d;
  }
  return main;
}

PImage findImage(color pc) {// pixel color
  float close=0;//difference between pixel hue and mosaic image main hue
  float smallest = 10;//the smallest difference between hues
  int choosen =0;//index of the choosen image
    int r = (pc >> 16) & 0xff;//shifting pixelColor to the right by 16 bits, where the red value is stored
    int g = (pc >> 8) & 0xff;//get the green value
    int b = pc & 0xff;//get the blue value
    
  PImage finalchose =imgs[choosen];
  for (int k=0; k< main.length-1; k++) {//loop through every mosaic hue
//  if(used[k]<500){ //check if choosen is already used   
    mc=hue(main[k]);
    close=abs(mc-ph);
    if (close<smallest) {
      smallest=close;
      choosen=k;
    } 
 // }
  }
 finalchose =imgs[choosen];
 color f=color(mc,pb,sb,100);
// colorMode(RGB,255);
// tint(f);
  used[choosen]+=1;
  return finalchose;
}


void draw() {
  
  video.loadPixels();


  for (int x = 0; x < width; x+= img_width) {
    for (int y = 0; y < height; y+= img_height) {

      /////////////      // COMMENT what's the difference between width and video width
      int vx = int(map(x, 0, width, 0, video.width));
      //map(value, current start1, current stop1, target start2, target stop2),convert value's range
      int vy = int(map(y, 0, height, 0, video.height));

      // the location of each individual mosaic image
      int i = video.width*vy + vx;
      //take the color of the original image at the position of a mosaic image 
      
       color Pcolor = video.get(vx,vy);
      //transform color values from a special format to standard RGB values (which is 8 bits long).

     // int r = (pixelColor >> 16) & 0xff;//shifting pixelColor to the right by 16 bits, where the red value is stored
     // int g = (pixelColor >> 8) & 0xff;//get the green value
     // int b = pixelColor & 0xff;//get the blue value
     // float pcolor = hue(Pcolor); 
      // randomly take one mosaic image from all images
      //int j = int(random(0, num_imgs));
      PImage f=findImage(Pcolor);
      
      image(f, x, y, img_width, img_height);
      // change the color of that random mosaic image to the a similar color to the original image 
      // tint(color(r, g, b));

      // print the mosaic image at the right position
      //image(imgs[j], x, y, img_width, img_height);
    }
  }


  // image(findImage(200.1), 100,100, 100,100);
  saveFrame("mosaic.png");
  noLoop();
}
