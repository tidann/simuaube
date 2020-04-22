#include <Wire.h>    // Bibliothèque pour l'I2C (module RTC)
#include "RTClib.h"  // Bibliothèque pour le module RTC
#include <LiquidCrystal.h> // Bibliothèque pour l'écran
#include <SoftwareSerial.h> // Bibliothèque pour l'HC-05

#include <Adafruit_NeoPixel.h> // Bibliothèque pour la matrice de LED
#ifdef __AVR__
 #include <avr/power.h> 
#endif

#define PIN        6 // Pin PWM de controle de la matrice
#define NUMPIXELS 64 // Nombre de pixels de la matrice

Adafruit_NeoPixel pixels(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);

#define DELAYVAL 50 // Temps (en milisecondes) de pause entre chaque pixel

// Variables de temps
uint16_t year = 2016;
uint8_t month = 2;
uint8_t day = 19;
uint8_t hour = 6;
uint8_t min = 33;
uint8_t second = 59;
DateTime dt = DateTime(year, month, day, hour, min, second);

SoftwareSerial hc05(10 , 11); //Premier argument : Pin PWM RX, Deuxième argument : Pin PWM TX

uint8_t hourStart = 7; // Heure de début
uint8_t minStart = 15;

uint8_t hourInt = 7; // Heure de fin d'augmentation de la lumière
uint8_t minInt = 20;

uint8_t hourEnd = 7; // Heure de fin
uint8_t minEnd = 25;

int maxR = 100; // Valeurs RGB quand l'intensité lumineuse est maximale
int maxG = 100;
int maxB = 40;


RTC_DS1307 RTC;      // Instance du module RTC de type DS1307
String message;

void setup() {
  Serial.begin(9600); // Communication avec l'ordi pour debugger
  hc05.begin(9600); // Communication avec le module Bluetooth

  //Initialisation de la matrice
#if defined(__AVR_ATtiny85__) && (F_CPU == 16000000)
  clock_prescale_set(clock_div_1);
#endif
  pixels.begin();

  // Initialise la liaison avec le module RTC
  Wire.begin();
  RTC.begin();

  if (!RTC.isrunning()) {
    Serial.println("Le module RTC a perdu l'heure, il faut la redefinir avec l'application");
  }
}

void loop() {
  //Récupèration de l'heure et le date courante
  DateTime dt=RTC.now();
  year = dt.year();
  month = dt.month();
  day = dt.day();
  hour = dt.hour();
  min = dt.minute();
  second = dt.second();
  
  delay(1000);
  
  recupBluetooth();
  messagesDebug();

  // On réinitialise la matrice
  pixels.clear(); 

  if (hour * 60 + min > hourStart * 60 + minStart && hour * 60 + min < hourInt * 60 + minInt) { 
    // Si on est dans la période d'augmentation de la lumière
    int totalMinsIncrease = (hourInt * 60 + minInt) - (hourStart * 60 + minStart);
    int actualMinsIncrease = (hour * 60 + min) - (hourStart * 60 + minStart);

    // Ratio d'intensité (0=pas de lumière, 1=intensité maximale)
    float ratio = (float) actualMinsIncrease / totalMinsIncrease;

    // Pour chaque pixel
    for(int i=0; i<NUMPIXELS; i++) { 
      pixels.setPixelColor(i, pixels.Color(ratio*maxR, ratio*maxG, ratio*maxB));
    }
  }
  else if (hour * 60 + min >= hourInt * 60 + minInt && hour * 60 + min < hourEnd * 60 + minEnd) {
    // Si on est dans la période d'intensité maximale
    // Pour chaque pixel
    for(int i=0; i<NUMPIXELS; i++) { 
      pixels.setPixelColor(i, pixels.Color(maxR, maxG, maxB));
    }
  }
  else {
    // Sinon, on éteint
    // Pour chaque pixel
    for(int i=0; i<NUMPIXELS; i++) { 
      pixels.setPixelColor(i, pixels.Color(0, 0, 0));
    }
  }
  pixels.show();
}

