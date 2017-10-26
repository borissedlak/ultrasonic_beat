(Documentation is fully in german)

# Allgemeine Idee

Meine Idee für dieses Projekt war ein im Raum rotierender Abstandsmesser, der anhand der Position im Kreis und der Entfernung zu Objekten in Raum einen entsprechenden Rhythmus spielt. Der Sensor rotiert um 360 Grad, die Geschwindigkeit mit der er sich dreht kann angepasst werden.

Die Position im Raum repräsentiert die Frequenz bzw. den Ton, welche/r ertönt wenn ein Objekt getroffen wird. Es ist aber auch möglich bestimmten Winkeln im Raum ein spezieller Ton zuzuweisen.

# Theoretischer Aufbau

Um die gesamte Umgebung \(360°\) gleichmäßig wahrzunehmen, ist es notwendig den für die Abstandsmessung verwendeten Ultraschallsensor kontinuierlich zu drehen. Diese Aufgabe erledigt ein spezieller Servomotor, der sich im Gegensatz zu den meisten bestehenden Servos frei und kontinuierlich dreht. Der Ultraschallsensor ist auf dem Servo montiert, wobei jedoch ein Problem bei der Verkabelung aufkommt, schließlich muss der Ultraschallsensor ebenfalls an den Mikrocontroller angeschlossen werden, die Verbindung würde die Rotation aber blockieren. Abhilfe schafft ein Schleifkontakt \(siehe Arduino -&gt; Bauteile\), welcher den Kontakt der Kabel in einem Bauteil aufrechterhält.

Über den Ultraschallsensor werden kontinuierlich Werte über den Abstand zu Objekten im Raum erhoben. Trifft die Reflexion in einem bestimmten Bereich statt, werden diese Informationen über die serielle Schnittstelle übergeben und es wird abhängig vom Abstand ein bestimmter Ton abgespielt.

Der Benutzer hat weiters die Möglichkeit über eine Fernbedienung die Installation zu beeinflussen. So ist es möglich die Geschwindigkeit des Servos zu erhöhen/verringern, oder ihn in der aktuellen Position zu pausieren. Über die Fernbedienung ist es außerdem möglich die Lautstärke der abgespielten Töne zu beeinflussen.

# Verwendete Bauteile

Für die Umsetzung des Projektes wurden folgende Bauteile in der finalen Version verwendet:

