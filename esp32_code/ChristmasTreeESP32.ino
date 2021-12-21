// This should contain 2 defines for WIFI_SSID and WIFI_PASS
#include "WiFiCredentials.h"

#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <ArduinoJson.h>
#include <StreamUtils.h>

//#define DEBUG 1

unsigned short eepRomSize = 512;

AsyncWebServer server(80);

byte rowSetup[][3] = {
  {32, 33, 25},
  {26, 27, 14},
};

ushort frameCount = 0;
unsigned char **frames;

// Boolean to specify if the animation has changed
bool hasChanged = false;

short blue[] = {
  33, // TOP
  4, // MIDDLE LEFT
  25, // MIDDLE RIGHT
  15, // BOTTOM LEFT
  12, // BOTTOM RIGHT
  5, // MIDDLE BOTTOM
};

short green[] = {
  32, // TOP
  16, // MIDDLE LEFT
  26, // MIDDLE RIGHT
  2, // BOTTOM LEFT
  14, // BOTTOM RIGHT
  18, // MIDDLE BOTTTOM
};

short red[] = {
  21, // TOP
  17, // MIDDLE LEFT
  27, // MIDDLE RIGHT
  0, // BOTTOM LEFT
  13, // BOTTOM RIGHT
  19, // MIDDLE BOTTOM
};

String strColors[5] = { "OFF", "RED", "GREEN", "BLUE", "YELLOW" };

// 0, 1, 2, 3, 4, 5
// TOP, MIDDLE LEFT, MIDDLE RIGHT, BOTTOM LEFT, BOTTOM RIGHT, MIDDLE BOTTOM

// New layout:
// Frames 1 - 256
// Rows 1 - 5 (eg Bands)
// Color 0 - 4 (eg Off, Red, Green, Blue, Yellow)

#pragma region WiFi Connection
// Code in here is just for the connection to your WiFi
void ConnectToWiFi()
{
  Serial.println();
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(WIFI_SSID);

  // WIFI Station => Make connection to AP
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASS);

  while (WiFi.status() != WL_CONNECTED)
  {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}
#pragma endregion

#pragma region Not Found Page
void notFound(AsyncWebServerRequest *request) {
  request->send(404, "text/plain", "Not found");
}
#pragma endregion

