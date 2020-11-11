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
int img_width = 18;
int img_height = 12;

int MAX_IMGS = 100;  //5883;

public void setup() {
  //video = loadImage("meme.jpg");
  video = loadImage("wwatcf.jpg");
  size(1000,1500);

  imgs = new PImage[MAX_IMGS];
  loadSavedImages();
  randomSeed(0);
  noStroke();
}

//load the mosaic images
void loadSavedImages() {
  for (int i = 1; i < MAX_IMGS; i += 1) {
    try {
      imgs[num_imgs] =  loadImage("snap" + nf(i, 4) + ".jpg"); 
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

void draw() {
  
  video.loadPixels();

  for (int x = 0; x < width; x+= img_width) {
    for (int y = 0; y < height; y+= img_height) {

      // COMMENT 
      int vx = int(map(x, 0, width, 0, video.width));
      int vy = int(map(y, 0, height, 0, video.height));

      // COMMENT
      int i = video.width*vy + vx;

      int pixelColor = video.pixels[i];

      // COMMENT
      int r = (pixelColor >> 16) & 0xff;
      int g = (pixelColor >> 8) & 0xff;
      int b = pixelColor & 0xff;

      // COMMENT
      int j = int(random(0, num_imgs));

      // COMMENT
      tint(color(r,g,b));

      // COMMENT
      image(imgs[j], x, y, img_width, img_height);
    }
  }
  saveFrame("mosaic.png");
  noLoop();
}
