/*
 * Exploring Homography Estimation
 * Keith J. O'Hara <kohara@bard.edu>
 * 
 * This sketch relates points in two images by a 3x3 homography matrix. 
 * The homography is estimated using four points (really eight, four in each image).
 * Click on four locations (in a clockwise order starting with the top left point).   
 * 
 * (1) First, understand how this code works. Write a few paragraphs in Dropbox
 *     Paper describing the algorithm. Explain the functions, global variables, 
 *     and describe what I mean by "forward" warping.
 *
 * (2) Perform your own, creative application of image stitching, for example:
 *     - insert the webcam into multiple spots in a static image
 *     - stitch together a panorama if multiples images
 *       - take multiple pictures of a planar surface or 
 *         take mutiples pictures by rotating about a central point
 *     - try using backward warping & blending to combine multiples images
 *     - use feature detection to automatically find correspondences
 * 
 * (3) Write up a lab report (PDF) explaining your project, include prose, 
 *     pictures, and code
 */

import Jama.*;
import processing.video.*;

boolean DEBUG = false;

Capture img;

ArrayList<PVector> p1 = new ArrayList<PVector>();//new image
ArrayList<PVector> p2 = new ArrayList<PVector>();//old image

Matrix homography = Matrix.identity(3, 3);

PImage back;
int state;

void setup() {
  size(640, 480);
  back = loadImage("cube2.jpg");
  back.resize(width,height);
  image(back, 0, 0, width, height); 
  state =0;
  
  img = new Capture(this, width, height);
  img.start();
  p2.add(new PVector(0, 0, 1));  
  p2.add(new PVector(img.width, 0, 1));
  p2.add(new PVector(img.width, img.height, 1));
  p2.add(new PVector(0, img.height, 1));
}

void mousePressed() {
  if (p1.size() >= 4) p1 = new ArrayList<PVector>();

  PVector v = new PVector(mouseX, mouseY, 1);
  p1.add(v);
  
  if (p1.size() == p2.size() && p1.size() >= 4) {
    homography = estimate(p1, p2);
    state=1;
  }
  
}

/*
 * Apply transformation H to vector v (matrix multiplication)
 * Return the result as a PVector in homogeneous coordinates
 */
PVector applyTransformation(Matrix H, PVector v) {
  Matrix u = new Matrix(3, 1);
  u.set(0, 0, v.x);
  u.set(1, 0, v.y);
  u.set(2, 0, v.z);
  Matrix t = H.times(u);
  return new PVector((float)t.get(0, 0), (float)t.get(1, 0), (float)t.get(2, 0));
} 

/**
 * Take two lists of points in homogeneous coordinates,
 * find the homography that relates them and return it as a 3x3 matrix
 * both lists should have 4 of more points to perform the estimation
 */
Matrix estimate(ArrayList<PVector> p1, ArrayList<PVector> p2) {
  Matrix h = Matrix.identity(3, 3);
  if (p1.size() == p2.size() && p1.size() >= 4) {

    double[][] a = new double[2*p1.size()][];

    // Creates the estimation matrix                                                                                                                                         
    for (int i = 0; i < p1.size (); i++) {
      PVector c1 = p1.get(i);//a point of new image
      PVector c2 = p2.get(i);//a point of old image
      double l1 [] = {
        c2.x, c2.y, c2.z, 0, 0, 0, -c2.x*c1.x, -c2.y*c1.x, -c1.x
      };
      double l2 [] = {
        0, 0, 0, c2.x, c2.y, c2.z, -c2.x*c1.y, -c2.y*c1.y, -c1.y
      };
      a[2*i] = l1;
      a[2*i+1] = l2;//estimate the unknow homography matrix
    }

    Matrix A = new Matrix(a);

    if (DEBUG) {
      println("Estimation Matrix");
      A.print(A.getRowDimension(), A.getColumnDimension() );
    }
    Matrix X = A.transpose().times(A);

    // assumes the eigenvalues/vectors are sorted in increasing order
    EigenvalueDecomposition E = X.eig();  
    Matrix v = E.getV();
    double[] eigenvalues = E.getRealEigenvalues();
    assert eigenvalues[0] < eigenvalues[1];

    if (DEBUG) {
      println("Eigenvalues: ");
      println(eigenvalues);
      println("Eigenvectors: ");
      v.print(v.getRowDimension(), v.getColumnDimension() );
    }

    // create the homography matrix from the smallest eigenvector                                                                                                                
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        h.set(i, j, v.get(i*3+j, 0));
      }
    }
  }

  if (DEBUG) {
    println("Estimated H");
    h.print(3, 3);
  }
  return h;
}
  
void draw() { 
  if (img.available()) {    
    img.read();    
  }
  loadPixels();
  // perform forward warping
  for (int x = 0; x < img.width; x++) {
    for (int y = 0; y < img.height; y++) {
      int idx = y * img.width + x;
      PVector np = applyTransformation(homography, new PVector(x, y, 1));
      int x1 = (int)(np.x / np.z);//new x/scale
      int y1 = (int)(np.y / np.z);//new y/scale
      //return the new image with the new scale
      
      if (x1 >= 0 && x1 < width && y1 >= 0 && y1 < height) {
        int idx1 = y1 * width + x1;
        
        color c =img.pixels[idx];
        color d=back.pixels[idx1];
        float r0 = ((c >> 16) & 0xff);    
        float g0 = ((c >> 8) & 0xff);
        float b0 = (c & 0xff);

        float r1 = ((d >> 16) & 0xff);    
        float g1 = ((d >> 8) & 0xff);
        float b1 = (d & 0xff);
        
        float r=(r0+r1*2)/3;
        float g=(g0+g1*2)/3;
        float b=(b0+b1*2)/3;

        color e=color(r, g, b); 
        if(state==1){
          pixels[idx1]= e;
        }else{
        pixels[idx1]= d;
        }
      }
    }
  }
  updatePixels();
  // draw the selected points
  for (int i = 0; i < p1.size (); i++) {
    ellipse(p1.get(i).x, p1.get(i).y, 2, 2);
    text(str(i), p1.get(i).x, p1.get(i).y);
  }
}
