import processing.sound.*;
import processing.serial.*;

SoundFile chant, clap, hat, kick, sax_loop, snare;
Serial myPort;
int input = 0;
float loudness = 1f;
//ArrayList circles = new ArrayList();
FadingCircle circle1000, circle800, circle600, circle400;
SoundCircle ring1, ring2, ring3, ring4;

void setup() {
  size(1030, 515);
  background(255);
  //println(Serial.list());
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);

  // Load a soundfile from the /data folder of the sketch and play it back
  chant = new SoundFile(this, "chant.wav");
  clap = new SoundFile(this, "clap.wav");
  hat = new SoundFile(this, "hat.wav");
  kick = new SoundFile(this, "kick.wav");
  sax_loop = new SoundFile(this, "sax_loop.wav");
  snare = new SoundFile(this, "snare.wav");
  //sax_loop.loop();

  circle1000 = new FadingCircle(1000, 1000, #ee26a0);
  circle800 = new FadingCircle(800, 800, #8926ee);
  circle600 = new FadingCircle(600, 600, #26afee);
  circle400 = new FadingCircle(400, 400, #eec626);

  ring1 = new SoundCircle(kick, circle400);
  ring2 = new SoundCircle(clap, circle600);
  ring3 = new SoundCircle(snare, circle800);
  ring4 = new SoundCircle(chant, circle1000);
}      

void draw() {
  while (myPort.available() > 0) {
    input = myPort.read();
    checkInput(input);
  }
  drawRadar();
  drawText();
}

void checkInput(int val) {
  println(val);

  switch(val) {
  case 1: 
    ring1.playSound();
    break;
  case 2: 
    ring2.playSound();
    break;
  case 3: 
    ring3.playSound();
    break;
  case 4: 
    ring4.playSound();
    break;
  case 72: 
    loudness *= 2;
    break;
  case 76: 
    loudness /= 2;
    break;
  case 90: 
    loudness = 1f;
    break;
  }
}

class SoundCircle {
  SoundFile file;
  FadingCircle circle;
  boolean blinking = false;
  long startTime = 0;
  int duration = 0;

  SoundCircle(SoundFile file, FadingCircle circle) {
    this.file = file;
    this.circle = circle;
  }

  void playSound() {
    this.blinking = true;
    long currentTime = System.nanoTime();
    if ((startTime + duration) < currentTime) {
      startTime = System.nanoTime();
      duration = (int)(this.file.duration() * 1000000000);
      //println("Case 1: "+duration);
      this.file.play(1, loudness);
    } else {
      //println("Current:"+currentTime+", Goal:"+(startTime+duration));
    }
  }
  
  void drawCircle(){
    if(!blinking){
      circle.display();
    }
    else{
      circle.blink();
    }
  }
}

void drawRadar() {
  //pushMatrix();
  translate(515, 515); // moves the starting coordinats to new location
  fill(255);
  strokeWeight(4);
  stroke(#5eee1c, 190);

  //draw the colored circles
  ring4.drawCircle();
  ring3.drawCircle();
  ring2.drawCircle();
  ring1.drawCircle();
  resetCircleBlink();

  /*for (int i = 0; i < circles.size(); i++) {
   FadingCircle fc = (FadingCircle) circles.get(i);
   fc.display();
   }*/

  /*
  fill(#ee26a0, 190);
   ellipse(0, 0, 1000, 1000);
   fill(#8926ee, 190);
   ellipse(0, 0, 800, 800);
   fill(#26afee, 190);
   ellipse(0, 0, 600, 600);
   fill(#eec626, 190);
   ellipse(0, 0, 400, 400);
   noFill();
   */

  // draws the arc lines
  arc(0, 0, 1000, 1000, PI, TWO_PI);
  arc(0, 0, 800, 800, PI, TWO_PI);
  arc(0, 0, 600, 600, PI, TWO_PI);
  arc(0, 0, 400, 400, PI, TWO_PI);

  // draws the angle lines
  line(-960, 0, 960, 0);
  line(0, 0, -960*cos(radians(30)), -960*sin(radians(30)));
  line(0, 0, -960*cos(radians(60)), -960*sin(radians(60)));
  line(0, 0, -960*cos(radians(90)), -960*sin(radians(90)));
  line(0, 0, -960*cos(radians(120)), -960*sin(radians(120)));
  line(0, 0, -960*cos(radians(150)), -960*sin(radians(150)));
  line(-960*cos(radians(30)), 0, 960, 0);

  fill(#ff4141, 255);
  ellipse(0, 0, 200, 200);
  //popMatrix();
}

void drawText() { // draws the texts on the screen

  pushMatrix();
  fill(255);
  textSize(18);
  text("23cm", 125, -10);
  text("31cm", 225, -10);
  text("39cm", 325, -10);
  text("47cm", 425, -10);
  popMatrix();
}

void resetCircleBlink(){
  ring1.blinking = false;
  ring2.blinking = false;
  ring3.blinking = false;
  ring4.blinking = false;
}

class FadingCircle {

  int width, height;
  color c;
  int defaultTransparency, currentTransparency;
  boolean goingUp = true;

  FadingCircle(int x, int y, color c) {
    this.width = x;
    this.height = y;
    this.c = c;
    this.defaultTransparency = 180;
    this.currentTransparency = 180;
  }

  void blink() {
    //noStroke();
    //if (goingUp) {
      
    fill(c);
    ellipse(0, 0, width, height);
    
    /*if (currentTransparency < 255) {
      // ??
      currentTransparency = 255;
      fill(c, currentTransparency);
      ellipse(0, 0, width, height);
    } else {
      currentTransparency = defaultTransparency;
      fill(c, currentTransparency);
      ellipse(0, 0, width, height);
      //goingUp = false;
    }*/
    /*} else {
     if (currentTransparency > defaultTransparency) {
     fill(c, --currentTransparency);
     ellipse(0, 0, width, height);
     } else {
     goingUp = true;
     }
     }*/
    noFill();
  }

  void display() {
    //fill(0);
    //ellipse(0, 0, width, height);
    fill(0);
    ellipse(0, 0, width, height);
    noFill();
  }
}