/*****************************************************
 *  Monitoreo de consumo eléctrico con ACS712 (30A)
 *  NodeMCU (ESP8266) + LCD 20x2 I2C + Google Sheets
 *  Autor: Hector & ChatGPT
 *****************************************************/

// === Librerías necesarias ===
#include <ESP8266WiFi.h>        // Conexión WiFi
#include <Wire.h>               // I2C
#include <LiquidCrystal_I2C.h>  // LCD I2C

// === CONFIGURACIÓN WIFI ===
const char* ssid = "TU_SSID";         // Cambiar por tu red WiFi
const char* password = "TU_PASSWORD"; // Cambiar por tu clave WiFi

// === CONFIGURACIÓN GOOGLE SCRIPT ===
// URL del script que vamos a crear en Google Apps Script (la paso después)
const char* scriptURL = "https://script.google.com/macros/s/TU_SCRIPT_ID/exec";

// === CONFIGURACIÓN SENSOR ===
const int sensorPin = A0;       // Pin analógico en NodeMCU
const float sensitivity = 0.066; // Sensibilidad ACS712 30A = 66mV/A
const float vcc = 3.3;           // Voltaje de referencia del NodeMCU
const int adcMax = 1023;         // Resolución ADC NodeMCU

// === CONFIGURACIÓN LCD ===
LiquidCrystal_I2C lcd(0x27, 20, 2); // Dirección I2C común: 0x27 o 0x3F

// === VARIABLES DE CÁLCULO ===
float current = 0;      // Corriente medida (A)
float power = 0;        // Potencia calculada (W)
float energy_kWh = 0;   // Energía acumulada (kWh)

// === CONFIGURACIÓN TIEMPO ===
unsigned long lastSend = 0;         // Último envío
const unsigned long sendInterval = 60000; // 1 min en ms

void setup() {
  Serial.begin(115200);

  // Inicializar LCD
  lcd.init();
  lcd.backlight();
  lcd.setCursor(0, 0);
  lcd.print("Iniciando...");

  // Conectar WiFi
  WiFi.begin(ssid, password);
  lcd.setCursor(0, 1);
  lcd.print("WiFi...");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Conectado WiFi");
  Serial.println("WiFi conectado");
}

void loop() {
  // === 1. Medir corriente RMS ===
  current = medirCorrienteRMS(1000); // 1000 muestras

  // === 2. Calcular potencia (P = I * V) ===
  power = current * 220.0; // Voltaje asumido fijo

  // === 3. Calcular energía acumulada (kWh) ===
  // Potencia en W * tiempo (1 seg) → Wh → kWh
  static unsigned long lastMeasureTime = millis();
  unsigned long now = millis();
  float elapsedHours = (now - lastMeasureTime) / 3600000.0;
  energy_kWh += (power * elapsedHours) / 1000.0;
  lastMeasureTime = now;

  // === 4. Mostrar en LCD ===
  lcd.setCursor(0, 0);
  lcd.print("I: ");
  lcd.print(current, 2);
  lcd.print(" A   ");

  lcd.setCursor(0, 1);
  lcd.print("P: ");
  lcd.print(power, 0);
  lcd.print("W E:");
  lcd.print(energy_kWh, 3);

  // === 5. Enviar a Google Sheets cada minuto ===
  if (millis() - lastSend >= sendInterval) {
    enviarGoogleSheets(current, power, energy_kWh);
    lastSend = millis();
  }
}

// === Función para medir corriente RMS ===
float medirCorrienteRMS(int muestras) {
  long sum = 0;
  for (int i = 0; i < muestras; i++) {
    int lectura = analogRead(sensorPin);
    sum += pow((lectura - (adcMax / 2)), 2); // Centro del ADC
  }
  float mean = sum / (float)muestras;
  float rms = sqrt(mean);

  // Convertir a voltaje
  float voltaje = (rms * vcc) / adcMax;

  // Convertir a corriente usando sensibilidad
  return voltaje / sensitivity;
}

// === Función para enviar datos a Google Sheets ===
void enviarGoogleSheets(float corriente, float potencia, float energia) {
  if (WiFi.status() == WL_CONNECTED) {
    WiFiClientSecure client;
    client.setInsecure(); // Evitar problemas con SSL

    if (client.connect("script.google.com", 443)) {
      String url = String(scriptURL) + 
                   "?corriente=" + String(corriente, 2) +
                   "&potencia=" + String(potencia, 0) +
                   "&energia=" + String(energia, 3);

      client.println(String("GET ") + url + " HTTP/1.1");
      client.println("Host: script.google.com");
      client.println("Connection: close");
      client.println();

      Serial.println("Datos enviados a Google Sheets");
    } else {
      Serial.println("Error conectando a Google Sheets");
    }
  }
}

