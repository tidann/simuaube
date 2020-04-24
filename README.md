# SimuAube
SimuAube est une application mobile créée par tidann (T. Danneels) qui permet de contrôler un réveil lumineux appelé "Simulateur d'aube". Un simulateur d'aube est un réveil fonctionnant à la lumière : l'intensité lumineuse permet de réveiller son utilisateur. Ici, l'intensité de la lumière augmente de façon linéaire, depuis l'heure de début d'allumage jusqu'à l'heure d'intensité maximale. Ensuite, elle reste constante jusqu'à l'heure d'arrêt.

## Fonctionnement
L'application permet de choisir les 3 heures d'allumage, d'intensité maximale et d'arrêt du réveil et lui envoie les données via Bluetooth (serial).

## Développement
SimuAube est écrit en Dart avec le Framework Flutter. Théoriquement, celui-ci permet de publier des applications sur Android et iOS mais il est malheureusement impossible à ce jour de publier l'app sur ce dernier, Apple ne permettant pas les communications Bluetooth en Serial.

## Application
Disponible sur le [Play Store](https://play.google.com/store/apps/details?id=com.tidann.simuaube)

## Licence
L'application est disponible sur le Play Store, mais le projet est open source, sous la licence du MIT, ce qui vous donne le droit de le modifier et le distribuer. (néanmoins, la mention de mon nom comme auteur original est appréciée :)
> MIT License
> Copyright (c) 2020 Timothée Danneels
> Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
> The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> MIT License
