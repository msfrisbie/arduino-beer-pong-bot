#include <Servo.h> 
#include <AFMotor.h>

const int BUFLEN = 10;
int i, j, k, l, m;
Servo yaw; 
int incomingByte = 0;
int power = 0;
int angle = 90;
int time = 0;
char letter;
char buffer[BUFLEN];
int bufsize;
//Servo pitch
//lower degrees rotates left
 
AF_DCMotor arm(1, MOTOR12_64KHZ);
 
//int pos = 0;   
 
void setup() 
{ 
  yaw.attach(9);  // attaches the servo on pin 9 to the servo object 
  Serial.begin(9600);
  
  //pitch.attach(10);
  
  //arm.setSpeed(160);
  //int i;
} 
 
 
void loop() 
{ 
  
  // fire(power, angle, time)
  
  // wait for command
  
  if(Serial.available())
  {
    i = 0;
    Serial.print(">> ");
    while(Serial.available())
    {
      buffer[i] = Serial.read();
      //letter = (char)incomingByte;
      //Serial.println(buffer[bufsize]);
      Serial.print(buffer[i]);
      //Serial.println(i);
      i++;
      //Serial.println(incomingByte, DEC);
    }
    Serial.print("\n");
    if(buffer[0]=='f' && buffer[1]=='i' && buffer[2]=='r' && buffer[3]=='e')
    {
      Serial.println("entering firing routine");\
      clearBuf();
      fireSetup();
      fire(power,angle,time);
    }
    else if(buffer[0]=='l' && buffer[1]=='f' && buffer[2]=='i' && buffer[3]=='r' && buffer[4]=='e')
    {
      if(power != 0 && angle != 0 && time != 0)
        fire(power,angle,time);
      else
        Serial.println("no firing values stored");
    }
    else if(buffer[0]=='a' && buffer[1]=='n' && buffer[2]=='g' && buffer[3]=='l' && buffer[4]=='e')
    {
      clearBuf();
      while(1)
      {
        Serial.println("enter angle to move to (0-255): ");
        getValue(angle);
        if(angle < 0 || power > 180)
        {
          Serial.println("invalid angle value, try again");
          continue;
        }
        Serial.print("rotating servo to angle ");
        Serial.println(angle);
        yaw.write(angle);
        break;
      }
      power = 0;
      angle = 0;
      time = 0;
    }
    else if(buffer[0]=='r' && buffer[1]=='e' && buffer[2]=='s' && buffer[3]=='e' && buffer[4]=='t')
    {
      yaw.write(100);
      returnToLoad();
    }
    else
      Serial.println("unknown command");
  }
} 

void fireSetup()
{
  while(1)
  {
    Serial.println("enter power value (0-255): ");
    getValue(power);
    if(power < 0 || power > 255)
    {
      Serial.println("invalid power value, try again");
      continue;
    }
    Serial.print("power value: ");
    Serial.println(power, DEC);
    break;
  }
  while(1)
  {
    Serial.println("enter angle value (0-180): ");
    getValue(angle);
    if(angle < 0 || angle > 180)
    {
      Serial.println("invalid angle value, try again");
      continue;
    }
    Serial.print("angle value: ");
    Serial.println(angle, DEC);
    break;
  }
  while(1)
  {
    Serial.println("enter time value (0-200): ");
    getValue(time);
    if(time < 0 || time > 200)
    {
      Serial.println("invalid time value, try again");
      continue;
    }
    Serial.print("time value: ");
    Serial.println(time, DEC);
    break;
  }
}

void fire(int power, int angle, int time)
{
  Serial.print("firing arm at ");
  Serial.print(power);
  Serial.print(", ");
  Serial.print(angle);
  Serial.print(", ");
  Serial.println(time);
  arm.run(RELEASE);
  yaw.write(angle);
  delay(1000); //allow ball to be placed in arm
  arm.setSpeed(power);
  
  Serial.println("Firing in 3...");
  delay(1000);
  Serial.println("2...");
  delay(1000);
  Serial.println("1...");
  delay(1000);
  arm.run(FORWARD); //fire!
  delay(time); 
  arm.run(RELEASE);
  returnToLoad();
}

void returnToLoad()
{
  arm.setSpeed(90);
  delay(1000);
  arm.run(BACKWARD);
  delay(500);
  arm.run(RELEASE);
  return;
}

void clearBuf()
{
  for(l=0;l<BUFLEN;l++)
    buffer[l]='\0';
}

void getValue(int & value)
{
  int mod = 0;
  while(!Serial.available())
  {
    if(mod%100==0)
      Serial.println("waiting for input...");
    delay(50);
    mod++;
  };
  
  i = 0;
  
  //Serial.print(">>");
  while(1)
  {
    Serial.print(buffer[2-i] = (int)(Serial.read()-48));
    i++;
    
    //Serial.println(incomingByte, DEC);
    if(!Serial.available())
      break;
  }
  
  value = 1*(int)buffer[0] + 10*(int)buffer[1] + 100*(int)buffer[2];
  if(i==2)
    value /= 10;
  if(i==1)
    value /= 100;
  
  clearBuf();
}
