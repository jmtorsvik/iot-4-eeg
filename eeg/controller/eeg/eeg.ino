#include <Filters.h>
#include <Filters/Butterworth.hpp>

#define SAMPLE_RATE 256
#define BAUD_RATE 115200
#define INPUT_PIN 34

float SIGNAL;
//float SENSOR_VALUE;

static long TIMER = 0;

static unsigned long PAST = 0;

void setup() {
	// Serial connection begin
	Serial.begin(BAUD_RATE);
}

// Sampling frequency
const double f_s = 256; // Hz
// Cut-off frequency (-3 dB)
const double f_c = 29.5; // Hz
// Normalized cut-off frequency
const double f_n = 2 * f_c / f_s;

auto filter = butter<4>(f_n);

void loop() {
	// Calculate elapsed time
	unsigned long present = micros();
	unsigned long interval = present - PAST;
	PAST = present;

	// Run timer
	TIMER -= interval;

  //float signal;
  //float SENSOR_VALUE;

	// Sample
	if(TIMER < 0){
		TIMER += 1000000 / SAMPLE_RATE;
		//SENSOR_VALUE = ;
		SIGNAL = filter(analogRead(INPUT_PIN));
    //Serial.print("eeg: ");
		sendToPC(&SIGNAL);
	}
}

void sendToPC(float* data)
{
  byte* byteData = (byte*)(data);    // Casting to a byte pointer
  Serial.write(byteData, 4);         // Send through Serial to the PC
}