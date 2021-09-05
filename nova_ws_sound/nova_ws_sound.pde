import oscP5.*;
import netP5.*;
import processing.sound.*;

AudioIn input;
Amplitude analyzer;
OscP5 oscP5;
NetAddress myRemoteLocation;

boolean animation1Flag = true;

void setup() {
  size(800, 500);
  background(255);
  frameRate(25);
  oscP5 = new OscP5(this, 7110);
  
  myRemoteLocation = new NetAddress("192.168.1.103", 7110);
  
  // Start listening to the microphone
  // Create an Audio input and grab the 1st channel
  input = new AudioIn(this, 0);

  // start the Audio Input
  input.start();

  // create a new Amplitude analyzer
  analyzer = new Amplitude(this);

  // Patch the input to an volume analyzer
  analyzer.input(input);
}


// ----- MAIN METHOD ------
/*
* create a program that reacts to keyboard typing.

* you can use the following helper functions 
*   random(0, 100); --> generates a random value between 0 and 99.
*   delay(1000); --> halt program for a specified amount of time.
*   sendOsc(lampNumber, isOn); --> sends signal to lamp number specified int he first parameter. Turns the lamp on or off based on the second parameter.
*/
void draw() {
  background(255); // accepted values 0 -> 255.
  // Get the overall volume (between 0 and 1.0)
  float volume = analyzer.analyze();
  
  // Do something when threshold is reached.
  float threshold = 0.1;
  if (volume > threshold) {
    turnOffAllLamps();
    int lampNr = (int) map(volume, 0, 1, 0, 7);
    sendOsc(lampNr, true);
    println("turned on:" + lampNr);
    delay(300);
  }
  
  // Graph the overall volume and show threshold
  float y = map(volume, 0, 1, height, 0);
  float ythreshold = map(threshold, 0, 1, height, 0);
  noStroke();
  fill(175);
  rect(0, 0, 20, height);
  // Then draw a rectangle size according to volume
  fill(0);
  rect(0, y, 20, y);
  stroke(0);
  line(0, ythreshold, 19, ythreshold);
}
// -----------------------


void turnOffAllLamps() {
  for (int i = 1; i < 7; i++) {
    sendOsc(i, false);
  }
}

void sendOsc(int point, boolean on) {
  OscMessage myMessage = new OscMessage("/pi3/band");
  int command = point * 10;
  if (on) {
    command += 1;
  }
  myMessage.add(command); /* add an int to the osc message */
  oscP5.send(myMessage, myRemoteLocation); 
}