#include <Servo.h>
#include <IRremote.h>

Servo myservo;

int val = 0;
int mappedVal = 0;
int speedVal = 80;

long duration;
int distance;
boolean play = true;

const int trigPin = 1;
const int echoPin = 2 ;
const int recvrPin = 10;
const int servoPin = 9;

IRrecv irrecv(recvrPin);
decode_results results;

void setup()
{
  Serial.begin(9600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }
  irrecv.enableIRIn(); // Start the receiver
  myservo.attach(servoPin); // servo digital pin 9
  myservo.write(speedVal);
  pinMode(trigPin, OUTPUT); // Sets the trigPin as an Output
  pinMode(echoPin, INPUT); // Sets the echoPin as an Input
}

void loop()
{
  //checkSpeed();
  checkDistance();
  checkRemote();
}

void checkRemote()
{
  if (irrecv.decode(&results)) {
    translateIR();
    //Serial.println(results.value, HEX);
    irrecv.resume(); // Receive the next value
  }
}

void checkSpeed()
{
  val = analogRead(0);
  mappedVal = map(val, 0, 1021, 60, 120);
  //Serial.println(mappedVal);
  myservo.write(mappedVal);
}

void checkDistance()
{
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(8);
  digitalWrite(trigPin, LOW);

  duration = pulseIn(echoPin, HIGH);
  distance = duration * 0.034 / 2;

  
  //if (constrain(distance, 15 , 63)) {
    Serial.write(map(distance, 15, 40, 1, 5));
    //Serial.println(distance);
    //Serial.println(distance + " --> " + map(distance, 10, 60, 1, 6));
    //Serial.println(map(distance, 10, 50, 1, 4));
  //}
  /*else if(constrain(distance, 1, 15)){
    Serial.write(0);
    }*/
}

void translateIR()
{
  switch (results.value)
  {
    case 0xFF629D:
      // VOL+
      Serial.write('H');
      break;

    case 0xFFA857:
      // VOL-
      Serial.write('L');
      break;

    case 0xFF906F:
      // CH+
      break;

    case 0xFFE01F:
      // CH-
      break;

    case 0xFFC23D:
      // >>|
      speedVal -= 2;
      myservo.write(speedVal);
      break;

    case 0xFF22DD:
      // |<<
      speedVal += 2;
      myservo.write(speedVal);
      break;

    case 0xFF02FD:
      // >||
      if (myservo.attached())
        myservo.detach();
      else
        myservo.attach(servoPin);
      myservo.write(speedVal);
      break;

    case 0xFF6897:
      // 0
      speedVal = 80;
      myservo.write(speedVal);
      Serial.write('Z');
      break;

    case 0xFF30CF:
      // 1
      break;

    case 0xFF18E7:
      // 2
      break;

    case 0xFF7A85:
      // 3
      break;

    case 0xFF10EF:
      // 4
      break;

    case 0xFF38C7:
      // 5
      break;

    case 0xFF5AA5:
      // 6
      break;

    case 0xFF42BD:
      // 7
      break;

    case 0xFF4AB5:
      // 8
      break;

    case 0xFF52AD:
      // 9
      break;

    default:
      // ??
      break;
  }
  //delay(500);
}