void setup()
{
  Serial.begin(115200);
  EEPROM.begin(512);
  delay(10);

  // This setups all the pins as outputs
  for (int i = 0; i < sizeof(red) / sizeof * (red); i++)
  {
    pinMode(red[i], OUTPUT);
    digitalWrite(red[i], LOW);
  }

  for (int i = 0; i < sizeof(green) / sizeof * (green); i++)
  {
    pinMode(green[i], OUTPUT);
    digitalWrite(green[i], LOW);
  }

  for (int i = 0; i < sizeof(blue) / sizeof * (blue); i++)
  {
    pinMode(blue[i], OUTPUT);
    digitalWrite(blue[i], LOW);
  }

  delay(10);
  ConnectToWiFi();

  DynamicJsonDocument doc(4096);
  EepromStream eepromStream(0, eepRomSize);
  deserializeJson(doc, eepromStream);

  JsonArray jsonFrames = doc.as<JsonArray>();
  if (frames != NULL)
  {
    for (int i = 0; i < frameCount; ++i)
    {
      delete[] frames[i];
    }
    delete[] frames;
  }

  frameCount = jsonFrames.size();
  frames = new unsigned char *[frameCount];
  for (int i = 0; i < frameCount; ++i)
    frames[i] = new unsigned char[6] {0};

  for (size_t i = 0; i < jsonFrames.size(); i++)
  {
    JsonArray bands = jsonFrames[i];
    // TOP
    frames[i][0] = bands[0].as<unsigned char>();

    // MIDDLE LEFT
    frames[i][1] = bands[1].as<unsigned char>();

    // MIDDLE RIGHT
    frames[i][2] = bands[2].as<unsigned char>();

    // BOTTOM LEFT
    frames[i][3] = bands[3].as<unsigned char>();

    // BOTTOM RIGHT
    frames[i][4] = bands[4].as<unsigned char>();

    // MIDDLE BOTTOM
    frames[i][5] = bands[5].as<unsigned char>();
  }

  server.on(
    "/get",
    HTTP_GET,
    [](AsyncWebServerRequest * request)
  {
#ifdef DEBUG
    Serial.println("Got get request!");
#endif
    String result = "[";
    for (int i = 0; i < frameCount; ++i)
    {
      String frame = String(frames[i][0]) + ", " +
                     String(frames[i][1]) + ", " +
                     String(frames[i][2]) + ", " +
                     String(frames[i][3]) + ", " +
                     String(frames[i][4]) + ", " +
                     String(frames[i][5]);

      result += "[" + frame + "]";
      if (i < frameCount - 1)
        result += ",";
    }
    result += "]";
    request->send(200, "application/json", result);
  });

  server.on(
    "/post",
    HTTP_POST,
  [](AsyncWebServerRequest * request) {},
  NULL,
  [](AsyncWebServerRequest * request, uint8_t *data, size_t len, size_t index, size_t total)
  {
#ifdef DEBUG
    Serial.write("Got data: ");
    for (size_t i = 0; i < len; i++)
    {
      Serial.write(data[i]);
    }
    Serial.println();
#endif

    DynamicJsonDocument doc(4096);
    DeserializationError err = deserializeJson(doc, data);
    if (err)
    {
      Serial.println("deserializeJson() failed with code " + String(err.f_str()));

      request->send(500, "application/json", "{\"result\": 1, \"msg\": \"" + String(err.f_str()) + "\"}");
      return;
    }

    EepromStream eepromStream(0, eepRomSize);
    serializeJson(doc, eepromStream);
    eepromStream.flush();

    // all frames of animations
    JsonArray jsonFrames = doc.as<JsonArray>();

#ifdef DEBUG
    Serial.println("Got " + String(jsonFrames.size()) + " frames of animation.");
#endif

    if (frames != NULL)
    {
      for (int i = 0; i < frameCount; ++i)
      {
        delete[] frames[i];
      }
      delete[] frames;
    }

    frameCount = jsonFrames.size();
    frames = new unsigned char *[frameCount];
    for (int i = 0; i < frameCount; ++i)
      frames[i] = new unsigned char[6] {0};

    for (size_t i = 0; i < jsonFrames.size(); i++)
    {
      JsonArray bands = jsonFrames[i];
      if (bands.size() < 6)
      {
        frameCount = 1;
        frames = new unsigned char *[frameCount];
        for (int i = 0; i < frameCount; ++i)
          frames[i] = new unsigned char[6] {0};

        request->send(200, "application/json", "{\"result\": 1, \"msg\": \"Too few band colors.\"}");
        return;
      }

      // TOP
      frames[i][0] = bands[0].as<unsigned char>();

      // MIDDLE LEFT
      frames[i][1] = bands[1].as<unsigned char>();

      // MIDDLE RIGHT
      frames[i][2] = bands[2].as<unsigned char>();

      // BOTTOM LEFT
      frames[i][3] = bands[3].as<unsigned char>();

      // BOTTOM RIGHT
      frames[i][4] = bands[4].as<unsigned char>();

      // MIDDLE BOTTOM
      frames[i][5] = bands[5].as<unsigned char>();
    }

    hasChanged = true;

    request->send(200, "application/json", "{\"result\": 0}");
  });
  server.onNotFound(notFound);
  server.begin();
}

void loop()
{
  if (frameCount == 0)
  {
    delay(500);
    return;
  }

  for (size_t i = 0; i < frameCount; i++)
  {
    if (hasChanged)
    {
      hasChanged = false;
      break;
    }
#ifdef DEBUG
    Serial.print("Frame ");
    Serial.print(i);
    Serial.print(": ");
    Serial.println();
    Serial.println("\t" + strColors[frames[i][0]]);
    Serial.println(strColors[frames[i][1]] + "\t\t" + strColors[frames[i][2]]);
    Serial.println(strColors[frames[i][3]] + "\t\t" + strColors[frames[i][4]]);
    Serial.println("\t" + strColors[frames[i][5]]);
#endif

    for (size_t j = 0; j < 6; j++)
    {
      digitalWrite(red[j], (frames[i][j] == 1 || frames[i][j] == 4) ? HIGH : LOW);
      digitalWrite(green[j], (frames[i][j] == 2 || frames[i][j] == 4) ? HIGH : LOW);
      digitalWrite(blue[j], (frames[i][j] == 3) ? HIGH : LOW);
    }
    delay(500);
  }

#ifdef DEBUG
  Serial.println("-------------------------");
#endif

  if (frameCount == 1)
  {
    for (int i = 0; i < 10; i++)
    {
      if (hasChanged)
      {
        hasChanged = false;
        break;
      }
      delay(500);
    }
  }
}