* Continuous Servo \([https://www.adafruit.com/product/2442](https://www.adafruit.com/product/154)\)
* Schleifkontakt \([http://www.senring.com/capsule-slip-ring/snm012.html](http://www.senring.com/capsule-slip-ring/snm012.html)\)
* Ultrasonic Sensor \([https://www.sparkfun.com/products/13959](https://www.sparkfun.com/products/13959)\)

Standardteile aus Bauteilsatz:

* Fernbedienung Elegoo mit Infrarotreceiver
* Arduino Uno Mikrocontroller Board
* Steckplatine
* Diverse Kabeln \(Female-Male, Male-Male\)

# Schaltplan

# ![](/assets/schaltplan_Steckplatine_cropped.jpg)

# Motorübersetzung

Wie im Bild zu sehen ist, habe ich für die Übersetzung des Motors auf den Ultraschallsensor ein Band verwendet. Das hat zum Effekt, dass ich eine recht beliebige Reichweite spannen kann und im Abstand zwischen den Bauteilen nicht so präzise bauen musste, wie im Vergleich zu einem Antrieb durch Zahnräder. Der Motor ist auf einem Sockel platziert um einen optimalen Antrieb zu gewährleisten. Ein Nachteil dieser Aufbauweise ist, dass zu keinem Zeitpunkt im Mikrocontroller eine Information über die aktuelle Position des Sensors besteht, das schließt dadurch eine visuelle Ausgabe im Stil eines rotierenden Sonars aus.

Man sieht durch das rechte Rad die Kabelverbindung vom Sensor in Richtung Arduino laufen. Rechts unten im Bild ist der essentielle Schleifkontakt zu sehen, der die Rotation der Kabel kompensiert. Die Räder für den Bandantrieb, der Stab im Rad, sowie der Aufbau des rechten Rads zum Ultraschallsensor stammen aus diversen Lego Bausätzen. Geklebt wurde an mehreren Stellen mit Sekundenkleber, im Falle des Podests mit Montagekleber.

![](/assets/Picture_Motor.jpg)

# Serielle Schnittstelle

Über die serielle Schnittstelle wurden zwischen Arduino und Processing zwei Informationsquellen übertragen: Abstandswerte des Ultraschallsensors, und Informationen der Fernbedienung.

#### Abstandswerte

Zuerst wird die Information aus dem Ultraschallsensor ausgewertet und in eine nativ interpretierbare Skala gebracht, anschließend werden, falls die Werte in einem bestimmten Bereich liegen, Informationen entsprechend der Distanz über die serielle Schnittstelle übertragen.

```java
duration = pulseIn(echoPin, HIGH);
distance = duration * 0.034 / 2;

if (constrain(distance, 15, 63)) {
Serial.write(map(distance, 15, 63, 1, 6));
}
```

#### Fernbedienung Receiver

Eingehende Werte der Fernbedienung werden, falls vorhanden, konstant interpretiert. Falls ein Wert zur Verfügung steht wird dieser über eine weitere Funktion interpretiert und entsprechend ausgewertet.

```java
if (irrecv.decode(&results)) {
translateIR();
irrecv.resume(); // Receive the next value
}
```

Beim Interpretieren wird die Informationen mit Referenzwerten verglichen und abhängig vom Wert Informationen über die Schnittstelle übertragen, wie im unten beschriebenen Fall Informationen zur Lautstärke.

```java
void translateIR() {
switch (results.value) {
case 0xFF629D:
// VOL+
Serial.write('H');
break;
// ...
}
}
```

# Video Output

Treffen Reflexionen in einer gewissen Distanz zum Sensor werden diese in einem Halbkreis dargestellt der an ein Sonar erinnert. Abhängig von der über die serielle Schnittstelle übertragenen Distanz (im Punkt Arduino beschrieben) wird ein entsprechender Bereich, einer der Ringe, in einer eindeutigen, unterscheidbaren Farbe hervorgehoben. Der größte Halbkreis stellt den Bereich der entferntesten Reflexionen dar, der kleinste Halbkreis den Bereich der dem Sensor am nähesten ist.

![](/assets/Picture_Visual.jpg)


Der rote Bereich im unteren Teil der Grafik stellt den Radius dar, in dem Reflexionen kein Resultat nach sich ziehen, der Mindestabstand wurde nicht eingehalten. Rechts unten in der Grafik sind Entfernungen notiert, welche dem Abstand entsprechen der benötigt wird um einen der Ringe zu aktivieren und gleichzeitig einen Sound zu erzeugen.

Pro frame das in Processing darsgestellt wird überprüft ob eine Reflexion vorliegt, abhängig davon wird der Kreisabschnitt farbig oder schwarz gefüllt.

```java
void drawCircle(){
if(!blinking){
circle.display();
}
else{
circle.blink();
}
}

//Füllen des Kreises mit der im Objekt gespeicherten Farbe
void blink() {
fill(c);
ellipse(0, 0, width, height);
noFill();
}
```

Damit Farbkreise sich nicht in der Tiefe überdecken wird immer von außen nach innen, also vom größten Kreis zum kleineren gezeichnet. Der vierte und kleinste Kreis an der Reihe überdeckt somit in jedem Fall alle anderen davor.

# Audio Output

Paralell zu dem Aufleuchten der Kreise (im Punkt Visueller Output beschrieben) ertönt ein Sound, der sich abhängig von der Distanz unterscheidet. Diese Sounds stammen aus Soundfiles, welche manuell für jede Distanz angepasst werden können. Zusätzlich zu den 4 Kreisen die umgesetzt wurden liefert der Sensor auch mehr als 4 Werte, die Darstellung eines 5. 6. usw. Kreises kann also problemlos skaliert werden.

```java
//Definieren einer Soundvariable aus dem Soundfile.
kick = new SoundFile(this, "kick.wav");

//Methode die zum Abspielen von Sounds verwendet wurde.
ring1.playSound();
```

Selbst wenn es nur ein Gegenstand im Raum ist der den Sensor reflektiert, bei der Reflexion werden immer mehrere Werte zu der selben Distanz geliefert. Aus diesem Grund wurde das Abspielen der Soundfiles so implementiert, dass selbst wenn mehrere Reflexionen hintereinander stattfinden der Sound prinzipiell nur einmal ertönt. Ist es aber der Fall, dass der reflektierende Gegenstand groß ist, bzw. der abgespielte Ton sehr kurz, dann ist es sehr wohl möglich zB. die HiHat mehrmals ertönen zu lassen.

Soll ein Sound abgespielt werden, so wird gleichgzeitig das Blinken aktiviert. Es erfolgt ein aktueller Timestamp, der zusammen mit der Länge des Soundfiles eine Bedingung bildet, wonach nur dann nochmals der selbe Soudn abgespielt werden kann, wenn das letzte Soundfile fertig abgespielt wurde.

```java
void playSound() {
this.blinking = true;
long currentTime = System.nanoTime();
if ((startTime + duration) < currentTime) {
startTime = System.nanoTime();
duration = (int)(this.file.duration() * 1000000000);
this.file.play(1, loudness);
}
}
```
