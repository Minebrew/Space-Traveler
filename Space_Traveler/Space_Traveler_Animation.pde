import processing.sound.*;

// Add a PImage for the overlay
PImage overlayImage;

// Cell size for smoother transition
int gridSize = 12;
// Noise transition
float timeOffset = 0.02;
//Background movement
float moveSpeed = 0;

// Virtual canvas size
int virtualWidth = 3900;
int virtualHeight = 1000;
int visibleWidth = width / gridSize + 1;
int visibleHeight = height / gridSize + 1;

// Sound objects
SinOsc soundEffect;
// +Sound layer for ambient
SinOsc soundLayer;

// Store previous circle sizes
float[][] previousSizes;
float[][] noiseCache;

void setup() {
  fullScreen(P3D);
  noStroke();
  frameRate(120);
  
  // Initialize sound
  soundEffect = new SinOsc(this);
  soundLayer = new SinOsc(this);  // For background ambient sound
  
  // Load the overlay image
  overlayImage = loadImage("your-image.png"); // Replace with your image file path
  
  // Initialize previous sizes
  previousSizes = new float[virtualWidth / gridSize + 2][virtualHeight / gridSize + 2];
  for (int i = 0; i < previousSizes.length; i++) {
    for (int j = 0; j < previousSizes[i].length; j++) {
      previousSizes[i][j] = 0; // Start with zero sizes
    }
  }
  
  // Start background sound layer with soft ambient tones
  soundLayer.amp(0.05);  // Set the initial amplitude
  soundLayer.freq(150);  // Set the frequency for background sound
  soundLayer.play();  // Start playing the ambient sound
}

void draw() {
  background(0); // Inverted background color (black)
  
  // Calculate movement offset based on mouse position
  float xOffset = (mouseX * moveSpeed) % gridSize;
  float yOffset = (mouseY * moveSpeed) % gridSize;
  
  // Add subtle dynamic color to background based on frameCount
  float r = (sin(frameCount * 0.01) + 1) * 50;
  float g = (cos(frameCount * 0.02) + 1) * 50;
  float b = (sin(frameCount * 0.03) + 1) * 50;
  fill(r, g, b, 50); // Subtle dynamic background color
  rect(0, 0, width, height); // Fill background with dynamic color
  
  // Loop through the virtual grid, drawing beyond screen bounds for a smooth scroll
  for (int i = -1; i <= virtualWidth / gridSize; i++) {
    for (int j = -1; j <= virtualHeight / gridSize; j++) {
      float x = (i * gridSize) * 0.5 - xOffset;
      float y = (j * gridSize) * 0.5 - yOffset;
      float noiseValue = noise(i * 0.1 + mouseX * 0.005, j * 0.1 + mouseY * 0.005, frameCount * timeOffset);
      float circleSize = map(noiseValue, 0, 1, gridSize * 1.2, 0);
      
      int gridX = i + 1;
      int gridY = j + 1;
      float previousSize = previousSizes[gridX][gridY];
      
      if (abs(circleSize - previousSize) > 1) {
        float frequency = map(circleSize, 0, gridSize * 1, 100, 400);
        float amplitude = map(abs(circleSize - previousSize), 0, gridSize * 2, 0.1, 0.1);
        soundEffect.freq(frequency);
        soundEffect.amp(amplitude);
        soundEffect.play();
      }
      
      previousSizes[gridX][gridY] = circleSize;
      
      float circleColor = map(noiseValue, 0, 1, 100, 255);
      fill(circleColor, 255 - circleColor, 255, 150);
      rect(x, y, circleSize, circleSize);
    }
  }
  
  float ambientFreq = map(mouseX, 0, width, 50, 150);
  float ambientAmp = 0.05 + sin(mouseY * 0.01) * 0.05;
  soundLayer.freq(ambientFreq);
  soundLayer.amp(ambientAmp);
  
  if (!soundLayer.isPlaying()) {
    soundLayer.play();
  }
  
  // Add the overlay image on top
  tint(255, 255); // Adjust transparency of the overlay
  image(overlayImage, 0, 0, width, height); // Draw the overlay image
  
  // Draw the crosshair
  drawCrosshair();
}

void drawCrosshair() {
  stroke(0, 255, 0); // Green crosshair
  strokeWeight(4);   // Line thickness
  
  // Horizontal line
  line(mouseX - 15, mouseY, mouseX + 15, mouseY);
  
  // Vertical line
  line(mouseX, mouseY - 15, mouseX, mouseY + 15);
  
  // Restore noStroke for other drawing operations
  noStroke();
}