void messagesDebug() {
  Serial.print("Mins actuelles : ");
  Serial.print(String(hour * 60 + min));
  Serial.print(" Mins start : ");
  Serial.print(String(hourStart * 60 + minStart));
  Serial.print(" Mins int : ");
  Serial.print(String(hourInt * 60 + minInt));
  Serial.print(" Mins end : ");
  Serial.print(String(hourEnd * 60 + minEnd));
  Serial.print(" ");
  Serial.print(hour);
  Serial.print(":");
  Serial.print(min);
  Serial.print(":");
  Serial.print(second);
  Serial.print(" 1=");
  Serial.print(Vers2Chiffres(hourStart));
  Serial.print(":");
  Serial.print(Vers2Chiffres(minStart));
  Serial.print(" 2=");
  Serial.print(Vers2Chiffres(hourInt));
  Serial.print(":");
  Serial.print(Vers2Chiffres(minInt));
  Serial.print(" 3=");
  Serial.print(Vers2Chiffres(hourEnd));
  Serial.print(":");
  Serial.print(Vers2Chiffres(minEnd));
  Serial.println("");
}

// Permet d'afficher les nombres sur deux chiffres
// Exemple : 5 -> 05
String Vers2Chiffres(byte nombre) {
  String resultat = "";
  if (nombre < 10)
    resultat = "0";
  return resultat += String(nombre, DEC);
}


void recupBluetooth() {
  if (Serial.available()) {
    hc05.write(Serial.read());
  }
  if (hc05.available()) {
    // On récupère le message
    message = hc05.readString(); 

    //Une commande doit commencer par * pour être acceptée
    if (message.startsWith("*")) {
      // On enlève le *
      message.replace("*", "");

      //PARSING de la commande
      //Exemple :       *2019,6,8,9,26,54,6,30,7,0,7,10
      //Correspond à :   year,m,d,h,mi,se,S,s ,I,i,E,e

      // ------ Debug ------
      // Affichage debug des valeurs reçues
      Serial.println(message);

      // Affichage debug des valeurs enregistrées
      for(int i=0; i<12; i++) {
        Serial.print(getValue(message, ',', i));
        Serial.print("; ");
      }
      // Si les deux messages debugs sont différents,
      // alors il y a erreur de transmission
      // --------------------

      // Ajustement du temps pour le RTC
      RTC.adjust(DateTime(year, month, day, hour, min, second));

      // Enregistrement des valeurs
      year =      getValue(message, ',', 0).toInt(); 
      month =     getValue(message, ',', 1).toInt();
      day =       getValue(message, ',', 2).toInt();
      hour =      getValue(message, ',', 3).toInt();
      min =       getValue(message, ',', 4).toInt();
      second =    getValue(message, ',', 5).toInt();
      hourStart = getValue(message, ',', 6).toInt();
      minStart =  getValue(message, ',', 7).toInt();
      hourInt =   getValue(message, ',', 8).toInt();
      minInt =    getValue(message, ',', 9).toInt();
      hourEnd =   getValue(message, ',', 10).toInt();
      minEnd =    getValue(message, ',', 11).toInt();
    }
  }
}

String getValue(String data, char separator, int index) 
{
  // Permet de récupérer une valeur dans une commande 
  // contenant des valeurs séparées par un caractère
  //
  // Exemple : getValue("pommes;poires;fraises", ';', 1)
  // Retourne : "poires"

  int found = 0;
  int strIndex[] = { 0, -1 };
  int maxIndex = data.length() - 1;

  for (int i = 0; i <= maxIndex && found <= index; i++) {
      if (data.charAt(i) == separator || i == maxIndex) {
          found++;
          strIndex[0] = strIndex[1] + 1;
          strIndex[1] = (i == maxIndex) ? i+1 : i;
      }
  }
  return found > index ? data.substring(strIndex[0], strIndex[1]) : "";
}