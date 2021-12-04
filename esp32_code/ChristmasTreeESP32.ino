// This should contain 2 defines for WIFI_SSID and WIFI_PASS
#include "WiFiCredentials.h"

#include <WiFi.h>
#include <ESPAsyncWebServer.h>
#include <ArduinoJson.h>

AsyncWebServer server(80);

byte rowSetup[][3] = {
    {32, 33, 25},
    {26, 27, 14},
};

ushort frameCount = 0;
unsigned char **frames;

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

void setup()
{
  Serial.begin(115200);
  delay(10);
  ConnectToWiFi();

  // This setups all the pins as outputs
  for (int i = 0; i < sizeof(rowSetup) / sizeof *(rowSetup); i++)
  {
    pinMode(rowSetup[i][0], OUTPUT); // R
    pinMode(rowSetup[i][1], OUTPUT); // G
    pinMode(rowSetup[i][2], OUTPUT); // B
  }

  server.on(
      "/post",
      HTTP_POST,
      [](AsyncWebServerRequest *request) {},
      NULL,
      [](AsyncWebServerRequest *request, uint8_t *data, size_t len, size_t index, size_t total)
      {
        for (size_t i = 0; i < len; i++)
        {
          Serial.write(data[i]);
        }

        DynamicJsonDocument doc(4096);
        DeserializationError err = deserializeJson(doc, data);
        if (err)
        {
          Serial.print(F("deserializeJson() failed with code "));
          Serial.println(err.f_str());
          request->send(500);
          return;
        }
        // all frames of animations
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
          frames[i] = new unsigned char[5]{0};

        for (size_t i = 0; i < jsonFrames.size(); i++)
        {
          // For now we just evaluate band with index 0
          JsonArray bands = jsonFrames[i];
          Serial.println();
          Serial.print("Color: ");
          Serial.print(bands[0].as<unsigned char>(), DEC);
          Serial.println();

          // Color of the first band.
          frames[i][0] = bands[0].as<unsigned char>();
          frames[i][1] = bands[1].as<unsigned char>();
          frames[i][2] = bands[2].as<unsigned char>();
          frames[i][3] = bands[3].as<unsigned char>();
          frames[i][4] = bands[4].as<unsigned char>();
        }

        Serial.println();
        request->send(200);
      });
  server.begin();
}

void loop()
{
  if (frameCount == 0)
  {
    delay(1000);
    return;
  }

  for (size_t i = 0; i < frameCount; i++)
  {
    Serial.print("Frame ");
    Serial.print(i);
    Serial.print(": ");
    Serial.println();
    Serial.println(frames[i][0]); // Output Color of first band
    Serial.println(frames[i][1]);
    Serial.println(frames[i][2]);
    Serial.println(frames[i][3]);
    Serial.println(frames[i][4]);

    for (size_t j = 0; j < 5; j++)
    {
      if (frames[i][j] == 1)
      {
        digitalWrite(rowSetup[j][0], HIGH);
        digitalWrite(rowSetup[j][1], LOW);
        digitalWrite(rowSetup[j][2], LOW);
      }
      else if (frames[i][j] == 2)
      {
        digitalWrite(rowSetup[j][0], LOW);
        digitalWrite(rowSetup[j][1], HIGH);
        digitalWrite(rowSetup[j][2], LOW);
      }
      else if (frames[i][0] == 3)
      {
        digitalWrite(rowSetup[j][0], LOW);
        digitalWrite(rowSetup[j][1], LOW);
        digitalWrite(rowSetup[j][2], HIGH);
      }
      else if (frames[i][0] == 4)
      {
        digitalWrite(rowSetup[j][0], HIGH);
        digitalWrite(rowSetup[j][1], HIGH);
        digitalWrite(rowSetup[j][2], LOW);
      }
      else
      {
        digitalWrite(rowSetup[j][0], LOW);
        digitalWrite(rowSetup[j][1], LOW);
        digitalWrite(rowSetup[j][2], LOW);
      }
    }
    delay(500);
  }
  Serial.println("-------------------------");
  delay(30000);
}
